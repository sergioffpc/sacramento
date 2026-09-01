#include <vulkan/vulkan_core.h>

#include <cstdio>

#if defined(_WIN32) && defined(VK_USE_PLATFORM_XLIB_KHR)
#error "The Windows probe must not enable a Linux Vulkan platform"
#endif

#if defined(D3D12_SDK_VERSION) || defined(__d3d12_h__)
#error "The Vulkan-only probe must not include the DirectX 12 SDK"
#endif

#ifndef SACRAMENTO_GATE1_SHADER_SHA256
#error "The identified SPIR-V digest is required"
#endif

int main() {
  const VkApplicationInfo application_info{
      .sType = VK_STRUCTURE_TYPE_APPLICATION_INFO,
      .pNext = nullptr,
      .pApplicationName = "Sacramento Gate 1",
      .applicationVersion = 1,
      .pEngineName = "Sacramento prototype",
      .engineVersion = 1,
      .apiVersion = VK_API_VERSION_1_3,
  };

  std::printf("vulkan_api=%u shader_sha256=%s\n", application_info.apiVersion,
              SACRAMENTO_GATE1_SHADER_SHA256);
  return 0;
}
