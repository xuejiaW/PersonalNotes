---
created: 2022-01-09
updated: 2022-01-09
---

类似于 `int printf( const char* format, ... )` 的函数称为 `可变函数（Variadic functions）`

# Variadic Parameters

可变函数中的 `...` 表示可变形参，该形参可以接纳任意数量，任意类型的形参。

为了解析 `...` 形参，在 `<cstarg>` 头文件中定义了一系列 Macros：

| Macros    | 说明                                                                      |
| -------- | --------------------------------------------------------------------- |
| va_start | enables access to variadic function arguments                         |
| va_arg   | accesses the next variadic function argument                          |
| va_copy  | makes a copy of the variadic function arguments                          |
| va_end   | ends traversal of the variadic function arguments                     |
| va_list  | holds the information needed by va_start, va_arg, va_end, and va_copy |

如下为使用上述的 `Macros` 实现一个简易的 `printf` 函数的示例：
```cpp
void simple_printf(const char* fmt...)  // C-style "const char* fmt, ..." is also valid
{
    va_list args;
    va_start(args, fmt);

    while (*fmt != '\0')
    {
        if (*fmt == 'd')
        {
            int i = va_arg(args, int);
            std::cout << i << '\n';
        }
        else if (*fmt == 'f')
        {
            double d = va_arg(args, double);
            std::cout << d << '\n';
        }
        ++fmt;
    }

    va_end(args);
}
```

# Variadic Parameters in Macro

```ad-note
该功能在 C99 编译器标准中定义
```

在 Macro 中，可以使用 `__VA_ARGS` 表示 `...`，如下代码：
```cpp
#define debug(...) printf(__VA_ARGS__)
```


# Referecne

[Variadic functions - cppreference.com](https://en.cppreference.com/w/cpp/utility/variadic)