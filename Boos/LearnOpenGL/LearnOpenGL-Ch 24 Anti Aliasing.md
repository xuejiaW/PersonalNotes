---
created: 2021-12-17
updated: 2021-12-18
---
 
 当渲染完一些物体后，可能会发现物体的边缘存在锯齿。锯齿是图像失真最常见的表现，减少失真的技术被称为 `Anti Aliasing` ，因为锯齿在各种失真表现中最为常见，所以 `Anti Aliasing` 常被翻译为抗锯齿。

图像的采样最小单位是像素，这是一个不连续的采样，像素的密集程度即是采样频率。如果图像的某一块频率很高（例如有颜色的跳变），而采样频率不够（未达到奈奎斯特采样频率），那么就会引起失真。

在光栅化时，会以每个像素的中点是否被图形覆盖来决定该物体是否要对这个像素的颜色做出贡献，该计算过程被称为 `Coverage` ，示意图如下：
![|400](assets/LearnOpenGL-Ch%2024%20Anti%20Aliasing/Untitled.png)

```ad-warning
`Coverage` 和 [Depth Testing](LearnOpenGL-Ch%2015%20Depth%20Testing.md) 中介绍的 `Occlusion` 共同决定了像素的可见性。
```

图中每个方块表示一个像素，方块中的点表示中心，点为红色表示像素中点在图形内，点为白色表示像素中心在图形外，采样的结果如下：
![|400](assets/LearnOpenGL-Ch%2024%20Anti%20Aliasing/Untitled%201.png)

# SSAA

`SSAA （Super Sample Anti-Aliasing）`会用比实际分辨率更高的分辨率来渲染场景（更高频率，消除了锯齿），然后再将图像下采样到实际分辨率。

但超采样将会有巨大的性能消耗，因为更高的分辨率更多的采样次数，无论是深度测试，模板测试，还是片元着色器的运行次数都会随着分辨率的上升而上升。

在上例中，如果使用了SSAA，上例中的每个方块会变的更小（同样的显示面积，像素数越多，像素大小越小），因此采样的精度会更高，最终锯齿会减少。

# MSAA

`MSAA（Multisamplaing Anti-Aliasing）` 的核心思想与 `SSAA` 类似，都是通过采样点的增加来减少锯齿。

但与 `SSAA` 不同的是，在 `MSAA` 中像素的数量仍然是不变的，但是每个像素会存在多个采样点，这些采样点被称为 `subsamples` ，如下所示：图中蓝色的是通过 `Coverage` 测试的 `subsamples` ，灰色的则是未通过的。MSAA的等级表示每个像素中 `subsamples` 的个数，如 `4X MSAA` 表示每个像素中有四个 `subsamples`。
![|400](assets/LearnOpenGL-Ch%2024%20Anti%20Aliasing/Untitled%202.png)

