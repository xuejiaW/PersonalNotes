---
created: 2021-12-20
updated: 2021-12-22
tags:
    - Unity
    - Catlike
---

# Rendering Things

Unity 场景内的每个物体本质上都是通过 `Mesh` 进行的渲染。

`Mesh` 最少需要一系列顶点和一系列用来连接这些顶点的三角形定义构成。

在 Unity 中如果渲染一个 Mesh，最少需要两个组件 `Mesh Filter` 和 `Mesh Renderer`，前者会包含对 Mesh 的引用，后者会负责 Mesh 的真正渲染。
![|400](assets/Mesh%20Basics%20-%20Procedural%20Grid/image-20211222083208337.png)



# Creating a Grid of Vertices

