#include <sacramento/authority.hpp>

#include <PxPhysicsAPI.h>
#include <flecs.h>

#include <cmath>
#include <fstream>
#include <iomanip>
#include <map>
#include <sstream>
#include <stdexcept>
#include <string>
#include <utility>

namespace sacramento::gate2a
{
namespace
{

constexpr double kMicrometresPerMetre = 1'000'000.0;
constexpr std::uint64_t kDigestOffset = 14695981039346656037ULL;
constexpr std::uint64_t kDigestPrime = 1099511628211ULL;

std::int64_t quantize(float value)
{
    return static_cast<std::int64_t>(
        std::llround(static_cast<double>(value) * kMicrometresPerMetre));
}

float metres(std::int64_t micrometres)
{
    return static_cast<float>(static_cast<double>(micrometres) /
                              kMicrometresPerMetre);
}

void hashByte(std::uint64_t& digest, std::uint8_t value)
{
    digest ^= value;
    digest *= kDigestPrime;
}

void hashUnsigned(std::uint64_t& digest, std::uint64_t value)
{
    for (unsigned int index = 0; index < 8U; ++index)
    {
        hashByte(digest, static_cast<std::uint8_t>(value & 0xffU));
        value >>= 8U;
    }
}

void hashSigned(std::uint64_t& digest, std::int64_t value)
{
    hashUnsigned(digest, static_cast<std::uint64_t>(value));
}

std::uint64_t parseUnsigned(const std::map<std::string, std::string>& values,
                            const std::string& key)
{
    const auto item = values.find(key);
    if (item == values.end())
        throw std::runtime_error("missing scenario key: " + key);
    std::size_t parsed = 0;
    const auto value = std::stoull(item->second, &parsed);
    if (parsed != item->second.size())
        throw std::runtime_error("invalid scenario value: " + key);
    return value;
}

std::int64_t parseSigned(const std::map<std::string, std::string>& values,
                         const std::string& key)
{
    const auto item = values.find(key);
    if (item == values.end())
        throw std::runtime_error("missing scenario key: " + key);
    std::size_t parsed = 0;
    const auto value = std::stoll(item->second, &parsed);
    if (parsed != item->second.size())
        throw std::runtime_error("invalid scenario value: " + key);
    return value;
}

} // namespace

struct SessionAuthorityPrototype::Impl
{
    explicit Impl(const Scenario& scenarioValue)
        : scenario(scenarioValue),
          foundation(PxCreateFoundation(PX_PHYSICS_VERSION, allocator,
                                        errors)),
          physics(foundation == nullptr
                      ? nullptr
                      : PxCreatePhysics(PX_PHYSICS_VERSION, *foundation,
                                        physx::PxTolerancesScale(), false,
                                        nullptr)),
          dispatcher(physx::PxDefaultCpuDispatcherCreate(0))
    {
        if (foundation == nullptr || physics == nullptr || dispatcher == nullptr)
            throw std::runtime_error("failed to initialize PhysX core");

        physx::PxSceneDesc sceneDescription(physics->getTolerancesScale());
        sceneDescription.gravity = physx::PxVec3(0.0F, -9.81F, 0.0F);
        sceneDescription.cpuDispatcher = dispatcher;
        sceneDescription.filterShader = physx::PxDefaultSimulationFilterShader;
        sceneDescription.solverType = physx::PxSolverType::eTGS;
        sceneDescription.flags |= physx::PxSceneFlag::eENABLE_ENHANCED_DETERMINISM;
        scene = physics->createScene(sceneDescription);
        material = physics->createMaterial(0.5F, 0.5F, 0.1F);
        if (scene == nullptr || material == nullptr)
            throw std::runtime_error("failed to initialize PhysX scene");

        ground = physx::PxCreatePlane(
            *physics, physx::PxPlane(0.0F, 1.0F, 0.0F, 0.0F), *material);
        const auto pose = physx::PxTransform(
            physx::PxVec3(metres(scenario.initialTransform.xMicrometres),
                          metres(scenario.initialTransform.yMicrometres),
                          metres(scenario.initialTransform.zMicrometres)));
        const auto geometry = physx::PxSphereGeometry(
            metres(static_cast<std::int64_t>(scenario.radiusMicrometres)));
        body = physx::PxCreateDynamic(
            *physics, pose, geometry, *material,
            static_cast<float>(scenario.densityKilogramsPerCubicMetre));
        if (ground == nullptr || body == nullptr)
            throw std::runtime_error("failed to create PhysX actors");
        scene->addActor(*ground);
        scene->addActor(*body);

        ecs.component<BodyIdentity>();
        ecs.component<CanonicalTransform>();
        ecs.component<CanonicalVelocity>();
        ecs.component<CanonicalContact>();
        entity = ecs.entity("authoritative-body")
                     .set<BodyIdentity>(scenario.body)
                     .set<CanonicalTransform>(scenario.initialTransform)
                     .set<CanonicalVelocity>({0, 0, 0})
                     .set<CanonicalContact>({false});

        for (const char character : kScenarioFormat)
            hashByte(digest, static_cast<std::uint8_t>(character));
    }

