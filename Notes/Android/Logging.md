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

第一个形参表示 Log 的优先级，第二个形参表示输出 Log 时的 Tag。

如有以下的 Log 输出：
```text
01-09 08:55:39.127  5626  5651 I Unity   : fps is 91 90
```

其中 `I` 表示该 Log 的优先级为 `ANDROID_LOG_INFO`，`Unity` 即为设定的 Tag。

后两个形参表示输出的内容，`fmt` 表示格式化的 string，`...` 为 [Variadic Parameters](../C++/Variadic%20functions.md#Variadic%20Parameters) 为需要被格式化的数据，如语句：
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

如果要将 android log 通过函数封装，则不能使用 `__android_log_print` 而需要使用 `__android_log_vprint`。 `__android_log_vprint` 的原型如下所示：
```cpp
__android_log_vprint(int prio, const char *tag, const char *fmt, va_list ap)
```

其与 `__android_log_print` 的差别在于最后一个形参从 `...` 变为了 `va_list`。

封装函数的实例如下所示：
```cpp
void YVRLog::StdInfo(const char *format, ...)
{
    va_list args;
    va_start(args, format);
    __android_log_vprint(priority, tag, format, args);
    va_end(args);
}
```

# Reference
 [Logging  |  Android NDK  |  Android Developers](https://developer.android.com/ndk/reference/group/logging)
