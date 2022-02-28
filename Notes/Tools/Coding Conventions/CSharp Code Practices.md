---
tags:
    - Coding-Conventions
created: 2022-02-27
updated: 2022-02-28
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


# Reference

[^1]: [coding style - Should I return from a function early or use an if statement? - Software Engineering Stack Exchange](https://softwareengineering.stackexchange.com/questions/18454/should-i-return-from-a-function-early-or-use-an-if-statement)
[^2]:[Code Inspection: Invert 'if' statement to reduce nesting | ReSharper (jetbrains.com)](https://www.jetbrains.com/help/resharper/2021.3/InvertIf.html)