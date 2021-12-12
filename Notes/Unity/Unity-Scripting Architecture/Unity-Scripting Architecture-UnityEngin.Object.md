---
created: 2021-12-11
updated: 2021-12-12
---
# Overview

`UnityEngin.Object` 是 Unity 中一个特殊的 C# `Object`，并用它来连接 C++ 中的对应数据。 如一个 `Camera` 组件，Unity 并不会在 C# 层控制数它数据的逻辑，所有的核心操作都在 C++ 侧，C# 侧仅作为上部封装。

Unity C++ 侧与 C# 侧的关系如下所示：
![](assets/Unity-Scripting%20Architecture-UnityEngin.Object/image-20211211183229890.png)

# Destroy Unity Object

当使用类似 `Object.Destroy` 的接口来销毁 Unity Object 时，该接口实际上释放了 C++ 侧的内存数据，而 C# 侧的内存数据并没有立即被释放，需要等到下一次 GC 时。

对于一个 C++ 侧内存已经释放，而 C# 侧还未释放的 Unity Object 而言，如果再次访问该对象，除了 `MonoBehaviour` 和 `ScriptableObject` 类型外，Unity 都会自动在 C++ 侧重新为其创建数据。

对于 `MonoBehaviour` 和 `SciptableObject` Unity 重载了 == 和 != 操作符。如果使用这两个操作符去判断 `MonoBehaviour` 和 `ScriptableObject` 是否为空，实际上判断的对象是 C++ 侧的内存。

```ad-note
因为对于 `MonoBehaviour` 和 `ScriptableObject` 调用 == 和 != ，真实操作是去检查 C++ 中的对象，所以 == 操作符在运行时也会有比较大的开销。
```

```ad-warning
?? 和 ?. 操作符，Unity并没有进行重载。因此，如果这两个操作符操作的对象派生自 Unity.Object 则可能出现与 == 操作符判断结果不一致的情况。
```

# Editor 模式下的 Fake Null

在 Editor 模式下，Unity 还会为所有的 `MoneBehaviour` 的 Field 对象自动创造出一个 Wrapper 。如以下代码，在 Editor 模式下仍然会分配内存：
```csharp
Camera camera = null;
```

Editor 模式下提供 Wrapper 的主要目的是为了增加调试信息，如告知开发者为空的 Field 对象处在哪个脚本之中。

在 Editor 模式下，诸如 GetComponent 这样的函数，如果未找到对应的组件，则返回的也不是真正意义上的 Null，而是一个 Wrapper ，Wrapper 指向的 C++ 对象为空。

```ad-tip
因为 == 和 != 进行了重载，而 `??` 和 `?.` 没有，所以在 Editor 模式下使用 `?.` 和 `??` 操作符会得到错误的结果。而在 Runtime 时，不会产生错误的结果。
```

示例如下：
```csharp
Camera camera = null;
// Case 1:
if (GetComponent<Camera>() == null)
    camera = gameObject.AddComponent<Camera>();

// Case 2:
camera = GetComponent<Camera>() ?? gameObject.AddComponent<Camera>(); // Result is still null
```

在 Editor 模式下， `Case 1` 能正常的添加 `Camera` 组件，而 `Case 2` 则不能。
在 Runtime 模式下， `Case 1` 和 `Case 2` 都能正常的添加 `Camera` 组件。

# Reference

 [Unity - Manual: Overview of .NET in Unity (unity3d.com)](https://docs.unity3d.com/2020.3/Documentation/Manual/overview-of-dot-net-in-unity.html)
 [Custom == operator, should we keep it? | Unity Blog](https://blog.unity.com/technology/custom-operator-should-we-keep-it)
