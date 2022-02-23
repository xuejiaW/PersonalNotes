---
tags:
    - Vulkan
created: 2022-02-21
updated: 2022-02-23
---

这一部分会先介绍 Vulkan 以及它解决的问题，然后会阐述绘制第一个三角形所需要的组成部分。

# Origin of Vulkan

早期的图形 API 诞生时是为了配合当时的显卡硬件，大多是采用可配置固定管线实现。随着显卡的架构及硬件发展，显卡也提供了更多的可编程功能，这些可编程功能也逐步的被添加进早期的图形 API 中。w'w但因为这些图形 API 诞生时的设计目标架构与目前的显卡架构已经存在比较大的差异，许多的工作被隐藏在显卡的驱动中，这也就是为何显卡的驱动也会极大程度的影响程序的性能。

另外因为显卡厂商的不同，在编写 Shader 时可能需要额外的 syntax 来保证 Shader 在不同厂商的显卡中运行效果的一致性。

同时对于一些移动端的特性，如 [TBR](../../Notes/Computer%20Graphics/Tiled-Baed%20Rendering.md)，传统的图形 API 也没有提供相应的结构。

Vulkan 通过针对现代 GPU 架构从头开始设计来解决这些问题，另外 Vulkan 还允许多线程提交渲染命令来降低 CPU 侧的开销。

# What it takes to draw a triangle

对于一个 Vulkan 程序需要使用如下的步骤绘制一个三角形，所有的步骤在后续的章节中都会进行更详细的解释：

## Instance and physical device selection

对于一个 Vulkan 应用首先需要创建 `VkInstance` ，并通过它进行一系列的设置。在创建后，可以通过它查询 Vulkan 支持的硬件并选择一个或多个 `VkPhysicalDevice` 作为后续需要使用的硬件。

## Logical device and queue families

当选择了需要使用的硬件后，需要进一步创建 `VkDevice`，它作为逻辑上的设备。当创建 `VkDevice` 时需要描述后续具体需要使用的 `VkPhysicalDeviceFeatures`，如需要使用 `64-bits  float` 或需要支持 `multi viewport rendering`。

同时还需要指定需要使用哪个`队列家族（Queue Family），大多数的 Vulkan操作都会异步的被提交到 `VkQueue` 中，它是从队列家族中被分配的。每个队列家族都支持将一个特定系列的操作放到它的队列中，如可以有不同的队列家族分别负责 Graphics / Cimputer / memory transfer 的操作。

## Window surface and swap chain

除非一个应用仅仅关心离屏渲染，开发者通常需要创建一个窗口用来展示渲染后的图像结果。在本教程中使用 [GLFW](../Learn%20OpenGL/Ch%2000%20Creating%20a%20Window.md#GLFW) 创建窗口。

为了真正渲染到窗口中，还需要创建一个 Window Surface (`VkSurfaceKHR`) 和一个 [Swap Chain](../../Notes/Computer%20Graphics/Swap%20Chain.md)（`VkSwapchainKHR`）。

```ad-note
`KHR` 后缀，标识这个对象是 Vulkan 拓展中的一部分。
```

Vulkan API 本身完全与平台不相关的，因此 Surface 在初始化时需要提供操作系统的 Window Handle，比如在 Windows 系统下为 `HWND`。 这些操作系统相关的细节，GLFW 都有内置的 API 提供相应信息。

```ad-note
一些操作系统允许通过 `VK_KHR_display` 和 `VK_KHR_display_swapchain` 拓展函数，直接将内容绘制到 Display 上。
```

## Image views and framebuffers

为了将内容绘制到纹理上，首先需要将其 Warp 到 `VKImageView` 和 `VKFramebuffer` 上。 Image View 用来标识图片中的一个特定区域，Framebuffer 用来标识需要用给 Color / Depth / Stencil Buffer 上的 Image View。

因为 [Swap Chain](../../Notes/Computer%20Graphics/Swap%20Chain.md) 需要有多张 Image，所以针对每张 Image 都需要创建一个 Image view 和 framebuffer。在渲染时切换选择当前需要的 Image Views 和 Framebuffer。

## Render passes

Render Passes 用来描述在渲染操作中需要用到的 Image 类型，Images 的用处，以及该如何对待 Image 的内容。

如，在最初的绘制三角形的应用中，Render passes 会将 Image 作为 color target，并指明在每次 drawing 操作前将其 clear。

## Graphics pipeline

Vulkan 中使用的 `图形管线（Graphics Pipeline）` 需要通过创建 `VKPiepeline` 对象设置。它描述了显卡中的可设置阶段，例如 viewport 的大小，对 depth buffer 的操作等。对于显卡中的可编程阶段，需要使用 `VKShaderModule` 对象设置，该对象是从 `shader byte code` 创建的。

驱动还需要知道在管线中具体使用的 render targers，这个需要通过引用 [Render passes](#Step%205%20-%20Render%20passes) 指定。

Vulkan 与其他图形 APIs 最大区别之一是几乎图形管线中所有的配置项都需要提前设定，这意味着如果要切换成其他的 Shader 或调整 Vertex layout，就需要完整的重建图形管线，所以在渲染前，需要为不同的设定预先创建许多 `VKPipleine` 对象。只有一些基本的配置，如更改  viewport size 和 clear color 可以在运行时调整。

图形管线中所有的配置需要显示的被定义，在 Vulkan 中没有类似于默认 Color Blend 方式这样的默认值。

Vulkan 对图形管线的这些设定让所有的配置在编译时就能确定，而非必须等待运行时，这样就能让驱动有更多的优化空间，同时应用整体的性能也能更好地预测。

## Command pools and command buffers

如在 [Logical device and queue families](#Logical%20device%20and%20queue%20families) 中所述，Vulkan 中的指定都需要被提交到 Queue 中。这些指令都需要首先被记录在 `VKCommandBuffer` 对象中，所有这些指令都会从 `VkCommandPool` 中分配，`VkCommandPool` 会与特定的 [queue families](#Logical%20device%20and%20queue%20families) 绑定。

为了渲染一个三角形，需要使用一个 Command Buffer 记录以下操作：
1. 开始 Render Pass
2. 绑定 Graphics Pipeline
3. 画三个顶点
4. 结束 Render Pass

因为 Framebuffer 中的 Image 依赖于当前 Swap Chain 中的 Image，因此需要为每个可能的 Image 记录一个 Command buffer，并在渲染时切换到当前需要的一个。

## Main Loop

渲染主流程首先需要通过 `vkAcquireNextImageKHR`从 Swap Chain 中获取到一个 Image，然后为这个 Image 选择正确的 Command buffer ，并用 `vkQueueSubmit` 执行它，最后用 `vkQueuePresentKHR` 将这个 Image 返回给 Swap Chain 并最终在屏幕上显示。

提交给 Queue 的命令会被异步的执行，
