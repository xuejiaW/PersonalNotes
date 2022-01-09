---
created: 2022-01-09
updated: 2022-01-09
---

类似于 `int printf( const char* format, ... )` 的函数称为 `可变函数（Variadic functions）`

# Variadic Parameters

可变函数中的 `...` 表示可变形参，该形参可以接纳任意数量，任意类型的形参。

为了解析 `...` 形参，在 `<cstarg>` 头文件中定义了一系列函数：

|          |                                               |
| -------- | --------------------------------------------- |
| va_start | enables access to variadic function arguments |
| va_arg   | accesses the next variadic function argument  |
| va_copy  | accesses the next variadic function argument  |
| va         |                                               |

# Referecne

[Variadic functions - cppreference.com](https://en.cppreference.com/w/cpp/utility/variadic)