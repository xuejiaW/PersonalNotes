---
tags:
    - C#
---

# Overview

`Class` , `Struct` 和 `Interface` 都可以是 Partial 的并被拆分到多个源文件中。

```ad-caution
`delegate` 和 `enumeration` 不支持 `partial`
```

# Partial Classes

对于同一个类的多个 Partial 部分，所有部分都必须加上 `partial` 关键字，所有的部分访问类型都必须是相同的，如都是 `public` 或都是 `private` 。

对于任一一个 `partial` 部分，如果它定义了 `abstract` 或 `sealed` 或 继承关系，则所有其余的 `partial` 部分都拥有相同的关系。多个 `partial` 部分可以继承自多个不同的 `interface` ，最终会认为该类继承自所有这些继承的 `interfaces` 。多个 `partial` 部分可以定义多个不同的 `attribute` ，最终会认为该类定义了所有这些 `attributes` 。

如下两个定义：

```csharp
partial class Earth : Planet, IRotate { }
partial class Earth : IRevolve { }
```

等同于：

```csharp
class Earth : Planet, IRotate, IRevolve { }
```

```ad-note
编译阶段会将所有 `partial` 部分结合在一起，因此 `partial` 并不会有任何 `runtime` 的开销。
```

## Restrictions

-   `partial` 关键字必须是在 `class` `struct` 和 `interface` 前的首个单词（immediately before）。
-   内嵌类同样可以是 `partial` 的，如下：
    ```csharp
    // Source file A
    partial class ClassWithNestedClass
    {
        partial class NestedClass { }
    }

    // Source file B
    partial class ClassWithNestedClass
    {
        partial class NestedClass { }
    }
    ```
-   所有 `partial` 类必须定义在同一个 Assembly 和 同一个模块中 （.exe 或 .dll）
-   对于有泛型的类而言，同样可以是 `partial` 的，但泛型的定义不能冲突，且对于泛型的定义顺序在各个 `partial` 部分中是要相同的

# Partial Methods

函数同样可以是 `partial` 的。可以在一个 `partial` 部分中定义函数的签名，在另一个 `partial` 部分中定义函数的实现。如果函数并未在任一的 `partial` 部分中实现，则这个函数以及对这个函数的所有调用会在编译阶段被移除。

Partial 函数的示例如下所示：

```csharp
// Definition in file1.cs
partial void OnNameChanged();

// Implementation in file2.cs
partial void OnNameChanged()
{
  // method body
}
```

## Restrictions

-   Partial 函数，都必须以 `partial` 开头
-   Partial 函数可以有 `static` 和 `unsafe` 的修饰符
-   只有定义了实现的 Partial 函数才能被添加到 `delegate` 中

只有在满足下列所有情况时， Partial 函数才可以不定义实现，且不会引发编译错误：

-   没有任何的访问修饰符（即使是默认的 `private` ）
-   返回 `void`
-   没有任何 `out` 参数
-   不包含 `virtual` , `override` , `sealed` , `new` , `extern` 关键字

```ad-note
即不满足上述任一条件，则实际上 Partial 函数就必须定义实现，此时 Partial 函数也就失去了原有的意义。
```

# Reference

[Partial Classes and Methods - C# Programming Guide](https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/classes-and-structs/partial-classes-and-methods)

[partial method - C# Reference](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/keywords/partial-method)
