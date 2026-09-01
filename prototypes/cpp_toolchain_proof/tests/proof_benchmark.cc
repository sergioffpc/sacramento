#include "sacramento/proof/proof_core.h"

#include <array>
#include <cstddef>

#include <benchmark/benchmark.h>

static void BMParseUnsigned(benchmark::State& state) {
  constexpr std::array input{static_cast<std::byte>('4'),
                             static_cast<std::byte>('2')};
  for (auto _ : state) {
    static_cast<void>(_);
    benchmark::DoNotOptimize(sacramento::proof::ParseUnsigned(input));
  }
}

BENCHMARK(BMParseUnsigned);
