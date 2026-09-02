#include <cstdint>
#include <iostream>
#include <sacramento/gate2c/protocol.hpp>
#include <stdexcept>
#include <string>
#include <vector>

int main() {
  using sacramento::gate2c::ClientRole;
  using sacramento::gate2c::DecodeMessage;
  using sacramento::gate2c::EncodeMessage;
  using sacramento::gate2c::Hello;

  const std::vector<std::uint8_t> expected{
      0x32U, 0x43U, 0x41U, 0x53U, 0x01U, 0x00U, 0x01U, 0x00U, 0x05U,
      0x00U, 0x00U, 0x00U, 0x07U, 0x00U, 0x00U, 0x00U, 0x01U};
  auto encoded = EncodeMessage(Hello{7U, ClientRole::kRendered});
  if (encoded != expected) throw std::runtime_error("SAC-NET-PROBE-WIRE-BYTES");

  std::string error;
  const auto decoded = DecodeMessage(encoded, error);
  const auto* hello = decoded ? std::get_if<Hello>(&*decoded) : nullptr;
  if (hello == nullptr || hello->client_id != 7U ||
      hello->role != ClientRole::kRendered)
    throw std::runtime_error("SAC-NET-PROBE-ROUNDTRIP");

  encoded[4] = 2U;
  if (DecodeMessage(encoded, error) || error != "SAC-NET-PROTOCOL-VERSION")
    throw std::runtime_error("SAC-NET-PROBE-VERSION-REJECTION");
  encoded[4] = 1U;
  encoded.pop_back();
  if (DecodeMessage(encoded, error) || error != "SAC-NET-PROTOCOL-LENGTH")
    throw std::runtime_error("SAC-NET-PROBE-LENGTH-REJECTION");

  std::cout << "{\"status\":\"pass\",\"wire_version\":1,"
               "\"hello_bytes\":17,\"unknown_version\":\"rejected\"}\n";
}
