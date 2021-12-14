---
tags:
    - OpenGL
created: 2021-12-14
updated: 2021-12-15
---

# Viewport Test

Viewport 指目标绘制的屏幕空间范围，可以通过 `glViewport` 指定 Projection 后的 NDC Space 中的顶点该如何映射到 Screen Space 中。

`glViewport` 的定义如下所示，其中前两个形参指定目标区域的左下角的位置，后两个形参指定目标区域的宽高：

```cpp
void glViewport(GLint x, GLint y, GLsizei width, GLsizei height);
```

```ad-note
指定区域的右上角位置为 $(x+width, y+height)$
```

因此 `glViewport` 的作用是将 NDC Space 的横坐标的 $-1 \sim 1$ 范围转换到屏幕空间的 $x \sim x+width$ 范围内，同理将纵坐标的 $-1 \sim 1$ 转换到屏幕空间的 $y \sim y+height$ 范围内。

如在 [OpenGL-Projection Matrix](OpenGL-Projection%20Matrix.md) 中阐述，因为 [Frustum Clipping](OpenGL-Projection%20Matrix.md#^1150b2) 的存在，绘制的顶点数据不会超过 NDC Space， 也因此不会超过目标屏幕空间范围

但是对于非顶点数据，如 `glClear` 则影响的像素仍然可能超过 Viewport 指定的屏幕空间。为了限制像素影响的范围，则需要通过 `Scissor Test` 。