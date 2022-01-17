---
created: 2022-01-12
updated: 2022-01-17
tags:
    - Unity
---

# Managed code stripping

`Managed code stripping` 用来在编译过程中通过静态分析删除没有被使用到的代码（包括类，类成员，甚至是函数内部的部分代码块），主要为了减少打包后包体的大小。当使用 [IL2CPP](Unity%20-%20IL2CPP.md) 时，该功能也能减少将代码转换到 C++ 的编译时间。

```ad-tip
`Managed code stripping` 的应用对象不仅仅是工程中自定义的代码，还包括 Package 或 plugins 中的代码，但不包括 Unity 引擎源码。
```

## Managed stripping levels