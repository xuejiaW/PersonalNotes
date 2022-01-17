---
created: 2021-12-23
updated: 2022-01-17
tags:
    - C++
---

# mutex

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

# condition_variable

可以使用 `std::condition_variable` 阻塞某一个线程：


# Reference
[c++ - Mutex example / tutorial? - Stack Overflow](https://stackoverflow.com/questions/4989451/mutex-example-tutorial)

