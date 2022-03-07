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
Vulkan 本身并没有提供任何的 Validation Layers，但 LumarG Vulkan SDK 则ti'go
```