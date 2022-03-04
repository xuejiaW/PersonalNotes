---
tags: Coding-Conventions
created: 2022-03-01
updated: 2022-03-04
---


# 统一使用 C# 类型关键字

对于内置的变量类型，C# 类型和 CLR 类型可互相转换，如 `bool -> Sysytem.Boolean`，

# Fied 初始化时需指明默认值

## Do not
```csharp
private int m_Value;
private bool m_Status;
private YVRManager m_Manager;
```

## Do
```csharp
private int m_Value = null;
private bool m_Status = null;
private YVRManager m_Manager = null;
```


# 尽可能使用 `??=` 

```ad-warning
不要对继承了 Unity.Object 的对象使用 `??=`
```

## Do

```csharp
public TextGenerator cachedTextGeneratorForLayout => m_TextCacheForLayout ??= new TextGenerator();
```

## Do Not
```csharp
public TextGenerator cachedTextGeneratorForLayout => m_TextCacheForLayout ?? (m_TextCacheForLayout = new TextGenerator());
```

# Code body

`Code body`  是针对函数体的设置

## Property

更倾向于使用 `Expression body` 形式。

### Do

```csharp
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

### Do not

```csharp
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
```

# Var

不要使用 `Var` 关键字

# Modifer

## Explicit/Implicit modier

永远显示定义修饰符

### Do
```csharp
private int a;
private int b;
```

### Do not
```csharp
int a;
private int b;
```

## Order

关键字的定义顺序如下所示

`public/private/protected` -> `internal` -> `new` -> `static` -> `abstract/virtual/sealed/override` -> `readonly` -> `extern` -> `unsafe` -> `volatile` -> `async`
