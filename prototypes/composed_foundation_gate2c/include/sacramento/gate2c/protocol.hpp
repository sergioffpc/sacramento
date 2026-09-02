#ifndef SACRAMENTO_PROTOTYPES_COMPOSED_FOUNDATION_GATE2C_INCLUDE_SACRAMENTO_GATE2C_PROTOCOL_HPP_
#define SACRAMENTO_PROTOTYPES_COMPOSED_FOUNDATION_GATE2C_INCLUDE_SACRAMENTO_GATE2C_PROTOCOL_HPP_

#include <cstdint>
#include <optional>
#include <span>
#include <string>
#include <variant>
#include <vector>

namespace sacramento::gate2c {

inline constexpr std::uint32_t kProtocolMagic = 0x53414332U;
inline constexpr std::uint16_t kProtocolVersion = 1U;

enum class ClientRole : std::uint8_t {
  kRendered = 1U,
  kSynthetic = 2U,
};

struct Hello {
  std::uint32_t client_id;
  ClientRole role;
};

struct CanonicalInput {
  std::uint32_t tick;
  std::int32_t movement_millimetres;
};

struct InputComplete {};

struct CanonicalSnapshot {
  std::uint32_t tick;
  std::int64_t aggregate_position_millimetres;
  std::uint64_t digest;
};

using ProtocolMessage =
    std::variant<Hello, CanonicalInput, InputComplete, CanonicalSnapshot>;

std::vector<std::uint8_t> EncodeMessage(const ProtocolMessage& message);
std::optional<ProtocolMessage> DecodeMessage(
    std::span<const std::uint8_t> bytes, std::string& error);
std::string FormatDigest(std::uint64_t digest);

}  // namespace sacramento::gate2c

#endif
