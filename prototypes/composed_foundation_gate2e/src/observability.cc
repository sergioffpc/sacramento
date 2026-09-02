#include "sacramento/gate2e/observability.h"

#include <cstdint>
#include <fstream>
#include <optional>
#include <string_view>

namespace sacramento::gate2e {
namespace {

constexpr std::string_view kContractVersion = "OBS-CONTRACT-001";
constexpr std::string_view kBuildVersion = "gate2e-prototype-build-001";
constexpr std::string_view kConfigurationVersion =
    "gate2e-observability-config-001";
constexpr std::string_view kSessionCorrelationId = "session-gate2e-001";
constexpr std::string_view kActionCorrelationId = "action-gate2e-017";
constexpr std::string_view kAcousticCorrelationId = "acoustic-gate2e-045";
constexpr std::string_view kProfileVersions =
    "[\"RWP-GATE2E-001\",\"content:sha256:"
    "1849d21148d23e4ad2da81e4ddbec5d7fbd636b00e4c9b087bc14db0589c2c46\"]";

[[nodiscard]] std::string_view RoleName(ProcessRole role) {
  switch (role) {
    case ProcessRole::kSessionAuthority:
      return "authority";
    case ProcessRole::kRenderedClient:
      return "rendered";
    case ProcessRole::kSyntheticClient:
      return "synthetic";
  }
  return "invalid";
}

[[nodiscard]] std::string_view DetailName(
    ObservabilityDetailLevel detail_level) {
  if (detail_level == ObservabilityDetailLevel::kCoreOnly) return "CoreOnly";
  return "Diagnostic";
}

class SignalWriter {
 public:
  SignalWriter(const std::string& output_path, ProcessRole role,
               ObservabilityDetailLevel detail_level)
      : output_(output_path, std::ios::binary | std::ios::trunc),
        role_(role),
        detail_level_(detail_level) {}

  [[nodiscard]] bool IsOpen() const { return output_.is_open(); }
  [[nodiscard]] bool IsValid() const { return output_.good(); }

  void Emit(std::string_view signal_id, std::uint64_t monotonic_timestamp_ns,
            std::optional<std::uint64_t> reference_timestamp_ns,
            std::optional<std::string_view> event_correlation_id,
            std::string_view fields, bool session_applies = true) {
    output_ << "{\"contract_version\":\"" << kContractVersion
            << "\",\"signal_id\":\"" << signal_id
            << "\",\"source_instance_id\":\"gate2e-" << RoleName(role_) << '-'
            << (detail_level_ == ObservabilityDetailLevel::kCoreOnly
                    ? "core"
                    : "diagnostic")
            << "-001\",\"source_sequence\":" << sequence_++
            << ",\"monotonic_timestamp_ns\":" << monotonic_timestamp_ns;
    if (reference_timestamp_ns) {
      output_ << ",\"reference_timestamp_ns\":" << *reference_timestamp_ns;
    }
    output_ << ",\"build_version\":\"" << kBuildVersion
            << "\",\"configuration_version\":\"" << kConfigurationVersion
            << "\",\"profile_versions\":" << kProfileVersions;
    if (session_applies) {
      output_ << ",\"session_correlation_id\":\"" << kSessionCorrelationId
              << '"';
    }
    if (event_correlation_id) {
      output_ << ",\"event_correlation_id\":\"" << *event_correlation_id << '"';
    }
    output_ << fields << "}\n";
  }

 private:
  std::ofstream output_;
  ProcessRole role_;
  ObservabilityDetailLevel detail_level_;
  std::uint64_t sequence_ = 1;
};

void EmitLifecycle(SignalWriter& writer, std::uint64_t timestamp,
                   std::string_view state, std::string_view classification) {
  std::string fields = ",\"lifecycle_state\":\"";
  fields += state;
  fields += '"';
  if (!classification.empty()) {
    fields += ",\"termination_class\":\"";
    fields += classification;
    fields += '"';
  }
  writer.Emit("OBS-PROCESS-LIFECYCLE-001", timestamp, std::nullopt,
              std::nullopt, fields, false);
}

}  // namespace

std::expected<void, ObservabilityError> WriteScenarioSignals(
    ProcessRole role, ObservabilityDetailLevel detail_level,
    const std::string& output_path) {
  SignalWriter writer(output_path, role, detail_level);
  if (!writer.IsOpen()) {
    return std::unexpected{ObservabilityError::kInputOutput};
  }

  EmitLifecycle(writer, 1'000, "Started", "");
  std::string identity_fields = ",\"observability_detail_level\":\"";
  identity_fields += DetailName(detail_level);
  identity_fields += '"';
  writer.Emit("OBS-RUNTIME-IDENTITY-001", 1'100, std::nullopt, std::nullopt,
              identity_fields, false);

  if (detail_level == ObservabilityDetailLevel::kDiagnostic) {
    writer.Emit("OBS-GATE2E-DIAGNOSTIC-MARKER-001", 1'150, std::nullopt,
                std::nullopt, ",\"marker_name\":\"scenario\"");
  }

  switch (role) {
    case ProcessRole::kSessionAuthority:
      writer.Emit("OBS-ACOUSTIC-EVENT-INITIATED-001", 2'000, 102'000,
                  kAcousticCorrelationId, ",\"script_step_id\":45");
      break;
    case ProcessRole::kRenderedClient:
      writer.Emit("OBS-ACTION-SUBMITTED-001", 1'200, 101'200,
                  kActionCorrelationId,
                  ",\"script_step_id\":17,\"origin_client_slot_id\":"
                  "\"rendered-slot-001\"");
      writer.Emit("OBS-ACTION-RESULT-PRESENTED-001", 1'600, 101'600,
                  kActionCorrelationId,
                  ",\"recipient_client_slot_id\":\"rendered-slot-001\","
                  "\"final_image_sequence\":42");
      writer.Emit("OBS-ACOUSTIC-EVENT-PRESENTED-001", 2'500, 102'500,
                  kAcousticCorrelationId,
                  ",\"script_step_id\":45,\"output_route_id\":"
                  "\"route-primary-001\"");
      break;
    case ProcessRole::kSyntheticClient:
      writer.Emit("OBS-ACTION-RESULT-RECEIVED-001", 1'500, 101'500,
                  kActionCorrelationId,
                  ",\"recipient_client_slot_id\":\"synthetic-slot-001\"");
      break;
  }

  EmitLifecycle(writer, 3'000, "Stopping", "");
  EmitLifecycle(writer, 3'100, "Terminated", "Clean");
  if (!writer.IsValid()) {
    return std::unexpected{ObservabilityError::kInputOutput};
  }
  return {};
}

}  // namespace sacramento::gate2e
