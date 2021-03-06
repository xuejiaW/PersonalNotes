---
created: 2022-01-25
updated: 2022-02-12
cssclass: [table-border]
tags:
    - Unity
    - UGUI
---

# Overview

`RectTransform` 是 Transform 对应的 2D Component，`RectTransform` 用来定义 UI 元素的位置，旋转，大小等信息，所有信息都会基于父物体得到。

![|500](assets/RectTransform/image-20220125231029155.png)

# Anchors

`Anchors` 用于父子物体的对齐，一个物体的 `Anchors` 表示它需要与父物体的哪个区域相对齐。其在 Inspector 面板和 Scene 界面中分别如下表达：

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

如当物体的 `Anchor Max` 与 `Anchor Min`   都为 $(0.5,0.5)$，此时它会与父物体的 $(0.5,0.5)$ 点对齐。如下所示，无论父物体如何变化，子物体与 $(0.5,0.5)$ 点的关系都不会变，子物体的尺寸也不会变化：
![](assets/RectTransform/Anchor_08.gif)

当 `Anchor Max` 与 `Anchor Min`   都为 $(0.0,1.0)$ 时，子物体与父物体的左上角对齐，如下所示：
![](assets/RectTransform/Anchor_09.gif)



## 相对布局

当相对布局时，`Left / Top / Right / Bottom` 分别表示 UI 元素的 `左/上/右/下` 边缘距离锚点所构成的 `左/上/右/下` 的距离。

效果如下所示：

|     |     |
| --- | --- |
|  ![](assets/RectTransform/image-20220126000437133.png)  |  ![](assets/RectTransform/image-20220126000442564.png)  | 


当 `Anchor Min` 值为 $(0.0,0.0)$ ，`Anchor Max` 值为 $(1.0,0.0)$ 时，子物体会对齐物体的父物体的左下角和右下角，在这种情况下，如果改变父物体的宽度，子物体的宽度也会一同变化，如下所示：
![](assets/RectTransform/Anchor_10.gif)

## Anchor Presets

点击 RectTransform 左上角，可以开启 `Anchor Presets` 界面，界面中列出了常用的 `Anchor`：
![|500](assets/RectTransform/image-20220126094652557.png)


# Pivot

`支点（Pivot）` 用来影响当前物体旋转，缩放及修改位置的支点。当选择了 `Rect Tool` 和 `Pivot` 时，`Pivot` 会在 Scene 中以蓝色空心小圈显示：

|                                                       |                                                       |
| ----------------------------------------------------- | ----------------------------------------------------- |
| ![](assets/RectTransform/image-20220126230525862.png) | ![](assets/RectTransform/image-20220126230722014.png) |


当 `Pivot` 为 $(0.5,0.5)$ 时，缩放与旋转都基于物体的中心点，如下所示：
![](assets/RectTransform/Pivot_02.gif)

当 `Pivot` 为 $(0,1)$ 时，缩放与旋转则会基于物体的左上角，如下所示：
![](assets/RectTransform/Pivot_03.gif)

# Edit Mode

## Blur Print Mode

蓝图模式通过在 `RectTransform` 的如下按钮启用：
![|500](assets/RectTransform/image-20220126231416341.png)

通常来说，在 `Rect Tool` 模式下，可以通过蓝色实心小圈调整 UI 的大小：
![](assets/RectTransform/GIF%201-26-2022%2011-30-35%20PM.gif)

当蓝图模式开启后，`Rect Tool` 模式下，帮助移动的蓝色标识点会无视物体的旋转和缩放，如下所示：

![](assets/RectTransform/image-20220126234213646.png)

## Raw Edit Mode

通常在修改物体的 `Anchors` 和 `Pivot` 时，该物体基于父物体的位置并不会发送变化，因此物体本地的 `Pos X/Y` 值等会随着 `Anchors` 和 `Pivot` 的改变而改变，如下所示：
![](assets/RectTransform/GIF%201-26-2022%2011-44-49%20PM.gif)

当开启 `Raw Edit Mode` 后，则会保证 `Pos X/Y` 等数值不变，而变化物体相对于父物体的位置，如下所示：
![](assets/RectTransform/GIF%201-26-2022%2011-51-26%20PM.gif)


# APIs

## GetLocalCorners

该函数返回 RectTransform 的四个顶点的本地位置，顺序为左下角，左上角，右上角，右下角。

返回的位置的基于 [Pivot](#Pivot) 点为原点。即如果 [Pivot](#Pivot) 点定义为左上角，则返回的左上角数据为 $(0,0,0)$，如果 [Pivot](#Pivot) 点定义为右上角，则返回的右上角数据为 $(0,0,0)$，其他情况类似。

# Reference

[Unity UGUI 原理篇(三)：RectTransform | ARKAI Studio](https://www.arkaistudio.com/blog/2016/05/02/unity-ugui-%E5%8E%9F%E7%90%86%E7%AF%87%E4%B8%89%EF%BC%9Arecttransform/)