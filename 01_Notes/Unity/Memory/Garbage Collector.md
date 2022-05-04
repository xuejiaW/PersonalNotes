---
created: 2022-01-27
updated: 2022-03-11
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

非增量式 GC 以 `stop-the-world Mode` 运行，即当 GC 发生时，CPU 的主线程会被挂起直到所有的 GC 工作完成。挂起的时间由 GC 需要处理的内存量决定，可能低于一毫秒 ，也可能多大几百毫秒。

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

如果一个 Object 已经被标记完，但在 GC 的后几帧中发生了 Reference 变化，则 GC 需要对该 Object 重新进行标记。同时，为了检测出这种 Reference 的变化，[Garbage Collector](Garbage%20Collector.md) 也会有额外的代码去进行检查操作，这些代码称为 `Write Barriers`。

```ad-note
因此在重复修改 Reference 的情况下，增量式 GC 可能会引发性能的下降。
```

极端情况下，如果一个应用非常高频的修改 Object 的 Reference，甚至会导致增量式 GC 永远无法执行完毕，因为始终在对 Object 进行重标记。在这种情况下，GC 会执行一次完整的，非增量式的 GC。


## Disabling GC

可以通过 [GarbageCollector.GCMode](https://docs.unity3d.com/2022.1/Documentation/ScriptReference/Scripting.GarbageCollector.GCMode.html)来关闭运行时的 GC，该选项一共由三种模式：
- Enable：打开 GC，该选项为默认值
- Disabled：关闭 GC。选择该选项后，整个 GC 线程都不会出现将程序挂起并执行 GC 的操作。即使调用 `System.GC.Collect` 也不会产生任何影响。
- Manual：手动管理 GC。此时 GC 不会被自动的触发，但仍然可以使用 `GC.Collect` 或 `GarbageCollector.CollectIncremental` 进行 GC 操作。

```ad-note
GC 模式的更改可以通过 [GarbageCollector.GCModeChanged ](https://docs.unity3d.com/2022.1/Documentation/ScriptReference/Scripting.GarbageCollector.GCModeChanged.html) 监听。
```

# Tracking allocations

-   [Unity Profiler’s CPU Usage module](https://docs.unity3d.com/2022.1/Documentation/Manual/ProfilerCPU.html): Provides details of the **GC Alloc** per frame
-   [Unity Profiler’s Memory module](https://docs.unity3d.com/2022.1/Documentation/Manual/ProfilerMemory.html): Provides high-level memory usage frame by frame
-   [The Memory Profiler package](https://docs.unity3d.com/Packages/com.unity.memoryprofiler@latest): A separate Unity package which provides detailed information about memory usage during specific frames in your application

# Reference

[Unity - Manual: Garbage collector overview (unity3d.com)](https://docs.unity3d.com/2020.3/Documentation/Manual/performance-garbage-collector.html)

[Unity - Manual: Incremental garbage collection (unity3d.com)](https://docs.unity3d.com/2022.1/Documentation/Manual/performance-incremental-garbage-collection.html)

[Feature Preview: Incremental Garbage Collection | Unity Blog](https://blog.unity.com/technology/feature-preview-incremental-garbage-collection)

[Unity - Manual: Disabling garbage collection (unity3d.com)](https://docs.unity3d.com/2022.1/Documentation/Manual/performance-disabling-garbage-collection.html)

[Unity - Scripting API: Scripting.GarbageCollector.GCMode (unity3d.com)](https://docs.unity3d.com/2022.1/Documentation/ScriptReference/Scripting.GarbageCollector.GCMode.html)