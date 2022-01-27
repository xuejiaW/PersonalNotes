---
created: 2022-01-27
updated: 2022-01-27
tags:
    - Unity
    - Memory
---
# Overview

Unity 应用一共涉及三种内存类型：
- [Managed memory](#Managed%20memory)：使用托管堆且使用 GC 自动分配及回收的内存
- [C# unmanaged memory](#C%20unmanaged%20memory)：依赖 `Unity Collection` 命名空间和 Package 分配的内存。它仍然通过 C# 语言访问，但因为不再被 GC 管理，所以被称为 `unmanaged`。
- [Native memory](#Native%20memory)：Unity 引擎分配的 C++ 内存，开发者无法直接访问到该内存


# Managed memory

Unity [Mono](Scripting%20Architecture/Scripting%20backends/Mono.md) 和 [IL2CPP](Scripting%20Architecture/Scripting%20backends/IL2CPP.md) 的`虚拟机（Virtual machines, VMs）`中都实现了`托管内存（Managed Memory）` 系统。

VMs将托管内存拆分为如下三种类型：
- The managed heap：分配在 Heap 上的内存，会被 GC 回收
- The scripting stack：分配在堆上的内存，在代码作用域退出后被回收
- Native VM memory：该内存与自动生成的代码相关，如泛型，Type 元数据，和反射。


[[Man]] 提供了自动的内存分配及释放管理，因此极大程度的减少了内存泄漏的可能。但 GC 分配和释放内存的方式在很大程度上是不可预测的，因此可能会造成性能问题。


# C# unmanaged memory

C# unmanaged memory 依赖 [Unity Collections package](https://docs.unity3d.com/Packages/com.unity.collections@latest/) 提供了在 C# 管理 Native 内存的方式，如 [NativeArray](https://docs.unity3d.com/2020.3/Documentation/ScriptReference/Unity.Collections.NativeArray_1.html)。

如果要使用 [Job system](https://docs.unity3d.com/2020.3/Documentation/Manual/JobSystem.html) 和 [Burst](http://docs.unity3d.com/Packages/com.unity.burst@latest)，则必须使用 C# unmanaged memory。

# Native memory

Unity 引擎内部使用的 `C/C++` 代码有自己的内存管理系统，这些内存称为 `native memory`。绝大部分情况下，开发者无法直接访问到这些内存。

# Reference

[Unity - Manual: Memory in Unity (unity3d.com)](https://docs.unity3d.com/2020.3/Documentation/Manual/performance-memory-overview.html)