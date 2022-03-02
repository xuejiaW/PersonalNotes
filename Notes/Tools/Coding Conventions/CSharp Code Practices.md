---
tags:
    - Coding-Conventions
created: 2022-02-27
updated: 2022-03-02
---

# Invert 'if' statement to reduce nesting

当 `if` 包含整个函数的有效函数体时，可以通过提前返回减少 `nested scope` [^1][^2]。

## Do

```csharp
void PrintName(Person p)
{
  if (p?.Name == null) return
  Console.WriteLine(p.Name);
}
```

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


# Reference

[^1]: [coding style - Should I return from a function early or use an if statement? - Software Engineering Stack Exchange](https://softwareengineering.stackexchange.com/questions/18454/should-i-return-from-a-function-early-or-use-an-if-statement)
[^2]:[Code Inspection: Invert 'if' statement to reduce nesting | ReSharper (jetbrains.com)](https://www.jetbrains.com/help/resharper/2021.3/InvertIf.html)
[^3]:[CA1822: Mark members as static ](https://docs.microsoft.com/zh-cn/previous-versions/visualstudio/visual-studio-2015/code-quality/ca1822-mark-members-as-static?view=vs-2015&redirectedfrom=MSDN)