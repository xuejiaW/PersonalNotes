---
tags:
    - C#
created: 2022-01-08
updated: 2022-01-08
---

# Overview

`GCHandle` 是用在需要将托管内存中的对象传递给非托管内存时使用的，如需要将一个对象从 C# 中传递到 C++ 中。


# Reference

[GCHandle.ToIntPtr vs. GCHandle.AddrOfPinnedObject | Microsoft Docs](https://docs.microsoft.com/zh-cn/archive/blogs/jmstall/gchandle-tointptr-vs-gchandle-addrofpinnedobject)

[GCHandle Struct (System.Runtime.InteropServices) | Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/api/system.runtime.interopservices.gchandle?view=net-6.0)

[GCHandleType Enum (System.Runtime.InteropServices) | Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/api/system.runtime.interopservices.gchandletype?view=net-6.0)