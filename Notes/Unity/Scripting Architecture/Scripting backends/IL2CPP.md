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
