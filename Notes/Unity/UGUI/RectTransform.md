---
created: 2022-01-25
updated: 2022-01-26
tags:
    - Unity
    - UGUI
---

# Overview

`RectTransform` 是 Transform 对应的 2D Component，`RectTransform` 用来定义 UI 元素的位置，旋转，大小等信息，所有信息都会基于父物体得到。

![|500](assets/RectTransform/image-20220125231029155.png)

# Anchors
`Anchors` 用于父子物体的对齐，其在 Inspector 面板和 Scene 界面中分别如下表达：

|                                                                |                                                            |
| -------------------------------------------------------------- | ---------------------------------------------------------- |
| ![Inspector](assets/RectTransform/image-20220125231146698.png) | ![Scene](assets/RectTransform/image-20220125232054760.png) |

在 Inspector 中 `Anchors` 通过 `Anchor Max` 及 `Anchor Min` 定义，`Anchors` 的四个点都可以根据这两个点算出。如下所示：
![|400](assets/RectTransform/image-20220125232613417.png)

当使用鼠标拖动表示 `Anchor` 点的三角形时，Unity 会显示 `Anchors` 基于父物体的比例关系：
![|500](assets/RectTransform/GIF%201-25-2022%2011-32-43%20PM.gif)

```ad-note
`Insepctor`中的值即为该比例关系的归一化数值。
```

针对 `Anchor Max` 和 `Anchor Min` 值相同与不同的情况，Unity 会使用绝对或相对布局计算子元素的位置，对应的 Inspector 面板也不同，如下所示：

|                                                               |                                                               |
| ------------------------------------------------------------- | ------------------------------------------------------------- |
| ![绝对布局](assets/RectTransform/image-20220125233931659.png) | ![相对布局](assets/RectTransform/image-20220125234037439.png) |

绝对和相对布局可以针对单一的轴向，如下情况 `Anchor Max` 和 `Anchor Min` 的 X 轴值不同，Y 轴值相同，因此 X 轴为相对布局，Y 轴为绝对布局：
![|500](assets/RectTransform/image-20220125235329968.png)

## 绝对布局

绝对布局的情况下，四个 `Anchors` 表示的是同一个点。 `width` 和 `height` 即为当前 UI 元素的宽和高，且该宽高与父物体无关。即无论父物体的大小，当前 UI 的宽高都是不变的。

`Pos X/Y/Z` 三个值表示该 UI 元素的 [Pivot](#Pivot) 距离 `Anchors` 点的距离。

## 相对布局

当相对布局时，`Left / Top / Right / Bottom` 分别表示 UI 元素的 `左/上/右/下` 边缘距离锚点所构成的 `左/上/右/下` 的距离。

效果如下所示：

|     |     |
| --- | --- |
|  ![](assets/RectTransform/image-20220126000437133.png)  |  ![](assets/RectTransform/image-20220126000442564.png)  | 
# Pivot