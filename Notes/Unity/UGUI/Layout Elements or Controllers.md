---
tags:
    - Unity
created: 2022-01-25
updated: 2022-01-25
---

# Overview

UGUI的 `Layout System`是让UI素材可以根据内容自动的调节大小，如通过 `Content Size Fitter` 组件可以自动根据文字的长度调整 `Text` 组件的大小，或让UI素材可以统一的被特定的组件调整，如在`Vertical Layout Group` 组件下的子物体都将受其控制。

|                                                                      |                                                                          |
| -------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| ![](assets/UGUI%20Layout%20Elements%20or%20Controllers/Untitled.png) | ![](assets/UGUI%20Layout%20Elements%20or%20Controllers/Untitled%201.png) | 

如 `Text` ， `Image` 这样的作为被调整对象的组件，称为 `Layout Elements` 。

如 `Vertical Layout Group` 这样的调整其他元素的组件，称为 `Layout Controller` 。

# Layout Elements

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

# Layout Controllers

典型的 `Layout Controllers` 如 `Content Size Fitter`。该组件会将同物体下的其他UI素材的 Preferred Size 或 Minimum Size 作为它们的 Size。

```ad-warning
这里的 Size 指 Width 或 Height
```

`Layout Controller` 通常需要实现如下两个接口之一：

-   `ILayoutGroup` ：表示该组件可以修改它的子物体的 `RectTransform`
-   `ILayoutSelfController` ：表示该组件可以修改自己的 `RectTransform`

`Layout Controllers` 通常会通过 Unity 的 `DrivenRectTransformTracker` 功能将 `RectTransform` 中的部分内容置灰，不让其被修改。

![|400](assets/UGUI%20Layout%20Elements%20or%20Controllers/Untitled%202.png)

# Layout 计算流程

1.  从子物体开始自下而上的调用每个元素的 `ILayoutElement.CalculateLayoutInputHorizontal` 获取该元素的 minimum/preferred/flexible 宽度
2.  从父物体开始自上而下的计算需要设置的宽度值，并通过 `ILayoutController.SetLayoutHorizontal` 设置宽度。
3.  从子物体开始自下而上的调用每个元素的 `ILayoutElement.CalculateLayoutInputVertical` 获取该元素的 minimum/preferred/flexible 高度
4.  从父物体开始自上而下的计算需要设置的宽度值，并通过 `ILayoutController.SetLayoutVertical` 设置高度。

```ad-warning
因为流程是先计算宽度再计算高度，因此对于高度的计算有时会依赖于宽度，如 `Aspect Ratio Fitter` 限制比例，因此会根据计算得到的宽度再计算高度。
```

# Layout Rebuild

当 Layout 相关的数据发生变化时，就需要重新计算Layout。重新计算Layout可以通过调用如下命令触发：

```csharp
LayoutRebuilder.MarkLayoutForRebuild (transform as RectTransform);
```

```ad-warning
当调用该接口后，Rebuild操作并不会马上发生，但会保证在渲染前发生。因此如果在更新帧的Update函数中检查物体的位置或大小，这些参数仍然未变。
```

通常重新计算Layout会发生在以下时机：

-   Layout相关属性发生变化
-   OnEnable
-   OnDisable
-   OnRectTransformDimensionsChange
-   OnValidate （仅在Editor时触发的函数）
-   OnDidApplyAnimationProperties

## Reference

[Auto Layout](https://docs.unity3d.com/Packages/com.unity.ugui@1.0/manual/UIAutoLayout.html)