---
created: 2021-12-23
updated: 2022-02-24
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

# unique_lock

可以使用 `unique_lock` 可以控制对 [mutex](#mutex) 的加解锁操作。当 `unique_lock` 的构造函数调用时会对 [mutex](#mutex) 进行加锁，当析构函数调用时会对 [mutex](#mutex) 进行解锁。示例如下所示：
```cpp
std::mutex mtx;

void print_block (int n, char c) {
  std::unique_lock<std::mutex> lck (mtx);
  for (int i=0; i<n; ++i) { std::cout << c; }
  std::cout << '\n';
}

int main ()
{
  std::thread th1 (print_block,50,'*');
  std::thread th2 (print_block,50,'$');

  th1.join();
  th2.join();

  return 0;
}
```

可能的输出为，其中可能先打印 `$` 也可能先打印 `*`，但两者不会交替打印：
```text
**************************************************
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
```

# condition_variable

可以使用 `std::condition_variable` 阻塞/唤醒某一个线程 ，示例如下所示：
```cpp
std::condition_variable condition;
std::mutex mtx;

void Push(const T& data)
{
    std::unique_lock<std::mutex> lock(mutex);
    queue.push(data);
    condition.notify_all();
}

void BlockPop(T& data)
{
    std::unique_lock<std::mutex> lock(mutex);

    if (queue.empty()) condition.wait(lock);

    data = queue.front();
    queue.pop();
}
```

当 `condition.wait` 函数触发时，会自动对 `mutex` 进行解锁。

# Reference
[c++ - Mutex example / tutorial? - Stack Overflow](https://stackoverflow.com/questions/4989451/mutex-example-tutorial)

