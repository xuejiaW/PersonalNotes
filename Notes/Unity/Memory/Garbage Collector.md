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

```ad-note
无论使用增量式与否，Unity 的 GC 都依赖于 [Boehm GC algorithm](Boehm%20GC%20algorithm.md)
```
# GC Mode

## Non-Incremental GC

Unity 2019 之前的版本尚未支持 `增量式 GC（Incremental GC）`，所有的 GC 都是非增量式的。

非增量式 GC 以 `stop-the-world Mode` 运行，即当 GC 发生时，CPU 的主线程会被挂起直到所有的 GC 工作完成。

## Incremental GC

Unity 2019+ 版本 的 GC 默认情况下以Incremental Mode 运行，该模式下，整个 GC 的过程会在多帧内被执行完毕。

Incremental Mode 并不会让整个 GC 变得更快，它只是将所有工作在多帧完成以避免由 GC 造成的 CPU 耗时峰值（GC Spike）。

如下为使用增量式 GC 与非增量式 GC 的 Profiler 对比，图中的深黄色即为 GC 的开销 ：
![Incremental GC](assets/Garbage%20Collector/image-20220128135452597.png)
![Non-incremental GC](assets/Garbage%20Collector/image-20220128135509359.png)

可以看到使用非增量式 GC 时，发生 GC 的一帧耗时会特别的长（GC Spike），引起的下降。

如果应用使用了 `VSync` 或 `Aplication.targetFrameRata`，则 Unity 会计算出每一帧计算完成后剩余的时间，并使用剩余时间来进行 GC。

```ad-tip
如果希望对增量式 GC 有更多的控制而不是依赖于 `VSync` 和 `Application.targetFrameRata`，可以通过类 [Scripting.GarbageCollector](https://docs.unity3d.com/2022.1/Documentation/ScriptReference/Scripting.GarbageCollector.html)。
```

### Referece change

因为增量式 GC 会将 GC 过程拆分至多帧内执行完毕，所以对 Heap 中所有对象的扫描标记阶段也会被拆分成多帧。

如果一个对象已经被标记完，但在 GC 的后几帧中发生了 Reference 变化，则 GC 需要对该物体重新进行标记。极端情况下，如果一个应用f


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