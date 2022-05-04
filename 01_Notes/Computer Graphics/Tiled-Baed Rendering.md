---
Alias: TBR
created: 2022-01-06
updated: 2022-01-24
tags:
    - Computer-Graphics
---
# Immediate Mode Rendering

在PC和游戏主机端，通常使用 `Immediate Mode Rendering（IMR）`，在该模式下渲染管线按照流程，依次渲染每个图元，对每个图元依次调用各着色器。渲染流程伪代码如下：

```python
for draw in renderPass:
    for primitive in draw:
        for vertex in primitive:
            execute_vertex_shader(vertex)
        if primitive not culled:
            for fragment in primitive:
                execute_fragment_shader(fragment)
```

渲染过程如下图所示，其中左半部分是颜色缓冲，右半部分是深度缓冲：

![](assets/Tiled-Baed%20Rendering/tech_GPUFramebuffer_01.gif)

在整个渲染过程中，因为是按照图元的顺序进行渲染，而每个图元的位置可能在屏幕上的任何位置，因此整个渲染交互的内存是整个帧缓冲。而对于整个屏幕的帧缓冲而言，它的尺寸过大，以至于没法容纳在GPU芯片的内存中，因此必须存放在内存中。

这也就导致了在整个渲染过程中，GPU需要频繁的访问内存中的帧缓冲（写入颜色或读取深度值做深度比较），如下图所示，这就会造成高带宽压力。

![](assets/Tiled-Baed%20Rendering/Untitled.png)

图中的FIFO表示一个先入先出的队列，即依次处理顶点着色器，并放置入队列，然后依次处理片段着色器。

# Tile-Based Rendering

在移动端，通常采用的是 `Tile-Based Rendering（TBR）`，TBR可以最大程度的减少了渲染过程中对外部内存的访问。

TBR的思路是先将整个屏幕拆分为多个小的Tile，对每个Tile进行渲染，然后将渲染好的Tile中的内容再绘制到内存的帧缓冲中，过程如下图所示。因为这些Tile足够的小（如 $16\times16$ 像素），因此可以存放在GPU本身的内存中，这样在为每个Tile绘制的过程中，就不需要对外部的内存进行调用。

![|500](assets/Tiled-Baed%20Rendering/tech_GPUFramebuffer_14.gif)

但上述过程就要求在正式绘制前需要知道每个Tile中会包含哪些图元，即在TBR下，整个渲染的流程被拆分为两步。第一步是根据顶点信息，计算出每个Tile中会有哪些图元，并将这些几何信息存放在一个列表中，第二步是每个Tile根据第一步中生成的几何信息列表，绘制其中的图元，在绘制完成后，将Tile绘制的结果绘制到帧缓冲中。

计算每个Tile中包含的图元的过程，称为 `Binning` ，示意图如下所示：

![|500](assets/Tiled-Baed%20Rendering/tech_GPUFramebuffer_12.gif)

整个TBR流程及示意图如下所示：
![](assets/Tiled-Baed%20Rendering/Untitled%201.png)

```python
# Pass one
for draw in renderPass:
    for primitive in draw:
        for vertex in primitive:
            execute_vertex_shader(vertex)
        if primitive not culled:
            append_tile_list(primitive)

# Pass two
for tile in renderPass:
    for primitive in tile:
        for fragment in primitive:
            execute_fragment_shader(fragment)
```

```ad-warning
TBR虽然很大程度的减少了绘制过程中对外部内存的频繁读取进而节省了带宽，但因为在绘制前要计算出所有Tile中包含的图元，所以这个过程在有大量顶点数据的情况下可能会引起性能下降。 另外，计算出的每个Tile中的图元信息也需要存储在内存中，所以TBR虽然减少了带宽，却使用了更多的内存。
```

#  Reference

[Documentation – Arm Developer](https://developer.arm.com/documentation/102662/latest/)

[GPU Framebuffer Memory: Understanding Tiling | Samsung Developers](https://developer.samsung.com/galaxy-gamedev/resources/articles/gpu-framebuffer.html)