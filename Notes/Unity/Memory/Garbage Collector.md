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
- [Incremental GC](#Incremental%20GC)：增量式 GC，让整个 GC 的流程分布在多帧中进行，以避免帧率的降低。（默认行为）。
- [Non-Incremental GC](#Non-Incremental%20GC)：非增量式 GC，当 GC 发生时会在当前帧挂起应用并直到所有 GC 工作完成。
- [Disabling GC](#Disabling%20GC)：自动化 GC 被关闭，开发者需要手动的进行 GC 管理

# GC Mode

## Non-Incremental GC

在 Unity 

[Unity - Manual: Incremental garbage collection (unity3d.com)](https://docs.unity3d.com/2022.1/Documentation/Manual/performance-incremental-garbage-collection.html)


## Incremental GC

Unity 的 GC 使用 [Boehm GC algorithm](Boehm%20GC%20algorithm.md)，且默认情况下以Incremental Mode 运行，该模式下，整个 GC 的过程会在多帧内被执行完毕。

```ad-note
与 incremental mode 相对的是 stop-the-world Mode。此模式下，当 GC 发生时，CPU 的主线程会被挂起直到所有的 GC 工作完成。
```

Incremental Mode 并不会让整个 GC 变得更快，它只是将所有工作在多帧完成以避免由 GC 造成的 CPU 耗时峰值（GC Spike）。



## Disabling GC

[Unity - Manual: Disabling garbage collection (unity3d.com)](https://docs.unity3d.com/2022.1/Documentation/Manual/performance-disabling-garbage-collection.html)

# Tracking allocations

-   [Unity Profiler’s CPU Usage module](https://docs.unity3d.com/2022.1/Documentation/Manual/ProfilerCPU.html): Provides details of the **GC Alloc** per frame
-   [Unity Profiler’s Memory module](https://docs.unity3d.com/2022.1/Documentation/Manual/ProfilerMemory.html): Provides high-level memory usage frame by frame
-   [The Memory Profiler package](https://docs.unity3d.com/Packages/com.unity.memoryprofiler@latest): A separate Unity package which provides detailed information about memory usage during specific frames in your application

# Reference

[Unity - Manual: Garbage collector overview (unity3d.com)](https://docs.unity3d.com/2020.3/Documentation/Manual/performance-garbage-collector.html)

[Unity - Manual: Incremental garbage collection (unity3d.com)](https://docs.unity3d.com/2022.1/Documentation/Manual/performance-incremental-garbage-collection.html)

[Feature Preview: Incremental Garbage Collection | Unity Blog](https://blog.unity.com/technology/feature-preview-incremental-garbage-collection)