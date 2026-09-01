#include "sacramento/proof/proof_core.h"

#include <limits>

#include <fmt/format.h>

namespace sacramento::proof {

std::expected<std::uint32_t, ParseError> ParseUnsigned(
    const std::span<const std::byte> input) noexcept {
  if (input.empty()) {
    return std::unexpected(ParseError::kEmptyInput);
  }

  std::uint32_t value = 0;
  for (const std::byte character : input) {
    const auto code = std::to_integer<unsigned int>(character);
    if (code < static_cast<unsigned int>('0') ||
        code > static_cast<unsigned int>('9')) {
      return std::unexpected(ParseError::kOutOfRange);
    }
    const auto digit = static_cast<std::uint32_t>(
        code - static_cast<unsigned int>('0'));
    if (value > (std::numeric_limits<std::uint32_t>::max() - digit) / 10U) {
      return std::unexpected(ParseError::kOutOfRange);
    }
    value = value * 10U + digit;
  }
  return value;
}

std::string BuildIdentity() {
  return fmt::format("{}:{}", "CPP-ENGINEERING-BASELINE-001", 23);
}

}  // namespace sacramento::proof
