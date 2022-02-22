---
created: 2021-12-23
updated: 2022-02-22
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

可以使用 `std::condition_variable` 阻塞/唤醒某一个线程 ，示例如下所示：
```cpp
std::condition_variable condition;

void Push(const T& data)
{
    std::unique_lock<std::mutex> lock;
    queue.push(data);
    condition.notify_all();
}

void BlockPop(T& data)
{
    std::unique_lock<std::mutex> lock;

    if (queue.empty()) condition.wait(lock);

    data = queue.front();
    queue.pop();
}
```


# Reference
[c++ - Mutex example / tutorial? - Stack Overflow](https://stackoverflow.com/questions/4989451/mutex-example-tutorial)

