---
tags:
    - Vulkan
created: 2022-03-06
updated: 2022-03-06
---

# Creating an instance

对一个 Vulkan 程序而言，首先需要创建一个 `instace`，它用来连接应用与 Vulkan 库，同时也会将程序的一些细节指示给驱动。

创建 Instance 的完整实现如下所示：

```csharp
void HelloTriangleApplication::createInstance()
{
	VkApplicationInfo appInfo{};
	appInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO;
	appInfo.pApplicationName = "Hello Triangle";
	appInfo.applicationVersion = VK_MAKE_VERSION(1, 0, 0);
	appInfo.pEngineName = "No Engine";
	appInfo.engineVersion = VK_MAKE_VERSION(1, 0, 0);
	appInfo.apiVersion = VK_API_VERSION_1_0;

	uint32_t glfwExtensionCount = 0;
	const char** glfwExtension = glfwGetRequiredInstanceExtensions(&glfwExtensionCount);

	VkInstanceCreateInfo createInfo{};
	createInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
	createInfo.pApplicationInfo = &appInfo;
	createInfo.enabledExtensionCount = glfwExtensionCount;
	createInfo.ppEnabledExtensionNames = glfwExtension;
	createInfo.enabledLayerCount = 0;

	if (vkCreateInstance(&createInfo, nullptr, &instance) != VK_SUCCESS)
	{
		throw std::runtime_error("failed to create instance!");
	}

	checkAvailableExtensions(createInfo);
	checkRequiredGlfwExtensions();
}
```

其中首先需要创建两个结构体 `VkApplicationInfo` 和 `VkInstanceCreateInfo`。
- `VkApplicationInfo`透露了关于应用的一些信息，驱动可以根据这些信息对程序做一些优化
- `VkInstanceCrateInfo` 描述了创建 Instance 所需要的信息。
    因为 Vulkan 本身是一个与平台不相关的接口，因此在 Create Info 中需要描述与平台 Surface 相关的 Extension，这些 Extension 可以从 GLFW 的接口 `glfwGetRequiredInstanceExtensions` 中获取。

```ad-note
Vulkan 设计中，许多函数需要的信息都是通过结构体，而不是一系列函数形参。
```

之后可以通过 `vkCreateInstance` 函数创建 Instance，这类 Create 函数通常有以下特性：
