---
created: 2022-01-16
updated: 2022-01-17
---
# Overview

在 C++ 中，可以通过如下的代码生成一定范围的随机数：

```cpp
std::uniform_real_distribution<float> randomFloats(0.0, 1.0);
std::default_random_engine generator;
```

之后可以通过 `randomFloats(generator)` 生成在范围 $0.0 \ sim 1.0$ 内的随机数。