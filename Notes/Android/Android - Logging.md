---
created: 2022-01-09
updated: 2022-01-09
tags:
    - Android
---

在使用 NDK 的 Android Native 开发中，可使用 `__android_log_print` 进行 Log 输出。

# __android_log_print

`__android_log_print` 的函数的原型如下：
```cpp
__android_log_print(int prio, const char *tag, const char *fmt, ...)
```

第一个形参表示 Log 的优先级，第二个形参表示输出 Log 时的 Tag。如有以下的 Log 输出：
```text
01-09 08:55:39.127  5626  5651 I Unity   : fps is 91 90
```

其中 `I` 表示该 Log 的优先级为 `ANDROID_LOG_INFO`，`Unity` 即为设定的 Tag。

后两个形参表示输出的内容，`fmt` 表示格式化的 string，`...` 为不定形参为需要被格式化的数据，如语句：
```cpp
__android_log_print(ANDROID_LOG_ERROR, "TexMgr", "fps is %d %d", 91, 90);
```

其中 `fps is %d %d` 即为 `fmd`，后续的 `91` 和 `90` 即为不定形参。

# Macro 封装

可使用 `Macro` 简化 Log 的输出，如下：

```cpp
#define LOG_TAG "TexMgr"
#define LOGD(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)
```

对于外部调用者而言，直接使用 `LOGD` 即可，如：
```cpp
LOGD("Called %s", __FUNCTION__);
```

# 函数封装

对于上述

# Reference
[Logging  |  Android NDK  |  Android Developers](https://developer.android.com/ndk/reference/group/logging)