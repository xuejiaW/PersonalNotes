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

# Integrating GLW

