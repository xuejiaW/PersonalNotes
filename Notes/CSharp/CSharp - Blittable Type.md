---
tags:
    - C#
created: 2022-01-08
updated: 2022-01-09
---

# Blittable Type

绝大部分数据类型在托管和非托管内存中有相同的表达，因此这些数据类型可以直接在托管及非托管内存中转换使用，这样的数据类型称为 `可直接复制到本机结构中的类型（Blittable Type）`。

在 C# 中，下列三种数据类型为 `Blittable Type`：
- 基础内置类型，如 `byte`，`int`，`Single`
- 由

# Reference

[Blittable and Non-Blittable Types - .NET Framework | Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/framework/interop/blittable-and-non-blittable-types)