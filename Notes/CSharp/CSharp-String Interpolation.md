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
输出结果为：`Hello,wxj.`。其中 `$"Hello,{name}.")` 被称为 `内插字符串表达式（interpolated string expression）`，最后输出的 `Hello,wxj.` 被称为 `结果字符串（result string）`

由上例可以看出字符串插值的两个必要因素：
1. 在字符串前需要有 `@` 字符标记，且该字符与后续的字符串双引号间不能有空格。


# Reference

[String interpolation - C# tutorial | Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/csharp/tutorials/exploration/interpolated-strings-local)