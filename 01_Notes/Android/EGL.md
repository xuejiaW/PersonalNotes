---
tags:
    - Android
created: 2022-01-09
updated: 2022-01-09
---

# Overview

EGL 是 OpenGL ES 和 操作系统间的一个中间层，其只要包含 `Display`，`Context`，`Surface` 概念。

## Display

`Display` 用来连接操作系统的窗口系统。

## Context

`Context` 是一个容器，用来存储 OpenGL ES 相关的输入，主要包括：
- 状态信息：Viewport，Depth Range，Clear Color，VBO.....
- 命令缓冲

## Surface 

Surface 用来存储 OpenGL ES 相关的输出数据，其中包含 `Color Buffer`，`Depth Buffer`，`Stencil Buffer`。


# EGL Context Shared

EGL 的 Context 是线程相关的，因此在一个线程中创建的资源需要在另一个线程中使用就需要进行 `Context Share`。

```ad-note
Context Shared 仅能共享 Context 中状态信息，命令缓冲无法被共享。

因此使用共享 Context 的线程中操作完成后需要推荐调用 `glflush` 操作。
```

如有 `Thread A` 和 `Thread B` 两个线程，`Thread A` 为已经创建了的 EGL Context 的线程，需要将 EGL Context 共享给 `Thread B`，过程如下：

1. 在 `Thread A` 中需要先获取当前线程的 Context 和 Display：
    ```cpp
    EGLContext threadAContext = eglGetCurrentContext();
    EGLDisplay threadADisplay = eglGetCurrentDisplay();
    ```

2. 在 `Thread B` 中根据 `TheadA` 中得到的 Display 和 Context 创造新的 Context：
    ```cpp
    int CONFIG_ATTRIBS[] = {EGL_RED_SIZE,     5,   // Red bit
                            EGL_GREEN_SIZE,   6,   // Green bit
                            EGL_BLUE_SIZE,    5,   // Blue bit
                            EGL_DEPTH_SIZE,   16,  // Depth bit
                            EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
                            EGL_NONE};

    EGLConfig config;
    int count;
    eglChooseConfig(targetEnv.display, CONFIG_ATTRIBS, &config, 0, &count);

    int contextAttrs[] = {EGL_CONTEXT_CLIENT_VERSION, 3, EGL_NONE};

    EGLContext threadBContext = eglCreateContext(targetEnv.display, config, targetEnv.context, contextAttrs);
    EGLDisplay threadBDisplay = threadADisplay;
    ```

3. 在 `Thread B` 中根据新的 Context 切换上下文：
    ```CPP
    eglMakeCurrent(threadBDisplay, EGL_NO_SURFACE,EGL_NO_SURFACE, threadBContext);
    ```

    ```ad-tip
    如果在 `Thread B` 中不需要进行绘制和读取 Framebuffer 0 的操作，则将 Read/Write Surface 设为 EGL_NO_SURFACE 即可
    ```

EGL Context 的共享是双向的，当 `Thread A` 和 `Thread B` 共享后， `A` 中创建的资源 `B` 可以用，`B` 中创建的资源在 `A` 中也可以用。

# Reference

[multithreading - egl - Can context be shared between threads - Stack Overflow](https://stackoverflow.com/questions/11726650/egl-can-context-be-shared-between-threads)

[談談eglMakeCurrent、eglSwapBuffers、glFlush和glFinish | 程式前沿 (codertw.com)](https://codertw.com/%E7%A8%8B%E5%BC%8F%E8%AA%9E%E8%A8%80/747105/)