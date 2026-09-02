#ifndef SACRAMENTO_PROTOTYPES_COMPOSED_FOUNDATION_GATE2E_INCLUDE_SACRAMENTO_GATE2E_OBSERVABILITY_H_
#define SACRAMENTO_PROTOTYPES_COMPOSED_FOUNDATION_GATE2E_INCLUDE_SACRAMENTO_GATE2E_OBSERVABILITY_H_

#include <expected>
#include <string>

namespace sacramento::gate2e {

enum class ProcessRole {
  kSessionAuthority,
  kRenderedClient,
  kSyntheticClient,
};

enum class ObservabilityDetailLevel {
  kCoreOnly,
  kDiagnostic,
};

enum class ObservabilityError {
  kInputOutput,
};

// Writes one deterministic process-local signal stream. The path is borrowed
// for the call. The function blocks on local file output and reports I/O
// failures without throwing across the observability boundary.
[[nodiscard]] std::expected<void, ObservabilityError> WriteScenarioSignals(
    ProcessRole role, ObservabilityDetailLevel detail_level,
    const std::string& output_path);

}  // namespace sacramento::gate2e

#endif  // SACRAMENTO_PROTOTYPES_COMPOSED_FOUNDATION_GATE2E_INCLUDE_SACRAMENTO_GATE2E_OBSERVABILITY_H_
