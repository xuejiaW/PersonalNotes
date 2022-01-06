---
created: 2022-01-06
updated: 2022-01-06
---
# Overview

在之前的光照计算中，都添加了一个固定值作为全局光反射的模拟（Ambient Light）。在现实生活中，因为遮挡关系的存在，并非所有地方都受到相同的光。如墙角，小洞等地方因为被周围物体遮挡的原因，会显得较为昏暗。

`Screen-Space Ambient Occulsion（SSAO）` 就是模拟这种因遮挡关系导致不同全局光效果的技术。

如下为使用了 `SSAO` 与否的对比，可以看到右侧开启了 `SSAO` 的图像在墙角，电话亭背面处因为被遮挡的关系显得更暗，更符合现实情况：
![|500](assets/Learn%20OpenGL%20-%20Ch%2034%20SSAO/image-20220106080946026.png)

`SSAO` 技术用深度缓冲来决定一块区域是否被周围物体所遮挡，相较于真实的计算所有几何的遮挡关系虽然准确度存在差异，但能节省大量性能。

`SSAO` 同样依赖于 [后处理](Learn%20OpenGL%20-%20Ch%2019%20Framebuffers.md#后处理)。在渲染全屏的 Quad 时，SSAO 会为每个 Fragment 生成一个 `Occlusion Factor`，该参数基于周围 Fragments 的深度值计算，周围每有一个 Fragment 的深度大于当前 Fragment 的深度，值 +1。
