---
tags:
    - Android
created: 2022-01-09
updated: 2022-01-09
---

# EGL Context Shared

EGL 的 Context 是线程相关的，因此在一个线程中创建的资源需要在另一个线程中使用就需要进行 `Context Share`。

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
    eglMakeCurrent(threadBDisplay, EGL_NO_SURFACE,EGL)
    ```


