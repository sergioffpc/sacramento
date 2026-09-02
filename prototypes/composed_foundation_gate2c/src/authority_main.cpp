#include <algorithm>
#include <chrono>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <map>
#include <sacramento/gate2c/protocol.hpp>
#include <sacramento/gate2c/transport.hpp>
#include <span>
#include <stdexcept>
#include <string>
#include <thread>
#include <type_traits>
#include <vector>

namespace sacramento::gate2c {
namespace {

constexpr std::uint32_t kTickRateHz = 60U;
constexpr std::uint32_t kFinalTick = 120U;
constexpr std::uint64_t kDigestOffset = 14695981039346656037ULL;
constexpr std::uint64_t kDigestPrime = 1099511628211ULL;

struct ClientState {
  PeerId peer;
  ClientRole role;
  std::int64_t position_millimetres = 0;
  bool complete = false;
};

void HashByte(std::uint64_t& digest, std::uint8_t value) {
  digest ^= value;
  digest *= kDigestPrime;
}

template <typename Value>
void HashUnsigned(std::uint64_t& digest, Value value) {
  static_assert(std::is_unsigned_v<Value>);
  for (std::size_t index = 0; index < sizeof(Value); ++index) {
    HashByte(digest, static_cast<std::uint8_t>(value & 0xffU));
    if constexpr (sizeof(Value) > 1U) value >>= 8U;
  }
}

void Run(std::uint16_t requested_port, std::uint32_t expected_clients,
         const std::string& trace_path, const std::string& result_path) {
  AuthorityTransport transport(requested_port);
  std::cout << "{\"event\":\"ready\",\"port\":" << transport.port() << "}"
            << std::endl;

  std::map<PeerId, std::uint32_t> peer_clients;
  std::map<std::uint32_t, ClientState> clients;
  std::map<std::uint32_t, std::vector<std::pair<std::uint32_t, std::int32_t>>>
      inputs;
  const auto deadline =
      std::chrono::steady_clock::now() + std::chrono::seconds(20);
  while (std::ranges::count_if(clients, [](const auto& item) {
           return item.second.complete;
         }) < static_cast<std::ptrdiff_t>(expected_clients)) {
    if (std::chrono::steady_clock::now() >= deadline)
      throw std::runtime_error("SAC-NET-AUTHORITY-INPUT-TIMEOUT");
    for (auto& event : transport.Poll()) {
      if (event.kind != TransportEventKind::kPayload) continue;
      std::string error;
      const auto message = DecodeMessage(event.payload, error);
      if (!message) throw std::runtime_error(error);
      if (const auto* hello = std::get_if<Hello>(&*message)) {
        if (hello->client_id == 0U || clients.contains(hello->client_id) ||
            peer_clients.contains(event.peer))
          throw std::runtime_error("SAC-NET-AUTHORITY-HELLO");
        peer_clients.emplace(event.peer, hello->client_id);
        clients.emplace(hello->client_id, ClientState{event.peer, hello->role});
      } else {
        const auto peer_item = peer_clients.find(event.peer);
        if (peer_item == peer_clients.end())
          throw std::runtime_error("SAC-NET-AUTHORITY-NO-HELLO");
        auto& client = clients.at(peer_item->second);
        if (const auto* input = std::get_if<CanonicalInput>(&*message)) {
          if (client.complete || input->tick == 0U || input->tick > kFinalTick)
            throw std::runtime_error("SAC-NET-AUTHORITY-INPUT");
          inputs[input->tick].emplace_back(peer_item->second,
                                           input->movement_millimetres);
        } else if (std::holds_alternative<InputComplete>(*message)) {
          client.complete = true;
        } else {
          throw std::runtime_error("SAC-NET-AUTHORITY-MESSAGE");
        }
      }
    }
    std::this_thread::sleep_for(std::chrono::milliseconds(1));
  }

  if (clients.size() != expected_clients ||
      std::ranges::count_if(clients, [](const auto& item) {
        return item.second.role == ClientRole::kRendered;
      }) != 1)
    throw std::runtime_error("SAC-NET-AUTHORITY-CLIENT-ROLES");
  for (auto& [tick, tick_inputs] : inputs) {
    static_cast<void>(tick);
    std::ranges::sort(tick_inputs);
  }

  std::ofstream trace(trace_path);
  if (!trace) throw std::runtime_error("SAC-NET-AUTHORITY-TRACE");
  std::uint64_t digest = kDigestOffset;
  HashUnsigned(digest, kProtocolVersion);
  const auto start = std::chrono::steady_clock::now();
  std::int64_t maximum_tick_lateness_microseconds = 0;
  for (std::uint32_t tick = 1U; tick <= kFinalTick; ++tick) {
    const auto input_item = inputs.find(tick);
    if (input_item != inputs.end()) {
      for (const auto& [client_id, movement] : input_item->second)
        clients.at(client_id).position_millimetres += movement;
    }
    HashUnsigned(digest, tick);
    std::int64_t aggregate_position = 0;
    for (const auto& [client_id, client] : clients) {
      HashUnsigned(digest, client_id);
      HashUnsigned(digest, static_cast<std::uint8_t>(client.role));
      HashUnsigned(digest,
                   static_cast<std::uint64_t>(client.position_millimetres));
      aggregate_position += client.position_millimetres;
    }
    trace << "{\"tick\":" << tick
          << ",\"aggregate_position_mm\":" << aggregate_position
          << ",\"digest\":\"" << FormatDigest(digest) << "\"}\n";
    const auto tick_deadline =
        start +
        std::chrono::nanoseconds((1'000'000'000ULL * tick) / kTickRateHz);
    std::this_thread::sleep_until(tick_deadline);
    maximum_tick_lateness_microseconds =
        std::max(maximum_tick_lateness_microseconds,
                 std::chrono::duration_cast<std::chrono::microseconds>(
                     std::chrono::steady_clock::now() - tick_deadline)
                     .count());
  }
  trace.close();
  const auto simulation_elapsed_microseconds =
      std::chrono::duration_cast<std::chrono::microseconds>(
          std::chrono::steady_clock::now() - start)
          .count();

  std::int64_t aggregate_position = 0;
  for (const auto& [client_id, client] : clients) {
    static_cast<void>(client_id);
    aggregate_position += client.position_millimetres;
  }
  const CanonicalSnapshot snapshot{kFinalTick, aggregate_position, digest};
  const auto encoded = EncodeMessage(snapshot);
  for (const auto& [client_id, client] : clients) {
    static_cast<void>(client_id);
    transport.Send(client.peer, encoded);
  }
  const auto flush_deadline =
      std::chrono::steady_clock::now() + std::chrono::milliseconds(250);
  while (std::chrono::steady_clock::now() < flush_deadline) {
    static_cast<void>(transport.Poll());
    std::this_thread::sleep_for(std::chrono::milliseconds(1));
  }

  std::ofstream result(result_path);
  result << "{\"status\":\"pass\",\"protocol_version\":" << kProtocolVersion
         << ",\"clients\":" << clients.size()
         << ",\"rendered_clients\":1,\"synthetic_clients\":"
         << (clients.size() - 1U) << ",\"tick_hz\":" << kTickRateHz
         << ",\"ticks\":" << kFinalTick
         << ",\"aggregate_position_mm\":" << aggregate_position
         << ",\"digest\":\"" << FormatDigest(digest) << "\"}\n";
  std::cout << "{\"event\":\"complete\",\"digest\":\"" << FormatDigest(digest)
            << "\",\"simulation_elapsed_us\":"
            << simulation_elapsed_microseconds << ",\"max_tick_lateness_us\":"
            << maximum_tick_lateness_microseconds << "}" << std::endl;
}

}  // namespace
}  // namespace sacramento::gate2c

int main(int argc, char** argv) {
  if (argc != 5) {
    std::cerr << "usage: authority PORT CLIENTS TRACE RESULT\n";
    return 2;
  }
  try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunsafe-buffer-usage-in-container"
    const std::span arguments(argv, static_cast<std::size_t>(argc));
#pragma clang diagnostic pop
    sacramento::gate2c::Run(
        static_cast<std::uint16_t>(std::stoul(arguments[1])),
        static_cast<std::uint32_t>(std::stoul(arguments[2])), arguments[3],
        arguments[4]);
    return 0;
  } catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
}
