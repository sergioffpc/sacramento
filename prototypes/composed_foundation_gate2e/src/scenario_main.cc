#include <cstdlib>
#include <iostream>
#include <optional>
#include <string>
#include <string_view>

#include "profiling.h"
#include "sacramento/gate2e/observability.h"

namespace sacramento::gate2e {
namespace {

[[nodiscard]] std::optional<ProcessRole> ParseRole(std::string_view value) {
  if (value == "authority") return ProcessRole::kSessionAuthority;
  if (value == "rendered") return ProcessRole::kRenderedClient;
  if (value == "synthetic") return ProcessRole::kSyntheticClient;
  return std::nullopt;
}

[[nodiscard]] std::optional<ObservabilityDetailLevel> ParseDetailLevel(
    std::string_view value) {
  if (value == "CoreOnly") return ObservabilityDetailLevel::kCoreOnly;
  if (value == "Diagnostic") return ObservabilityDetailLevel::kDiagnostic;
  return std::nullopt;
}

}  // namespace
}  // namespace sacramento::gate2e

int main() {
  const char* role_text = std::getenv("SACRAMENTO_GATE2E_ROLE");
  const char* detail_text = std::getenv("SACRAMENTO_GATE2E_DETAIL");
  const char* output_path = std::getenv("SACRAMENTO_GATE2E_OUTPUT");
  if (role_text == nullptr || detail_text == nullptr ||
      output_path == nullptr) {
    std::cerr << "SAC-OBS-GATE2E-ENVIRONMENT\n";
    return 2;
  }

  const auto role = sacramento::gate2e::ParseRole(role_text);
  const auto detail_level = sacramento::gate2e::ParseDetailLevel(detail_text);
  if (!role || !detail_level) {
    std::cerr << "SAC-OBS-GATE2E-ARGUMENT\n";
    return 2;
  }

#if SACRAMENTO_GATE2E_DIAGNOSTIC_BUILD
  if (*detail_level !=
      sacramento::gate2e::ObservabilityDetailLevel::kDiagnostic) {
    std::cerr << "SAC-OBS-GATE2E-DIAGNOSTIC-DETAIL\n";
    return 2;
  }
#else
  if (*detail_level !=
      sacramento::gate2e::ObservabilityDetailLevel::kCoreOnly) {
    std::cerr << "SAC-OBS-GATE2E-CORE-DETAIL\n";
    return 2;
  }
#endif

  const auto profiling_result = sacramento::gate2e::MarkDiagnosticScenario();
  const auto write_result = sacramento::gate2e::WriteScenarioSignals(
      *role, *detail_level, std::string{output_path});
  if (!write_result) {
    std::cerr << "SAC-OBS-GATE2E-WRITE\n";
    return 1;
  }

  std::cout
      << "{\"status\":\"pass\",\"diagnostic_marker\":\""
      << (profiling_result ==
                  sacramento::gate2e::DiagnosticProfileResult::kMarkerEmitted
              ? "emitted"
              : "disabled")
      << "\"}\n";
  return 0;
}
