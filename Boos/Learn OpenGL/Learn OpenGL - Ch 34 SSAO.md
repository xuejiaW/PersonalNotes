---
created: 2022-01-06
updated: 2022-01-15
---
# Overview

在之前的光照计算中，都添加了一个固定值作为全局光反射的模拟（Ambient Light）。在现实生活中，因为遮挡关系的存在，并非所有地方都受到相同的光。如墙角，小洞等地方因为被周围物体遮挡的原因，会显得较为昏暗。

`Screen-Space Ambient Occulsion（SSAO）` 就是模拟这种因遮挡关系导致不同全局光效果的技术。

如下为使用了 `SSAO` 与否的对比，可以看到右侧开启了 `SSAO` 的图像在墙角，电话亭背面处因为被遮挡的关系显得更暗，更符合现实情况：
![|500](assets/Learn%20OpenGL%20-%20Ch%2034%20SSAO/image-20220106080946026.png)

因为 `SSAO` 是基于屏幕空间的计算，相较于真实的计算所有几何的遮挡关系虽然准确度存在差异，但能节省大量性能。

`SSAO` 会在屏幕空间中为每个像素生成一个 `Occlusion Factor`，该数值越大，之后计算光照时该像素使用的 `Ambient Light` 系数就越低 ，以此体现几何的遮挡关系。

`Occlusion Factor` 的计算依赖于 `Screen-Space` 的 3D 位置信息，该信息可以通过 [G-buffer](Learn%20OpenGL%20-%20Ch%2033%20Deferred%20Shading.md#The%20G-buffer) 获得。

```ad-note
因为 `SSAO` 同样需要  [G-buffer](Learn%20OpenGL%20-%20Ch%2033%20Deferred%20Shading.md#The%20G-buffer) ，因此 `SSAO` 通常与 [Deferred Shading](Learn%20OpenGL%20-%20Ch%2033%20Deferred%20Shading.md) 一起使用。
```

```ad-note
此处 [G-buffer](Learn%20OpenGL%20-%20Ch%2033%20Deferred%20Shading.md#The%20G-buffer) 存储的位置是基于 `View-Space` 而非 `World-Space`，因为物体的遮挡关系会随着视线的变化而产生变化。
```

对于屏幕空间的每个像素而言，会为其生成一系列的采样点，每个采样点表示表示该像素在 `ViewSpace` 中的周围位置。通过比较采样点与该采样点在同屏幕空间中像素的 z 值，就能知晓该采样点是否会被几何遮挡。  

如一个像素屏幕空间中的位置是 $(0.29, 0.29)$，查询 `G-Buffer` 得该像素在 `View-Space` 的位置为 $(10.1,10.1,-10.1)$。该像素的一个采样点在 `View-Space` 的偏移量为 $(0.25,0.25,0.25)$，则该采样点在 `View-Space` 的位置为 $(10.35,10.35,-9.85)$。如果该采样点转换到屏幕空间中的位置是 $(0.3, 0.3)$，则再进一步通过 $(0.3,0.3)$ 查询该像素在 `G-Buffer` 中记录的 `View-Space` 位置为 $(10.35, 10.35, -8)$。即采样点的 $Z$ 值为 $-9.85$，对应在 `G-Buffer` 中的 $z$ 值为 $-8$，所以该采样点会被真实的几何所遮挡。每有一个采样点被遮挡，该像素的 `Occlusion Factor` +1。

```ad-important
在 OpenGL 的右手坐标系下， `View-Space` 的 Z 值都为负数，数值越大越靠近摄像机。
```

整个流程的示意图如下所示：
![曲线表示 G-Buffer 中的位置，黑色为当前点，灰色为被遮挡的采样点 | 500](assets/Learn%20OpenGL%20-%20Ch%2034%20SSAO/image-20220106082121010.png)

对于一个 Fragment 而言，如果采样的周围 Fragment 处于当前 Fragment 下方，则它必然会被遮挡，也就会造成 `Occlusion Factor` 过大。为了解决这个问题，应当只采样当前 Fragment 上半侧的其他 Fragments，通过法线方向决定上半侧的朝向。如下图所示，可以看到获取周围采样点的范围由之前的球变成了半球：
![|500](assets/Learn%20OpenGL%20-%20Ch%2034%20SSAO/image-20220106083942529.png)

```ad-note
对于一个 Fragment 而言，在基于该 Fragment 法线的 TBN 空间中，Z 值正数即表示在该 `Fragment `的上半侧。
```

`SSAO` 的精度取决于计算每个 Fragment 时取的周围 Fragments 的数量，数量太低则精度不够，会引发一种称为 `Banding` 的失真效果，但数量太高则会引发性能问题。

为了在采样 Fragments 数量尽量小的情况下（为节约性能）取得更好的效果，可以为采样的周围 Fragments 引入随机值。即对每个 Fragment，在采样它周围的 Fragments 时，随机将这些 Fragments 旋转一定角度，保证采样点并不会仅计算某个特定方向。但随机值的引入会导致噪声的产生，为了解决噪声问题，可以再对结果进行一个模糊化处理。

下图为采样值过少时的 `Banding` 现象，当引入随机值后的噪声表现，以及对噪声进行模糊处理后的结果：
![](assets/Learn%20OpenGL%20-%20Ch%2034%20SSAO/image-20220106082927518.png)

# Sample buffers
