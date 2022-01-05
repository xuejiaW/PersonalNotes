---
created: 2022-01-05
updated: 2022-01-05
---
# GPU Core

在 GPU Core 中有两个运算单元 `floating point unit(FP UNIT)` 和 `integer unit (INT UNIT)` ，当 GPU Core 接收到数据后，会通过这两个运算单元进行计算。

![|500](assets/Render%20Hell%20-%20Book%202%20Pipeline/GIF_9-14-2021_9-27-55_AM.gif)

# Not Everything is done by GPU Cores

对于如分发渲染任务，计算 tessellation，culling ，depth testing，光栅化，将计算后的 Pixel 信息写入到 Framebuffer 中等工作，并不是不通过 GPU Cores 完成，这些工作会由 GPU 中其他的硬件模块完成（这些模块不受开发者的代码控制）。

# Parallel Running Pipelines

对于 GPU Core 而言，它需要 `Streaming Multiprocessor(SM)` 为其分配工作，一个 SM 处理来自于 **一个** Shader 的顶点或像素数据。因此当一个 SM 下有多个 Core 时，来自于 **一个** Shader 的顶点或像素就能被并行的处理。当有多个 SM 时，多个 Shader 间也能并行处理。如下图所示：

![|500](assets/Render%20Hell%20-%20Book%202%20Pipeline/Untitled.png)

# Pipeline Stages In-Depth

```ad-note
这一部分从上至下更深入的讲解 GPU Pipeline
```

## Application Stage

对于应用而言，其提交的图形 API 都是提交给 GPU 的驱动，告诉其需要绘制的内容和 Render State。

![|500](assets/Render%20Hell%20-%20Book%202%20Pipeline/GIF_9-15-2021_8-41-31_AM.gif)

## Driver Stage

驱动会将绘制的数据 Push 到 Command Buffer 中，当 VSync 或 Flush 时，Command Buffer 中的数据会被 Push 到 GPU 中。

![|500](assets/Render%20Hell%20-%20Book%202%20Pipeline/GIF_9-15-2021_8-44-49_AM.gif)

## Read Commands

显卡中的 `Host Interface` 会负责读取 Command Buffer 传递进来的数据供后续的使用。
![|500](assets/Render%20Hell%20-%20Book%202%20Pipeline/GIF_9-15-2021_8-45-28_AM.gif)

## Data Fetch

一些 Command 包含数据的拷贝。GPU 通常会有一个单独的模块处理从 RAM 拷贝数据到 VRAM 的过程，反之亦然。这些需要拷贝的数据可以是 Vertex Buffer，纹理或其他 Shader 的参数。通常渲染一帧会从传递 Camera 相关的数据开始。

当所有数据准备完成后，GPU 中会有一个模块（Gigathread Engine）负责处理任务的分发。它为每一个要处理的顶点或像素创建一个线程，并将多个线程打包成一个 Package，NVIDIA 将这个 Package 称为 [Thread block](../../Notes/GPU/GPU%20-%20Thread%20block.md) 。 Thread Block 会被分发给 SM，如下图所示：
![|500](assets/Render%20Hell%20-%20Book%202%20Pipeline/GIF_9-15-2021_8-58-59_AM.gif)

## Vertex Fetch

SM 中仍然包含了多个硬件的单元，其中一个为 `Polymorph Engine` ，它负责将数据拷贝到各内存部分中，让 Core 在之后的工作中可以更快的访问数据。

![|500](assets/Render%20Hell%20-%20Book%202%20Pipeline/GIF_9-15-2021_9-03-27_AM.gif)

## Shader Execution

`Streaming MultiProcessor (SM)` 的主要功能为执行开发者编写的 Shaders。

SM 首先会将之前获取到的 ThreadBlock 拆分为多个 `Warp` 。每一个 Warp 包含的线程数根据硬件的不同可能存在差异， Nvidia 平台下一个 Warp 包含32个 Thread。
![|500](assets/Render%20Hell%20-%20Book%202%20Pipeline/pipeline_workdistribution_02.gif)

SM 中包含多个 `Warp Schedulers` ，每个 `Warp Schedulers` 会选择其中一个 Warp，并将需要执行的指令进行翻译。与 Warp 中线程数相同的 GPU Core 会一起逐条执行这些指令。每个 GPU Core 在同一时间点会执行相同的指令，但有着不同的数据（如不同的像素，不同的顶点）。为了简化，如下只展示一个 `Warp Schedulers` 的情况，过程如下所示：

![|500](assets/Render%20Hell%20-%20Book%202%20Pipeline/pipeline_workdistribution_04.gif)

```ad-note
对于每个 GPU Core 而言，它们无法知晓整个 Shader 指令，它们在仅知晓当前需要执行的那 **一条** 指令。
```

需要再次强调的是，一个 Warp 对应的 GPU Cores 在同一时间点会执行相同的指令，不会存在某个时间点一个 Core 执行语句 A，另一个 Core 执行语句 B 的情况。这种限制被称为 `lock-step` 。

当 Shader 中 IF 指令时，进入分支的 Core 会进行工作，剩下的 Core 会进入“休眠”。同理如果 Shader 中存在循环，那么仍然在循环内的 Core 进行工作，已经完成循环 工作的 Core 进入休眠，直到所有的 Core 都完成了操作。如下所示：

![|500](assets/Render%20Hell%20-%20Book%202%20Pipeline/pipeline_workdistribution_06.gif)

```ad-note
部分 Cores 工作，部分 Cores 休眠的现象称为 **`divergent threads`** 应当要尽量避免。
```

当 Warp 中需要执行的指令依赖的数据尚未被准备好， SM 会选择另一个 Warp 并执行其中的指令，如下所示：
![|500](assets/Render%20Hell%20-%20Book%202%20Pipeline/pipeline_workdistribution_07.gif)

```ad-note
Warp 中指令依赖数据未准备好，必须切换另一个 Warp 继续执行的现象，称为 `Memory Stall` 。
```

如前所述，一个 SM 可能包含多个 Warp Schedulers，也因此可以并行的处理多个 Warps，
![|500](assets/Render%20Hell%20-%20Book%202%20Pipeline/Untitled%201.png)

## Vertex Shader

每一个顶点着色器的实例对应 **一个** 顶点的处理，且运行在被 SM 管理的一个线程上。
![|500](assets/Render%20Hell%20-%20Book%202%20Pipeline/pipeline_vertex_shader_01.gif)

## Tessellation

```ad-note
曲面细分 `Tessellation` 是可选编程项，仅当使用了 `曲面细分着色器(Tessellation Shader)`时才会进行。
```

```ad-tip
曲面细分阶段中，有两个可编程的着色器， `Hull Shader` 和 `Domain Shader` 
```

```ad-note
为何需要曲面细分阶段，而不是直接在模型中增加更多的顶点？

1.  相较于更多顶点时数据传输时的开销，通过曲面细分生成更多顶点的开销更低
2.  曲面细分阶段可以控制顶点该如何被细分，如根据摄像机的距离。这样就能产生出更适合实际使用时的顶点数据。
```
<aside> 💡 

</aside>