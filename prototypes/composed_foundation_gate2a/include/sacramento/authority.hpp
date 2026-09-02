#pragma once

#include <cstdint>
#include <memory>
#include <string>
#include <string_view>

namespace sacramento::gate2a
{

inline constexpr std::string_view kScenarioFormat =
    "sacramento.authority-gate2a.v1";

struct BodyIdentity
{
    std::uint64_t value;
};

struct CanonicalTransform
{
    std::int64_t xMicrometres;
    std::int64_t yMicrometres;
    std::int64_t zMicrometres;
};

struct CanonicalVelocity
{
    std::int64_t xMicrometresPerSecond;
    std::int64_t yMicrometresPerSecond;
    std::int64_t zMicrometresPerSecond;
};

struct CanonicalContact
{
    bool groundObserved;
};

struct Scenario
{
    std::uint32_t ticks;
    std::uint32_t tickHz;
    BodyIdentity body;
    CanonicalTransform initialTransform;
    std::uint32_t radiusMicrometres;
    std::uint32_t densityKilogramsPerCubicMetre;
};

struct CanonicalSnapshot
{
    std::uint64_t tick;
    BodyIdentity body;
    CanonicalTransform transform;
    CanonicalVelocity velocity;
    CanonicalContact contact;
    std::uint64_t digest;
};

Scenario loadScenario(std::string_view path);
std::string formatSnapshot(const CanonicalSnapshot& snapshot);

class SessionAuthorityPrototype
{
  public:
    explicit SessionAuthorityPrototype(const Scenario& scenario);
    ~SessionAuthorityPrototype();

    SessionAuthorityPrototype(const SessionAuthorityPrototype&) = delete;
    SessionAuthorityPrototype& operator=(const SessionAuthorityPrototype&) =
        delete;
    SessionAuthorityPrototype(SessionAuthorityPrototype&&) noexcept;
    SessionAuthorityPrototype& operator=(SessionAuthorityPrototype&&) noexcept;

    void advance();
    [[nodiscard]] CanonicalSnapshot snapshot() const;

  private:
    struct Impl;
    std::unique_ptr<Impl> mImpl;
};

} // namespace sacramento::gate2a
