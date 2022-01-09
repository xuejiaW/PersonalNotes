---
tags:
    - C#
created: 2022-01-08
updated: 2022-01-09
---

# Blittable Type

绝大部分数据类型在托管和非托管内存中有相同的表达，因此这些数据类型可以直接在托管及非托管内存中转换使用，这样的数据类型称为 `可直接复制到本机结构中的类型（Blittable Type）`。

在 C# 中，下列三种数据类型为 `Blittable Type`：
- `System` 命名空间下的内置类型：
    -   [System.Byte](https://docs.microsoft.com/en-us/dotnet/api/system.byte)
    -   [System.SByte](https://docs.microsoft.com/en-us/dotnet/api/system.sbyte)
    -   [System.Int16](https://docs.microsoft.com/en-us/dotnet/api/system.int16)
    -   [System.UInt16](https://docs.microsoft.com/en-us/dotnet/api/system.uint16)
    -   [System.Int32](https://docs.microsoft.com/en-us/dotnet/api/system.int32)
    -   [System.UInt32](https://docs.microsoft.com/en-us/dotnet/api/system.uint32)
    -   [System.Int64](https://docs.microsoft.com/en-us/dotnet/api/system.int64)
    -   [System.UInt64](https://docs.microsoft.com/en-us/dotnet/api/system.uint64)
    -   [System.IntPtr](https://docs.microsoft.com/en-us/dotnet/api/system.intptr)
    -   [System.UIntPtr](https://docs.microsoft.com/en-us/dotnet/api/system.uintptr)
    -   [System.Single](https://docs.microsoft.com/en-us/dotnet/api/system.single)
    -   [System.Double](https://docs.microsoft.com/en-us/dotnet/api/system.double)
- 由上述类型构成的一维数组
- 由第一种构成的值类型

Reference 并不是 Blittable 的，即使 Reference 的对象是 Blittable 的。如 `int` 是 `blittable`，`int[]` 同样是 `blittable`，但包含 `int[]` 结构体并非是 `Blittable`。

# Reference

[Blittable and Non-Blittable Types - .NET Framework | Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/framework/interop/blittable-and-non-blittable-types)