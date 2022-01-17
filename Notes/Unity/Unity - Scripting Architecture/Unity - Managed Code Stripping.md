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

工程中所有的 `assemblies` 都是 `UnityLinker`   的分析目标，它会首先标记 `Top-Level` 的类型，方法，属性等。  如一个派生自 `Monobehavior` 的自定义类，被添加在 Unity 的场景中，该自定义类就会被标记为 `Top-Level` 的类型。

`UnityLinker` 会基于标记的 `Top-Level` 数据，进一步查询并标记这些数据依赖的其他数据，依次类推。当整个流程结束后，未被标记的数据即会被认为无用的数据。

### Reflection and code stripping

`UnityLinker` 有时会无法正确的标记通过反射访问的数据，并错误的认为这些数据无用。

# Error Handle

因为 `Managed code stripping` 无法保证删除的脚本都是无用的，所以提供了 `Preserve attribute` 和 `link.xml` 两种方式来处理意外删除有用代码的情况。

```ad-note
`UnityLinker` 会将使用了 `Preserve attribute` 的元素以及定义在 `link.xml` 中的元素都作为 `Top-Level` 类型。
```

## Preserve Attribute

可以使用 `UnityEngine.Scripting.Preserve` Attribute 标识某个元素不应该被剔除，如下所示：
```cpp
[UnityEngine.Scripting.Preserve]
public class TextureManagerTest : MonoBehaviour {}
```

该 Attribute 可以为不同的类型声明，不同类型的效果如下所示：
1. `Type`：保护这个类型与默认构造函数
2. `Method`：保护这个函数，定义它的类型，返回类型和所有参数的类型
3. `Property`：保护这个属性，定义它的类型，Getter 和 Setter 的函数
4. `Field`：保护这个字段，定义它的类型，以及该字段的类型
5. `Event`：保护这个事件，定义它的类型，添加的函数以及删除的函数
6. `Delegate`：保护这个回调，以及所有它使用的函数
7. `Assembly`：保护该程序集下的所有数据，可使用如下的方式为 `Assembly` 添加 `perserve 字段`：
    ```csharp
    [assembly: UnityEngine.Scripting.Preserve]

    namespace YFramework.ResourceManager
    {
    // ...
    }
    ```
    该代码片段可以加在属于该 `Assembly` 中任何文件中，且需要在命名空间外。


## AlwaysLinkAssembly

## Link XML

`Link XML` 的方式相较于 `Preserve` Attribute 有更高的自由度，如对一个类使用 `Preserve` 会保护该类的类型以及它的默认构造函数，但通过 `Link XML` 可以设置为仅保存该类的类型。


# Reference

[Unity - Manual: Managed code stripping (unity3d.com)](https://docs.unity3d.com/Manual/ManagedCodeStripping.html)