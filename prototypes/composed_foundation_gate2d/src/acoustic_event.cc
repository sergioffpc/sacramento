#include <array>
#include <charconv>
#include <cstdint>
#include <fstream>
#include <limits>
#include <string>
#include <string_view>

#include "sacramento/gate2d/acoustics.h"

namespace sacramento::gate2d {
namespace {

constexpr std::uint64_t kNanosecondsPerSecond = 1'000'000'000;

// std::from_chars exposes a [first, last) pointer pair. Keep that standard
// library interop inside these bounded string_view helpers.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunsafe-buffer-usage"
template <typename Value>
[[nodiscard]] bool ParseUnsigned(std::string_view text, Value& value) {
  const auto result =
      std::from_chars(text.data(), text.data() + text.size(), value);
  return result.ec == std::errc{} && result.ptr == text.data() + text.size();
}

[[nodiscard]] bool ParseSigned(std::string_view text, std::int32_t& value) {
  const auto result =
      std::from_chars(text.data(), text.data() + text.size(), value);
  return result.ec == std::errc{} && result.ptr == text.data() + text.size();
}
#pragma clang diagnostic pop

[[nodiscard]] bool SplitLine(const std::string& line, std::string_view key,
                             std::string_view& value) {
  if (!line.starts_with(key) || line.size() <= key.size() ||
      line[key.size()] != '=') {
    return false;
  }
  value = std::string_view{line}.substr(key.size() + 1);
  return !value.empty();
}

[[nodiscard]] bool IsEventValid(const AcousticEvent& event) {
  return event.format_version == kAcousticEventFormatVersion &&
         event.event_correlation_id != 0 && event.script_step_id != 0 &&
         event.acoustic_profile_version != 0 &&
         event.authoritative_arrival_timestamp_ns >=
             event.initiated_timestamp_ns &&
         event.wall_transmission_per_mille <= 1'000;
}

}  // namespace

AcousticEvent MakeRepresentativeAcousticEvent() {
  constexpr std::uint64_t kInitiatedTimestampNs = 4'000'000'000;
  constexpr std::uint64_t kDistanceMillimeters = 12'000;
  constexpr std::uint64_t kPropagationNanoseconds =
      (kDistanceMillimeters * kNanosecondsPerSecond +
       kSpeedOfSoundMillimetersPerSecond - 1) /
      kSpeedOfSoundMillimetersPerSecond;

  return AcousticEvent{
      .format_version = kAcousticEventFormatVersion,
      .event_correlation_id = 0xAC00571C0000002D,
      .script_step_id = 45,
      .acoustic_profile_version = 7,
      .initiated_timestamp_ns = kInitiatedTimestampNs,
      .authoritative_arrival_timestamp_ns =
          kInitiatedTimestampNs + kPropagationNanoseconds,
      .source = {.x = 12'000, .y = 0, .z = 0},
      .listener = {.x = 0, .y = 0, .z = 0},
      .wall_transmission_per_mille = 350,
  };
}

std::expected<void, AcousticError> WriteAcousticEvent(
    const AcousticEvent& event, const std::string& path) {
  if (!IsEventValid(event)) {
    return std::unexpected{AcousticError::kInvalidEvent};
  }
  std::ofstream output{path, std::ios::binary | std::ios::trunc};
  if (!output) {
    return std::unexpected{AcousticError::kInputOutput};
  }
  output << "sacramento.acoustic-event.v1\n"
         << "format_version=" << event.format_version << '\n'
         << "event_correlation_id=" << event.event_correlation_id << '\n'
         << "script_step_id=" << event.script_step_id << '\n'
         << "acoustic_profile_version=" << event.acoustic_profile_version
         << '\n'
         << "initiated_timestamp_ns=" << event.initiated_timestamp_ns << '\n'
         << "authoritative_arrival_timestamp_ns="
         << event.authoritative_arrival_timestamp_ns << '\n'
         << "source_x_mm=" << event.source.x << '\n'
         << "source_y_mm=" << event.source.y << '\n'
         << "source_z_mm=" << event.source.z << '\n'
         << "listener_x_mm=" << event.listener.x << '\n'
         << "listener_y_mm=" << event.listener.y << '\n'
         << "listener_z_mm=" << event.listener.z << '\n'
         << "wall_transmission_per_mille=" << event.wall_transmission_per_mille
         << '\n';
  if (!output) {
    return std::unexpected{AcousticError::kInputOutput};
  }
  return {};
}

std::expected<AcousticEvent, AcousticError> ReadAcousticEvent(
    const std::string& path) {
  std::ifstream input{path, std::ios::binary};
  if (!input) {
    return std::unexpected{AcousticError::kInputOutput};
  }
  std::array<std::string, 14> lines;
  for (auto& line : lines) {
    if (!std::getline(input, line)) {
      return std::unexpected{AcousticError::kInvalidEvent};
    }
  }
  std::string extra;
  if (std::getline(input, extra) ||
      lines[0] != "sacramento.acoustic-event.v1") {
    return std::unexpected{AcousticError::kInvalidEvent};
  }

  AcousticEvent event{};
  std::string_view value;
  bool valid =
      SplitLine(lines[1], "format_version", value) &&
      ParseUnsigned(value, event.format_version) &&
      SplitLine(lines[2], "event_correlation_id", value) &&
      ParseUnsigned(value, event.event_correlation_id) &&
      SplitLine(lines[3], "script_step_id", value) &&
      ParseUnsigned(value, event.script_step_id) &&
      SplitLine(lines[4], "acoustic_profile_version", value) &&
      ParseUnsigned(value, event.acoustic_profile_version) &&
      SplitLine(lines[5], "initiated_timestamp_ns", value) &&
      ParseUnsigned(value, event.initiated_timestamp_ns) &&
      SplitLine(lines[6], "authoritative_arrival_timestamp_ns", value) &&
      ParseUnsigned(value, event.authoritative_arrival_timestamp_ns) &&
      SplitLine(lines[7], "source_x_mm", value) &&
      ParseSigned(value, event.source.x) &&
      SplitLine(lines[8], "source_y_mm", value) &&
      ParseSigned(value, event.source.y) &&
      SplitLine(lines[9], "source_z_mm", value) &&
      ParseSigned(value, event.source.z) &&
      SplitLine(lines[10], "listener_x_mm", value) &&
      ParseSigned(value, event.listener.x) &&
      SplitLine(lines[11], "listener_y_mm", value) &&
      ParseSigned(value, event.listener.y) &&
      SplitLine(lines[12], "listener_z_mm", value) &&
      ParseSigned(value, event.listener.z) &&
      SplitLine(lines[13], "wall_transmission_per_mille", value) &&
      ParseUnsigned(value, event.wall_transmission_per_mille) &&
      IsEventValid(event);
  if (!valid) {
    return std::unexpected{AcousticError::kInvalidEvent};
  }
  return event;
}

std::expected<void, AcousticError> WritePcm16(
    const RenderedAcousticEvent& rendered, const std::string& path) {
  std::ofstream output{path, std::ios::binary | std::ios::trunc};
  if (!output) {
    return std::unexpected{AcousticError::kInputOutput};
  }
  for (const std::int16_t sample : rendered.interleaved_pcm) {
    const auto bits = static_cast<std::uint16_t>(sample);
    const std::array<char, 2> bytes{
        static_cast<char>(bits & 0xffU),
        static_cast<char>((bits >> 8U) & 0xffU),
    };
    output.write(bytes.data(), static_cast<std::streamsize>(bytes.size()));
  }
  if (!output) {
    return std::unexpected{AcousticError::kInputOutput};
  }
  return {};
}

}  // namespace sacramento::gate2d
