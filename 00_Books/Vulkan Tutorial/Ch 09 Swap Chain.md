---
created: 2022-03-12
updated: 2022-03-14
tags:
    - Vulkan
---

在 Vulkan 中必须显式的创建 [Swap Chain](../../01_Notes/Computer%20Graphics/Swap%20Chain.md)。关于 Swap Chain 中的 queue 如何工作，以及何时将 queue 中的 Image present 到屏幕上，都可以在创建 Swap Chain 时配置。但绝大部分情况下，Swap Chian 的 Present Image 频率都是和屏幕的刷新率一致的。

# Checking for swap chain support

并不是所有的显卡都支持将 Image 表现到屏幕上，如这个显卡是设计为 Server 使用，并不包含有任何的 Display 输出。

另外因为 Image 的 Presentation 与平台的 Window System 强相关，所以 Swap Chain 并非是 Vulkan Core 的部分。要使用 SwapChain，必须启用 Device Extension `VK_KHR_swapchain`。

```ad-note
在 Vulkan 的头文件中，定义了 Macro `VK_KHR_SWAPCHAIN_EXTENSION_NAME` 用来表示 `VK_KHR_swapchain`。
```

首先如同在[Ch 05 Validation Layers](Ch%2005%20Validation%20Layers.md) 中定义 [checkValidationLayerSupport](Ch%2005%20Validation%20Layers.md#^6ee230) 一样，这里需要增加函数 `checkDeviceExtensionSupport` 检查 Device Extension `Vk_KHR_swapchain` 是否存在：
```cpp
bool HelloTriangleApplication::checkDeviceExtensionsSupport(VkPhysicalDevice device)
{
	uint32_t extensionCount = 0;
	vkEnumerateDeviceExtensionProperties(device, nullptr, &extensionCount, nullptr);
	std::vector<VkExtensionProperties> availableExtensions(extensionCount);
	vkEnumerateDeviceExtensionProperties(device, nullptr, &extensionCount, availableExtensions.data());

	std::set<std::string> requiredExtensions(deviceExtensions.begin(), deviceExtensions.end());
	for (const auto& extension : availableExtensions)
	{
		requiredExtensions.erase(extension.extensionName);
	}

	return requiredExtensions.empty();
}
```

其中 `deviceExtensions` 定义如下：
```cpp
const std::vector<const char*> deviceExtensions = { VK_KHR_SWAPCHAIN_EXTENSION_NAME };
```

在 `isDeviceSuitable` 函数中需要增加对 Device Extension 支持性的访问：
```cpp
bool HelloTriangleApplication::isDeviceSuitable(VkPhysicalDevice device)
{
    // ...
	bool extensionsSupported = checkDeviceExtensionsSupport(device);

	return deviceSuitable && queueFamilySuitable && extensionsSupported;
}
```

# Enabling device extensions

在创建 Logical Device 时需要指明 Extensions 的数目和类型：
```cpp
createInfo.enabledExtensionCount = static_cast<uint32_t>(deviceExtensions.size());
createInfo.ppEnabledExtensionNames = deviceExtensions.data();
```

# Querying detail of swap chain support

仅仅检查设备是否包含 SwapChain 的 Extension 还不够，这里还需要进一步的检查，因为获取到的 Swap chain 可能与 window 的 surface 不兼容，另外创建 Swap chain 也需要比 instance 和 device 创建时更多的配置。

因此这里需要查询更多关于 swap chain 的信息，基本由三种信息需要检查：
- 基本的 Surface 兼容性：如 images 的最小，最大数量，Image 的最小最大宽度和高度
- Surface 的格式：如像素格式，Color Space
- 可选的 Presentation 模式

首先定义一个结构体存储上述需要的所有信息：
```cpp
struct SwapChainSupportDetails
{
	VkSurfaceCapabilitiesKHR capabilities;
	std::vector<VkSurfaceFormatKHR> formats;
	std::vector<VkPresentModeKHR> presentMode;
};
```

定义函数 `querySwapChainSupport` 生成上述结构体：
```cpp
SwapChainSupportDetails HelloTriangleApplication::querySwapChainSupport(VkPhysicalDevice device)
{
	SwapChainSupportDetails details;

	// Surface capabilities
	vkGetPhysicalDeviceSurfaceCapabilitiesKHR(device, surface, &details.capabilities);

	// Surface formats
	uint32_t formatCount;
	vkGetPhysicalDeviceSurfaceFormatsKHR(device, surface, &formatCount, nullptr);
	if (formatCount != 0)
	{
		details.formats.resize(formatCount);
		vkGetPhysicalDeviceSurfaceFormatsKHR(device, surface, &formatCount, details.formats.data());
	}

	// Surface present mode
	uint32_t presentModeCount;
	vkGetPhysicalDeviceSurfacePresentModesKHR(device, surface, &presentModeCount, nullptr);
	if (presentModeCount != 0)
	{
		details.presentMode.resize(presentModeCount);
		vkGetPhysicalDeviceSurfacePresentModesKHR(device, surface, &presentModeCount, details.presentMode.data());
	}

	return details;
}
```

此时修改函数 `isDeviceSuitable`，在支持的 Image Format 和 Presentation Mode 都不为空时才认为设备合适：
```cpp
bool HelloTriangleApplication::isDeviceSuitable(VkPhysicalDevice device)
{
    // ...

	bool swapChainAdequate = false;
	if (extensionsSupported)
	{
		SwapChainSupportDetails swapChainSupport = querySwapChainSupport(device);
		swapChainAdequate = !swapChainSupport.formats.empty() && !swapChainSupport.presentMode.empty();
	}

	return deviceSuitable && queueFamilySuitable && extensionsSupported && swapChainAdequate;
}
```

# Choosing the right settings for the swap chain

在确认 Swap Chain 可以获取后，还需要一个函数为 SwapChain 选择最合适的设置，不同的性能设置可能带来不同的性能。Swap chain 主要有三种类型数据需要设置：
- Surface Format：如颜色 / 深度缓冲
- Presentation Mode：如交换 Image 到屏幕上的条件
- Swap Extent：Swap Chain 图片的分辨率

对于上述每一种数据类型，都会尝试找寻最合适的值，如果该值无法获取即寻找次优的值。

## Surface format

定义函数 `chooseSwapSurfaceFormat` 找寻最合适的 Surface format：
```cpp
VkSurfaceFormatKHR HelloTriangleApplication::chooseSwapSurfaceFormat(const std::vector<VkSurfaceFormatKHR>& availableFormats)
{
	for (const auto& availableFormat : availableFormats)
	{
		if (availableFormat.format == VK_FORMAT_B8G8R8A8_SRGB && availableFormat.colorSpace == VK_COLOR_SPACE_SRGB_NONLINEAR_KHR)
			return availableFormat;
	}

	return availableFormats[0];
}
```

## Presentation mode

在 Vulkan 中一共有如下四种可能的 Present 模式：
- `VK_PRESENT_MODE_IMMEDIATE_KHR`：当应用提交了一个画面后，马上将画面显示到屏幕上。该模式可能造成画面撕裂。
- `VK_PRESENT_MODE_FIFO_KHR`：当设备的  VSync 到来后，从 queue 中获取一个画面显式到屏幕上。当应用提交画面时，放置到 queue 的末尾。如果应用提交画面时，发现 queue 已满，则会阻塞应用。如果 VSync 到来但是 Queue 为空时，则会等待下一个 VSync 重新尝试获取。
- `Vk_PRESENT_MODE_FIFI_RELAXED_KHR`：与 `VK_PRESENT_MODE_FIFO_KHR` 类似，只不过在 VSync 到来但 Queue 为空后，不会再次等到设备 VSync 时做第二次查询，而是当新的图像一到来就刷新到屏幕上
- `VK_PRESENT_MODE_MAILBOX_KHR`：与 `VK_PRESENT_MODE_FIFO_KHR` 类似，只不过当应用提交画面且 Queue 已满时，不再阻塞应用提交画面，而是会用新画面取代 Queue 中最老的画面。

在设备支持 Swap Chain 后，`VK_PRESENT_MODE_FIFO_KHR`  模式可保证必然支持。但这里选择使用 `VK_PRESENT_MODE_MAILBOX_KHR` 模式，避免应用意外的阻塞，仅当 `VK_PRESENT_MODE_MAILBOX_KHR` 不存在时再使用 `VK_PRESENT_MODE_FIFO_KHR`。

封装函数 `chooseSwapPresentMode` 选择最合适的 Present Mode：
```cpp
VkPresentModeKHR HelloTriangleApplication::chooseSwapPresentMode(const std::vector<VkPresentModeKHR>& availablePresentMode)
{
	for (const auto& availablePresentMode : availablePresentMode)
	{
		if (availablePresentMode == VK_PRESENT_MODE_MAILBOX_KHR)
			return availablePresentMode;
	}
	return VK_PRESENT_MODE_FIFO_KHR;
}
```

## Swap extent

最后一个需要设置的属性是 Swap Extent，该属性表示 Swap Chain Image 的分辨率，Swap Extent 的上下限再 `VkSurfaceCapabilitiesKHR` 结构体中定义。

Swap Extent 分辨率几乎一直和屏幕的分辨率相同，如果平台的 Window Managers 允许开发者定义与屏幕不相同的分辨率，那么会将 `VkSurfaceCapabilitiesHKR.current` 的宽高都设定为 `UINT32_MAX`，反之 `VkSurfaceCapabilitiesHKR.current` 即为即为屏幕分辨率。

定义函数 `chooseSwapExtent` 在允许的情况下，将 Swap Extent 设定为之前窗口的宽高：
```cpp
VkExtent2D HelloTriangleApplication::chooseSwapExtent(const VkSurfaceCapabilitiesKHR& capabilities)
{
	if (capabilities.currentExtent.width != UINT32_MAX)
	{
		return capabilities.currentExtent;
	}
	else
	{
		VkExtent2D actualExtent = { WIDTH,HEIGHT };
		actualExtent.width = std::max(capabilities.minImageExtent.width, std::min(capabilities.maxImageExtent.width, actualExtent.width));
		actualExtent.height = std::max(capabilities.minImageExtent.height, std::min(capabilities.maxImageExtent.height, actualExtent.height));
		return actualExtent;
	}
}
```

# Creating the swap chain

