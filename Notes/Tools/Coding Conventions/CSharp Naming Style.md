---
tags:
    - Coding-Conventions
created: 2022-02-28
updated: 2022-03-07
---

```ad-note
该命名规范主要用于 Unity 项目使用的 C# 语言
```

# Class / Namespace

以`UpperCamelCase` 形式

# Interfaces

所有接口以 `IUpperCamelCase` 形式。

# Method

所有方法都以 `UpperCamelCase` 形式。

函数的形参以及函数内定义的所有变量，都以 `lowerCamelCase` 形式定义。

# Property

所有属性都以 `lowerCamelCase` 形式。

# Events

所有事件都以 `lowerCamelCase` 形式

# Enum

所有 Enum 中的类型，都以 `UpperCamelCase` 形式定义

# Field

## Public

所有 `public` 的字段以 `lowerCamelCase` 形式。

## Non-Public

`Private/ protected / internal` 的字段：
- 普通字段以 `m_UpperCamelCase`  形式
- `static` 字段以 `s_UpperCamelCase` 形式
- `const` 字段以 `k_UpperCamelCase` 形式：

```csharp
public GameObject gameObject = null;
private GameObject m_GameObject = null;
private static GameObject s_GameObject = null;
private const GameObject k_GameObject = null;
```


