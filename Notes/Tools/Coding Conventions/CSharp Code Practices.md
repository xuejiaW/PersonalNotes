---
tags:
    - Coding-Conventions
created: 2022-02-27
updated: 2022-03-04
---

# 提前 Return 减少嵌套作用域

如当 `if` 包含整个函数的有效函数体时，可以通过提前返回减少 `nested scope` [^1][^2]。

## Do not

```csharp
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
```

## Do

```csharp
void PrintName(Person p)
{
  if (p?.Name == null) return
  Console.WriteLine(p.Name);
}
```


# 构造对象时指明类型

当使用 new 构造对象时，指定构造的类型。

## Do not

```csharp
private static readonly ObjectPool<LayoutRebuilder> s_Rebuilders = new(null, x => x.Clear());
```

## Do
```csharp
private static readonly ObjectPool<LayoutRebuilder> s_Rebuilders = new ObjectPool<LayoutRebuilder>(null, x => x.Clear());
```

# Static Member 

如下代码中 `Print` 函数可以被设定为 `static` 函数：
```csharp
public class Foo
{
    public void Test()
    {
        Print("John");
    }

    private void Print(string name)
    {
        Console.WriteLine("Hello, {0}!", name);
    }
}
```

对于类中的函数，在运行调用时会需要做一个检查，保证该类示例不为空，但如果将类函数设置为静态，则可以避免这一个检查，提升一部分性能[^3]。

## Prefer

```csharp
private static void Print(string name)
{
  Console.WriteLine("Hello, {0}!", name);
}
```

# readonly

如果一个 Field 仅在构造函数中被赋值，可以将其设定为 `readonly`，如下变量：
```csharp
public class Person
{
    private string m_Name;
    private int m_Age;
    public Person(string name, int age)
    {
        this.m_Name = name;
        this.m_Age = age;
    }
}
```

## Prefer
```csharp
public class Person
{
    private readonly string m_Name;
    private readonly int m_Age;
    // ...
}
```

# 尽可能使用 LINQ 表达式

```ad-warning
每帧都需要执行的代码中谨慎使用 LINQ，LINQ 表达式会造成一部分的内存分配
```

使用 LINQ 表达式可简化循环判断的操作。

## Do not

```csharp
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
```

## Do

```csharp
if (comps.Any(cur => cur is Behaviour { isActiveAndEnabled: true }))
{
    validLayoutGroup = true;
    layoutRoot = parent;
}
```

# 使用 ?: return 操作

使用 `?:` 减少 return 操作

## Do not

```csharp
if (m_Material != null)
    return m_Material.mainTexture;

return base.mainTexture;
```

## Do

```csharp
return m_Material != null ? m_Material.mainTexture : base.mainTexture;
```

# 使用 ?. 操作符

```ad-warning
不要对继承自 `Unity.Object` 的对象使用 `?.` 操作符
```

## Do not

```csharp
if(next == null)
    next.Break();
```

## Do

```csharp
next?.Break();
```

# Reference

[^1]: [coding style - Should I return from a function early or use an if statement? - Software Engineering Stack Exchange](https://softwareengineering.stackexchange.com/questions/18454/should-i-return-from-a-function-early-or-use-an-if-statement)
[^2]:[Code Inspection: Invert 'if' statement to reduce nesting | ReSharper (jetbrains.com)](https://www.jetbrains.com/help/resharper/2021.3/InvertIf.html)
[^3]:[CA1822: Mark members as static ](https://docs.microsoft.com/zh-cn/previous-versions/visualstudio/visual-studio-2015/code-quality/ca1822-mark-members-as-static?view=vs-2015&redirectedfrom=MSDN)