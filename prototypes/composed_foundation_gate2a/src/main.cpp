#include <sacramento/authority.hpp>

#include <exception>
#include <fstream>
#include <iostream>
#include <span>
#include <stdexcept>
#include <string>

namespace
{

std::string jsonSafe(std::string value)
{
    for (char& character : value)
    {
        if (character == '"' || character == '\\' || character == '\n' ||
            character == '\r')
            character = ' ';
    }
    return value;
}

} // namespace

int main(int argumentCount, char** arguments)
{
    if (argumentCount != 3)
    {
        std::cerr << "usage: sacramento_gate2a_authority SCENARIO TRACE\n";
        return 2;
    }

    try
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunsafe-buffer-usage-in-container"
        const std::span argumentValues(
            arguments, static_cast<std::size_t>(argumentCount));
#pragma clang diagnostic pop
        const auto scenario =
            sacramento::gate2a::loadScenario(argumentValues[1]);
        std::ofstream trace(argumentValues[2]);
        if (!trace)
            throw std::runtime_error("cannot create canonical trace");

        sacramento::gate2a::SessionAuthorityPrototype authority(scenario);
        for (std::uint32_t tick = 0; tick < scenario.ticks; ++tick)
        {
            authority.advance();
            trace << sacramento::gate2a::formatSnapshot(authority.snapshot())
                  << '\n';
        }
        trace.close();

        const auto finalState = authority.snapshot();
        if (!finalState.contact.groundObserved)
            throw std::runtime_error("representative ground contact not observed");
        if (finalState.tick != scenario.ticks)
            throw std::runtime_error("canonical tick count mismatch");

        std::cout << "{\"format\":\"sacramento.gate2a-result.v1\","
                     "\"status\":\"pass\",\"tick_hz\":"
                  << scenario.tickHz << ",\"final\":"
                  << sacramento::gate2a::formatSnapshot(finalState)
                  << "}\n";
        return 0;
    }
    catch (const std::exception& error)
    {
        std::cerr << "{\"format\":\"sacramento.gate2a-result.v1\","
                     "\"status\":\"fail\",\"error\":\""
                  << jsonSafe(error.what()) << "\"}\n";
        return 1;
    }
}
