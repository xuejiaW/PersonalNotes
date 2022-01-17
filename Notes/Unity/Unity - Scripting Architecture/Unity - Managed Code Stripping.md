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

可以在 。

# Understanding managed code stripping

当编译 Unity 工程时，C# 代码会先被编译为 `.Net` 的字节码，称为 `Common Intermediate Language（CIL）`，`CIL` 会进一步被编为 `assemblies`， 在 Unity 中所有使用的 .Net framework 库和 Package 都已经被预先编译为了 `assemblies` 。默认而言，编译过程会包含 assembly 中的所有文件。

`Managed code` stripping 就是在编译时分析 `assemblies` 找到并删除没有使用的代码。找出未使用代码的策略越激进，包体就越小，但误删除实际有用的代码的概率就越高，策略的调节可以通过[Managed stripping levels](../Unity%20-%20PlayerSettings.md#Managed%20stripping%20levels) 设置。

## UnityLinker

Unity 编译过程中使用了一个称为 `UnityLinker` 的工具来剥离无用代码，该工具是 Unity 基于 [Mono IL Linker](https://github.com/mono/linker) 的修改版本。

### How the UnityLinker works

`UnityLinker`  会分析工程中所有的 `assemblies`，它会首先标记 `Top-Level` 的类型，方法，属性等。

如一个派生自 `Monobehavior` de