#include <Falcor/Core/API/Device.h>
#include <Falcor/Core/Pass/ComputePass.h>

#include <exception>
#include <iostream>

int main()
{
    try
    {
        Falcor::Device::Desc desc;
        desc.type = Falcor::Device::Type::Vulkan;
        desc.enableAftermath = true;
        desc.enableDebugLayer = false;
        desc.shaderCachePath.clear();

        auto device = Falcor::make_ref<Falcor::Device>(desc);
        auto program = Falcor::ComputePass::create(device, "gate1c.slang", "main");
        if (!program || device->getType() != Falcor::Device::Type::Vulkan)
            return 2;

        const auto& info = device->getInfo();
        std::cout << "{\"status\":\"pass\",\"api\":\"" << info.apiName
                  << "\",\"adapter\":\"" << info.adapterName
                  << "\",\"slang_program\":\"gate1c.slang\",\"aftermath\":true}\n";
        return 0;
    }
    catch (const std::exception& error)
    {
        std::cerr << "{\"status\":\"fail\",\"error\":\"" << error.what() << "\"}\n";
        return 1;
    }
}
