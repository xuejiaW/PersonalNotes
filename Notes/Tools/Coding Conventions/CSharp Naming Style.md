---
tags:
    - Coding-Conventions
created: 2022-02-28
updated: 2022-03-01
---

```ad-note
该命名规范主要用于 Unity 项目使用的 C# 语言
```

# Field

## Non-Static

`Private` 和 `protected` 字段以 `m_UpperCamelCase`  形式：

```csharp
private GameObject m_GameObject;
```

`Public`字段以  `lowerCamelCase` 形式：

```csharp
public float distance;
```

# Property

无论作用域，都以 `lowerCamelCase` 形式

```csharp
public bool isValid => module != null && gameObject != null;
```

# Method

无论作用域，都以 `UpperCamelCase` 形式

```csharp
protected Text()
{
    useLegacyMeshGeneration = false;
}
```