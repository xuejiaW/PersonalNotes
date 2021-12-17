颜色缓冲，深度缓冲和模板缓冲都被存储在 `帧缓冲（Framebuffers）`中，当开发者不手动设置帧缓冲时，上述所有的缓冲都会存储到默认的帧缓冲中。当通过 `GLFW` 创建窗口时， `GLFW` 会自动的创建默认的帧缓冲。

当然OpenGL也提供了开发者自己定义帧缓冲以及颜色，深度，模板缓冲的方法。

# 创建帧缓冲

通过 `glGenFramebuffers` 创建帧缓冲：

```cpp
unsigned int fbo;
glGenFramebuffers(1, &fbo);
```

通过 `glBindFramebuffer` 绑定帧缓冲：

```cpp
glBindFramebuffer(GL_FRAMEBUFFER, fbo);
```

当绑定帧缓冲到 `GL_FRAMEBUFFER`后，之后所有关于帧缓冲的读和写操作都会针对于这个缓冲。

也可以通过绑定缓冲到 `GL_READ_FRAMEBUFFER` 和 `GL_DRAW_FRAMEBUFFER` 上，分别设定读操作（如 `glReadPixels`）的目标和写操作（如 `GlClear` 和 `glDrawElements`）的目标。

但绑定了帧缓冲后，还不能使用该帧缓冲，因为这个缓冲还不是完整的，对于一个完整的帧缓冲，他必须要：

1.  依附至少一个缓冲（颜色，深度，模板缓冲）
2.  至少有一个颜色附件（color attachment）
3.  所有的附件都是完整的（分配了内存）