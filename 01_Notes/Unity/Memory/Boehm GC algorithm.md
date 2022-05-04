---
created: 2022-01-28
updated: 2022-03-11
tags:
    - Unity
    - Memory
Alias: Boehm–Demers–Weiser garbage collector
---

# Overview

`Boehm GC` 是一种 `non-generational`，`non-compacting` 的算法[^1]。
- `non-generational` 意味着当 GC 发生时 ，需要完整扫描整个 [Managed heap](Managed%20Memory.md#Managed%20heap) 。 
- `non-compacting` 意味着 GC 进行过程中，内存中的物体并不会被移动以解决内存的碎片化。


# Reference

[^1]: [Unity - Manual: Understanding the managed heap (archive.org)](https://web.archive.org/web/20181204043411/https://docs.unity3d.com/Manual/BestPracticeUnderstandingPerformanceInUnity4-1.html)

[Unity3D托管堆BoehmGC算法学习-内存分配篇 - 掘金 (juejin.cn)](https://juejin.cn/post/6966954993869914119)

[Unity3D托管堆BoehmGC算法学习-垃圾回收篇 - 掘金 (juejin.cn)](https://juejin.cn/post/6968400262629163038)

