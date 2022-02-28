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

## Private

以 `m_` 作为前缀，后续以驼峰命名，第一个单词首字母大写：`m_UpperCamelCase`  

```csharp
private GameObject m_GameObject; // Game object hit by the raycast
```

## Public

驼峰命名，第一个单词首字母小写， `lowerCamelCase`：

```csharp
public float distance;
```

## Property