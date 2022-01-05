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

当所有数据准备完成后，GPU 中会有一个模块（Gigathread Engine）负责处理任务的分发。它为每一个要处理的顶点或像素创建一个线程，并将多个线程打包成一个 Package，NVIDIA 将这个 Package 称为 `Thread Block` 。 Thread Block 会被分发给 SM，如下图所示：
![|500](assets/Render%20Hell%20-%20Book%202%20Pipeline/GIF_9-15-2021_8-58-59_AM.gif)

```ad-```