---
tags:
    - Coding-Style
created: 2022-02-27
updated: 2022-02-27
---

# Invert 'if' statement to reduce nesting

当 `if` 包含整个函数的有效函数体时，可以通过提前返回减少 `nested scope`。

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