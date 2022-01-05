# GPU Core

在 GPU Core 中有两个运算单元 `floating point unit(FP UNIT)` 和 `integer unit (INT UNIT)` ，当 GPU Core 接收到数据后，会通过这两个运算单元进行计算。

![](assets/Render%20Hell%20-%20Book%202%20Pipeline/GIF_9-14-2021_9-27-55_AM.gif)

# Not Everything is done by GPU Cores

对于如分发渲染任务，计算 tessellation，culling ，depth testing，光栅化，将计算后的 Pixel 信息写入到 Framebuffer 中等工作，并不是不通过 GPU Cores 完成，这些工作会由 GPU 中其他的硬件模块完成（这些模块不受开发者的代码控制）。

# Parallel Running Pipelines

对于 GPU Core 而言，它需要 `Streaming Multiprocessor(SM)` 为其分配工作，一个 SM 处理来自于 **一个** Shader 的顶点或像素数据。因此当一个 SM 下有多个 Core 时，来自于 **一个** Shader 的顶点或像素就能被并行的处理。当有多个 SM 时，多个 Shader 间也能并行处理。如下图所示：

![](assets/Render%20Hell%20-%20Book%202%20Pipeline/Untitled.png)