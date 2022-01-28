---
created: 2022-01-27
updated: 2022-01-28
tags:
    - Unity
    - Memory
Alias: GC
---

# Overview

当 GC 发生时，Collector 会检查 [Managed heap](Managed%20Memory.md#Managed%20heap%20overview) 上的所有 objects。对于每个对象而言，它会被检查是否有被引用，如果有则它会被`标记（Mark）`。当完整检查结束后，未被标记的对象将会被释放。

Unity 中 garbage collector 有以下三种模式：
- [Incremental GC](#Incremental%20GC)：增量式 GC，让整个 GC 的流程分布在多帧中进行，以避免帧率的降低
- [Non-Incremental GC](#Non-Incremental%20GC)
- [Disabling GC](#Disabling%20GC)


# Incremental GC

# Non-Incremental GC

# Disabling GC

# Reference

[Unity - Manual: Garbage collector overview (unity3d.com)](https://docs.unity3d.com/2020.3/Documentation/Manual/performance-garbage-collector.html)


[Unity3D托管堆BoehmGC算法学习-内存分配篇 - 掘金 (juejin.cn)](https://juejin.cn/post/6966954993869914119)

[Unity3D托管堆BoehmGC算法学习-垃圾回收篇 - 掘金 (juejin.cn)](https://juejin.cn/post/6968400262629163038)

[Feature Preview: Incremental Garbage Collection | Unity Blog](https://blog.unity.com/technology/feature-preview-incremental-garbage-collection)