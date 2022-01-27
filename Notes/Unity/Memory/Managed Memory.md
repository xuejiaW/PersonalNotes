---
created: 2022-01-27
updated: 2022-01-27
tags:
    - Unity
    - Memory
---

# Overview

Unity 的 managed memory system 依赖 [Mono](../Scripting%20Architecture/Scripting%20backends/Mono.md) 或 [IL2CPP](../Scripting%20Architecture/Scripting%20backends/IL2CPP.md) 的虚拟机。Managed memory system 的好处在于，开发者不再需要手动的申请和释放内存。

Managed memory system 可能会影响运行时的性能，因为 Managed Memory 的申请需要消耗 CPU 的性能，且在 GC 发生时会暂停 CPU 中其他的工作直到 GC 完成。

# Value and reference types



# Reference

[Unity - Manual: Memory in Unity (unity3d.com)](https://docs.unity3d.com/2022.1/Documentation/Manual/performance-memory-overview.html)