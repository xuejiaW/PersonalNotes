---
created: 2022-02-28
updated: 2022-03-06
tags:
    - Vulkan
---

# General structure

三角形应用的基本代码结构如下所示：
```cpp
class HelloTriangleApplication
{
public:
	void run();

private:
	void initVulkan();
	void mainLoop();
	void cleanup();
};

void HelloTriangleApplication::run()
{
	initVulkan();
	mainLoop();
	cleanup();
}

void HelloTriangleApplication::initVulkan() { }

void HelloTriangleApplication::mainLoop() { }

void HelloTriangleApplication::cleanup() { }

int main()
{
    HelloTriangleApplication app;

    try
    {
        app.run();
    }
    catch (const std::exception& e)
    {
        std::cerr << e.what() << std::endl;
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
```

其中所有初始化操作会放到 `initVulkan` 中，渲染的操作会被放置到 `mainLoop` 中，当窗口关闭时 `cleanup` 会保证相应资源的释放。

# Resource management

Vulkan 对象会从类似于 `vkCreateXXX` 或者 `vkAllocateXXX` 的函数中创建，对应的当这些物体不再需要时，需要调用 `vkDestoryxxx` 或 `vkFreeXXX` 进行释放。

这些函数的形参会根据具体需要的类型而不同，但所有函数都有一个 `pAllocator` 的形参，这个形参用来指定内存操作后的回调，在本教程中，这个形参始终会被设为 `nullptr`。

# Integrating GLFW

定义 `initWindow`，其中使用 GLFW 初始化窗口，并在调用 `initVulkan` 前先调用该函数：
```csharp
void HelloTriangleApplication::initWindow()
{
	glfwInit();
	glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
	glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE);

	window = glfwCreateWindow(WIDTH, HEIGHT, "vulkan", nullptr, nullptr);
}
```

因为 GLFW 起初是为 OpenGL 设计的，因此这里需要显式的调用 `GLFWwindow* window = nullptr` 告知 GLFW 不需要创建 OpenGL 的上下文。

另外当窗口大小变化时，需要额外处理，因此这里显式的设定窗口不可改变`glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE)`。

其中 `WIDTH`, `HEIGHT` 和 `window` 的定义如下：
```csharp
const uint32_t WIDTH = 800;
const uint32_t HEIGHT = 600;

GLFWwindow* window = nullptr;
```

在主循环中，需要判断窗口是否应当关闭，且运行时检测是否有按键时间发生：
```csharp
void HelloTriangleApplication::mainLoop()
{
	while (!glfwWindowShouldClose(window))
	{
		glfwPollEvents();
	}
}
```

在退出时需要清理 GLFW 窗口：
```csharp
void HelloTriangleApplication::cleanup()
{
	glfwDestroyWindow(window);
	glfwTerminate();
}
```