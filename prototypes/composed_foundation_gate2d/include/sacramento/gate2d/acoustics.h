#ifndef SACRAMENTO_PROTOTYPES_COMPOSED_FOUNDATION_GATE2D_INCLUDE_SACRAMENTO_GATE2D_ACOUSTICS_H_
#define SACRAMENTO_PROTOTYPES_COMPOSED_FOUNDATION_GATE2D_INCLUDE_SACRAMENTO_GATE2D_ACOUSTICS_H_

#include <cstdint>
#include <expected>
#include <string>
#include <vector>

namespace sacramento::gate2d {

inline constexpr std::uint32_t kAcousticEventFormatVersion = 1;
inline constexpr std::uint32_t kSampleRateHz = 48'000;
inline constexpr std::uint32_t kFrameSizeSamples = 1'024;
inline constexpr std::uint32_t kSpeedOfSoundMillimetersPerSecond = 343'000;

struct PositionMillimeters {
  std::int32_t x;
  std::int32_t y;
  std::int32_t z;
};

struct AcousticEvent {
  std::uint32_t format_version;
  std::uint64_t event_correlation_id;
  std::uint32_t script_step_id;
  std::uint32_t acoustic_profile_version;
  std::uint64_t initiated_timestamp_ns;
  std::uint64_t authoritative_arrival_timestamp_ns;
  PositionMillimeters source;
  PositionMillimeters listener;
  std::uint16_t wall_transmission_per_mille;
};

struct RenderedAcousticEvent {
  std::uint32_t sample_rate_hz;
  std::uint32_t channel_count;
  std::uint64_t scheduled_arrival_sample;
  std::uint64_t first_nonzero_sample;
  std::uint64_t first_nonzero_timestamp_ns;
  std::uint64_t pcm_fnv1a_64;
  std::uint64_t left_absolute_energy;
  std::uint64_t right_absolute_energy;
  std::uint16_t distance_attenuation_per_mille;
  std::uint16_t direct_occlusion_per_mille;
  std::uint16_t low_band_transmission_per_mille;
  std::int32_t left_peak_delay_microseconds;
  std::int32_t right_peak_delay_microseconds;
  std::vector<std::int16_t> interleaved_pcm;
};

enum class AcousticError {
  kInvalidEvent,
  kInputOutput,
  kRendererInitialization,
  kRendererProcessing,
};

[[nodiscard]] AcousticEvent MakeRepresentativeAcousticEvent();

[[nodiscard]] std::expected<void, AcousticError> WriteAcousticEvent(
    const AcousticEvent& event, const std::string& path);

[[nodiscard]] std::expected<AcousticEvent, AcousticError> ReadAcousticEvent(
    const std::string& path);

// Blocking client-side processing. The input event and returned samples are
// Sacramento-owned values; the implementation-specific audio objects do not
// escape this call. This function performs no device I/O.
[[nodiscard]] std::expected<RenderedAcousticEvent, AcousticError>
RenderAcousticEvent(const AcousticEvent& event);

[[nodiscard]] std::expected<void, AcousticError> WritePcm16(
    const RenderedAcousticEvent& rendered, const std::string& path);

}  // namespace sacramento::gate2d

#endif  // SACRAMENTO_PROTOTYPES_COMPOSED_FOUNDATION_GATE2D_INCLUDE_SACRAMENTO_GATE2D_ACOUSTICS_H_
