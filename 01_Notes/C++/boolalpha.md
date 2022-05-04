---
tags:
    - C++
created: 2022-03-11
updated: 2022-03-12
---

`std::boolalpha` 是给 str 输出流设置上一个 Flag，当该 Flag 设上后，所有对输出流传入的 bool 值都会默认以字符表示，如下所示：
```cpp
bool b = true;
std::cout << std::boolalpha << b << std::endl;
std::cout << b << std::endl;
```

此时的输出为：
```text
true
true
```

可以通过 `std::noboolalpha` 将 flag 去除，如下所示：
```cpp
bool b = true;
std::cout << std::boolalpha << b << std::endl;
std::cout << b << std::endl;
std::cout << std::noboolalpha << b << std::endl;
std::cout << b << std::endl;
```

此时的输出为：
```text
true
true
1
1
```