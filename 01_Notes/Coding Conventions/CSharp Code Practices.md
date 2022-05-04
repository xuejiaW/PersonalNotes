---
tags:
    - Coding-Conventions
    - C#
created: 2022-02-27
updated: 2022-03-29
---

# 统一使用 C# 类型关键字

对于内置的变量类型，C# 类型和 CLR 类型可互相转换，如 `bool -> System.Boolean`，`int -> System.Int32`，完整的转换可见 [Built-in types](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/builtin-types/built-in-types)

在代码中统一使用 C# 类型关键。：
```csharp
// Do not
String.IsNullOrEmpty(value)

// Do
string.IsNullOrEmpty(value)
```

# Property 使用 Expression 形式

```csharp
// Do not
int PropertyA
{
    get { return field; }
    set { field = value; }
}

int PropertyB => field;

int this[int i]
{
    get { return array[i]; }
    set { array[i] = value; }
}

// Do
private int PropertyA
{
    get => field;
    set => field = value;
}

private int PropertyB => field;

private int this[int i]
{
    get => array[i];
    set => array[i] = value;
}
```

# 使用 Auto Property

当一个 Property 仅是对另一个 Field 直接进行简单封装时，可仅使用 `Auto Property` 来减少 Field 的初始化：
```csharp
// Do not
private int m_Value = 0;
public int value
{
    get => m_Value;
    set => m_Value = value;
}

// Do
public int value{get;set;}
```


# Fied 初始化时需指明默认值

```csharp
// Do not
private int m_Value;
private bool m_Status;
private YVRManager m_Manager;

// Do
private int m_Value = null;
private bool m_Status = null;
private YVRManager m_Manager = null;
```

# 永远显示定义修饰符

```csharp
// Do not
int a = 0;
int b = 0;

// Do
private int a;
private int b;
```

# 使用 ?: return 操作

使用 `?:` 减少 return 操作
```csharp
// Do not
if (m_Material != null)
    return m_Material.mainTexture;

return base.mainTexture;

// Do
return m_Material != null ? m_Material.mainTexture : base.mainTexture;
```

# 使用 ?. 操作符

```ad-warning
不要对继承自 `Unity.Object` 的对象使用 `?.` 操作符
```

```csharp
// Do not
if(next == null)
    next.Break();

// Do
next?.Break();
```

# 使用 ??= 操作符

```ad-warning
不要对继承自 `Unity.Object` 的对象使用 `??` 操作符
```

```csharp
// Do not
public TextGenerator cachedTextGeneratorForLayout => m_TextCacheForLayout ?? (m_TextCacheForLayout = new TextGenerator());

// Do
public TextGenerator cachedTextGeneratorForLayout => m_TextCacheForLayout ??= new TextGenerator();
```

# 提前 Return 减少嵌套作用域

如当 `if` 包含整个函数的有效函数体时，可以通过提前返回减少 `nested scope` [^1][^2]。

```csharp
// Do not
void PrintName(Person p)
{
  if (p != null)
  {
    if (p.Name != null)
    {
      Console.WriteLine(p.Name);
    }
  }
}

// Do
void PrintName(Person p)
{
  if (p?.Name == null) return
  Console.WriteLine(p.Name);
}
```

# 构造对象时指明类型

当使用 new 构造对象时，指定构造的类型。
```csharp
// Do not
private static readonly ObjectPool<LayoutRebuilder> s_Rebuilders = new(null, x => x.Clear());

// Do
private static readonly ObjectPool<LayoutRebuilder> s_Rebuilders = new ObjectPool<LayoutRebuilder>(null, x => x.Clear());
```

# Static Member 

对于类中的函数，在运行调用时会需要做一个检查，保证该类示例不为空，但如果将类函数设置为静态，则可以避免这一个检查，提升一部分性能[^3]。
```csharp

private void Print(string name)
{
    Console.WriteLine("Hello, {0}!", name);
}
    
// Prefer
private static void Print(string name)
{
    Console.WriteLine("Hello, {0}!", name);
}
```

# readonly

如果一个 Field 仅在构造函数中被赋值，可以将其设定为 `readonly`，如下变量：
```csharp
private string m_Name;
private int m_Age;
public Person(string name, int age)
{
    this.m_Name = name;
    this.m_Age = age;
}

// Prefer
private readonly string m_Name;
private readonly int m_Age;
```

# 尽可能使用 LINQ 表达式

```ad-warning
每帧都需要执行的代码中谨慎使用 LINQ，LINQ 表达式会造成一部分的内存分配
```

使用 LINQ 表达式可简化循环判断的操作。
```csharp
// Do not
for (int i = 0; i < comps.Count; ++i)
{
    var cur = comps[i];
    if (cur is Behaviour { isActiveAndEnabled: true })
    {
        validLayoutGroup = true;
        layoutRoot = parent;
        break;
    }
}

// Do
if (comps.Any(cur => cur is Behaviour { isActiveAndEnabled: true }))
{
    validLayoutGroup = true;
    layoutRoot = parent;
}

```

# 使用 String Interpolation Expression

尽可能的使用 [$ String Interpolation](../CSharp/$%20String%20Interpolation.md)，示例如下：
```cpp
// Do not
return string.Format("Image Size: {0}x{1}", x, y);

// Do
return $"Image Size : {x}x{y}";

```


# Reference

[^1]: [coding style - Should I return from a function early or use an if statement? - Software Engineering Stack Exchange](https://softwareengineering.stackexchange.com/questions/18454/should-i-return-from-a-function-early-or-use-an-if-statement)
[^2]:[Code Inspection: Invert 'if' statement to reduce nesting | ReSharper (jetbrains.com)](https://www.jetbrains.com/help/resharper/2021.3/InvertIf.html)
[^3]:[CA1822: Mark members as static ](https://docs.microsoft.com/zh-cn/previous-versions/visualstudio/visual-studio-2015/code-quality/ca1822-mark-members-as-static?view=vs-2015&redirectedfrom=MSDN)



[C# Coding Conventions | Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions)