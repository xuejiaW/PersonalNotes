---
tags:
    - Coding-Conventions
created: 2022-02-28
updated: 2022-03-29
---

```ad-note
该命名规范主要用于 Unity 项目使用的 C# 语言
```

# Class / Struct / Namespace
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

# Example
```ad-note
以下例子仅是为了说明命名的格式规范，但每个对象的命名本身并不合理，如不应该使用 `value` 这样无意义的名字。
```

```csharp
namespace NamespaceConvention
{
    // Interface
    public interface IConvention
    {
    }

    // Class
    public class NamingConvention
    {
        // Fields
        private int m_Value = 0;
        public string strValue = null;
        private static int s_Value = 0;
        private const int k_Value = 0;

        // Property
        private int value => m_Value;
        private int anotherValue => m_Value;

        //Callback
        public event System.Action onCallback = null;


        // Method
        public void DummyMethod1() { }
        private void DummyMethod2() { }
        private static void DummyMethod3() { }
    }

    // Enum
    public enum CustomEnum
    {
        FirstData,
        SecondData
    }
}
```


