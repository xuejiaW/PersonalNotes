---
tags:
    - C#
created: 2022-01-08
updated: 2022-01-14
---

# Overview

`GCHandle` 是用在需要将托管（Managed）内存中的对象传递给非托管（UnManaged）内存时使用的[^1]。

对于托管内存的 GC 而言，它无法感知一个对象是否仍然被非托管程序使用的。因此如果一个对象从托管程序被传递给了非托管程序，当 GC 发生时该对象可能会被托管程序释放，导致非托管程序意外访问了空地址。

```ad-note
GC 会挂起当前运行的托管程序，因此即使托管程序和非托管程序运作在同一线程中，上述问题仍可能发生。
```

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

# Truth About GCHandle

当为一个对象分配 GCHandle 时，会在 `Handle-Table` 中为该对象创建让一个 `entry`，GCHandle 中会存储该 `entry` 的 Handle。

GCHandle 的原理造成对 GCHandle 的拷贝可能会引发错误的释放[^2]，如下代码所示：

```csharp
Object obj = new Object();  
GCHandle gch = GCHandle.Alloc(obj, GCHandleType.Normal);  
GCHandle gch2 = gch;
```

GCHandle 是 struct，因此当 GCHandle 拷贝后，其中的 Handle 同样会被拷贝。

上例中两个 GCHandle 中的 Handle 会指向同一个 entry。所以当上例中的 `gch2` 调用了 `free` 函数，`gch` 管理的对象同样也被 `free` 了。如果再次为 `gch` 调用 `free` 则会产生 `double-free` 的错误。

# GCHandle Type

当调用 `GCHandle.Alloc` 时可以设置 `GCHandleType`，默认类型为 `GCHandleType.Normal`。

所有的 `GCHandleType` 类型[^3]如下：

| 字段                  | 说明                                                                                                                                                                                                                  |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Normal                | 此句柄类型表示不透明句柄，这意味着无法通过此句柄解析固定对象的地址。 可以使用此类型跟踪对象，并防止它被垃圾回收器回收。<br>当非托管客户端持有对托管对象的唯一引用（从垃圾回收器检测不到该引用）时，此枚举成员很有用。 |
| Pinned                | 此句柄类型类似于 Normal ，但允许使用固定对象的地址。 这将防止垃圾回收器移动对象，因此将降低垃圾回收器的效率。 使用 Free 方法可尽快释放已分配的句柄。                                                                  |
| Weak                  | 此句柄类型用于跟踪对象，但允许回收该对象。 当回收某个对象时，GCHand 的内容归零。 在终结器运行之前，`Weak` 引用归零，因此即使终结器使该对象复活，`Weak` 引用仍然是归零的。                                             |
| WeakTrackResurrection | 该句柄类型类似于 Weak，但如果对象在终结过程中复活，此句柄不归零。                                                                                                                                                     |

其中 `Normal` 和 `Pinned` 都保证了对象不会被 GC 释放，但 `Pinnned` 可以保证对象在 GC 时也不会被移动，而  `Normal` 不行。

```ad-note
`Pinned` 的对象会比较明显的影响性能，因为 GC 时该对象无法移动，所以会造成较严重的内存碎片化。
```


## AddrOfPinnedObject vs ToIntPtr

通过 `Pinned` 和 `Normal` 类型分配的 GCHandle 可以分别通过 `AddrOfPinnedObject` 和 `ToIntPtr` 返回 `IntPtr` 指针。

`AddrOfPinnedObject` 返回的是对象的绝对地址。 `ToIntPtr` 则是返回 `Handle-Table` 中的 entry。`ToIntPtr` 返回的 `IntPtr` 可以通过 `FromIntPtr` 重新转换为 `GCHandle`

因此即使 Normal 的对象被移动了，返回的 `IntPtr` 也不会失效，仍然可以通过该 `Intptr` 找到原来的对象[^4]。

也因此只有通过 `AddrOfPinnedObject` 返回的 `IntPtr` 可以被非托管内存解析。

# Reference

 [GCHandle Struct (System.Runtime.InteropServices) | Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/api/system.runtime.interopservices.gchandle?view=net-6.0)

[^1]: [GCHandle - C# in a Nutshell [Book](oreilly.com) ](https://www.oreilly.com/library/view/c-in-a/0596001819/re525.html)
[^2]: [The Truth About GCHandles | Microsoft Docs](https://docs.microsoft.com/en-us/archive/blogs/clyon/the-truth-about-gchandles)
[^3]: [GCHandleType Enum (System.Runtime.InteropServices) | Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/api/system.runtime.interopservices.gchandletype?view=net-6.0)
[^4]: [GCHandle.ToIntPtr vs. GCHandle.AddrOfPinnedObject | Microsoft Docs](https://docs.microsoft.com/zh-cn/archive/blogs/jmstall/gchandle-tointptr-vs-gchandle-addrofpinnedobject)
