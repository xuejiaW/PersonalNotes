---
cssclass: [table-border]
tags:
    - Unity
    - SRP
created: 2022-01-24
updated: 2022-01-24
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

```ad-note
 `ShaderLab` , `CG` , `HLSL` 区别：

Unity 定义的 `.shader` 文件属于 `ShaderLab` 。`ShaderLab` 中可以使用不同的语言来写，如 `CG` 和 `HLSL` 。

`HLSL` 可以同时被用在 DRP，URP，HDRP 和自定义 SRP 中。 `CG` 仅可以被用在 DRP 和自定义 SRP 中。

因此为了保证与 Unity 的 RP 的统一性，在自定义 SRP 中建议使用 `HLSL` 。
```

在 Shader 中需要指定顶点着色器和片元着色器的函数名称，如下所示， `UnlitPassVertex` 和 `UnlitPassFragment` 分别为两者的名称：

```glsl
Pass
{
    HLSLPROGRAM
		#pragma vertex UnlitPassVertex
    #pragma fragment UnlitPassFragment
    ENDHLSL
}
```

但此时 Shader 中并没有 `UnlitPassVertex` 和 `UnlitPassFragment` 的具体实现，因此会产生编译错误。

可以直接在 `HLSLPROGRAM` 和 `ENDHLSL` 间定义上述函数的实现，也可以选择将函数的实现放在 `.hlsl` 文件中，并 `include` 到 `.shader` 文件中，如下所示：

```glsl
Pass
{
    HLSLPROGRAM
		#pragma vertex UnlitPassVertex
    #pragma fragment UnlitPassFragment
		#include "UnlitPass.hlsl"
    ENDHLSL
}
```

```ad-note
HLSL 和 C++ 的 `include` 逻辑类似，即直接将被 include 的文件的所有内容拷贝到 `include` 语句所在地。
```

## Include Guard && Shader Functions

`.hlsl` 文件不能通过 Unity 直接创建，但在文件浏览器中创建后，可以在 Unity 中直接查看，如下所示：
![|300](assets/Draw%20Calls/Untitled%203.png)

一个可通过编译的 `hlsl` 文件如下所示：

```glsl
#ifndef CUSTOM_UNLIT_PASS_INCLUDED

    #define CUSTOM_UNLIT_PASS_INCLUDED

    float4 UnlitPassVertex():SV_POSITION
    {
        return 0.0;
    }

    float4 UnlitPassFragment():SV_TARGET
    {
        return 0.0;
    }

#endif
```

其中 `#ifndef` 等宏编译是为了避免， `.hlsl` 文件被多次时 include 时产生重定义，并导致编译错误。

`UnlitPassVertex` 和 `UnlitPassFragment` 为需要的顶点着色器 和 片段着色器函数。

在函数声明后的 `SV_POSITION` 和 `SV_TARGET` 为 `semantics` ，它告诉了编译器函数的返回值的具体含义。

其中 `SV_TARGET` 表示渲染对象的颜色， `SV_POSITION` 表示在其次裁剪空间的位置。

```ad-note
如果没有定义 `semantics` ，则会导致编译失败。
```

此时通过该 Shader 并不能渲染出任何物体，因为在顶点着色器中直接返回了 `0.0` 表示，即所有物体渲染的结果都会集中在屏幕正中间的一个像素上，所以不可见。

## Space Transformation

为了让物体可以正常的被渲染，需要将传入的顶点数据通过顶点着色器进行 `MVP` 矩阵的转换，如下所示:

```glsl
float4 UnlitPassVertex(float3 positionOS: POSITION) : SV_POSITION
{
    float3 positionWS = TransformObjectToWorld(positionOS.xyz);
    return TransformWorldToHClip(positionWS);
}
```

```ad-note
传入的 `positionOS` 参数后的 `POSITION` 也是 semantics，表示传入的数据是表示位置的。
```

```ad-note
`POSITION` 和 `SV_POSITION` 的差异可见 [Half-Pixel Offset](../../../Notes/Computer%20Graphics/Computer%20Graphics%20-%20Half-Pixel%20Offset.md)
```

其中的 `TransformObjectToWorld` 和 `TransformWorldToHClip` 为自定义的坐标系转换的函数，如下所示：

```glsl
// In ShaderLibrary/Common.hlsl 
float3 TransformObjectToWorld(float3 positionOS)
{
    return mul(unity_ObjectToWorld,float4(positionOS,1.0)).xyz;
}

float4 TransformWorldToHClip(float3 positionWS)
{
    return mul(unity_MatrixVP,float4(positionWS,1.0));
}
```

两个函数中用到了两个矩阵 `unity_ObjectToWorld` 和 `unity_MatrixVP` ，定义如下所示：

```glsl
// In ShaderLibrary/UnityInput.hlsl
float4x4 unity_ObjectToWorld;
float4x4 unity_MatrixVP;
```

```ad-note
在 HLSL 中直接定义的变量即为 `Uniform` 变量，上述两个变量的命名与 Unity 内置着色器的变量名相同，因此 Unity 可以找到这两个 `Uniform` 变量并为其赋值。
```

`UnityInput.hlsl` 和 `Common.hlsl` 为新增的 `.hlsl` 文件，并放置在 `ShaderLibrary` 文件夹中，前者是为了封装 Unity 内置 Uniform变量输入，后者是为了封装一些常用的函数。即此时文件结构为：
![|200](assets/Draw%20Calls/Untitled%204.png)

## Core Library

像上述的 `TransformObjectToWorld` 和 `TransformWorldToHClip` 是非常同样的函数，Unity 提供了 包 `Core RP Pipeline` 封装了这些函数的实现。
![|200](assets/Draw%20Calls/Untitled%205.png)