---
created: 2022-03-12
updated: 2022-03-14
tags:
    - Vulkan
---

因为 Vulkan 是一个平台不相关的 API，所以它无法直接与 Window System 交互。为了建立 Vulkan 和 Window System 之间的连接，就需要使用 `WSI（Window System Integration）` 拓展。

在这一章会首先讨论 `VK_KHR_surafce`，它定义了 `VkSurfaceKHR` 对象标识用于作为画面的 Surface  的抽象。

```ad-note
`VK_KHR_surface`是一个 instance 层面的拓展，在创建 Instance 前就已经通过函数 `glfwGetRequiredInstanceExtensions` 获取到
```

Window surface 可以通过 GLFW 获取，它应该在创建了 Instance 后马上被创建，因为它实际上会影响 Physical device 的选择。

```ad-tip
Window surface 在 Vulkan 中实际上是可选的，如果应用纯粹是作为离屏渲染使用，就不再需要创建 Window surface。

但在 OpenGL 中 surface 必须被创建，因此纯粹离屏的应用还需要进行创建不可见的 window 这样的 Hack。
```

# Window surface creation

首先定义一个类型为 `VkSurfaceKHR` 的类成员 surface：
```cpp
VkSurfaceKHR surface = nullptr;
```

同时增加一个函数 `createSurface` 创建 surface，该函数需要在 `createInstance` 后调用。同时在删除 Instance 前通过 `vkDestroySurfaceKHR`  函数杉树 Surface：
```cpp
void HelloTriangleApplication::initVulkan()
{
	createInstance();
	setupDebugMessenger();
	createSurface();
    // ...
}

void HelloTriangleApplication::cleanup()
{
    // ...

	vkDestroySurfaceKHR(instance, surface, nullptr);
	vkDestroyInstance(instance, nullptr);
    // ...
}

void HelloTriangleApplication::createSurface()
{
	if (glfwCreateWindowSurface(instance, window, nullptr, &surface) != VK_SUCCESS)
	{
		throw std::runtime_error("failed to create window surface!");
	}
}
```

```ad-note
`glfwCreateWindowSurface` 函数封装了在个平台创建 Surface 的过程。在 Windows 平台下该函数即封装了为 Windows 提供的 `vkCreateWin32SurfaceKHR`。
```

# Querying for presentation support

并非所有的硬件设备都支持将 Image 表现到创建的上述 Surface 上，因此在这里还需要检测设备的 Presentation 支持。因为 Presentation 实际上是一个需要放置在 Queue 中的指令，因此我们需要查询是否有支持 Presenting 的 Queue family。如下在 `QueueFamilyIndices` 结构体中新增 `presentFamily`：
```cpp
struct QueueFamilyIndices
{
	std::optional<uint32_t> graphicsFamily;
	std::optional<uint32_t> presentFamily;

	bool isComplete() const
	{
		return graphicsFamily.has_value() && presentFamily.has_value();
	}
};
```

之后需要修改 `findQueueFamilies` 函数，因为 Surface 是拓展，所以无法直接从 `VkQueueFamilyProperties` 的 `queueFlags` 判断。这里需要使用函数 `vkGetPhysicalDeviceSurfaceSupportKHR` 查询：
```cpp
QueueFamilyIndices HelloTriangleApplication::findQueueFamilies(VkPhysicalDevice device)
{
    // ...
   	for (const auto& queueFamily : queueFamilies)
	{
		if (queueFamily.queueFlags & VK_QUEUE_GRAPHICS_BIT)
		{
			indices.graphicsFamily = i;
		}

		VkBool32 presentSupport = false;
		vkGetPhysicalDeviceSurfaceSupportKHR(device, i, surface, &presentSupport);

		if (presentSupport)
			indices.presentFamily = i;

		if (indices.isComplete())
			break;

		i++;
	}
    // ... 
}
```

```ad-note
虽然用了两个变量分别标识 graphics 和 present 的 Queue Family，但很可能这两个变量是一样的值。
```

# Creating the presentation queue

增加类成员函数 `presentQueue` 表示 present 的 Queue，同时修改 `createLogicalDevice` 函数，此时该函数中需要同时创建 graphics 和 present 两个 queue。

数据结构 `set` 来存储两个 queue 对应的 queue families，如果两个 queue families 相同，则该数据结构中实际上只有一个元素。使用数据结构 `vector` 存储创建两个 queue 需要用到的 createInfo，因为即使两个 queue families 的 index 相同，创建两个 queue 所需要用到的 create info 仍然不同。修改后的 `createLogicalDevice` 如下：
```cpp
void HelloTriangleApplication::createLogicalDevice()
{
	QueueFamilyIndices indices = findQueueFamilies(physicalDevice);

	std::vector<VkDeviceQueueCreateInfo> queueCreateInfos{};
	std::set<uint32_t> uniqueQueueFamilies = { indices.graphicsFamily.value(),indices.presentFamily.value() };
	float queuePriority = 1.0f;
	for (uint32_t queueFamily : uniqueQueueFamilies)
	{
		VkDeviceQueueCreateInfo  queueCreateInfo{};
		queueCreateInfo.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
		queueCreateInfo.queueFamilyIndex = queueFamily;
		queueCreateInfo.queueCount = 1;
		queueCreateInfo.pQueuePriorities = &queuePriority;
		queueCreateInfos.push_back(queueCreateInfo);
	}
	
    // ...

	VkDeviceCreateInfo createInfo{};
	createInfo.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;
	createInfo.pQueueCreateInfos = queueCreateInfos.data();
	createInfo.queueCreateInfoCount = static_cast<uint32_t>(queueCreateInfos.size());
    // ...

	vkGetDeviceQueue(device, indices.graphicsFamily.value(), 0, &graphicsQueue);
	vkGetDeviceQueue(device, indices.presentFamily.value(), 0, &presentQueue);
}
```
