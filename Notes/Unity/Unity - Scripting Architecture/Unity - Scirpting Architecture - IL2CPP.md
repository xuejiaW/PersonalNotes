---
tags:
    - Unity
created: 2022-01-05
updated: 2022-01-05
---

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

会新产生如下错误，表明需要添加 `NotSupportedException: To marshal a managed method, please add an attribute
named 'MonoPInvokeCallback' to the method definition.`：
```text
NotSupportedException: To marshal a managed method, please add an attribute
named 'MonoPInvokeCallback' to the method definition.
```

# Reference

 [Unity - Manual: IL2CPP Overview (unity3d.com)](https://docs.unity3d.com/Manual/IL2CPP.html)
