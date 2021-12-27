---
created: 2021-12-27
updated: 2021-12-27
tags:
    - OpenGL
---
# Overview

之前进行的渲染都称为`前向渲染（Forward Rendering / Forward Shading）。在前向渲染中对于场景内的每个物体，在它们的着色器中都需要对场景内的每个光照都进行计算，如 [Light Casters, Multiple Lights](Learn%20OpenGL%20-%20Ch%2014%20%20Light%20Casters,%20Multiple%20Lights.md) 即为典型的前向渲染计算。

延迟渲染（Deferred Rendering / Deferred Shading）技术的主要目的就是为了优化场景内存在大量光照时的性能。

延迟渲染主要被拆分为两部分：
1. Geometry Pass：渲染一次场景并将所有得到的关于场景内物体的几何信息存储到一系列称为 `G-buffer` 的纹理中，比如位置，法线，颜色，高光等等。
2. Lighting Pass：渲染一个铺满屏幕的 Quad，在这次渲染中使用上 `Geometry Pass `生成的 `G-Buffer`

整体的流程如下所示：
![](assets/Learn%20OpenGL%20-%20Ch%2033%20Deferred%20Shading/image-20211227082817485.png)


延迟xu'a
