---
tags:
    - Unity
---

# Overview

UGUI的 `Layout System`是让UI素材可以根据内容自动的调节大小，如通过 `Content Size Fitter` 组件可以自动根据文字的长度调整 `Text` 组件的大小，或让UI素材可以统一的被特定的组件调整，如在`Vertical Layout Group` 组件下的子物体都将受其控制。

|                                                                      |                                                                          |
| -------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| ![](assets/UGUI%20Layout%20Elements%20or%20Controllers/Untitled.png) | ![](assets/UGUI%20Layout%20Elements%20or%20Controllers/Untitled%201.png) | 

如 `Text` ， `Image` 这样的作为被调整对象的组件，称为 `Layout Elements` 。

如 `Vertical Layout Group` 这样的调整其他元素的组件，称为 `Layout Controller` 。

## Layout Elements

所有带有 `Rect Transform` 组件的UI元素都是 `Layout Elements` ，每个 `Layout Elements` 理论上都包含如下六个参数，这些参数的默认值都为0：

-   Minimum width
-   Minimum height
-   Preferred width
-   Preferred height
-   Flexible width
-   Flexible height

```ad-warning
虽然带有 `Rect Transform` 组件的UI元素都算是 `Layout Elements` ，但上述的六个参数实际上是通过 `ILayoutElement` 接口获取的。如果UI元素未继承 `ILayoutElement` ，则这六个参数是通常会根据 `RectTransform` 的大小计算得到。
```

一些组件会这些参数，如 `Text` 会根据内容调整 `Preferred width` 和 `Preferred height` 。

组件 `Layout Controller` 可修改同 `Rect Transform` 下其他UI元素的这六个参数。

## Layout Controllers

典型的 `Layout Controllers` 如 `Content Size Fitter`。该组件会将同物体下的其他UI素材的 Preferred Size 或 Minimum Size 作为它们的 Size。

```ad-warning
这里的 Size 指 Width 或 Height
```

`Layout Controller` 通常需要实现如下两个接口之一：

-   `ILayoutGroup` ：表示该组件可以修改它的子物体的 `RectTransform`
-   `ILayoutSelfController` ：表示该组件可以修改自己的 `RectTransform`

`Layout Controllers` 通常会通过 Unity 的 `DrivenRectTransformTracker` 功能将 `RectTransform` 中的部分内容置灰，不让其被修改。

![](assets/UGUI%20Layout%20Elements%20or%20Controllers/Untitled%202.png)