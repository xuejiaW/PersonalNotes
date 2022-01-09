---
created: 2022-01-09
updated: 2022-01-09
---
# Overview

在使用 NDK 的 Android Native 开发中，可使用 `__android_log_print` 进行 Log 输出，该函数的原型如下：
```cpp
__android_log_print(int prio, const char *tag, const char *fmt, ...)
```

第一个形参表示 Log 的优先级，第二个形参表示输出 Log 时的 Tag。如有以下的 Log 输出：
```text
01-09 08:55:39.127  5626  5651 I Unity   : fps is 91
```

其中 `I` 表示该 Log 的优先级为 `ANDROID_LOG_INFO`，`Unity` 即为设定的 Tag。


# Reference
[Logging  |  Android NDK  |  Android Developers](https://developer.android.com/ndk/reference/group/logging)