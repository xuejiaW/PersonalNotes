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

![](assets/RectTransform/image-20220125231146698.png)

`锚点（Anchor）`用于父子物体的对齐。`Anchor` 通过两个点 `Anchor Max` 及 `Anchor Min` 定义，根据这两个点可以