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

除非一个应用仅仅关心离屏渲染，开发者通常需要创建一个窗口用来展示渲染后的图像结果。可以使用 [[GLfw]]