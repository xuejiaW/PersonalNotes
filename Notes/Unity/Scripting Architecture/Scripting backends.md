---
tags:
    - Unity
created: 2022-01-27
updated: 2022-01-27
---

# Overview

Unity 含有两种 `Scripting backends`：
1. [Mono](Scripting%20backends/Mono.md)：使用 `just-in-time (JIT)` 让代码在运行时才编译代码
2. [IL2CPP](Scripting%20backends/IL2CPP.md)：使用 `ahead-of-time (AOT)` 让代码在实际运行前就完成所有编译

可以在 Projection 中切换，如下位置：
![](assets/Scripting%20backends/image-20220127160045630.png)


# Notes
[Mono](Scripting%20backends/Mono.md)：使用 Mono 作为 Scripting Backend 
[IL2CPP](Scripting%20backends/IL2CPP.md)：使用 IL2CPP 作为 Scripting Backend 
[Managed Code Stripping](Scripting%20backends/Managed%20Code%20Stripping.md)：Unity 剔除无用代码的功能及常见问题修复