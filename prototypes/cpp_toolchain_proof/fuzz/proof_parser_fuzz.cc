#include "sacramento/proof/proof_core.h"

#include <cstddef>
#include <cstdint>
#include <span>

extern "C" int LLVMFuzzerTestOneInput(const std::uint8_t* data,
                                      const std::size_t size) {
  const auto bytes = std::as_bytes(std::span{data, size});
  static_cast<void>(sacramento::proof::ParseUnsigned(bytes));
  return 0;
}
