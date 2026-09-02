#include <chrono>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <sacramento/gate2c/protocol.hpp>
#include <sacramento/gate2c/transport.hpp>
#include <span>
#include <stdexcept>
#include <string>
#include <thread>
#include <vector>

namespace sacramento::gate2c {
namespace {

std::vector<CanonicalInput> LoadInputs(const std::string& path) {
  std::ifstream input(path);
  if (!input) throw std::runtime_error("SAC-NET-CLIENT-SCRIPT");
  std::vector<CanonicalInput> result;
  std::uint32_t tick = 0;
  std::int32_t movement = 0;
  while (input >> tick >> movement) result.push_back({tick, movement});
  if (!input.eof()) throw std::runtime_error("SAC-NET-CLIENT-SCRIPT-FORMAT");
  return result;
}

void Run(std::uint16_t port, std::uint32_t client_id, ClientRole role,
         const std::string& script_path) {
  const auto inputs = LoadInputs(script_path);
  ClientTransport transport("127.0.0.1", port);
  const auto deadline =
      std::chrono::steady_clock::now() + std::chrono::seconds(20);
  bool sent = false;
  while (std::chrono::steady_clock::now() < deadline) {
    for (auto& event : transport.Poll()) {
      if (event.kind == TransportEventKind::kConnected && !sent) {
        transport.Send(EncodeMessage(Hello{client_id, role}));
        for (const auto& input : inputs) transport.Send(EncodeMessage(input));
        transport.Send(EncodeMessage(InputComplete{}));
        sent = true;
      }
      if (event.kind == TransportEventKind::kPayload) {
        std::string error;
        const auto message = DecodeMessage(event.payload, error);
        if (!message) throw std::runtime_error(error);
        const auto* snapshot = std::get_if<CanonicalSnapshot>(&*message);
        if (snapshot == nullptr)
          throw std::runtime_error("SAC-NET-CLIENT-MESSAGE");
        std::cout << "{\"status\":\"pass\",\"client_id\":" << client_id
                  << ",\"role\":\""
                  << (role == ClientRole::kRendered ? "rendered" : "synthetic")
                  << "\",\"tick\":" << snapshot->tick
                  << ",\"aggregate_position_mm\":"
                  << snapshot->aggregate_position_millimetres
                  << ",\"digest\":\"" << FormatDigest(snapshot->digest)
                  << "\"}\n";
        return;
      }
      if (event.kind == TransportEventKind::kDisconnected)
        throw std::runtime_error("SAC-NET-CLIENT-DISCONNECTED");
    }
    std::this_thread::sleep_for(std::chrono::milliseconds(1));
  }
  throw std::runtime_error("SAC-NET-CLIENT-TIMEOUT");
}

}  // namespace
}  // namespace sacramento::gate2c

int main(int argc, char** argv) {
  if (argc != 5) {
    std::cerr << "usage: client PORT CLIENT_ID rendered|synthetic SCRIPT\n";
    return 2;
  }
  try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunsafe-buffer-usage-in-container"
    const std::span arguments(argv, static_cast<std::size_t>(argc));
#pragma clang diagnostic pop
    const std::string role_value(arguments[3]);
    const auto role = role_value == "rendered"
                          ? sacramento::gate2c::ClientRole::kRendered
                          : sacramento::gate2c::ClientRole::kSynthetic;
    if (role_value != "rendered" && role_value != "synthetic")
      throw std::runtime_error("SAC-NET-CLIENT-ROLE");
    sacramento::gate2c::Run(
        static_cast<std::uint16_t>(std::stoul(arguments[1])),
        static_cast<std::uint32_t>(std::stoul(arguments[2])), role,
        arguments[4]);
    return 0;
  } catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
}
