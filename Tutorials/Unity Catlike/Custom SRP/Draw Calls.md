---
cssclass: [table-border]
tags:
    - Unity
    - SRP
---

# Shaders

## Unlit Shader

`Unlit Shader` 是不受光照影响的 Shader。

创建一个 Shader 并将其删减到最少的结构，如下所示，其中 `Properties` 为会在 Insepector 面板中显示的属性， `SubShader` 中定义的 `Pass` 表示一种渲染的方式，一个 `SubShader` 中可以有多个 `Pass` ：

```glsl
Shader "Custom RP/Unlit"
{
    Properties { }
    SubShader
    {
        Pass
        {}
    }
}
```

如果使用这个 Shader 创建一个材质，则该材质会默认的渲染白色，如下所示：

|                                       |                                           |                                           |
| ------------------------------------- | ----------------------------------------- | ----------------------------------------- |
| ![](assets/Draw%20Calls/Untitled.png) | ![](assets/Draw%20Calls/Untitled%201.png) | ![](assets/Draw%20Calls/Untitled%202.png) |

## HLSL Programs

SRP 中通常用来书写 Shader 的语言是 `HLSL（High-Level Shading Language）` 。所有 HLSL 语言需要写在 `Pass` 中，且必须在 `HLSLPROGRAM` 和 `ENDHLSL` 中，如下所示：

```glsl
Pass
{
    HLSLPROGRAM
    ENDHLSL
}
```