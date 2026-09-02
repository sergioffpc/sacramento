#include <array>
#include <iomanip>
#include <limits>
#include <sacramento/gate2c/protocol.hpp>
#include <sstream>
#include <type_traits>
#include <utility>

namespace sacramento::gate2c {
namespace {

enum class MessageKind : std::uint16_t {
  kHello = 1U,
  kCanonicalInput = 2U,
  kInputComplete = 3U,
  kCanonicalSnapshot = 4U,
};

constexpr std::size_t kHeaderBytes = 12U;
constexpr std::size_t kMaximumPayloadBytes = 64U;

template <typename Value>
void AppendUnsigned(std::vector<std::uint8_t>& output, Value value) {
  static_assert(std::is_unsigned_v<Value>);
  for (std::size_t index = 0; index < sizeof(Value); ++index) {
    output.push_back(static_cast<std::uint8_t>(value & 0xffU));
    if constexpr (sizeof(Value) > 1U) value >>= 8U;
  }
}

template <typename Value>
std::optional<Value> ReadUnsigned(std::span<const std::uint8_t> bytes,
                                  std::size_t& offset) {
  static_assert(std::is_unsigned_v<Value>);
  if (bytes.size() - offset < sizeof(Value)) return std::nullopt;
  Value result = 0;
  for (std::size_t index = 0; index < sizeof(Value); ++index) {
    result |= static_cast<Value>(bytes[offset + index]) << (index * 8U);
  }
  offset += sizeof(Value);
  return result;
}

void AppendSigned(std::vector<std::uint8_t>& output, std::int64_t value) {
  AppendUnsigned(output, static_cast<std::uint64_t>(value));
}

void AppendSigned(std::vector<std::uint8_t>& output, std::int32_t value) {
  AppendUnsigned(output, static_cast<std::uint32_t>(value));
}

std::optional<std::int64_t> ReadSigned64(std::span<const std::uint8_t> bytes,
                                         std::size_t& offset) {
  const auto value = ReadUnsigned<std::uint64_t>(bytes, offset);
  if (!value) return std::nullopt;
  return static_cast<std::int64_t>(*value);
}

std::optional<std::int32_t> ReadSigned32(std::span<const std::uint8_t> bytes,
                                         std::size_t& offset) {
  const auto value = ReadUnsigned<std::uint32_t>(bytes, offset);
  if (!value) return std::nullopt;
  return static_cast<std::int32_t>(*value);
}

std::vector<std::uint8_t> Wrap(MessageKind kind,
                               std::vector<std::uint8_t> payload) {
  std::vector<std::uint8_t> output;
  output.reserve(kHeaderBytes + payload.size());
  AppendUnsigned(output, kProtocolMagic);
  AppendUnsigned(output, kProtocolVersion);
  AppendUnsigned(output, static_cast<std::uint16_t>(kind));
  AppendUnsigned(output, static_cast<std::uint32_t>(payload.size()));
  output.insert(output.end(), payload.begin(), payload.end());
  return output;
}

}  // namespace

std::vector<std::uint8_t> EncodeMessage(const ProtocolMessage& message) {
  return std::visit(
      [](const auto& value) {
        using Value = std::decay_t<decltype(value)>;
        std::vector<std::uint8_t> payload;
        MessageKind kind{};
        if constexpr (std::is_same_v<Value, Hello>) {
          kind = MessageKind::kHello;
          AppendUnsigned(payload, value.client_id);
          AppendUnsigned(payload, static_cast<std::uint8_t>(value.role));
        } else if constexpr (std::is_same_v<Value, CanonicalInput>) {
          kind = MessageKind::kCanonicalInput;
          AppendUnsigned(payload, value.tick);
          AppendSigned(payload, value.movement_millimetres);
        } else if constexpr (std::is_same_v<Value, InputComplete>) {
          kind = MessageKind::kInputComplete;
        } else {
          kind = MessageKind::kCanonicalSnapshot;
          AppendUnsigned(payload, value.tick);
          AppendSigned(payload, value.aggregate_position_millimetres);
          AppendUnsigned(payload, value.digest);
        }
        return Wrap(kind, std::move(payload));
      },
      message);
}

std::optional<ProtocolMessage> DecodeMessage(
    std::span<const std::uint8_t> bytes, std::string& error) {
  if (bytes.size() < kHeaderBytes) {
    error = "SAC-NET-PROTOCOL-TRUNCATED";
    return std::nullopt;
  }
  std::size_t offset = 0;
  const auto magic = ReadUnsigned<std::uint32_t>(bytes, offset);
  const auto version = ReadUnsigned<std::uint16_t>(bytes, offset);
  const auto raw_kind = ReadUnsigned<std::uint16_t>(bytes, offset);
  const auto payload_size = ReadUnsigned<std::uint32_t>(bytes, offset);
  if (*magic != kProtocolMagic) {
    error = "SAC-NET-PROTOCOL-MAGIC";
    return std::nullopt;
  }
  if (*version != kProtocolVersion) {
    error = "SAC-NET-PROTOCOL-VERSION";
    return std::nullopt;
  }
  if (*payload_size > kMaximumPayloadBytes ||
      bytes.size() != kHeaderBytes + *payload_size) {
    error = "SAC-NET-PROTOCOL-LENGTH";
    return std::nullopt;
  }

  const auto kind = static_cast<MessageKind>(*raw_kind);
  if (kind == MessageKind::kHello) {
    const auto client_id = ReadUnsigned<std::uint32_t>(bytes, offset);
    const auto role = ReadUnsigned<std::uint8_t>(bytes, offset);
    if (!client_id || !role || offset != bytes.size() ||
        (*role != static_cast<std::uint8_t>(ClientRole::kRendered) &&
         *role != static_cast<std::uint8_t>(ClientRole::kSynthetic))) {
      error = "SAC-NET-PROTOCOL-HELLO";
      return std::nullopt;
    }
    return Hello{*client_id, static_cast<ClientRole>(*role)};
  }
  if (kind == MessageKind::kCanonicalInput) {
    const auto tick = ReadUnsigned<std::uint32_t>(bytes, offset);
    const auto movement = ReadSigned32(bytes, offset);
    if (!tick || !movement || offset != bytes.size()) {
      error = "SAC-NET-PROTOCOL-INPUT";
      return std::nullopt;
    }
    return CanonicalInput{*tick, *movement};
  }
  if (kind == MessageKind::kInputComplete && offset == bytes.size())
    return InputComplete{};
  if (kind == MessageKind::kCanonicalSnapshot) {
    const auto tick = ReadUnsigned<std::uint32_t>(bytes, offset);
    const auto position = ReadSigned64(bytes, offset);
    const auto digest = ReadUnsigned<std::uint64_t>(bytes, offset);
    if (!tick || !position || !digest || offset != bytes.size()) {
      error = "SAC-NET-PROTOCOL-SNAPSHOT";
      return std::nullopt;
    }
    return CanonicalSnapshot{*tick, *position, *digest};
  }
  error = "SAC-NET-PROTOCOL-KIND";
  return std::nullopt;
}

std::string FormatDigest(std::uint64_t digest) {
  std::ostringstream output;
  output << std::hex << std::setw(16) << std::setfill('0') << digest;
  return output.str();
}

}  // namespace sacramento::gate2c
