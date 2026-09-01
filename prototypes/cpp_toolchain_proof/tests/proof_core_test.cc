#include "sacramento/proof/proof_core.h"

#include <array>
#include <cstddef>

#include <gtest/gtest.h>

namespace sacramento::proof {
namespace {

TEST(ParseUnsignedTest, ParsesAValidDecimalValue) {
  constexpr std::array input{static_cast<std::byte>('4'),
                             static_cast<std::byte>('2')};
  const auto result = ParseUnsigned(input);
  ASSERT_TRUE(result.has_value());
  EXPECT_EQ(*result, 42U);
}

TEST(ParseUnsignedTest, RejectsAnEmptyInput) {
  const auto result = ParseUnsigned({});
  ASSERT_FALSE(result.has_value());
  EXPECT_EQ(result.error(), ParseError::kEmptyInput);
}

}  // namespace
}  // namespace sacramento::proof
