---
created: 2021-12-26
updated: 2021-12-27
tags:
    - C#
---
# Overview

属性（Properties）使用起来类似于 public 的成员变量，但实际上它是一个称为 `accessors` 的函数。

# Properties with backing fields

最常见的 Properties 的定义如下所示：
```csharp
private double _seconds;

public double Hours
{
    get { return _seconds / 3600; }
    set { _seconds = value * 3600; }
}
```

其中属性 `Hours` 的 `get` 和 `set` 都会访问私有成员变量 `_seconds`。这种被属性操作和访问的成员变量称为 `backing fields`。

# Expression body definitions

如果属性中的 `get` 方法只需要一个 `return` 语句，可以使用 => 字符后接函数表达式替代，如下所示：
```csharp
private double _seconds;

public double Hours => _seconds / 3600;
```

在 C# 7.0 后，对 `get` 和 `set` 方法都可以后借函数表达式，但两者都需要显示的加入 `get` 和 `set` 关键字，如下所示：
```csharp
private string _name;

public string Name
{
    get => _name;
    set => _name = value;
}
```

# Auto-Implemented Properties

在  C# 3.0 后，如果不需要在 Properties 中添加额外的逻辑，可以不指明 `backing field`，如下所示：
```csharp
public string Name { get; set; }
```

这种情况下编译器会为属性自动添加 `Backing Field`。

在 C# 6.0 后，可以给自动添加 `Backing Field` 的属性设定默认值，如下所示：
```csharp
public string FirstName { get; set; } = "Jane";
```

```ad-note
在 C# 6.0 之前，可以通过 `DefaultValue` Attribute，如下所示：
~~~csharp
[System.ComponentModel.DefaultValue(27)]
public int DefaultValueInt { get; set; }
~~~
```

# Reference

[Properties - C# Programming Guide | Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/classes-and-structs/properties)