---
created: 2022-02-07
updated: 2022-02-07
tags:
    - C#
---

# Overview

`闭包（Closure）` 并非是 C# 特有的概念，关于 Closure 的学术定义如下：
```ad-cite
In computer science, a **closure** is a first-class function with free variables that are bound in the lexical environment.
```

## First class function 
`First-class function` 表示可以被当作类成员变量的函数，C# 中可以通过委托实现 `First-class function`：
```csharp
Func<string,string> myFunc = delegate(string var1)
                                {
                                    return "some value";
                                };

```

同样可以使用 `lambda` 表达式实现 `First-class function`：
```csharp
Func<string,string> myFunc = var1 => "some value";
```

## Free Variables

`Free Variables` 表示在一个函数的实现中，既不是函数的形参也不是函数局部变量的其他变量。如下例子中的 `myVar` 即为 `Free Variables`：
```csharp
var myVar = "this is good";

Func<string,string> myFunc = delegate(string var1)
                                {
                                    return var1 + myVar;
                                };
```

## Example