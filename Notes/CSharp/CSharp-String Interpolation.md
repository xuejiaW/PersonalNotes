---
created: 2021-12-09
updated: 2021-12-10
---

# Creating an interpolated string

`字符串插值（String Interpolation）` 是用来将表达式插入到字符串中的方式，简单的示例如下所示：
```csharp
string name = "wxj";
Debug.Log($"Hello,{name}.");
```

输出结果为：`Hello,wxj.`。
其中 `$"Hello,{name}.")` 被称为 `内插字符串表达式（interpolated string expression）`，最后输出的 `Hello,wxj.` 被称为 `结果字符串（result string）`

由上例可以看出字符串插值的两个必要因素：
1. 在字符串前需要有 `@` 字符标记，且该字符与后续的 `"` 间不能有空格。
2. 在内插字符串表达式内部可以有一个或多个 `{}` ，其中包含着任何返回结果的 C# 表达式，表达式的返回值也可以为 `null`。

# Include different data types

对于内插字符串表达式中的各 C# 表达式可以是任何类型的，如下所示：
```csharp
var item = (Name: "eggplant", Price: 1.99m, perPackage: 3);
var date = DateTime.Now;
Debug.Log($"On {date}, the price of {item.Name} was {item.Price} per {item.perPackage} items.");
```

输出结果为：`On 12/10/2021 8:26:07 AM, the price of eggplant was 1.99 per 3 items.`

```ad-note
表达式的返回结果为 `null` 时，字符串插值仍然可以正常工作，此时表达式的结果相当于为空字符串。
```


# Reference

[String interpolation - C# tutorial | Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/csharp/tutorials/exploration/interpolated-strings-local)