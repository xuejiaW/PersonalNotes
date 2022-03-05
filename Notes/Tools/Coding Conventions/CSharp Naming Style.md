---
tags:
    - Coding-Conventions
created: 2022-02-28
updated: 2022-03-05
---

```ad-note
该命名规范主要用于 Unity 项目使用的 C# 语言
```

# Class / Namespace

以`UpperCamelCase` 形式

# Interfaces

所有接口以 `IUpperCamelCase` 形式

# Method

无论方法，都以 `UpperCamelCase` 形式

```csharp
protected Text()
{
    useLegacyMeshGeneration = false;
}
```

# Field

## Public

所有 `public` 的 `Field` 以 `lowerCamelCase` 形式。

## Non-Public

`Private/ protected` 的普通字段以 `m_UpperCamelCase`  形式，`static` 字段以 `s_UpperCamelCase` 形式，`const` 字段以 `k_UpperCamelCase` 形式：

```csharp
public GameObject gameObject = null;
private GameObject m_GameObject = null;
private static GameObject s_GameObject = null;
private const GameObject k_GameObject = null;
```

# Property

无论作用域，都以 `lowerCamelCase` 形式

```csharp
public bool isValid => module != null && gameObject != null;
```

