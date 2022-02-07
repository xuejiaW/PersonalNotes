---
created: 2022-01-27
updated: 2022-02-07
tags:
    - Unity
    - Memory
---

# Overview

Unity 的 managed memory system 依赖 [Mono](../Scripting%20Architecture/Scripting%20backends/Mono.md) 或 [IL2CPP](../Scripting%20Architecture/Scripting%20backends/IL2CPP.md) 的虚拟机。Managed memory system 的好处在于，开发者不再需要手动的申请和释放内存。

但 Managed memory system 可能会影响运行时的性能，一是因为 Managed Memory 的申请需要消耗 CPU 的性能，二是因为 GC 发生存在不确定性，因此可能会在不期望的时刻触发 GC 并带来性能开销。

```ad-tip
[Incremental GC](Garbage%20Collector.md#Incremental%20GC) 极大程度上减少了由 GC 带来的性能下降。
```

# Automatic memory management

当 object 被创建时，Unity 会在 Heap 中分配其需要的内存。 Heap 会被选择的 [Scripting backends](../Scripting%20Architecture/Scripting%20backends.md) 管理。

## Managed heap

`Managed heap` 是 [Scripting backends](../Scripting%20Architecture/Scripting%20backends.md) 自动管理的一部分内存。

如下图展现了一系列 Unity 分配在 Managed Heap 上的内存，其中 **A** 为空闲的内存，当需要为新对象分配内存时，即会从空闲内存中分配：
![](assets/Managed%20Memory/image-20220128091330797.png)


## Memory fragmentation and heap expansion

当分配的内存被释放后，可能会造成`内存碎片化（Memory fragmentation）`，如下图所示：
![](assets/Managed%20Memory/image-20220128091934529.png)

此时如果要为新对象分配内存，可能会出现空闲内存够，但连续内存不足的情况。如下图所示，**A** 为需要分配的内存，**B** 为当前一共空闲的内存，可以看到空闲内存大于需要分配的内存，但因为连续内存不足，仍然不能为对象分配内存：
![](assets/Managed%20Memory/image-20220128092412292.png)

这种情况下 Unity 会进行如下的操作：
1. 触发 GC
2. 如果 GC 完成后，仍然没有足够的连续空间为新对象分配内存，Heap 则会扩张。每次扩张会让 Heap 增大多少是平台相关的，但在绝大部分平台下每次扩张 Heap 的尺寸会扩大一倍。

```ad-note
因为 Unity 的 [GC](Garbage%20Collector.md) 使用的是 [Boehm GC algorithm](Boehm%20GC%20algorithm.md)，所以与传统 .Net GC 不同的是，Unity 中发生的 GC 并不会解决碎片化。
```

## Managed heap expansion considerations

扩张后的 Heap，即使在 GC后存在大量的空闲内存，Unity 也不会立即将内存返还给系统。这一行为是为了避免 Unity 在后续需要分配内存时反复的重新扩张 Heap 导致性能开销。

Unity 最终还是会在某个时间点将 Heap 内存返还给系统，但返还的时间是无法保证且不可依赖的。

```ad-warning
Heap 的`地址空间（Address Space）` 永远都不会返还给操作系统。

因此对于 32 位的应用，如果频繁的扩张和收缩 Heap 堆，那么内存地址空间可能会被耗尽，在这种情况下系统会终止应用的运行。

对于 64 位应用而言，因为地址空间足够的大，因此几乎不会发生因为地址空间耗尽而导致的应用被系统关闭的情况

```

# Basic memory conservation

## Collection and array reuse

如果存在如下需要每帧使用全新的容器的情况：
```csharp
void Update() {

    List<float> nearestNeighbors = new List<float>();

    findDistancesToNearestNeighbors(nearestNeighbors);

    nearestNeighbors.Sort();

    // … use the sorted list somehow …

}
```

可以选择将容器定义为类的成员变量，并使用 `Clear` 函数在每帧清空数据。`Clear` 函数会清除容器内已有的数据，但会保留容器的内存占用，以此减少 Heap 堆内存的分配。修改方式如下所示：
```csharp
List<float> m_NearestNeighbors = new List<float>();

void Update() {

    m_NearestNeighbors.Clear();

    findDistancesToNearestNeighbors(NearestNeighbors);

    m_NearestNeighbors.Sort();

    // … use the sorted list somehow …

}
```

## Closures and anonymous methods

对于函数本身的内存开销，有两点需要注意：
1. C# 中所有函数的引用都是引用类型，即会在 Heap 进行分配。所以当使用函数作为形参时都会发生 Heap 的分配操作，无论该函数是匿名函数或已定义的函数。
2. 当匿名函数中存在 [Closure](../../CSharp/Closure.md) 时，它作为参数传递时的内存开销会增大许多，因为编译器需要为其创建一个帮助类。

# Reference

[Unity - Manual: Memory in Unity (unity3d.com)](https://docs.unity3d.com/2022.1/Documentation/Manual/performance-memory-overview.html) 

[Unity - Manual: Understanding the managed heap (archive.org)](https://web.archive.org/web/20181204043411/https://docs.unity3d.com/Manual/BestPracticeUnderstandingPerformanceInUnity4-1.html)