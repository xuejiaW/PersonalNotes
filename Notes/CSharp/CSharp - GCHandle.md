---
tags:
    - C#
created: 2022-01-08
updated: 2022-01-09
---

# Overview

`GCHandle` 是用在需要将托管（Managed）内存中的对象传递给非托管（UnManaged）内存时使用的，如需要将一个对象从 C# 中传递到 C++ 中。因为对于托管内存的 GC 而言，它是bu

`GCHandle.Alloc(instance)` 函数为 `instance` 对象创建了 `GCHandle` 结构体且保证了 `instance` 对象不会被 GC 回收，直到对返回的 `GCHandle` 调用 `Free` 函数为止。

如下实例代码保证了 `TextWriter tw` 对象在调用 Native 函数 `EnumWindows` 函数时不会被意外释放：
```csharp
public delegate bool CallBack(int handle, IntPtr param);

public class App
{
    [DllImport("user32.dll")]
    internal static extern bool EnumWindows(CallBack cb, IntPtr param);

    public static void Run()
    {
        CallBack cewp = new CallBack(CaptureEnumWindowsProc);

        TextWriter tw = Console.Out;
        GCHandle gch = GCHandle.Alloc(tw);

        NativeMethods.EnumWindows(cewp, GCHandle.ToIntPtr(gch));
        gch.Free();
    }

    private static bool CaptureEnumWindowsProc(int handle, IntPtr param)
    {
        GCHandle gch = GCHandle.FromIntPtr(param);
        TextWriter tw = (TextWriter)gch.Target;
        tw.WriteLine(handle);
        return true;
    }
}
```

```ad-note
因为 GC 可能随时挂起 C# 中执行的代码，因此即使Native `EnumWindows` 函数和 C# 运行在同一线程上，如果没有 GCHandle 的存在，当
```

# Reference

[GCHandle.ToIntPtr vs. GCHandle.AddrOfPinnedObject | Microsoft Docs](https://docs.microsoft.com/zh-cn/archive/blogs/jmstall/gchandle-tointptr-vs-gchandle-addrofpinnedobject)

[GCHandle Struct (System.Runtime.InteropServices) | Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/api/system.runtime.interopservices.gchandle?view=net-6.0)

[GCHandleType Enum (System.Runtime.InteropServices) | Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/api/system.runtime.interopservices.gchandletype?view=net-6.0)