---
created: 2022-01-25
updated: 2022-01-25
tags:
    - Unity
    - UGUI
---

# Overview

`RectTransform` 是 Transform 对应的 2D Component，`RectTransform` 用来定义 UI 元素的位置，旋转，大小等信息，所有信息都会基于父物体得到。

![|500](assets/RectTransform/image-20220125231029155.png)


# Anchor
`锚点（Anchor）`用于父子物体的对齐，其在 Inspector 面板和 Scene 界面中分别如下表达：

|                                                                |                                                            |
| -------------------------------------------------------------- | ---------------------------------------------------------- |
| ![Inspector](assets/RectTransform/image-20220125231146698.png) | ![Scene](assets/RectTransform/image-20220125232054760.png) | 

在 Inspector 中`Anchor` 通过两个点 `Anchor Max` 及 `Anchor Min` 定义，根据这两个点可以计算出 `Scene` 中 `Anchor` 的四个点。如下所示：
![|400](assets/RectTransform/image-20220125232613417.png)

当使用鼠标拖动表示 `Anchor` 点的三角形时，Unity 会显示 `Anchor` 四个点基于父物体的比例guan'xi