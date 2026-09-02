#include <Falcor/Core/API/Device.h>
#include <Falcor/Core/Pass/ComputePass.h>
#include <sacramento/gate2d/acoustics.h>
#include <sacramento/gate2e/observability.h>

#include <chrono>
#include <cstdint>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <sacramento/gate2c/protocol.hpp>
#include <sacramento/gate2c/transport.hpp>
#include <span>
#include <stdexcept>
#include <string>
#include <thread>
#include <vector>

namespace {

using sacramento::gate2c::CanonicalInput;

std::vector<CanonicalInput> LoadInputs(const std::filesystem::path& path) {
  std::ifstream input(path);
  if (!input) throw std::runtime_error("SAC-COMPOSED-CLIENT-SCRIPT");
  std::vector<CanonicalInput> result;
  std::uint32_t tick = 0;
  std::int32_t movement = 0;
  while (input >> tick >> movement) result.push_back({tick, movement});
  if (!input.eof())
    throw std::runtime_error("SAC-COMPOSED-CLIENT-SCRIPT-FORMAT");
  return result;
}

sacramento::gate2c::CanonicalSnapshot ReceiveSnapshot(
    const std::string& host, std::uint16_t port,
    const std::filesystem::path& script_path) {
  const auto inputs = LoadInputs(script_path);
  sacramento::gate2c::ClientTransport transport(host, port);
  const auto deadline =
      std::chrono::steady_clock::now() + std::chrono::seconds(20);
  bool sent = false;
  while (std::chrono::steady_clock::now() < deadline) {
    for (auto& event : transport.Poll()) {
      if (event.kind == sacramento::gate2c::TransportEventKind::kConnected &&
          !sent) {
        transport.Send(
            sacramento::gate2c::EncodeMessage(sacramento::gate2c::Hello{
                1U, sacramento::gate2c::ClientRole::kRendered}));
        for (const auto& input : inputs)
          transport.Send(sacramento::gate2c::EncodeMessage(input));
        transport.Send(sacramento::gate2c::EncodeMessage(
            sacramento::gate2c::InputComplete{}));
        sent = true;
      }
      if (event.kind == sacramento::gate2c::TransportEventKind::kPayload) {
        std::string error;
        const auto message =
            sacramento::gate2c::DecodeMessage(event.payload, error);
        if (!message) throw std::runtime_error(error);
        const auto* snapshot =
            std::get_if<sacramento::gate2c::CanonicalSnapshot>(&*message);
        if (snapshot == nullptr)
          throw std::runtime_error("SAC-COMPOSED-CLIENT-MESSAGE");
        return *snapshot;
      }
      if (event.kind == sacramento::gate2c::TransportEventKind::kDisconnected)
        throw std::runtime_error("SAC-COMPOSED-CLIENT-DISCONNECTED");
    }
    std::this_thread::sleep_for(std::chrono::milliseconds(1));
  }
  throw std::runtime_error("SAC-COMPOSED-CLIENT-TIMEOUT");
}

void Run(const std::string& host, std::uint16_t port,
         const std::filesystem::path& script_path,
         const std::filesystem::path& output_root) {
  std::filesystem::create_directories(output_root);
  const auto snapshot = ReceiveSnapshot(host, port, script_path);

  Falcor::Device::Desc device_description;
  device_description.type = Falcor::Device::Type::Vulkan;
  device_description.enableAftermath = true;
  device_description.enableDebugLayer = false;
  device_description.shaderCachePath.clear();
  auto device = Falcor::make_ref<Falcor::Device>(device_description);
  auto program = Falcor::ComputePass::create(device, "gate2f.slang", "main");
  if (!program || device->getType() != Falcor::Device::Type::Vulkan)
    throw std::runtime_error("SAC-COMPOSED-FALCOR");

  const auto acoustic_event =
      sacramento::gate2d::MakeRepresentativeAcousticEvent();
  const auto rendered_audio =
      sacramento::gate2d::RenderAcousticEvent(acoustic_event);
  if (!rendered_audio) throw std::runtime_error("SAC-COMPOSED-STEAM-AUDIO");
  const auto pcm_path = output_root / "rendered-client.pcm";
  if (!sacramento::gate2d::WritePcm16(*rendered_audio, pcm_path.string()))
    throw std::runtime_error("SAC-COMPOSED-PCM-WRITE");

  const auto signals_path = output_root / "rendered-client.ndjson";
  if (!sacramento::gate2e::WriteScenarioSignals(
          sacramento::gate2e::ProcessRole::kRenderedClient,
          sacramento::gate2e::ObservabilityDetailLevel::kCoreOnly,
          signals_path.string()))
    throw std::runtime_error("SAC-COMPOSED-OBSERVABILITY");

  const auto& device_info = device->getInfo();
  std::cout << "{\"status\":\"pass\",\"composition\":\"literal\","
            << "\"network\":\"GameNetworkingSockets\",\"tick\":"
            << snapshot.tick << ",\"digest\":\""
            << sacramento::gate2c::FormatDigest(snapshot.digest)
            << "\",\"renderer\":\"Falcor\",\"api\":\"" << device_info.apiName
            << "\",\"adapter\":\"" << device_info.adapterName
            << "\",\"audio\":\"Steam Audio\","
            << "\"pcm_fnv1a_64\":\"" << std::hex << rendered_audio->pcm_fnv1a_64
            << "\",\"observability_detail_level\":\"CoreOnly\","
            << "\"tracy_linked\":false}" << std::endl;
}

}  // namespace

int main(int argc, char** argv) {
  if (argc != 5) {
    std::cerr << "usage: rendered-client HOST PORT SCRIPT OUTPUT_ROOT\n";
    return 2;
  }
  try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunsafe-buffer-usage-in-container"
    const std::span arguments(argv, static_cast<std::size_t>(argc));
#pragma clang diagnostic pop
    Run(arguments[1], static_cast<std::uint16_t>(std::stoul(arguments[2])),
        arguments[3], arguments[4]);
    return 0;
  } catch (const std::exception& error) {
    std::cerr << "{\"status\":\"fail\",\"error\":\"" << error.what() << "\"}"
              << std::endl;
    return 1;
  }
}
