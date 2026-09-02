#include <iomanip>
#include <iostream>
#include <span>

#include "sacramento/gate2d/acoustics.h"

int main(int argc, char** argv) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunsafe-buffer-usage-in-container"
  const std::span<char*> arguments{argv, static_cast<std::size_t>(argc)};
#pragma clang diagnostic pop
  if (argc != 3) {
    std::cerr << "usage: sacramento_gate2d_client <event-path> <pcm-path>\n";
    return 2;
  }
  const auto event = sacramento::gate2d::ReadAcousticEvent(arguments[1]);
  if (!event) {
    std::cerr << "SAC-ACOUSTIC-EVENT-READ\n";
    return 1;
  }
  auto rendered = sacramento::gate2d::RenderAcousticEvent(*event);
  if (!rendered) {
    std::cerr << "SAC-ACOUSTIC-RENDER\n";
    return 1;
  }
  if (!sacramento::gate2d::WritePcm16(*rendered, arguments[2])) {
    std::cerr << "SAC-ACOUSTIC-PCM-WRITE\n";
    return 1;
  }
  std::cout << "{\"status\":\"pass\",\"signal\":"
               "\"OBS-ACOUSTIC-EVENT-PRESENTED-001\","
            << "\"event_correlation_id\":" << event->event_correlation_id
            << ",\"script_step_id\":" << event->script_step_id
            << ",\"output_route_id\":\"gate2d-offline-pcm\","
            << "\"authoritative_arrival_timestamp_ns\":"
            << event->authoritative_arrival_timestamp_ns
            << ",\"scheduled_arrival_sample\":"
            << rendered->scheduled_arrival_sample
            << ",\"first_nonzero_sample\":" << rendered->first_nonzero_sample
            << ",\"first_nonzero_timestamp_ns\":"
            << rendered->first_nonzero_timestamp_ns
            << ",\"left_absolute_energy\":" << rendered->left_absolute_energy
            << ",\"right_absolute_energy\":" << rendered->right_absolute_energy
            << ",\"distance_attenuation_per_mille\":"
            << rendered->distance_attenuation_per_mille
            << ",\"direct_occlusion_per_mille\":"
            << rendered->direct_occlusion_per_mille
            << ",\"low_band_transmission_per_mille\":"
            << rendered->low_band_transmission_per_mille
            << ",\"left_peak_delay_us\":"
            << rendered->left_peak_delay_microseconds
            << ",\"right_peak_delay_us\":"
            << rendered->right_peak_delay_microseconds << ",\"pcm_fnv1a_64\":\""
            << std::hex << std::setw(16) << std::setfill('0')
            << rendered->pcm_fnv1a_64 << "\"}\n";
  return 0;
}
