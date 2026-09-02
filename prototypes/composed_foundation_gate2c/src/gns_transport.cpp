#include <steam/steamnetworkingsockets.h>

#include <array>
#include <cstring>
#include <limits>
#include <sacramento/gate2c/transport.hpp>
#include <stdexcept>
#include <string>
#include <utility>

namespace sacramento::gate2c {
namespace {

void InitializeTransport() {
  SteamNetworkingErrMsg error{};
  if (!GameNetworkingSockets_Init(nullptr, error))
    throw std::runtime_error(std::string("SAC-NET-TRANSPORT-INIT: ") + error);
}

void CheckPayloadSize(std::span<const std::uint8_t> payload) {
  if (payload.empty() ||
      payload.size() > std::numeric_limits<std::uint32_t>::max())
    throw std::runtime_error("SAC-NET-TRANSPORT-PAYLOAD-SIZE");
}

std::vector<std::uint8_t> CopyMessage(ISteamNetworkingMessage& message) {
  if (message.m_cbSize <= 0)
    throw std::runtime_error("SAC-NET-TRANSPORT-EMPTY-MESSAGE");
  std::vector<std::uint8_t> result(static_cast<std::size_t>(message.m_cbSize));
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunsafe-buffer-usage-in-libc-call"
  std::memcpy(result.data(), message.m_pData, result.size());
#pragma clang diagnostic pop
  return result;
}

}  // namespace

struct AuthorityTransport::Impl {
  explicit Impl(std::uint16_t requested_port) {
    if (active_ != nullptr)
      throw std::runtime_error("SAC-NET-TRANSPORT-AUTHORITY-SINGLETON");
    InitializeTransport();
    interface_ = SteamNetworkingSockets();
    active_ = this;

    SteamNetworkingIPAddr address{};
    address.Clear();
    address.m_port = requested_port;
    SteamNetworkingConfigValue_t callback{};
    callback.SetPtr(k_ESteamNetworkingConfig_Callback_ConnectionStatusChanged,
                    reinterpret_cast<void*>(StatusChanged));
    listen_ = interface_->CreateListenSocketIP(address, 1, &callback);
    poll_group_ = interface_->CreatePollGroup();
    if (listen_ == k_HSteamListenSocket_Invalid ||
        poll_group_ == k_HSteamNetPollGroup_Invalid)
      throw std::runtime_error("SAC-NET-TRANSPORT-LISTEN");

    SteamNetworkingIPAddr bound_address{};
    if (!interface_->GetListenSocketAddress(listen_, &bound_address))
      throw std::runtime_error("SAC-NET-TRANSPORT-ADDRESS");
    port_ = bound_address.m_port;
  }

  ~Impl() {
    for (const auto connection : connections_)
      interface_->CloseConnection(connection, 0, "gate complete", false);
    if (poll_group_ != k_HSteamNetPollGroup_Invalid)
      interface_->DestroyPollGroup(poll_group_);
    if (listen_ != k_HSteamListenSocket_Invalid)
      interface_->CloseListenSocket(listen_);
    active_ = nullptr;
    GameNetworkingSockets_Kill();
  }

  static void StatusChanged(SteamNetConnectionStatusChangedCallback_t* info) {
    if (active_ != nullptr) active_->OnStatusChanged(*info);
  }

  void OnStatusChanged(const SteamNetConnectionStatusChangedCallback_t& info) {
    switch (info.m_info.m_eState) {
      case k_ESteamNetworkingConnectionState_Connecting:
        if (interface_->AcceptConnection(info.m_hConn) != k_EResultOK ||
            !interface_->SetConnectionPollGroup(info.m_hConn, poll_group_)) {
          interface_->CloseConnection(info.m_hConn, 0, nullptr, false);
          return;
        }
        connections_.push_back(info.m_hConn);
        break;
      case k_ESteamNetworkingConnectionState_Connected:
        pending_.push_back(
            {TransportEventKind::kConnected, {info.m_hConn}, {}});
        break;
      case k_ESteamNetworkingConnectionState_ClosedByPeer:
      case k_ESteamNetworkingConnectionState_ProblemDetectedLocally:
        pending_.push_back(
            {TransportEventKind::kDisconnected, {info.m_hConn}, {}});
        interface_->CloseConnection(info.m_hConn, 0, nullptr, false);
        std::erase(connections_, info.m_hConn);
        break;
      default:
        break;
    }
  }

  std::vector<TransportEvent> Poll() {
    interface_->RunCallbacks();
    std::array<ISteamNetworkingMessage*, 16> messages{};
    for (;;) {
      const int count = interface_->ReceiveMessagesOnPollGroup(
          poll_group_, messages.data(), static_cast<int>(messages.size()));
      if (count < 0) throw std::runtime_error("SAC-NET-TRANSPORT-RECEIVE");
      if (count == 0) break;
      for (int index = 0; index < count; ++index) {
        auto* message = messages[static_cast<std::size_t>(index)];
        pending_.push_back({TransportEventKind::kPayload,
                            {message->m_conn},
                            CopyMessage(*message)});
        message->Release();
      }
    }
    return std::exchange(pending_, {});
  }

  void Send(PeerId peer, std::span<const std::uint8_t> payload) {
    CheckPayloadSize(payload);
    const auto result = interface_->SendMessageToConnection(
        peer.value, payload.data(), static_cast<std::uint32_t>(payload.size()),
        k_nSteamNetworkingSend_Reliable, nullptr);
    if (result != k_EResultOK)
      throw std::runtime_error("SAC-NET-TRANSPORT-SEND");
  }

