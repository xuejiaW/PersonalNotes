---
created: 2021-12-23
updated: 2021-12-27
tags:
    - C++
---

# Mutex

在 C++ 11 中可以通过 `std::mutex` 对线程进行加解锁操作，示例如下所示：
```cpp
std::mutex m;
int i = 0;
void MultiThreadFunction()
{
    m.lock();
    i++;
    m.unlock();
}
```

# Reference
[c++ - Mutex example / tutorial? - Stack Overflow](https://stackoverflow.com/questions/4989451/mutex-example-tutorial)

