---
tags:
    Computer-Graphics
created: 2021-12-30
updated: 2021-12-31
---

# Triangle Rasterization Rules

在 OpenGL 和 D3D 中，对于三角形的光栅化都依赖于 `Top - Left` 规则，即如果一个像素落在三角形内部，或三角形的上边缘或左边缘，则该像素会作为三角形光栅化的结果。其中三角形上边缘和左边缘的定义为：

- 上边缘：如果三角形的一条边是水平的，且高于其他的边，则该边是上边缘

- 左边缘：如果三角形的一条边是非水平的，且在三角形的左侧，则该边是左边缘。

```ad-note
一个三角形可以有一条或两条左边缘
```

如下是一系列像素和两个三角形，其中黑色的点属于右测的三角形的光栅化的结果，灰色的点属于左侧三角形光栅化的结果。

![|400](assets/Computer%20Graphics%20-%20Triangle%20Rasterization%20Rules/Untitled.png)

```ad-note
对角线上的点在左侧三角形的右边缘上，在右侧三角形的左边缘上，因此属于右侧的三角形
```

```ad-note
如果一个像素的中心处在三角形的左边缘和右边缘交界处，则该像素不算是三角形光栅化的结果，如左图中的 (5,5)。
```

如下为更多三角形光栅化的实例，其中浅灰色和深灰色的像素都表示属于三角形光栅化的结果，浅灰色和深灰色只不过为了区分这像素究竟相邻三角形的哪一个：
![|500](assets/Computer%20Graphics%20-%20Triangle%20Rasterization%20Rules/Untitled%201.png)

# Reference

[Rasterization Rules (Direct3D 9) - Win32 apps | Microsoft Docs](https://docs.microsoft.com/en-us/windows/win32/direct3d9/rasterization-rules)

[Rasterization Rules - Win32 apps | Microsoft Docs](https://docs.microsoft.com/en-us/windows/win32/direct3d11/d3d10-graphics-programming-guide-rasterizer-stage-rules)