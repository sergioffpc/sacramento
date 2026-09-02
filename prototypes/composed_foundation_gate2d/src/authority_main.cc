#include <iostream>
#include <span>

#include "sacramento/gate2d/acoustics.h"

int main(int argc, char** argv) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunsafe-buffer-usage-in-container"
  const std::span<char*> arguments{argv, static_cast<std::size_t>(argc)};
#pragma clang diagnostic pop
  if (argc != 2) {
    std::cerr << "usage: sacramento_gate2d_authority <event-path>\n";
    return 2;
  }
  const auto event = sacramento::gate2d::MakeRepresentativeAcousticEvent();
  if (!sacramento::gate2d::WriteAcousticEvent(event, arguments[1])) {
    std::cerr << "SAC-ACOUSTIC-EVENT-WRITE\n";
    return 1;
  }
  std::cout << "{\"status\":\"pass\",\"signal\":"
               "\"OBS-ACOUSTIC-EVENT-INITIATED-001\","
            << "\"event_correlation_id\":" << event.event_correlation_id
            << ",\"script_step_id\":" << event.script_step_id
            << ",\"acoustic_profile_version\":"
            << event.acoustic_profile_version
            << ",\"initiated_timestamp_ns\":" << event.initiated_timestamp_ns
            << ",\"authoritative_arrival_timestamp_ns\":"
            << event.authoritative_arrival_timestamp_ns << "}\n";
  return 0;
}
