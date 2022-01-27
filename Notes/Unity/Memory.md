---
created: 2022-01-27
updated: 2022-01-27
---
# Overview

Unity 应用一共涉及三种内存类型：
- [Managed memory](#Managed%20memory)：使用托管堆且使用 GC 自动分配及回收的内存
- [C# unmanaged memory](#C%20unmanaged%20memory)：依赖 `Unity Collection` 命名空间和 Package 分配的内存。它仍然通过 C# 语言访问，但因为不再被 GC 管理，所以被称为 `unmanaged`。
- [Native memory](#Native%20memory)：Unity 引擎分配的 C++ 内存，开发者无法直接访问到该内存


# Managed memory

Unity [Mono](../Scripting%20Architecture/Scripting%20backends/Mono.md) 和 [IL2CPP](../Scripting%20Architecture/Scripting%20backends/IL2CPP.md) 的`虚拟机（Virtual machines, VMs）`中都实现了`托管内存（Managed Memory）` 系统。

VMs将托管内存拆分为如下三种类型：



# C# unmanaged memory

# Native memory