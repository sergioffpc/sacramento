#ifndef SACRAMENTO_PROTOTYPES_CPP_TOOLCHAIN_PROOF_INCLUDE_SACRAMENTO_PROOF_PROOF_CORE_H_
#define SACRAMENTO_PROTOTYPES_CPP_TOOLCHAIN_PROOF_INCLUDE_SACRAMENTO_PROOF_PROOF_CORE_H_

#include <cstddef>
#include <cstdint>
#include <expected>
#include <span>
#include <string>

#if defined(_WIN32)
#if defined(SACRAMENTO_PROOF_BUILDING_LIBRARY)
#define SACRAMENTO_PROOF_API __declspec(dllexport)
#else
#define SACRAMENTO_PROOF_API __declspec(dllimport)
#endif
#else
#define SACRAMENTO_PROOF_API __attribute__((visibility("default")))
#endif

namespace sacramento::proof {

enum class ParseError : std::uint8_t { kEmptyInput, kOutOfRange };

[[nodiscard]] SACRAMENTO_PROOF_API std::expected<std::uint32_t, ParseError>
ParseUnsigned(std::span<const std::byte> input) noexcept;

[[nodiscard]] SACRAMENTO_PROOF_API std::string BuildIdentity();

}  // namespace sacramento::proof

#endif  // SACRAMENTO_PROTOTYPES_CPP_TOOLCHAIN_PROOF_INCLUDE_SACRAMENTO_PROOF_PROOF_CORE_H_
