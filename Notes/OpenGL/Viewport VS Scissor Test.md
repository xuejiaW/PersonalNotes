---
tags:
    - OpenGL
created: 2021-12-14
updated: 2022-01-27
---
# Overview

通过一系列例子说明 [Viewport](Viewport.md) 和 [Scissor Test](Scissor%20Test.md) 的效果。

# Example

如在 NDC 空间有以下的输出，且指定屏幕未渲染部分为灰色， Clear Color 为白色：
![|300](assets/Viewport%20VS%20Scissor%20Test/image-20211208085005785.png)

如果将 Viewport 和 Scissor 范围都设置为全屏幕（最普遍情况），效果如下：
![|300](assets/Viewport%20VS%20Scissor%20Test/image-20211208085025284.png)

如果将两者都设置为屏幕中的一个小区域，效果如下：
![|300](assets/Viewport%20VS%20Scissor%20Test/image-20211208085039399.png)

如果将 Viewport 设置为全屏， Scissor 范围设置为一个小区域，则效果如下：
![|300](assets/Viewport%20VS%20Scissor%20Test/image-20211208085056169.png)

```ad-tip
示意图中灰绿色的三角形，仅仅是为了说明被渲染的三角形区域，并非真正的画出了灰绿色的三角形
```

如果将 Scissor 范围设置为全屏， Viewport 设置为一个小区域，则效果如下：
![|300](assets/Viewport%20VS%20Scissor%20Test/image-20211208085122359.png)

# Reference

[opengl - What is the purpose of glScissor? - Game Development Stack Exchange](https://gamedev.stackexchange.com/questions/40704/what-is-the-purpose-of-glscissor)