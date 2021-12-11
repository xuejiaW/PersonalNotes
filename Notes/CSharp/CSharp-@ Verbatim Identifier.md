---
tags:
   - C#
created: 2021-12-11
updated: 2021-12-11
---

`@` 关键字用来作为`原义标识符（Verbatim Identifier）`，主要包含以下用处：

# 支持使用 C# 关键字做表示

默认而言，无法使用 C# 关键字作为标识符，如无法将 `for` 作为一个变量的命名。但可以使用 `@` 关键字作为代码元素的前缀，之后编译器就会将代编元素解释为标识符，而非 C# 关键字。

如下所示，使用了 `for` 作为了数组变量的名称：
```csharp
        string[] @for = { "John", "James", "Joan", "Jamie" };
        for (int ctr = 0; ctr < @for.Length; ctr++)
        {
            Debug.Log($"Here is your gift, {@for[ctr]}!");
        }

```

结果为：
```text
Here is your gift, John!
Here is your gift, James!
Here is your gift, Joan!
Here is your gift, Jamie!
```

# 支持使用原义解释字符串

当使用 `@` 作为字符串前缀时，会对字符串内所有的字符用原义解释，即不再需要依赖于[转义序列](CSharp-Escape%20Sequences.md)。

如下所示：
```csharp
string filename1 = @"c:\documents\files\u0066.txt";
string filename2 = "c:\\documents\\files\\u0066.txt";
string filename3 = @"c:\\documents\\files\\u0066.txt";

Debug.Log(filename1);
Debug.Log(filename2);
Debug.Log(filename3);
```

输出结果为：
```text
c:\documents\files\u0066.txt
c:\documents\files\u0066.txt
c:\\documents\\files\\u0066.txt
```

可以看到当使用了 `@` 作为前缀时，无论 `\` 还是 `\\` 都会直接被解析为原义。

```ad-error
当使用 `@` 作为前缀时，`\` 会被原义解释，因此原先 [转义序列](CSharp-Escape%20Sequences.md) 中通过 `\"` 输出双引号的方法失效。因此当使用 `@` 时，需要通过 `""` 输出双引号。如下所示：
~~~csharp
// string result = @"\" DEF \""; // Compile error
string result = @""" DEF """;
Debug.Log(result);
~~~

此时输出结果为：
~~~text
" DEF "
~~~
```

```ad-note
当使用 [字符串插值](CSharp-$%20String%20Interpolation.md) 时，因为 `{` 也变成了特殊含义字符，因此 `@` 也不会将其原义解释。
当需要在字符串中插入 `{` 时，需要使用 `{{`。
```

# 让编译器在命名冲突时区分属性

C# 中可以通过继承 `Attribute` 类自定义属性，且自定义属性的命名通常以 `Attribute` 作为后缀，如下所示：
```csharp
[AttributeUsage(AttributeTargets.Method)]
public class InfoAttribute : Attribute
{
    private string information;

    public InfoAttribute(string info)
    {
        information = info;
    }
}
```

当使用该属性时，可以通过 `InfoAttribute` ，也可以使用 `Info`，如下所示：
```csharp
[Info("Start Function")]
private void Start() { }

[InfoAttribute("Start Function")]
private void Update() { }
```

以 `Attribute` 作为后缀并非是编译器的强制要求，因此可以同样定义如下的属性：
```csharp
[AttributeUsage(AttributeTargets.Class)]
public class Info : Attribute
{
    private string information;

    public Info(string info)
    {
        information = info;
    }
}
```

当同时存在 `InfoAttribute` 和 `Info` 两个属性定义时，使用 `Info` 则会造成命名冲突，因为编译器无法决定要使用的究竟是 `InfoAttribute` 还是 `Info`。

因此为了使用 `Info` 属性，需要在前加入 `@` 字符，如下所示：
```csharp
```



# Reference

[@ - C# Reference | Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/tokens/verbatim)
