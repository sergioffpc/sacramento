#include <expected>
#include <iostream>
#include <string_view>

namespace {

[[nodiscard]] std::expected<int, std::string_view> parse_answer(
    const bool valid) {
  if (!valid) {
    return std::unexpected{"invalid"};
  }
  return 42;
}

}  // namespace

int main() {
  const auto answer = parse_answer(true);
  if (!answer || *answer != 42) {
    return 1;
  }

  std::cout << "windows-cross-proof: expected=" << *answer << '\n';
  return 0;
}
