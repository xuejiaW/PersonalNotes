---
created: 2021-12-11
updated: 2021-12-11
---
# Overview

`UnityEngin.Object` 是 Unity 中一个特殊的 C# `Object`，并用它来连接 C++ 中的对应数据。 如一个 `Camera` 组件，Unity 并不会在 C# 层控制数它数据的逻辑，所有的核心操作都在 C++ 侧，C# 侧仅作为上部封装。

Unity C++ 侧与 C# 侧的关系如下所示：
![](assets/Unity-Scripting%20Architecture-UnityEngin.Object/image-20211211183229890.png)

# Destroy Unity Object

当使用类似 `Object.Destroy` 的接口来销毁 Unity Object 时，该接口实际上释放了 C++ 侧的内存数据，而 C# 侧的内存数据并没有立即被释放，需要等到下一次 GC 时。

对于一个 C++ 侧内存已经释放，而 C# 侧还未释放的 Unity Object 而言，如果再次访问该对象，除了 `MonoBehaviour` 和 `ScriptableObject` 类型外，Unity 都会自动在 C++ 侧重新为其创建数据。

对于 `MonoBehaviour` 和 `SciptableObject` Unity 重载了 `==` 和 `!=` 操作符。如果使用这两个操作符去判断 `MonoBehaviour` 和 `ScriptableObject` 是否为空，实际上判断的对象是 C++ 侧的内存。

```ad-warning
?? 和 ?. 操作符，Unity并没有进行重载。因此，如果这两个操作符操作的对象派生自 Unity.Object 则可能出现与 == 操作符判断结果不一致的情况。
```

# Reference

 [Unity - Manual: Overview of .NET in Unity (unity3d.com)](https://docs.unity3d.com/2020.3/Documentation/Manual/overview-of-dot-net-in-unity.html)