    ~Impl()
    {
        if (body != nullptr)
            body->release();
        if (ground != nullptr)
            ground->release();
        if (scene != nullptr)
            scene->release();
        if (material != nullptr)
            material->release();
        if (dispatcher != nullptr)
            dispatcher->release();
        if (physics != nullptr)
            physics->release();
        if (foundation != nullptr)
            foundation->release();
    }

    Scenario scenario;
    physx::PxDefaultAllocator allocator;
    physx::PxDefaultErrorCallback errors;
    physx::PxFoundation* foundation = nullptr;
    physx::PxPhysics* physics = nullptr;
    physx::PxDefaultCpuDispatcher* dispatcher = nullptr;
    physx::PxScene* scene = nullptr;
    physx::PxMaterial* material = nullptr;
    physx::PxRigidStatic* ground = nullptr;
    physx::PxRigidDynamic* body = nullptr;
    flecs::world ecs;
    flecs::entity entity;
    std::uint64_t tick = 0;
    std::uint64_t digest = kDigestOffset;
    bool contactObserved = false;
};

Scenario loadScenario(std::string_view path)
{
    std::ifstream input{std::string(path)};
    if (!input)
        throw std::runtime_error("cannot open scenario");

    std::map<std::string, std::string> values;
    for (std::string line; std::getline(input, line);)
    {
        if (line.empty())
            continue;
        const auto separator = line.find('=');
        if (separator == std::string::npos)
            throw std::runtime_error("invalid scenario line");
        values.emplace(line.substr(0, separator), line.substr(separator + 1));
    }
    const auto format = values.find("format");
    if (format == values.end() || format->second != kScenarioFormat)
        throw std::runtime_error("unsupported scenario format");

    Scenario result{};
    result.ticks = static_cast<std::uint32_t>(parseUnsigned(values, "ticks"));
    result.tickHz = static_cast<std::uint32_t>(parseUnsigned(values, "tick_hz"));
    result.body.value = parseUnsigned(values, "body_id");
    result.initialTransform = {
        parseSigned(values, "initial_x_um"),
        parseSigned(values, "initial_y_um"),
        parseSigned(values, "initial_z_um"),
    };
    result.radiusMicrometres =
        static_cast<std::uint32_t>(parseUnsigned(values, "radius_um"));
    result.densityKilogramsPerCubicMetre =
        static_cast<std::uint32_t>(parseUnsigned(values, "density_kg_m3"));
    if (result.ticks == 0U || result.tickHz == 0U ||
        result.radiusMicrometres == 0U ||
        result.densityKilogramsPerCubicMetre == 0U)
        throw std::runtime_error("scenario values must be positive");
    return result;
}

SessionAuthorityPrototype::SessionAuthorityPrototype(const Scenario& scenario)
    : mImpl(std::make_unique<Impl>(scenario))
{
}

SessionAuthorityPrototype::~SessionAuthorityPrototype() = default;
SessionAuthorityPrototype::SessionAuthorityPrototype(
    SessionAuthorityPrototype&&) noexcept = default;
SessionAuthorityPrototype& SessionAuthorityPrototype::operator=(
    SessionAuthorityPrototype&&) noexcept = default;

void SessionAuthorityPrototype::advance()
{
    const auto step = 1.0F / static_cast<float>(mImpl->scenario.tickHz);
    mImpl->scene->simulate(step);
    if (!mImpl->scene->fetchResults(true))
        throw std::runtime_error("PhysX did not finish the fixed tick");
    ++mImpl->tick;

    const auto pose = mImpl->body->getGlobalPose();
    const auto linearVelocity = mImpl->body->getLinearVelocity();
    const CanonicalTransform transform{
        quantize(pose.p.x), quantize(pose.p.y), quantize(pose.p.z)};
    const CanonicalVelocity velocity{
        quantize(linearVelocity.x), quantize(linearVelocity.y),
        quantize(linearVelocity.z)};
    const auto contactThreshold =
        static_cast<std::int64_t>(mImpl->scenario.radiusMicrometres) + 10'000;
    mImpl->contactObserved =
        mImpl->contactObserved || transform.yMicrometres <= contactThreshold;

    mImpl->entity.set<CanonicalTransform>(transform)
        .set<CanonicalVelocity>(velocity)
        .set<CanonicalContact>({mImpl->contactObserved});

    hashUnsigned(mImpl->digest, mImpl->tick);
    hashUnsigned(mImpl->digest, mImpl->scenario.body.value);
    hashSigned(mImpl->digest, transform.xMicrometres);
    hashSigned(mImpl->digest, transform.yMicrometres);
    hashSigned(mImpl->digest, transform.zMicrometres);
    hashSigned(mImpl->digest, velocity.xMicrometresPerSecond);
    hashSigned(mImpl->digest, velocity.yMicrometresPerSecond);
    hashSigned(mImpl->digest, velocity.zMicrometresPerSecond);
    hashByte(mImpl->digest,
             static_cast<std::uint8_t>(mImpl->contactObserved ? 1U : 0U));
}

CanonicalSnapshot SessionAuthorityPrototype::snapshot() const
{
    const auto* identity = mImpl->entity.try_get<BodyIdentity>();
    const auto* transform = mImpl->entity.try_get<CanonicalTransform>();
    const auto* velocity = mImpl->entity.try_get<CanonicalVelocity>();
    const auto* contact = mImpl->entity.try_get<CanonicalContact>();
    if (identity == nullptr || transform == nullptr || velocity == nullptr ||
        contact == nullptr)
        throw std::runtime_error("Flecs canonical components are incomplete");
    return {mImpl->tick, *identity, *transform, *velocity, *contact,
            mImpl->digest};
}

std::string formatSnapshot(const CanonicalSnapshot& snapshot)
{
    std::ostringstream output;
    output << "{\"tick\":" << snapshot.tick << ",\"body_id\":"
           << snapshot.body.value << ",\"position_um\":["
           << snapshot.transform.xMicrometres << ','
           << snapshot.transform.yMicrometres << ','
           << snapshot.transform.zMicrometres << "],\"velocity_um_s\":["
           << snapshot.velocity.xMicrometresPerSecond << ','
           << snapshot.velocity.yMicrometresPerSecond << ','
           << snapshot.velocity.zMicrometresPerSecond
           << "],\"ground_contact\":"
           << (snapshot.contact.groundObserved ? "true" : "false")
           << ",\"digest\":\"" << std::hex << std::setw(16)
           << std::setfill('0') << snapshot.digest << "\"}";
    return output.str();
}

} // namespace sacramento::gate2a
