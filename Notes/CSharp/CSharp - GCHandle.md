---
tags:
    - C#
created: 2022-01-08
updated: 2022-01-09
---

# Overview

`GCHandle` 是用在需要将托管（Managed）内存中的对象传递给非托管（UnManaged）内存时使用的，如需要将一个对象从 C# 中传递到 C++ 中。

如下实例代码所示：
```csharp
using System;
using System.IO;
using System.Threading;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using System.Security.Permissions;

public delegate bool CallBack(int handle, IntPtr param);

internal static class NativeMethods
{
    // passing managed object as LPARAM
    // BOOL EnumWindows(WNDENUMPROC lpEnumFunc, LPARAM lParam);

    [DllImport("user32.dll")]
    internal static extern bool EnumWindows(CallBack cb, IntPtr param);
}

public class App
{
    public static void Main()
    {
        Run();
    }

    [SecurityPermission(SecurityAction.Demand, UnmanagedCode = true)]
    public static void Run()
    {
        TextWriter tw = Console.Out;
        GCHandle gch = GCHandle.Alloc(tw);

        CallBack cewp = new CallBack(CaptureEnumWindowsProc);

        // platform invoke will prevent delegate to be garbage collected
        // before call ends

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

如有以下 C++ 函数，需要将 C# 侧的 Task 对象作为指针传递给 C++：
```csharp
[DllImport("texmgr")]
private static extern void LoadTexture2D(IntPtr taskPtr);
```

则可以使用如下的代码进行传递：
```csharp
Task task = new Task();
GCHandle taskData = GCHandle.Alloc(task);
LoadTexture2D(GCHandle.ToIntPtr(taskData));
```




# Reference

[GCHandle.ToIntPtr vs. GCHandle.AddrOfPinnedObject | Microsoft Docs](https://docs.microsoft.com/zh-cn/archive/blogs/jmstall/gchandle-tointptr-vs-gchandle-addrofpinnedobject)

[GCHandle Struct (System.Runtime.InteropServices) | Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/api/system.runtime.interopservices.gchandle?view=net-6.0)

[GCHandleType Enum (System.Runtime.InteropServices) | Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/api/system.runtime.interopservices.gchandletype?view=net-6.0)