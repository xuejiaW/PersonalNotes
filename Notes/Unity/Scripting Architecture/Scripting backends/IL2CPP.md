---
tags:
    - Unity
created: 2022-01-05
updated: 2022-01-27
---

# Overview

使用 `IL2CPP` 作为 Scripting Backends 时，会在 Unity 工程打包阶段使用 `AOT` 将 C# 代码转换为的 `Common Intermediate Language(CIL)` 转换为 C++ 代码，并使用 C++ 代码生成不同平台需要的可执行文件，如 `.exe`，`.apk` 等。

IL2CPP 可以在一些平台中提升运行时的性能，但因为需要将机器码包含在最终生成的可执行文件中，因此无论是编译时间还是编译后可执行文件的大小都会增加。

# How Il2CPP works

使用 `IL2CPP` 编译生成文件时，Unity 会自动执行如下操作：
1. C# 编译器会将 C# 代码转换为 .Net Dlls（managed assemblies）
2. 使用 [Managed Code Stripping](Managed%20Code%20Stripping.md) 将无用的代码剔除
3. IL2CPP 将所有 Managed Assemblies 转换为标准 C++ 代码
4. C++ 编译器编译生成的 C++ 代码以及目标平台相关的运行时的 C++ 代码
5. Unity 根据平台生成可执行文件

# optimizing IL2CPP build times

因为在使用 IL2CPP 模式下，编译时间会明显的 Mono 模式下长，可以使用如下的方式减少编译时间：
1. 关闭如 Windows Defender 这样的杀毒软件，因为编译过程中杀毒软件可能会实时的扫描编译的结果
2. 将 Unity 工程文件放在固态硬盘中
3. 更改 IL2CPP 编译模式（Unity 2021+）
    - 默认情况下，Unity 会以保证运行时效率更高的方式编译 IL2CPP。这意味着 IL2CPP 编译过程中会产生更多的机器码，也就增长了编译时间和编译后可执行文件的大小。

# Enable runtime checks

当处于 IL2CPP 编译模式下时，可以通过 `Il2CpppSetOption` Attribute 控制 `il2cpp`  如何生成 C++ 代码。该 Attribute 主要包含如下选项：

| Property   | Description                                                                                                                                                                                         | Default |
| ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| Null checks | 当启用后， 生成 C++ 代码时会自动添加对空对象访问的检查。当访问空对象时，会上报 `NullReferenceException` 错误。<br> 如果关闭此选项，可能会提升项目的性能，但当出现对空对象的访问时，程序会直接 Crash | Enabled |
| Array bounds checkes           | 当启用后， 生成 C++ 代码时会自动添加对数组越界访问的检查。当访问越界时，会上报 `` |         |

# Marshall Problems

如有以下代码，希望将一个 C# 侧回调设置给 C++ 侧：
```csharp
[DllImport("texmgr")]
public static extern void SetTaskCompleteCallback(Action<IntPtr, int> onTaskCompleted);

private Action<IntPtr, int> onTexMgrTaskCallback = null;

private void Start()
{
    onTexMgrTaskCallback = new Action<IntPtr, int>(OnTexMgrTaskComplete);
    SetTaskCompleteCallback(onTexMgrTaskCallback);
}

public void OnTexMgrTaskComplete(IntPtr taskPtr, int errorCode)
{
    Debug.Log("sss callback in OnTexMgrTaskComplete");
}
```

当在 IL2CPP 模式下，会报以下错误，即表示 IL2CPP 模式下无法将实例函数转换到 Native 代码：
```text
NotSupportedException: IL2CPP does not support marshaling delegates that point
to instance methods to native code.
```

将函数修改为静态函数后，即修改为如下形式：
```csharp
public static void OnTexMgrTaskComplete(IntPtr taskPtr, int errorCode)
{
    Debug.Log("sss callback in OnTexMgrTaskComplete");
}
```

会新产生如下错误，表明需要添加 `MonoPInvokeCallback` Attribute：
```text
NotSupportedException: To marshal a managed method, please add an attribute
named 'MonoPInvokeCallback' to the method definition.
```

该 Attribute 位于 `AOT` 命名空间下，且需要接纳一个表示回调类型的形参，使用方法如下所示：
```csharp
using AOT;

[MonoPInvokeCallback(typeof(Action<IntPtr, int>))]
public static void OnTexMgrTaskComplete(IntPtr taskPtr, int errorCode)
{
    Debug.Log("sss callback in OnTexMgrTaskComplete");
}
```

# Reference

 [Unity - Manual: IL2CPP Overview (unity3d.com)](https://docs.unity3d.com/Manual/IL2CPP.html)
