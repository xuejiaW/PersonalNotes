---
tags:
    - OpenGL
created: 2021-12-14
updated: 2021-12-15
---
# Scissor Test

在 OpenGL 中，可以通过 `glEnable(GL_SCISSOR_TEST)` 开启 Scissor Test[^1]，并通过 `glScissor` 指定 Scissor Test 的范围。

`glScissor` 的定义如下，如同 `gkViewport`，其中前两个形参指定目标区域的左下角的位置，后两个形参指定目标区域的宽高：：

```cpp
void glScissor(	GLint x, GLint y, GLsizei width, GLsizei height);
```

超过了 Scissor 范围的像素会被直接丢弃，因此所有对像素影响的操作，都不会超过 `glScissor` 指定的范围。

`Scissor Test` 理论上发生在 Fragment Shader 后，但如同 Depth Test 在现代 GPU 中往往会在 Fragment Shader 前被执行一样（Early - Z），现代 GPU 中 `Scissor Test` 同样会发生在 Fragment Shader 前[^2]。


```ad-note
在一些 OpenGL 实现中，设置了 `glViewport` 的同时会自动设置 `glScissor` ，以此让 Viewport 与 Scissor 范围相同，但这种并不是 OpenGL 标准中的设定，因此并不能依赖这样的实现。
```


# Reference
[^1]:[Scissor Test - OpenGL Wiki (khronos.org)](https://www.khronos.org/opengl/wiki/Scissor_Test)

[^2]: [opengl - Why is scissor test behind fragment operation? - Stack Overflow](https://stackoverflow.com/questions/33808005/why-is-scissor-test-behind-fragment-operation)