#pragma once

#include <expected>
#include <string>
#include <string_view>

namespace proof {

[[nodiscard]] std::expected<std::string, std::string_view> format_answer(
    bool valid);

}  // namespace proof
