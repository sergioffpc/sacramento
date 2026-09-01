#include "proof/proof_core.hpp"

#include <gtest/gtest.h>

TEST(ProofCore, UsesExpectedAndFmt) {
  const auto answer = proof::format_answer(true);
  ASSERT_TRUE(answer.has_value());
  EXPECT_EQ(*answer, "expected=42");
}

TEST(ProofCore, ReturnsExpectedError) {
  const auto answer = proof::format_answer(false);
  ASSERT_FALSE(answer.has_value());
  EXPECT_EQ(answer.error(), "invalid");
}
