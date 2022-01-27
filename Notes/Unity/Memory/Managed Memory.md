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



# Reference

[Unity - Manual: Memory in Unity (unity3d.com)](https://docs.unity3d.com/2022.1/Documentation/Manual/performance-memory-overview.html)