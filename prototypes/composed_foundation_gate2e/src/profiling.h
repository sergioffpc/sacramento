#ifndef SACRAMENTO_PROTOTYPES_COMPOSED_FOUNDATION_GATE2E_SRC_PROFILING_H_
#define SACRAMENTO_PROTOTYPES_COMPOSED_FOUNDATION_GATE2E_SRC_PROFILING_H_

namespace sacramento::gate2e {

enum class DiagnosticProfileResult {
  kDisabled,
  kMarkerEmitted,
};

[[nodiscard]] DiagnosticProfileResult MarkDiagnosticScenario();

}  // namespace sacramento::gate2e

#endif  // SACRAMENTO_PROTOTYPES_COMPOSED_FOUNDATION_GATE2E_SRC_PROFILING_H_
