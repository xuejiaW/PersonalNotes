---
tags:
    - GPU
---

# CPU/GPU 工作模型

在每一帧中，当调用了GPU相关的命令，CPU并不会把这些命令立即传递给GPU，而是会先保存到一个缓存中，当缓存满了或遇到 `Present` 命令（在例如 `VSync` 等情况触发）时才会将相应的命令发送给GPU进行绘制（发送的过程称为 `Marshalling` ）。且CPU和GPU是并行工作的。理想状态下CPU与GPU工作情况如下：