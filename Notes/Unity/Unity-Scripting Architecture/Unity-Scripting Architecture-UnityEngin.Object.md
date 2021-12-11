---
created: 2021-12-11
updated: 2021-12-11
---
# Overview

`UnityEngin.Object` 是 Unity 中一个特殊的 C# `Object`，并用它来连接 C++ 中的对应数据。 如一个 `Camera` 组件，Unity 并不会在 C# 层控制数它数据的逻辑，所有的核心操作都在 C++ 侧，C# 侧仅作为上部封装。

Unity C++ 侧与 C# 侧的关系如下所示：
![](assets/Unity-Scripting%20Architecture-UnityEngin.Object/image-20211211183229890.png)

# Reference
