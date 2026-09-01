#include <array>
#include <bit>
#include <cstdint>
#include <expected>
#include <span>

#if !defined(__cpp_lib_expected) || __cpp_lib_expected < 202202L
#error "The approved std::expected feature is unavailable"
#endif

#if !defined(__cpp_lib_byteswap) || __cpp_lib_byteswap < 202110L
#error "The approved std::byteswap feature is unavailable"
#endif

#if !defined(__cpp_lib_span) || __cpp_lib_span < 202002L
#error "The approved std::span feature is unavailable"
#endif

int main() {
  constexpr std::expected<std::uint32_t, int> value{42U};
  constexpr std::array values{*value};
  const std::span<const std::uint32_t> view{values};
  return std::byteswap(view.front()) == 0x2A000000U ? 0 : 1;
}
