---
created: 2021-12-26
updated: 2022-01-27
---
# Creation

`Default Framebuffer` 就是 `Framebuffer 0`，当 OpenGL 的上下文被建立后，会自动被创建。

因为 OpenGL 的上下文建立是平台相关的，所以通常 `Default Framebuffer` 的建立也与平台相关，如 [GLFW](../../Books/Learn%20OpenGL/Ch%2001%20Hello%20Window.md#初始化GLFW)  库中在创建 Window 时就自动创建了 `Default Framebuffer` 。

# Color buffers

一个 `Default Framebuffer` 有四个颜色缓冲， `GL_FRONT_LEFT`， `GL_BACK_LEFT`， `GL_FRONT_RIGHT`， 和 `GL_BACK_RIGHT` 。 其中 Right 的两个 Buffer 仅在开启了 Stereoscopic Rendering 时有用，当未开启时仅使用 Left 的两个 Buffer，且对于 Right Buffer 的读写操作都会出错。

## Aliases

对于这四个颜色缓冲，OpenGL 还定义了一系列别名，这些别名默认寻找最 Left 和 Front 的缓冲，如下：

| Alias             | Real_Image     |
| ----------------- | -------------- |
| GL_LEFT           | GL_FRONT_LEFT  |
| GL_RIGHT          | GL_FRONT_RIGHT |
| GL_FRONT          | GL_FRONT_LEFT  |
| GL_BACK           | GL_BACK_LEFT   |
| GL_FRONT_AND_BACK | GL_FRONT_LEFT  |

## Swap Buffer

四个缓冲中的 Front 和 Back Buffer 就对应 [Swap Chain](../Computer%20Graphics/Swap%20Chain.md)  中的多缓冲。其中的 `Front Buffer` 就是上屏的缓冲， `Back Buffer` 就是渲染的目标缓冲。平台相关的 `Swap Buffer` 操作就是快速的切换这两个缓冲。

```ad-warning
并不建议直接向 `Front Buffer` 中读取和写入数据
```

OpenGL 并不要求 Swap Buffer 做到真正的交换两个缓冲，即交换后 `Back Buffer` 中有 `Front Buffer` 内容，而 `Font Buffer` 中有 `Back Buffer` 的内容。 OpenGL 中仅要求交换后 `Front Buffer` 中有之前 `Back Buffer` 中的内容即可。

```ad-note
Sterero Rendering 时，对于 `Left Buffer` 和 `Right Buffer` 都会做各自的 Swap Buffer
```

# Depth buffer

Default Framabuffer 可以包含 Depth Buffer，用来进行深度测试。对于 Default Framebuffer 中 Depth Buffer 的精度在创建 OpenGL 上下文时通过参数决定。

Default Framebuffer 中的 Depth Buffer，可以通过 `GL_DEPTH` 进行查询。

```ad-note
Sterero Rendering 时仅有一块 Depth Buffer，在对 Left Buffer 和 Right Buffer 渲染时共享使用。
```

# Stencil buffer

Default Framabuffer 可以包含 Stencil Buffer，用来进行模板测试。对于 Default Framebuffer 中 Stencil Buffer 的精度在创建 OpenGL 上下文时通过参数决定。

Default Framebuffer 中的 Stencil Buffer，可以通过 `GL_STENCIL` 进行查询。
```ad-note
Sterero Rendering 时仅有一块 Stencil Buffer，在对 Left Buffer 和 Right Buffer 渲染时共享使用。
```

# Multisample Framebuffer

Default Framebuffer 也可以开启 MSAA，但这同样要求在创建 OpenGL 上下文时就指定 MSAA 的等级。

因此在 [Anti Aliasing](../../Books/Learn%20OpenGL/Ch%2024%20Anti%20Aliasing.md) 中，如果是对于 `Framebuffer 0` 开启 MSAA，就需要在 [GLFW 初始化窗口时指定 MSAA](../../Books/Learn%20OpenGL/Ch%2024%20Anti%20Aliasing.md#MSAA%20in%20GLFW) 。

# Reference

[Default Framebuffer - OpenGL Wiki (khronos.org)](https://www.khronos.org/opengl/wiki/Default_Framebuffer)