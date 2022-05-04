---
tags:
    - Vulkan
created: 2022-03-06
updated: 2022-03-16
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
    CreateInfo 中的 `enabledLayerCount` 和 `ppEnabledLayerNames` 用来表示启用的 Validation Layers，这里暂时不启用，因此将 `enabledLayouCount` 设为 0。

```ad-note
Vulkan 设计中，许多函数需要的信息都是通过结构体，而不是一系列函数形参。
```

之后可以通过 `vkCreateInstance` 函数创建 Instance：
```csharp
if (vkCreateInstance(&createInfo, nullptr, &instance) != VK_SUCCESS)
{
	throw std::runtime_error("failed to create instance!");
}
```

这类 Create 函数通常有以下的形参：
1. 一个指针指向创建需要的信息结构体
2. 一个指针指向创建后的回调函数，在本教程中一直是 `nullptr`
3. 一个指针指向存储创建物体内存的对象。

同时几乎所有的 Vulkan 函数都会返回一个 `VkResult` 值表示接口运行是否成功，`VkResult 的值是 ·VK_SUCCESS` 或其他错误值。

# Checking for extension support

可以通过 `vkEnumerateInstanceExtensionProperties` 函数获取所有支持的 extensions，其中第一个参数为用来过滤 extensions 的 validation layer 的名称，这里暂不使用，第二个参数为 extensions 的数目，第三个参数为所有 extension 的数据。

使用示例如下所示：
```csharp
void HelloTriangleApplication::checkAvailableExtensions(const VkInstanceCreateInfo& createInfo)
{

	uint32_t extensionCount = 0;
	vkEnumerateInstanceExtensionProperties(nullptr, &extensionCount, nullptr);
	std::vector<VkExtensionProperties> extensions(extensionCount);

	vkEnumerateInstanceExtensionProperties(nullptr, &extensionCount, extensions.data());

	std::cout << "available extensions:\n";

	for (const auto& extension : extensions)
	{
		std::cout << '\t' << extension.extensionName << std::endl;
	}
}
```

上例中调用了两次 `vkEnumerateInstanceExtensionProperties` 函数，第一次是为了获取数量，第二次则是完整的获取所有的 Extensions。

此时的输出结果如下所示
```text
available extensions:
        VK_KHR_device_group_creation
        VK_KHR_display
        VK_KHR_external_fence_capabilities
        VK_KHR_external_memory_capabilities
        VK_KHR_external_semaphore_capabilities
        VK_KHR_get_display_properties2
        VK_KHR_get_physical_device_properties2
        VK_KHR_get_surface_capabilities2
        VK_KHR_surface
        VK_KHR_surface_protected_capabilities
        VK_KHR_win32_surface
        VK_EXT_debug_report
        VK_EXT_debug_utils
        VK_EXT_swapchain_colorspace
        VK_NV_external_memory_capabilities
```

# Checking for required extensions

如前所述，需要通过 `glfwGetRequiredInstanceExtensions` 获取依赖的 Surface 接口，可以通过以下的方式将依赖的 Extensions 打出：
```cpp
void HelloTriangleApplication::checkRequiredGlfwExtensions()
{
	uint32_t glfwExtensionCount = 0;
	const char** glfwExtension = glfwGetRequiredInstanceExtensions(&glfwExtensionCount);

	std::cout << "required extensions: \n";
	for (uint32_t i = 0; i != glfwExtensionCount; ++i)
	{
		std::cout << "\t" << glfwExtension[i] << std::endl;
	}

}
```
此时结果如下所示：
```text
required extensions:
        VK_KHR_surface
        VK_KHR_win32_surface
```
 
 # Cleaning up

 在退出时，需要调用 `vkDestroyInstance` 销毁 Instance：
 ```csharp
void HelloTriangleApplication::cleanup()
{
	vkDestroyInstance(instance, nullptr);
	glfwDestroyWindow(window);
	glfwTerminate();
}
 ```

 之后所有创建的 Vulkan 资源都需要在销毁 Instance 前被销毁。