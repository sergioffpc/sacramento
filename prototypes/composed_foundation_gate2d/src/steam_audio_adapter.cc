#include <phonon.h>

#include <algorithm>
#include <array>
#include <cmath>
#include <cstdint>
#include <expected>
#include <limits>
#include <span>
#include <vector>

#include "sacramento/gate2d/acoustics.h"

namespace sacramento::gate2d {
namespace {

constexpr std::uint64_t kFnvOffsetBasis = 14695981039346656037ULL;
constexpr std::uint64_t kFnvPrime = 1099511628211ULL;
constexpr std::uint64_t kNanosecondsPerSecond = 1'000'000'000;

[[nodiscard]] bool Succeeded(IPLerror error) {
  return error == IPL_STATUS_SUCCESS;
}

[[nodiscard]] IPLVector3 ToMeters(const PositionMillimeters& position) {
  constexpr float kMillimetersPerMeter = 1'000.0F;
  return IPLVector3{
      .x = static_cast<float>(position.x) / kMillimetersPerMeter,
      .y = static_cast<float>(position.y) / kMillimetersPerMeter,
      .z = static_cast<float>(position.z) / kMillimetersPerMeter,
  };
}

[[nodiscard]] IPLVector3 Direction(const PositionMillimeters& source,
                                   const PositionMillimeters& listener) {
  const float x = static_cast<float>(source.x - listener.x);
  const float y = static_cast<float>(source.y - listener.y);
  const float z = static_cast<float>(source.z - listener.z);
  const float length = std::sqrt(x * x + y * y + z * z);
  return IPLVector3{.x = x / length, .y = y / length, .z = z / length};
}

// Steam Audio's C ABI represents a bounded deinterleaved buffer as float**.
// Contain the unavoidable pointer indexing here and expose a sized span to the
// rest of the adapter.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunsafe-buffer-usage"
[[nodiscard]] std::span<const float> AudioChannel(const IPLAudioBuffer& buffer,
                                                  std::uint32_t channel) {
  return {buffer.data[channel], static_cast<std::size_t>(buffer.numSamples)};
}
#pragma clang diagnostic pop

[[nodiscard]] std::int16_t Quantize(float sample) {
  constexpr float kPcmScale = 32'767.0F;
  const float bounded = std::clamp(sample, -1.0F, 1.0F);
  return static_cast<std::int16_t>(std::lround(bounded * kPcmScale));
}

[[nodiscard]] std::uint16_t ToPerMille(float value) {
  return static_cast<std::uint16_t>(
      std::lround(std::clamp(value, 0.0F, 1.0F) * 1'000.0F));
}

[[nodiscard]] IPLCoordinateSpace3 Coordinates(IPLVector3 origin) {
  return IPLCoordinateSpace3{
      .right = {.x = 1.0F, .y = 0.0F, .z = 0.0F},
      .up = {.x = 0.0F, .y = 1.0F, .z = 0.0F},
      .ahead = {.x = 0.0F, .y = 0.0F, .z = -1.0F},
      .origin = origin,
  };
}

void ReleasePropagation(IPLSource& source, IPLSimulator& simulator,
                        IPLStaticMesh& static_mesh, IPLScene& scene) {
  if (source != nullptr) {
    iplSourceRelease(&source);
  }
  if (simulator != nullptr) {
    iplSimulatorRelease(&simulator);
  }
  if (static_mesh != nullptr) {
    iplStaticMeshRelease(&static_mesh);
  }
  if (scene != nullptr) {
    iplSceneRelease(&scene);
  }
}

void HashSample(std::int16_t sample, std::uint64_t& hash) {
  const auto bits = static_cast<std::uint16_t>(sample);
  hash ^= bits & 0xffU;
  hash *= kFnvPrime;
  hash ^= (bits >> 8U) & 0xffU;
  hash *= kFnvPrime;
}

}  // namespace

std::expected<RenderedAcousticEvent, AcousticError> RenderAcousticEvent(
    const AcousticEvent& event) {
  if (event.format_version != kAcousticEventFormatVersion ||
      event.authoritative_arrival_timestamp_ns < event.initiated_timestamp_ns ||
      (event.source.x == event.listener.x &&
       event.source.y == event.listener.y &&
       event.source.z == event.listener.z) ||
      event.wall_transmission_per_mille > 1'000) {
    return std::unexpected{AcousticError::kInvalidEvent};
  }

  IPLContext context = nullptr;
  IPLContextSettings context_settings{};
  context_settings.version = STEAMAUDIO_VERSION;
  context_settings.simdLevel = IPL_SIMDLEVEL_SSE2;
  context_settings.flags = IPL_CONTEXTFLAGS_VALIDATION;
  if (!Succeeded(iplContextCreate(&context_settings, &context))) {
    return std::unexpected{AcousticError::kRendererInitialization};
  }

  IPLAudioSettings audio_settings{
      .samplingRate = static_cast<IPLint32>(kSampleRateHz),
      .frameSize = static_cast<IPLint32>(kFrameSizeSamples),
  };
  IPLHRTF hrtf = nullptr;
  IPLHRTFSettings hrtf_settings{
      .type = IPL_HRTFTYPE_DEFAULT,
      .sofaFileName = nullptr,
      .sofaData = nullptr,
      .sofaDataSize = 0,
      .volume = 1.0F,
      .normType = IPL_HRTFNORMTYPE_NONE,
  };
  if (!Succeeded(
          iplHRTFCreate(context, &audio_settings, &hrtf_settings, &hrtf))) {
    iplContextRelease(&context);
    return std::unexpected{AcousticError::kRendererInitialization};
  }

  IPLScene scene = nullptr;
  IPLSceneSettings scene_settings{};
  scene_settings.type = IPL_SCENETYPE_DEFAULT;
  IPLStaticMesh static_mesh = nullptr;
  std::array<IPLVector3, 4> wall_vertices{
      IPLVector3{.x = 6.0F, .y = -10.0F, .z = -10.0F},
      IPLVector3{.x = 6.0F, .y = 10.0F, .z = -10.0F},
      IPLVector3{.x = 6.0F, .y = 10.0F, .z = 10.0F},
      IPLVector3{.x = 6.0F, .y = -10.0F, .z = 10.0F},
  };
  std::array<IPLTriangle, 2> wall_triangles{
      IPLTriangle{.indices = {0, 1, 2}},
      IPLTriangle{.indices = {0, 2, 3}},
  };
  std::array<IPLint32, 2> material_indices{0, 0};
  const float wall_transmission =
      static_cast<float>(event.wall_transmission_per_mille) / 1'000.0F;
  std::array<IPLMaterial, 1> materials{IPLMaterial{
      .absorption = {0.05F, 0.07F, 0.08F},
      .scattering = 0.05F,
      .transmission = {wall_transmission, wall_transmission, wall_transmission},
  }};
  IPLStaticMeshSettings mesh_settings{
      .numVertices = static_cast<IPLint32>(wall_vertices.size()),
      .numTriangles = static_cast<IPLint32>(wall_triangles.size()),
      .numMaterials = static_cast<IPLint32>(materials.size()),
      .vertices = wall_vertices.data(),
      .triangles = wall_triangles.data(),
      .materialIndices = material_indices.data(),
      .materials = materials.data(),
  };
  IPLSimulator simulator = nullptr;
  IPLSimulationSettings simulation_settings{};
  simulation_settings.flags = IPL_SIMULATIONFLAGS_DIRECT;
  simulation_settings.sceneType = IPL_SCENETYPE_DEFAULT;
  simulation_settings.reflectionType = IPL_REFLECTIONEFFECTTYPE_CONVOLUTION;
  simulation_settings.maxNumOcclusionSamples = 1;
  simulation_settings.maxNumRays = 1;
  simulation_settings.numDiffuseSamples = 1;
  simulation_settings.maxDuration = 0.1F;
  simulation_settings.maxNumSources = 1;
  simulation_settings.numThreads = 1;
  simulation_settings.rayBatchSize = 1;
  simulation_settings.numVisSamples = 1;
  simulation_settings.samplingRate = audio_settings.samplingRate;
  simulation_settings.frameSize = audio_settings.frameSize;
  IPLSource source = nullptr;
  IPLSourceSettings source_settings{.flags = IPL_SIMULATIONFLAGS_DIRECT};
  const bool propagation_initialized =
      Succeeded(iplSceneCreate(context, &scene_settings, &scene)) &&
      Succeeded(iplStaticMeshCreate(scene, &mesh_settings, &static_mesh)) &&
      Succeeded(
          iplSimulatorCreate(context, &simulation_settings, &simulator)) &&
      Succeeded(iplSourceCreate(simulator, &source_settings, &source));
  if (!propagation_initialized) {
    ReleasePropagation(source, simulator, static_mesh, scene);
    iplHRTFRelease(&hrtf);
    iplContextRelease(&context);
    return std::unexpected{AcousticError::kRendererInitialization};
  }
  iplStaticMeshAdd(static_mesh, scene);
  iplSceneCommit(scene);
  iplSimulatorSetScene(simulator, scene);
  iplSourceAdd(source, simulator);
  iplSimulatorCommit(simulator);

  IPLSimulationInputs simulation_inputs{};
  simulation_inputs.flags = IPL_SIMULATIONFLAGS_DIRECT;
  simulation_inputs.directFlags = static_cast<IPLDirectSimulationFlags>(
      IPL_DIRECTSIMULATIONFLAGS_DISTANCEATTENUATION |
      IPL_DIRECTSIMULATIONFLAGS_OCCLUSION |
      IPL_DIRECTSIMULATIONFLAGS_TRANSMISSION);
  simulation_inputs.source = Coordinates(ToMeters(event.source));
  simulation_inputs.distanceAttenuationModel.type =
      IPL_DISTANCEATTENUATIONTYPE_DEFAULT;
  simulation_inputs.occlusionType = IPL_OCCLUSIONTYPE_RAYCAST;
  simulation_inputs.occlusionRadius = 1.0F;
  simulation_inputs.numOcclusionSamples = 1;
  simulation_inputs.numTransmissionRays = 1;
  iplSourceSetInputs(source, IPL_SIMULATIONFLAGS_DIRECT, &simulation_inputs);
  IPLSimulationSharedInputs shared_inputs{};
  shared_inputs.listener = Coordinates(ToMeters(event.listener));
  iplSimulatorSetSharedInputs(simulator, IPL_SIMULATIONFLAGS_DIRECT,
                              &shared_inputs);
  iplSimulatorRunDirect(simulator);
  IPLSimulationOutputs simulation_outputs{};
  iplSourceGetOutputs(source, IPL_SIMULATIONFLAGS_DIRECT, &simulation_outputs);

  IPLDirectEffect direct_effect = nullptr;
  IPLDirectEffectSettings direct_settings{.numChannels = 1};
  IPLBinauralEffect binaural_effect = nullptr;
  IPLBinauralEffectSettings binaural_settings{.hrtf = hrtf};
  IPLAudioBuffer input{};
  IPLAudioBuffer direct_output{};
  IPLAudioBuffer spatial_output{};

  const bool initialized =
      Succeeded(iplDirectEffectCreate(context, &audio_settings,
                                      &direct_settings, &direct_effect)) &&
      Succeeded(iplBinauralEffectCreate(
          context, &audio_settings, &binaural_settings, &binaural_effect)) &&
      Succeeded(iplAudioBufferAllocate(context, 1, audio_settings.frameSize,
                                       &input)) &&
      Succeeded(iplAudioBufferAllocate(context, 1, audio_settings.frameSize,
                                       &direct_output)) &&
      Succeeded(iplAudioBufferAllocate(context, 2, audio_settings.frameSize,
                                       &spatial_output));
  if (!initialized) {
    iplAudioBufferFree(context, &spatial_output);
    iplAudioBufferFree(context, &direct_output);
    iplAudioBufferFree(context, &input);
    iplBinauralEffectRelease(&binaural_effect);
    iplDirectEffectRelease(&direct_effect);
    ReleasePropagation(source, simulator, static_mesh, scene);
    iplHRTFRelease(&hrtf);
    iplContextRelease(&context);
    return std::unexpected{AcousticError::kRendererInitialization};
  }

  std::fill_n(input.data[0], kFrameSizeSamples, 0.0F);
  input.data[0][0] = 0.8F;

  IPLDirectEffectParams direct_params = simulation_outputs.direct;
  iplDirectEffectApply(direct_effect, &direct_params, &input, &direct_output);

  std::array<float, 2> peak_delays{};
  IPLBinauralEffectParams binaural_params{
      .direction = Direction(event.source, event.listener),
      .interpolation = IPL_HRTFINTERPOLATION_NEAREST,
      .spatialBlend = 1.0F,
      .hrtf = hrtf,
      .peakDelays = peak_delays.data(),
  };
  iplBinauralEffectApply(binaural_effect, &binaural_params, &direct_output,
                         &spatial_output);

  const std::uint64_t propagation_ns =
      event.authoritative_arrival_timestamp_ns - event.initiated_timestamp_ns;
  const std::uint64_t scheduled_sample =
      (propagation_ns * kSampleRateHz + kNanosecondsPerSecond - 1) /
      kNanosecondsPerSecond;
  const std::uint64_t output_frames = scheduled_sample + kFrameSizeSamples;
  if (output_frames >
      static_cast<std::uint64_t>(std::numeric_limits<std::size_t>::max() / 2)) {
    iplAudioBufferFree(context, &spatial_output);
    iplAudioBufferFree(context, &direct_output);
    iplAudioBufferFree(context, &input);
    iplBinauralEffectRelease(&binaural_effect);
    iplDirectEffectRelease(&direct_effect);
    ReleasePropagation(source, simulator, static_mesh, scene);
    iplHRTFRelease(&hrtf);
    iplContextRelease(&context);
    return std::unexpected{AcousticError::kRendererProcessing};
  }

  RenderedAcousticEvent rendered{
      .sample_rate_hz = kSampleRateHz,
      .channel_count = 2,
      .scheduled_arrival_sample = scheduled_sample,
      .first_nonzero_sample = output_frames,
      .first_nonzero_timestamp_ns = 0,
      .pcm_fnv1a_64 = kFnvOffsetBasis,
      .left_absolute_energy = 0,
      .right_absolute_energy = 0,
      .distance_attenuation_per_mille =
          ToPerMille(direct_params.distanceAttenuation),
      .direct_occlusion_per_mille = ToPerMille(direct_params.occlusion),
      .low_band_transmission_per_mille =
          ToPerMille(direct_params.transmission[0]),
      .left_peak_delay_microseconds =
          static_cast<std::int32_t>(std::lround(peak_delays[0] * 1'000'000.0F)),
      .right_peak_delay_microseconds =
          static_cast<std::int32_t>(std::lround(peak_delays[1] * 1'000'000.0F)),
      .interleaved_pcm = std::vector<std::int16_t>(
          static_cast<std::size_t>(output_frames * 2), 0),
  };
  const auto left_channel = AudioChannel(spatial_output, 0);
  const auto right_channel = AudioChannel(spatial_output, 1);
  for (std::uint32_t frame = 0; frame < kFrameSizeSamples; ++frame) {
    const std::int16_t left = Quantize(left_channel[frame]);
    const std::int16_t right = Quantize(right_channel[frame]);
    const std::uint64_t output_frame = scheduled_sample + frame;
    const std::size_t index = static_cast<std::size_t>(output_frame * 2);
    rendered.interleaved_pcm[index] = left;
    rendered.interleaved_pcm[index + 1] = right;
    rendered.left_absolute_energy +=
        static_cast<std::uint64_t>(std::abs(static_cast<std::int32_t>(left)));
    rendered.right_absolute_energy +=
        static_cast<std::uint64_t>(std::abs(static_cast<std::int32_t>(right)));
    if ((left != 0 || right != 0) &&
        rendered.first_nonzero_sample == output_frames) {
      rendered.first_nonzero_sample = output_frame;
    }
  }
  for (const std::int16_t sample : rendered.interleaved_pcm) {
    HashSample(sample, rendered.pcm_fnv1a_64);
  }
  if (rendered.first_nonzero_sample == output_frames ||
      rendered.left_absolute_energy == 0 ||
      rendered.right_absolute_energy == 0) {
    iplAudioBufferFree(context, &spatial_output);
    iplAudioBufferFree(context, &direct_output);
    iplAudioBufferFree(context, &input);
    iplBinauralEffectRelease(&binaural_effect);
    iplDirectEffectRelease(&direct_effect);
    ReleasePropagation(source, simulator, static_mesh, scene);
    iplHRTFRelease(&hrtf);
    iplContextRelease(&context);
    return std::unexpected{AcousticError::kRendererProcessing};
  }
  rendered.first_nonzero_timestamp_ns =
      event.initiated_timestamp_ns +
      rendered.first_nonzero_sample * kNanosecondsPerSecond / kSampleRateHz;

  iplAudioBufferFree(context, &spatial_output);
  iplAudioBufferFree(context, &direct_output);
  iplAudioBufferFree(context, &input);
  iplBinauralEffectRelease(&binaural_effect);
  iplDirectEffectRelease(&direct_effect);
  ReleasePropagation(source, simulator, static_mesh, scene);
  iplHRTFRelease(&hrtf);
  iplContextRelease(&context);
  return rendered;
}

}  // namespace sacramento::gate2d
