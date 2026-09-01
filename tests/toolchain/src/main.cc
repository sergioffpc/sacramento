#include "proof/proof_core.hpp"

#include <iostream>

int main() {
  const auto answer = proof::format_answer(true);
  if (!answer) {
    return 1;
  }
  std::cout << "windows-cross-proof: " << *answer << '\n';
  return 0;
}
