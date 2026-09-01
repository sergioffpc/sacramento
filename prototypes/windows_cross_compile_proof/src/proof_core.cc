#include "proof/proof_core.hpp"

#include <fmt/format.h>

namespace proof {

std::expected<std::string, std::string_view> format_answer(const bool valid) {
  if (!valid) {
    return std::unexpected{"invalid"};
  }
  return fmt::format("expected={}", 42);
}

}  // namespace proof
