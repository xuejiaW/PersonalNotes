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

`Private` 字段以

以 `m_` 作为前缀，后续以驼峰命名，第一个单词首字母大写：`m_UpperCamelCase`  

```csharp
private GameObject m_GameObject; // Game object hit by the raycast
```

## Public

`lowerCamelCase`：

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