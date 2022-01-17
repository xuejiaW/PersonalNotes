---
created: 2022-01-12
updated: 2022-01-14
tags:
    - Unity
---

# Managed code stripping

`Managed code stripping` 用来在编译过程中删除没有被使用到的代码，主要为了减少打包后包体的大小。当使用 [IL2CPP](Unity%20-%20IL2CPP.md) 时，该功能也能减少将代码转换到 C++ 的编译时间。

```ad-tip
`Managed code stripping` 的应用对象不仅仅是工程中自定义的代码，还包括 Package 或 plugins 中的 Assembl
```
