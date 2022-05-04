---
tags:
    - C++
created: 2022-03-11
updated: 2022-03-12
---

```ad-note
C++ 17 之后支持的特性
```

`std::optional` 有点像 C# 中的可空类型。

对于类型 `T` 可以构建一个 `std::optional<T>`，并通过 `has_value` 判断是否真的有值，如下所示：
```cpp
std::cout << std::boolalpha;
std::optional<int> value;
std::cout << value.has_value() << std::endl;
value = 0;
std::cout << value.has_value() << std::endl;
```

此时输出为：
```text
false
true
```

# Value

- 此处用了 [boolalpha](boolalpha.md) 保证输出的 bool 值是以字符形式

可以使用 `*` 获取 `optional` 中的值，但当一个 `optional` 未赋值时，对其使用 `*` 的结果时未定义的。因此为了安全性，建议使用 `value` 获取值，如果 `optional` 未赋值，该函数会产生 `std::bad_optional_access` 错误。

```cpp
std::optional<int> opt = {};

try
{
	int n = opt.value();
}
catch (const std::bad_optional_access& e)
{
	std::cout << e.what() << '\n';
}

try
{
	opt.value() = 42;
}
catch (const std::bad_optional_access& e)
{
	std::cout << e.what() << '\n';
}

opt = 43;
std::cout << *opt << '\n';

opt.value() = 44;
std::cout << opt.value() << '\n';
```

此时结果为：
```text
Bad optional access
Bad optional access
43
44
```

# Value_or
可以使用 `value_or(T)` 函数对一个可能为空的 `optional` 取值，当失败时则会使用默认值。示例如下：
```cpp
std::optional<int> value;
std::cout << value.value_or(2) << std::endl;
value = 1;
std::cout << value.value_or(2) << std::endl;
```

此时结果为：
```cpp
2
1
```

# Reference

[std::optional<T>::value - cppreference.com](https://en.cppreference.com/w/cpp/utility/optional/value)