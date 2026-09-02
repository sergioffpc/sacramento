#include <tracy/Tracy.hpp>

#include "profiling.h"

namespace sacramento::gate2e {

DiagnosticProfileResult MarkDiagnosticScenario() {
  ZoneScopedN("Sacramento Gate 2E observability scenario");
  TracyMessageL("Sacramento diagnostic marker; no gameplay payload");
  FrameMarkNamed("Sacramento Gate 2E frame");
  return DiagnosticProfileResult::kMarkerEmitted;
}

}  // namespace sacramento::gate2e
