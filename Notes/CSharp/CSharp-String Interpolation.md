---
created: 2021-12-09
updated: 2021-12-11
---

# 创建内插字符串

`字符串插值（String Interpolation）` 是用来将表达式插入到字符串中的方式，简单的示例如下所示：
```csharp
string name = "wxj";
Debug.Log($"Hello,{name}.");
```

输出结果为：
```text
Hello,wxj.
```

其中 `$"Hello,{name}.")` 被称为 `内插字符串表达式（interpolated string expression）`（下简称 `内插表达式`），最后输出的 `Hello,wxj.` 被称为 `结果字符串（result string）`

由上例可以看出字符串插值的两个必要因素：
1. 在字符串前需要有 `@` 字符标记，且该字符与后续的 `"` 间不能有空格。
2. 在内插表达式内部可以有一个或多个 `{}` ，其中包含着任何返回结果的 C# 表达式，表达式的返回值也可以为 `null`。

# 包含不同的数据类型

对于内插表达式中的各 C# 表达式可以是任何类型的，如下所示：
```csharp
var item = (Name: "eggplant", Price: 1.99m, perPackage: 3);
var date = DateTime.Now;
Debug.Log($"On {date}, the price of {item.Name} was {item.Price} per {item.perPackage} items.");
```

输出结果为：
```text
On 12/10/2021 8:26:07 AM, the price of eggplant was 1.99 per 3 items.
```

可以看到该内插字符串表达式中包含有各种类型的表达式（`string`，`Decimal`，`int`，`DeltaTime`），在最终的结果中都被正确的解析。

内插字符串表达式，各表达式都会被转换为 `string`，且规则如下：
1. 如果表达式结果为 `null` ，将其转换为空字符串。
2. 如果表达式结果不为 `null`，对其调用 `ToString` 函数。

# 控制内插表达式的格式

在内插表达式中，还可以控制各表达式转换到 `string` 时的格式，如下所示：
```csharp
DateTime date = DateTime.Now;
float value = 1.12345678f;
Debug.Log($"On {date}, value is {value}");
Debug.Log($"On {date:d}, value is {value:f3}");
```

输出结果为：
```text
On 12/10/2021 8:39:56 AM, value is 1.123457
On 12/10/2021, value is 1.123
```

在内插表达式中的各表达式中可以通过 `:` 后加控制的字符格式化输出。如上例中的  `d` 和 `f3` 即为控制字符。

```ad-note
`:` 后的控制字符，相当于在调用 `ToString` 时作为形参控制表达式的输出。

上述表达式等同于：
~~~csharp
Debug.Log("On " + date.ToString("d") + ", value is " + value.ToString("f3"));
~~~
```

# 控制内插表达式的对齐方式

在内插表达式中的个表达式中可以通过 `,` 后加数字来控制字符宽度和对其方式，如下所示：
```csharp
var inventory = new Dictionary<string, int>()
{
    ["hammer, ball pein"] = 14,
    ["hammer, ball pein a"] = 18,
    ["hammer, cross pein"] = 5,
    ["screwdriver, Phillips #2"] = 14
};

string result = $"|{"Item",-25}|{"Quantity",10}|\n";
foreach (var item in inventory)
    result += $"|{item.Key,-25}|{item.Value,10}|\n";

Debug.Log(result);
```

输出结果为：
```text
|Item                     |  Quantity|
|hammer, ball pein        |        14|
|hammer, ball pein a      |        18|
|hammer, cross pein       |         5|
|screwdriver, Phillips #2 |        14|
```

其中逗号后的数字，如果为负数，则输出为左对齐，如果为正数则右对齐。数字本身表示最少的**字符数**。因此如果显示系统中每个字符的宽度是不相等的话，如 `i` 和 `a` 的宽度在某些显示系统下会有较大差异，则即使控制字符宽度也无法实现对其的效果。

如下为相同输出结果在 Unity 的 Console 面板中的展示：
![|300](assets/CSharp-String%20Interpolation/image-20211210201354094.png)

表达式格式和对齐方式也可以一起设定，但需要首先设定对其方式，再设定格式。如下首先控制了左对齐，且字符数为 10 个，又设定输出格式为当前小时数：
```csharp
Debug.Log($"[{DateTime.Now,-10:HH}]");
```

结果为：
```text
[10        ]
```



# Reference

[String interpolation - C# tutorial | Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/csharp/tutorials/exploration/interpolated-strings-local)