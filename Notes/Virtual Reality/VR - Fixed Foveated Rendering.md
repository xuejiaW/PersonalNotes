---
Alias: FFR
tags:
    - Virtual-Reality
---

# 像素密度问题

在VR中，渲染到平面屏幕上的内容会进一步被投射到曲面的镜片上，如下图所示。图中的半圆表示曲面镜片，中央的横线表示屏幕。在曲面上去角度相同的区域，可以看到越靠近曲面边缘的部分，在平面屏幕上需要的像素越多。

![|300](assets/VR%20-%20Fixed%20Foveated%20Rendering/Untitled.png)

因此，在曲面镜片上，越靠近边缘的部分，像素密度越大，这是与实际的需要相悖的。实际需求中，越重要的内容应该有更高的像素进行渲染，而在镜片边缘的内容通常来说是不重要的。

为了确定镜片上哪一部分的内容更重要，通常需要用到眼部追踪来确定用户的视线。而Fixed Foveated Rendering 假设重要的内容永远出现在镜面的中心（绝大部分情况确实如此），因此称为Fixed。

# 节省像素

因为一体机运行在移动平台上，而移动平台的渲染是将整个屏幕分为多个Tile。可以给不同的Tile设置不同的分辨率来减少需要渲染的像素。

![|500](assets/VR%20-%20Fixed%20Foveated%20Rendering/Untitled%201.png)

如上图所示，白色的部分为球面镜片的中心，以全分辨率渲染。红色部分以$1/2$的分辨率进行渲染，绿色部分以 $1/4$ 分辨率进行渲染，蓝色部分以 $1/8$ 分辨率渲染，紫色部分以 $1/16$ 分辨率渲染。

需要注意的是FFR必然会导致边缘内容的模糊，而当内容是文字时，会造成较明显的影响，如下所示，从左到右，FFR的等级逐渐变高。

![|500](assets/VR%20-%20Fixed%20Foveated%20Rendering/Untitled%202.png)

# 实现方法

传统做法是将FrameBuffer，拆分成多个小块，对每个小块已更低的像素进行渲染，然后再将小块绘制到总的FrameBuffer上。如原先分辨率为 $100 \times 100$，将其拆分为四个 $25\times 25$的小块，但是每个小块实际上以 $10*10$ 的分辨率绘制，再绘制完后再将其拉伸到 $25\times25$，并拷贝到 FrameBuffer上。

更高效的做法是通过修改渲染管线，在移动端的GPU上，通常 [Tile-Based Rendering](../Computer%20Graphics/Computer%20Graphics%20-%20Tiled-Baed%20Rendering.md#Tile-Based%20Rendering) ，可以直接通过修改Tile绘制到Framebuffer上时的流程来实现FFR，即对每一个Tile进行更低分辨率的渲染，最后再将每个Tile进行拉伸并绘制到最终FrameBuffer上。