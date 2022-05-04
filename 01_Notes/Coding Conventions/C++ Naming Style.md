---
tags:
    - Coding-Conventions
    - C++
created: 2022-03-19
updated: 2022-03-29
---

# Variables

## Common Variable names

以 `lower_camel` 风格

```cpp
std::string table_name;
```

## Class Data Members

以 `lower_camel_` 风格，无论是否是 static 与否：
```cpp
class TableInfo
{
  ...
 private:
    std::string table_name_;
};
```

## Struct Data Members

以 `lower_camel` 风格：
```cpp
struct UrlTableProperties
{
    std::string name;
};
```

## Constant Names

以 `kUpperCamerl` 风格：
```cpp
const int kDaysInAWeek = 7;
```

# Function Names




# Reference

[Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html#Variable_Names)