---
tags:
    - C++
created: 2022-01-05
updated: 2022-01-05
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