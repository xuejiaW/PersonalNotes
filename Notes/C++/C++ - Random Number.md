# Overview

在 C++ 中，可以通过如下的代码生成一定范围的随机数：
```cpp
std::uniform_real_distribution<float> randomFloats(0.0, 1.0);
std::default_random_engine generator;
```