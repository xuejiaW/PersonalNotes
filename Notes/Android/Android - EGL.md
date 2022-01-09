---
tags:
    - Android
created: 2022-01-09
updated: 2022-01-09
---

# EGL Context Shared

EGL 的 Context 是线程相关的，因此在一个线程中创建的资源需要在另一个线程中使用就需要进行 `Context Share`。

如有 `Thread A` 和 `Thread B` 两个线程，`Thread A` 为已经创建了的 EGL Context 的线程，需要将 EGL Context 共享给 `Thread B`，过程如下：

1. 在 `Thread A` 中需要先获取当前线程的 Context 和 Display
    ```cpp
    EGLContext threadAContext = eglGetCurrentContext();
    EGLDisplay threadADisplay = eglGetCurrentDisplay();
    ```
2. 在 `Thread B` 中
## 
