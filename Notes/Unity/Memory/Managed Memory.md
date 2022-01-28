---
created: 2022-01-27
updated: 2022-01-28
tags:
    - Unity
    - Memory
---

# Overview

Unity 的 managed memory system 依赖 [Mono](../Scripting%20Architecture/Scripting%20backends/Mono.md) 或 [IL2CPP](../Scripting%20Architecture/Scripting%20backends/IL2CPP.md) 的虚拟机。Managed memory system 的好处在于，开发者不再需要手动的申请和释放内存。

Managed memory system 可能会影响运行时的性能，因为 Managed Memory 的申请需要消耗 CPU 的性能，且在 [GC](Garbage%20Collector.md) 发生时会暂停 CPU 中其他的工作直到 [GC](Garbage%20Collector.md) 完成。

# Automatic memory management

当 object 被创建时，Unity 会在 Heap 中分配其需要的内存。 Heap 会被选择的 [Scripting backends](../Scripting%20Architecture/Scripting%20backends.md) 管理。

## Managed heap overview

`Managed heap` 是 [Scripting backends](../Scripting%20Architecture/Scripting%20backends.md) 自动管理的一部分内存。

如下图展现了一系列 Unity 分配在 Managed Heap 上的内存，其中 **A** 为空闲的内存，当需要为新对象分配内存时，即会从空闲内存中分配：
![](assets/Managed%20Memory/image-20220128091330797.png)


## Memory fragmentation and heap expansion

当分配的内存被释放后，可能会造成`内存碎片化（Memory fragmentation）`，如下图所示：
![](assets/Managed%20Memory/image-20220128091934529.png)

此时如果要为新对象分配内存，可能会出现空闲内存够，但连续内存不足的情况。如下图所示，**A** 为需要分配的内存，**B** 为当前一共空闲的内存，可以看到空闲内存da'yu

# Reference

[Unity - Manual: Memory in Unity (unity3d.com)](https://docs.unity3d.com/2022.1/Documentation/Manual/performance-memory-overview.html) 