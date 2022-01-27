---
tags:
    - C++
created: 2022-01-05
updated: 2022-01-06
---

# Example

可使用如下的方式定义一个模板类：
```cpp
template <typename T>
class BlockQueue
{
  public:
    BlockQueue() : queue(){}
    ~BlockQueue() {}

    void Push(const T& data)
    {
        // ...
    }

    void BlockPop(T& data)
    {
        // ...
    }

  private:
    std::queue<T> queue;
};

```

对于模板成员函数而言，实现必须定义在头文件中[^1]，因为编译器在生成模板类时，必须能访问到模板函数的实现。

# Reference
[^1]: [c++ - Undefined reference error for template method - Stack Overflow](https://stackoverflow.com/questions/1111440/undefined-reference-error-for-template-method)