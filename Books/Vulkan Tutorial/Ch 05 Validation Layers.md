---
tags:
    - Vulkan
created: 2022-03-06
updated: 2022-03-07
---

在程序变得更加复杂之前，需要了解 Validation layers 帮助调试。

# What are validation layers

因为 Vulkan API 的设计理念是最小化驱动的负载，因此在 API 层只有非常少的错误检测。

为此 Vulkan 引入了 `Validation Layers` 系统进行错误检测，`Validation Layers` 会 Hook 进 Vulkan 的函数调用并进行系一系列额外的操作。这些操作通常有：
1. 检测函数的形参是否符合标准，是否有错误使用
2. 追踪资源的创建和销毁，检测是否有资源的泄露
3. 检测线程的安全性
4. 输出每一个函数调用和它的形参
5. 追踪 Vulkan 的函数调用，进行 Profiling 和 replaying。

```ad-note
可以仅在 Debug builds 情况下打开 Validation Layers，并在 Release builds 时关闭
```

```ad-note
Vulkan 本身并没有提供任何的 Validation Layers，但 LumarG Vulkan SDK 则提供了一系列 Layers 用来进行常见的错误检查。
```

# Using validation layers

所有有用的标准 Layers 都被封装进 SDK 中一个名为 `VK_LAYER_KHRONOS_validation` 的 layer 里。可以选择仅在 debug 情况下打开检测：
```cpp
const uint32_t WIDTH = 800;
const uint32_t HEIGHT = 600;

const std::vector<const char*> validationLayers = { "VK_LAYER_KHRONOS_validation" };

#ifdef NDEBUG
const bool enableValidationLayers = false;
#else
const bool enableValidationLayers = true;
#endif
```

可以通过函数 `vkEnumerateInstanceLayerProperties` 检测可用的 Validation Layers，该函数的用法与 `vkEnumerateInstanceExtensionProperties` 类似。

整个检测函数如下所示，其首先通过 `vkEnumerateInstanceLayerProperties` 找到所有可用的 Layers，并检测 `availableLayers` 中是否有需要的  `VK_LAYER_KHRONOS_validation`：
```cpp
bool HelloTriangleApplication::checkValidationLayerSupport()
{
	uint32_t layerCount = 0;
	vkEnumerateInstanceLayerProperties(&layerCount, nullptr);

	std::vector<VkLayerProperties> availableLayers(layerCount);
	vkEnumerateInstanceLayerProperties(&layerCount, availableLayers.data());

	bool layerFound = false;
	const char* layerName = validationLayers[0];

	for (const auto& layerProperty : availableLayers)
	{
		if (strcmp(layerName, layerProperty.layerName) == 0)
		{
			layerFound = true;
			break;
		}
	}

	if (!layerFound)
		return false;

	return true;
}
```

此时修改 `createInstance` 函数如下所示：
```cpp
void HelloTriangleApplication::createInstance()
{
	if (enableValidationLayers && !checkValidationLayerSupport())
	{
		throw std::runtime_error("Validation layers requested, but not available!");
	}
    // ...

    VkInstanceCreateInfo createInfo{};
    // ....

	if (enableValidationLayers)
	{
		createInfo.enabledLayerCount = static_cast<uint32_t>(validationLayers.size());
		createInfo.ppEnabledLayerNames = validationLayers.data();
	}
	else
	{
		createInfo.enabledLayerCount = 0;
	}
    // ...
}
```
