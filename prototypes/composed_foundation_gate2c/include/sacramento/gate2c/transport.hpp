#ifndef SACRAMENTO_PROTOTYPES_COMPOSED_FOUNDATION_GATE2C_INCLUDE_SACRAMENTO_GATE2C_TRANSPORT_HPP_
#define SACRAMENTO_PROTOTYPES_COMPOSED_FOUNDATION_GATE2C_INCLUDE_SACRAMENTO_GATE2C_TRANSPORT_HPP_

#include <compare>
#include <cstdint>
#include <memory>
#include <span>
#include <string_view>
#include <vector>

namespace sacramento::gate2c {

struct PeerId {
  std::uint32_t value;

  auto operator<=>(const PeerId&) const = default;
};

enum class TransportEventKind {
  kConnected,
  kDisconnected,
  kPayload,
};

struct TransportEvent {
  TransportEventKind kind;
  PeerId peer;
  std::vector<std::uint8_t> payload;
};

class AuthorityTransport {
 public:
  explicit AuthorityTransport(std::uint16_t port);
  ~AuthorityTransport();

  AuthorityTransport(const AuthorityTransport&) = delete;
  AuthorityTransport& operator=(const AuthorityTransport&) = delete;
  AuthorityTransport(AuthorityTransport&&) noexcept;
  AuthorityTransport& operator=(AuthorityTransport&&) noexcept;

  [[nodiscard]] std::uint16_t port() const;
  std::vector<TransportEvent> Poll();
  void Send(PeerId peer, std::span<const std::uint8_t> payload);

 private:
  struct Impl;
  std::unique_ptr<Impl> impl_;
};

class ClientTransport {
 public:
  ClientTransport(std::string_view host, std::uint16_t port);
  ~ClientTransport();

  ClientTransport(const ClientTransport&) = delete;
  ClientTransport& operator=(const ClientTransport&) = delete;
  ClientTransport(ClientTransport&&) noexcept;
  ClientTransport& operator=(ClientTransport&&) noexcept;

  std::vector<TransportEvent> Poll();
  void Send(std::span<const std::uint8_t> payload);

 private:
  struct Impl;
  std::unique_ptr<Impl> impl_;
};

}  // namespace sacramento::gate2c

#endif