  static inline Impl* active_ = nullptr;
  ISteamNetworkingSockets* interface_ = nullptr;
  HSteamListenSocket listen_ = k_HSteamListenSocket_Invalid;
  HSteamNetPollGroup poll_group_ = k_HSteamNetPollGroup_Invalid;
  std::uint16_t port_ = 0;
  std::vector<HSteamNetConnection> connections_;
  std::vector<TransportEvent> pending_;
};

struct ClientTransport::Impl {
  Impl(std::string_view host, std::uint16_t port) {
    if (active_ != nullptr)
      throw std::runtime_error("SAC-NET-TRANSPORT-CLIENT-SINGLETON");
    InitializeTransport();
    interface_ = SteamNetworkingSockets();
    active_ = this;

    SteamNetworkingIPAddr address{};
    address.Clear();
    if (host != "127.0.0.1") throw std::runtime_error("SAC-NET-TRANSPORT-HOST");
    address.SetIPv4(0x7f000001U, port);
    SteamNetworkingConfigValue_t callback{};
    callback.SetPtr(k_ESteamNetworkingConfig_Callback_ConnectionStatusChanged,
                    reinterpret_cast<void*>(StatusChanged));
    connection_ = interface_->ConnectByIPAddress(address, 1, &callback);
    if (connection_ == k_HSteamNetConnection_Invalid)
      throw std::runtime_error("SAC-NET-TRANSPORT-CONNECT");
  }

  ~Impl() {
    if (connection_ != k_HSteamNetConnection_Invalid)
      interface_->CloseConnection(connection_, 0, "gate complete", false);
    active_ = nullptr;
    GameNetworkingSockets_Kill();
  }

  static void StatusChanged(SteamNetConnectionStatusChangedCallback_t* info) {
    if (active_ != nullptr) active_->OnStatusChanged(*info);
  }

  void OnStatusChanged(const SteamNetConnectionStatusChangedCallback_t& info) {
    if (info.m_info.m_eState == k_ESteamNetworkingConnectionState_Connected) {
      pending_.push_back({TransportEventKind::kConnected, {info.m_hConn}, {}});
    } else if (info.m_info.m_eState ==
                   k_ESteamNetworkingConnectionState_ClosedByPeer ||
               info.m_info.m_eState ==
                   k_ESteamNetworkingConnectionState_ProblemDetectedLocally) {
      pending_.push_back(
          {TransportEventKind::kDisconnected, {info.m_hConn}, {}});
      interface_->CloseConnection(info.m_hConn, 0, nullptr, false);
      connection_ = k_HSteamNetConnection_Invalid;
    }
  }

  std::vector<TransportEvent> Poll() {
    interface_->RunCallbacks();
    std::array<ISteamNetworkingMessage*, 16> messages{};
    for (;;) {
      const int count = interface_->ReceiveMessagesOnConnection(
          connection_, messages.data(), static_cast<int>(messages.size()));
      if (count < 0) throw std::runtime_error("SAC-NET-TRANSPORT-RECEIVE");
      if (count == 0) break;
      for (int index = 0; index < count; ++index) {
        auto* message = messages[static_cast<std::size_t>(index)];
        pending_.push_back({TransportEventKind::kPayload,
                            {message->m_conn},
                            CopyMessage(*message)});
        message->Release();
      }
    }
    return std::exchange(pending_, {});
  }

  void Send(std::span<const std::uint8_t> payload) {
    CheckPayloadSize(payload);
    const auto result = interface_->SendMessageToConnection(
        connection_, payload.data(), static_cast<std::uint32_t>(payload.size()),
        k_nSteamNetworkingSend_Reliable, nullptr);
    if (result != k_EResultOK)
      throw std::runtime_error("SAC-NET-TRANSPORT-SEND");
  }

  static inline Impl* active_ = nullptr;
  ISteamNetworkingSockets* interface_ = nullptr;
  HSteamNetConnection connection_ = k_HSteamNetConnection_Invalid;
  std::vector<TransportEvent> pending_;
};

AuthorityTransport::AuthorityTransport(std::uint16_t port)
    : impl_(std::make_unique<Impl>(port)) {}

AuthorityTransport::~AuthorityTransport() = default;
AuthorityTransport::AuthorityTransport(AuthorityTransport&&) noexcept = default;
AuthorityTransport& AuthorityTransport::operator=(
    AuthorityTransport&&) noexcept = default;

std::uint16_t AuthorityTransport::port() const { return impl_->port_; }

std::vector<TransportEvent> AuthorityTransport::Poll() { return impl_->Poll(); }

void AuthorityTransport::Send(PeerId peer,
                              std::span<const std::uint8_t> payload) {
  impl_->Send(peer, payload);
}

ClientTransport::ClientTransport(std::string_view host, std::uint16_t port)
    : impl_(std::make_unique<Impl>(host, port)) {}

ClientTransport::~ClientTransport() = default;
ClientTransport::ClientTransport(ClientTransport&&) noexcept = default;
ClientTransport& ClientTransport::operator=(ClientTransport&&) noexcept =
    default;

std::vector<TransportEvent> ClientTransport::Poll() { return impl_->Poll(); }

void ClientTransport::Send(std::span<const std::uint8_t> payload) {
  impl_->Send(payload);
}

}  // namespace sacramento::gate2c
