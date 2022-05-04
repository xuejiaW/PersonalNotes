---
created: 2022-03-12
updated: 2022-03-14
tags:
    - Vulkan
---

# Introduction

在创建了 Physical Device（`VkPhysicalDevice`） 后需要建立一个 Logical Device （`VkDevice`）来与之交互。创建 Logical Device 的过程与创建 Instance 类似，都需要描述需要的 Features，另外需要指定要创建那些 Queue。

增加成员变量 `VkDevice device` 表示 Logical Device，并封装函数 `createLogicalDevice` 创建 Logical Device。该函数需要在选择了合适的 Physical Device 后使用：
```cpp
// .h
VkDevice device = nullptr;

// .cpp
void HelloTriangleApplication::initVulkan()
{
	createInstance();
	setupDebugMessenger();
	pickPhysicalDevice();
	CreateLogicalDevice();
}

void HelloTriangleApplication::CreateLogicalDevice()
{
    // ...	
}
```

# Specifying the queues to be created

创建 Logical Device 需要一系列包含细节信息的 Struct，首先是 `VkDeviceQueueCreateInfo`，该结构体描述了从一个 Queue Family 中获取 Queue 需要的信息，如指定目标 Queue Family 的 Index，创建的 Queue 的数量，Queue 的优先级（范围为 $0 \sim 1$）等。代码如下所示：
```cpp
float queuePriority = 1.0f;

QueueFamilyIndices indices = findQueueFamilies(physicalDevice);
VkDeviceQueueCreateInfo queueCreateInfo{};
queueCreateInfo.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
queueCreateInfo.queueFamilyIndex = indices.graphicsFamily.value();
queueCreateInfo.queueCount = 1;
queueCreateInfo.pQueuePriorities = &queuePriority;
```

# Specifying use device features

之后需要创建需要的 Device Feature，如再 [Physical devices and queue families](Ch%2006%20Physical%20devices%20and%20queue%20families.md) 中选择 Physical Device 时一样，可以通过 `vkGetPhysicalDeviceFeatures` 获取。

但目前暂时将指明 Feature 的 `VkPhysicalDeviceFeatures` 设定为空，后续真正使用时再修改：
```cpp
VkPhysicalDeviceFeatures deviceFeatures{};
```

# Creating the logical device

当创建了 `VkDeviceQueueCreateInfo` 和 `VkPhysicalDeviceFeatures` 后，就可以创建最终的 `vkDeviceCreateInfo` 结构体：
```cpp
VkDeviceCreateInfo createInfo{};
createInfo.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;
createInfo.pQueueCreateInfos = &queueCreateInfo;
createInfo.queueCreateInfoCount = 1;
createInfo.pEnabledFeatures = &deviceFeatures;

createInfo.enabledExtensionCount = 0;
createInfo.enabledLayerCount = enableValidationLayers ? static_cast<uint32_t>(validationLayers.size()) : 0;
createInfo.ppEnabledLayerNames = enableValidationLayers ? validationLayers.data() : nullptr;
```

其中如同创建 Instance 时一样，需要指定 Extensions 和 Validation
 Layers。但与创建 Instance 时不一样的是，这里的 Extensions 和 Validation Layers 是针对设备而言的。
- 如 `VK_KHR_swapchain` 就是一个设备相关的拓展，但在这一章中暂时不指定拓展，因此将 `enabledExtensionCount` 设为 0。
- 在早期的 Vulkan 实现中，对 Instance 和 Device 的 Validation Layers 做了较为明显的区分，但在现有的实现中已经没有了这种情况。因此理论上 `enabledLayerCount` 和 `ppEnabledExtensionNames` 字段可以被无视。但为了保证与老版本的兼容性，这里仍然填写。

此时可以通过 `vkCreateDevice` 函数创建 Logical Device。另外在 `cleanup` 函数中需要通过 `vkDestroyDeivce` 函数释放 logical device：
```cpp
// createLogicalDevice
if (vkCreateDevice(physicalDevice, &createInfo, nullptr, &device) != VK_SUCCESS)
{
	throw std::runtime_error("failed to create logical device!");
}

// cleanup
void HelloTriangleApplication::cleanup()
{
	vkDestroyDevice(device, nullptr);
	// ...
}
```

# Retrieving queue handles

Queue 在 Logical Device 创建时会被自动创建，但仍需要创建一个 Handle 作为与之交互的接口。

首先增加一个类型为 `VkQueue` 的成员变量：
```cpp
VkQueue graphicsQueue = nullptr;
```

`VkQueue` 在 Logical Device 被销毁时会隐式的被清理，因此不需要在 cleanup 中对其做任何处理。

获取 `VkQueue` 的函数如下所示：
```cpp
vkGetDeviceQueue(device, indices.graphicsFamily.value(), 0, &graphicsQueue);
```

其中：
- 第一个参数为 Logical Device
- 第二个参数为目标 Queue Family
- 第三个参数为需要获取的 Queue 的 Index，因为这里仅需要获取一个 Queue，因此为 0
- 第四个参数是存储获取到的 Queue 的地址。