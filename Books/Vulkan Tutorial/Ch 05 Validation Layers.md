---
tags:
    - Vulkan
created: 2022-03-06
updated: 2022-03-07
---

在程序变得更加复杂之前，需要了解 Validation layers 帮助调试。

# What are validation layers

因为 Vulkan API 的设计理念是最小化驱动的负载，因此在 API 层只有非常少的错误检测。为此 Vulkan 引入了 `Validation Layers` 系统进行错误检测，`Validation Layers` 
