---
created: 2022-01-06
updated: 2022-01-06
---
# Overview

在之前的光照计算中，都添加了一个固定值作为全局光反射的模拟（Ambient Light）。在现实生活中，因为遮挡关系的存在，并非所有地方都受到相同的光。如墙角，小洞等地方因为被周围物体遮挡的原因，会显得较为昏暗。

`Screen-Space Ambient Occulsion（SSAO）` 就是模拟这种因遮挡关系导致不同全局光效果的技术。

如下为使用了 `SSAO` 与否的对比，可以看到右侧开启了 `SSAO` 的图像在墙角，电话亭背面处因为被遮挡的关系显得更暗，更符合现实情况：
![|500](assets/Learn%20OpenGL%20-%20Ch%2034%20SSAO/image-20220106080946026.png)

`SSAO` 技术用 `Srceen-Space` 的深度缓冲来决定一块区域是否被周围物体所遮挡，相较于真实的计算所有几何的遮挡关系虽然准确度存在差异，但能节省大量性能。

```ad-note
`SSAO` 所有的计算都基于 `Screen-Space`，即它所计算的 Frgament 是指 [后处理](Learn%20OpenGL%20-%20Ch%2019%20Framebuffers.md#后处理) 中绘制整屏的 Quad 的 Fragment。该 Fragment 中实际表现的是 3D 空间中的几何，只不过将数据转换到了 `Screen-Space `。
```

`SSAO` 会为 Full-Screen Quad 的每个 Fragment 生成一个 `Occlusion Factor`，该数值基于周围 Fragments 的深度值计算，周围每有一个 Fragment 的深度大于当前 Fragment 的深度，值 +1，示意图如下所示。该数值越大，当前 Fragment 的 Ambient Light 系数就越低。

![曲线表示几何表面，黑色为当前 Fragment，灰色为深度更大的 Fragments | 500](assets/Learn%20OpenGL%20-%20Ch%2034%20SSAO/image-20220106082121010.png)

对于一个 Fragment 而言，如果采样的周围 Fragment 处于当前 Fragment 下方，则它的深度必然会低于当前 Fragment，也就会造成 `Occlusion Factor` 过大。为了解决这个问题，应当只采样当前 Fragment 上半侧的其他 Fragments，通过法线方向决定上半侧的朝向。如下图所示，可以看到获取周围采样点的范围由之前的球变成了半球：
![|500](assets/Learn%20OpenGL%20-%20Ch%2034%20SSAO/image-20220106083942529.png)

`SSAO` 的精度取决于计算每个 Fragment 时取的周围 Fragments 的数量，数量太低则精度不够，会引发一种称为 `Banding` 的失真效果，但数量太高则会引发性能问题。

为了在采样 Fragments 数量尽量小的情况下（为节约性能）取得更好的效果，可以为采样的周围 Fragments 引入随机值。即对每个 Fragment，在采样它周围的 Fragments 时，随机将这些 Fragments 旋转一定角度，保证采样点并不会仅计算某个特定方向。但随机值的引入会导致噪声的产生，为了解决噪声问题，可以再对结果进行一个模糊化处理。

下图为采样值过少时的 `Banding` 现象，当引入随机值后的噪声表现，以及对噪声进行模糊处理后的结果：
![](assets/Learn%20OpenGL%20-%20Ch%2034%20SSAO/image-20220106082927518.png)

# Sample buffers