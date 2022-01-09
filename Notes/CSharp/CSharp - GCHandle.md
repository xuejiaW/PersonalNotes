---
tags:
    - C#
created: 2022-01-08
updated: 2022-01-09
---

# Overview

`GCHandle` 是用在需要将托管（Managed）内存中的对象传递给非托管（UnManaged）内存时使用的，如需要将一个对象从 C# 中传递到 C++ 中。

`GCHandle.Alloc` 函数返回一个 `GCHandle` 结构体且保证了托管内存中的对象不会被 GC 回收，直到对该对象调用 `GCHandle.Free`

如下实例代码所示：
```csharp
public delegate bool CallBack(int handle, IntPtr param);

public class App
{
    [DllImport("user32.dll")]
    internal static extern bool EnumWindows(CallBack cb, IntPtr param);

    public static void Run()
    {
        TextWriter tw = Console.Out;
        GCHandle gch = GCHandle.Alloc(tw);

        CallBack cewp = new CallBack(CaptureEnumWindowsProc);

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

可以看到 Native 函数 `EnumWindows` 需要接纳一个 `IntPtr` 的形参。`TextWriter` 对象通过 `GCHandle.Alloc` 和  `GCHandle.ToIntPtr` 转换成了 `IntPtr` 并传递给了 Native 函数

# Reference

[GCHandle.ToIntPtr vs. GCHandle.AddrOfPinnedObject | Microsoft Docs](https://docs.microsoft.com/zh-cn/archive/blogs/jmstall/gchandle-tointptr-vs-gchandle-addrofpinnedobject)

[GCHandle Struct (System.Runtime.InteropServices) | Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/api/system.runtime.interopservices.gchandle?view=net-6.0)

[GCHandleType Enum (System.Runtime.InteropServices) | Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/api/system.runtime.interopservices.gchandletype?view=net-6.0)