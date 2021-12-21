---
created: 2021-12-21
updated: 2021-12-21
tags:
    - C#
---

#  Overview

```ad-note
`nameof` 是C# 6.0 支持的特性
```

```ad-important
`nameof` 的值是在编译时决定的 
```

可以通过 `nameof` 表达式得到命名空间，变量，类型，类成员的名称，如下所示：

```csharp
Debug.Log(nameof(System.Collections.Generic)); // Generic
Debug.Log(nameof(List<int>)); // List
Debug.Log(nameof(List<int>.Count)); // Count
Debug.Log(nameof(List<int>.Add)); // Add

var values = new List<int> { 1, 2, 3 };
Debug.Log(nameof(values)); // values
Debug.Log(nameof(values.Add)); // Add
Debug.Log(nameof(values.Count)); // Count

var @new =5;
Debug.Log(nameof(@new));
```

根据上述示例，可以发现：
1. `nameof` 并不会输出完整的命名空间
2. 3. `nameof` 并不会输出具体的泛型
3. 使用 `nameof` 时，调用类成员时不一定依赖类实例
4. 当使用 [ @ Verbatim Identifier](CSharp%20-%20@%20Verbatim%20Identifier.md) 时，`@` 符号并不会作为输出结果的一部分

# Reference
[nameof expression - C# reference | Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/operators/nameof)