---
cssclass: [table-border]
tags:
    - Unity
    - SRP
created: 2022-01-24
updated: 2022-01-25
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

```ad-note
当导入了 `Core RP Pipeline` 后，相关的源码可以在 `<ProjectPath>Library\\PackageCache\\com.unity.render-pipelines.core@<version>\\` 中查看
```

因此可以使用 `Core RP Pipeline` 的 `SpaceTransform.hlsl` 中 的内容替代自己实现的版本。

```glsl
// In Common.hlsl

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"

// float3 TransformObjectToWorld(float3 positionOS)
// {
//     return mul(unity_ObjectToWorld,float4(positionOS,1.0)).xyz;
// }

// float4 TransformWorldToHClip(float3 positionWS)
// {
//     return mul(unity_MatrixVP,float4(positionWS,1.0));
// }
```

因为 `Core RP Pipeline` 中定义的变量与 Unity 传递的 Shader 参数命名不相同，因此需要通过 `define` 将两者进行转换。如 `unity_ObjectToWorld` 变量，在 `SpaceTransform.hlsl` 中对应的变量为 `Unity_MATRIX_M` ，因此转换语句为：

```csharp
#define UNITY_MATRIX_M unity_ObjectToWorld
```

`SpaceTransform.hlsl` 中有许多变量，如上述 `Unity_MATRIX_M` 只有使用，而未进行定义。因此当引入了 `SpaceTransform.hlsl` 后，这些未定义的变量会导致编译失败。如下的代码将所有这些代码与 Unity 内置的 Shader 参数命名对应在一起：

```glsl
#define UNITY_MATRIX_M unity_ObjectToWorld
#define UNITY_MATRIX_I_M unity_WorldToObject
#define UNITY_MATRIX_V unity_MatrixV
#define UNITY_MATRIX_VP unity_MatrixVP
#define UNITY_MATRIX_P glstate_matrix_projection
```

所有需要用到的参数，都需要在 `UnityInput.hlsl` 中定义，即如下所示：

```glsl
float4x4 unity_ObjectToWorld;
float4x4 unity_WorldToObject;
real4 unity_WorldTransformParams;

float4x4 unity_MatrixVP;
float4x4 unity_MatrixV;
float4x4 glstate_matrix_projection;
```

其中的 `real4` 是一个根据平台定义的参数，根据不同的平台，它可能被定义为 `half4` 或 `float4` 。 `real4` 的定义在 `Core RP Pipeline` 的 `Common.hlsl` 中。

因此，最终自定义的 `Common.hlsl` 如下所示：

```glsl
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "UnityInput.hlsl"

#define UNITY_MATRIX_M unity_ObjectToWorld
#define UNITY_MATRIX_I_M unity_WorldToObject
#define UNITY_MATRIX_V unity_MatrixV
#define UNITY_MATRIX_VP unity_MatrixVP
#define UNITY_MATRIX_P glstate_matrix_projection
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
```

上述引入的相互依赖关系如下：

1.  先引入 `Core RP Pipeline` 的 `Common.hlsl` 文件，保证 `real4` 变量被定义。
2.  引入自定义的 `UnityInput.hlsl` 文件，保证需要的变量被定义，且用 Unity 定义的着色器变量的名称。
3.  使用一系列 `define` 语句，将定义的变量与 `Core RP Pipeline` 中需要用的变量联系在一起。
4.  引入 `Core RP Pipeline` 的 `SpaceTransforms.hlsl` ，其中的 `TransformObjectToWorld` 和 `TransformWorldToHClip` 即为需要的函数。

## Color

在 `UnlitPass.hlsl` 中新增变量 `_BaseColor` 并将该颜色作为像素输出的颜色，如下所示：

```glsl
float4 _BaseColor;

// ...

float4 UnlitPassFragment(): SV_TARGET
{
    return _BaseColor;
}
```

为了让该变量可以在 Unity 的 Material 面板中展现出来，需要在 `.shader` 文件的 `Properties` 中加入，如下所示：

```glsl
Properties
{
    _BaseColor("Color",Color) = (1.0, 1.0, 1.0, 1.0)
}
```

其中的 `_BaseColor` 对应在 `UnlitPass.hlsl` 中定义的变量， `"Color"` 为最终在 Inspector 面板中显示的名称， `Color` 为变量的类型，`(1.0, 1.0, 1.0, 1.0)` 为变量的初始值。

即在 `Properties` 中定义的变量，格式为：

```glsl
<Target Parameter>("<DisplayName>", <Type>) = <default Value>
```

# Batch

使用上述着色器，生成四个颜色不同的材质，如下所示：
![|300](assets/Draw%20Calls/Untitled%206.png)
![|300](assets/Draw%20Calls/Untitled%207.png)
![|300](assets/Draw%20Calls/Untitled%208.png)

在场景内添加 76 个小球，此时一共需要用到 78 个 Drawcall ，其中 76 个绘制小球，一个绘制天空盒，一个用来 Clear。如下所示：

|                                           |                                            |
| ----------------------------------------- | ------------------------------------------ |
| ![](assets/Draw%20Calls/Untitled%209.png) | ![](assets/Draw%20Calls/Untitled%2010.png) |

如果在 Game 窗口的 Statistic 界面中，只能看到 77 个 `Batches` ，这是因为 `Batches` 的计算无视了 Clear 。
![|300](assets/Draw%20Calls/Untitled%2011.png)

## SRP Batcher

`Batching` 是将多个 Draw Call 结合在一起的过程。在 SRP 中最简单使用 `Batching` 的方法就是激活 `SRP Batcher` 功能，但这功能仅能在兼容的 Shader 中开启，上述自定义的 `Unlit` Shader 还不支持此功能，如下所示：
![|500](assets/Draw%20Calls/Untitled%2012.png)

`SRP Batcher` 本质上并没有减少 Draw Call 的数量，它只是将一些材质的 Uniform 数据缓存在 GPU 上，让 CPU 不需要每帧都去设置。这样同时减少了 CPU 处理数据的时间以及 CPU 向 GPU 传输的数据量。

所有可以被 `SRP Batcher` 缓存在 GPU 的 Uniform 数据都必须定义在一块地址不变的内存中，在 `SRP` 中可以通过将数据包裹在 `cbuffer`(Constant buffer) 定义的数据块中，如下所示：

```glsl
cbuffer UnityPerMaterial
{
    float4 _BaseColor;
}
```

```ad-note
`SRP Batcher` 要求自定义的数据类型必须要放在名为 `UnityPerMaterial` 的数据块中，所有 Unity 内置的数据类型要放在名为 `UnityPerDraw` 的数据库中。
```

但 `cbuffer` 并不是在所有的平台下都支持，如 OpenGL ES 2.0 就不支持，所以为了保证兼容性，可以可以使用如下的方式进行替代：

```glsl
CBUFFER_START(UnityPerMaterial)
    float4 _BaseColor;
CBUFFER_END
```

同理，还需要将一些坐标转换的数据也放到 `cbuffer` 中，如下所示，其中的 `unity_LODFADE` 虽然没用到，但同样必须包裹在 `Cbuffer` 中：

```glsl
CBUFFER_START(UnityPerDraw)
	float4x4 unity_ObjectToWorld;
	float4x4 unity_WorldToObject;
	float4 unity_LODFADE;
	real4 unity_WorldTransformParams;
CBUFFER_END
```

当定义完后，Shader 就变为兼容 `SRP Batcher` ，如下所示：
![|300 ](assets/Draw%20Calls/Untitled%2013.png)

此时在自定义的渲染管线中，开启 `SRP Batcher` 即可，如下：

```glsl
public CustomRenderPipeline()
{
    GraphicsSettings.useScriptableRenderPipelineBatching = true;
}
```

此时在 Game 界面的 Statistic 窗口查看，可以看到仍然显示 77 个 Batches，而 `Saved by batching` 又是 $-76$ ，如下所示：
![|400](assets/Draw%20Calls/Untitled%2014.png)

这是因为 Unity 2019 的 Statistic 窗口对于 SRP 存在 Bug，因此更好的选择是通过 Frame Debugger 查看，如下所示可以看到仅有一个 Batch：
![|500](assets/Draw%20Calls/Untitled%2015.png)

```ad-note
上图中 Draw Calls 仍然是76，因为 `SRP Batcher` 并未合并 Drawcall，只是在 GPU 缓存了数据，减少了数据的传输和准备时间。
```

## Many Colors

SRP Batcher 的实现原理中，真正关心的是材质的 GPU 的内存的分布是否相同。因此不同的材质只要使用相同的着色器时，他们的 `UnityPerMaterial` 的内存分布都是相同的，因此可以被合并。

如在上述的例子中，虽然使用了四种不同的材质来绘制小球，但最终所有的都被合并到一个 Batch 中，这是因为这四个材质实际上都是使用同一个 Shader。

```ad-warning
Unity 实际上判断的是着色器是否相同。因此如果两个不同的着色器定义了相同的 `UnityPerMaterial` 内存，仍然是没法被合并的。
```

但是在开发过程中，如果有更多的小球需要有更多不同的颜色，为每种颜色都创建一个材质是不现实的。因此需要在运行时去修改已有的材质。如下脚本可以通过 `baseColor` 去修改 `MaterialPropertyBlock`达到修改材质颜色的目标 ：

```csharp
public Color baseColor = Color.white;

private static int baseColorID = Shader.PropertyToID("_BaseColor");

private void Awake()
{
    OnValidate();
}

private void OnValidate()
{
		if (block == null)
        block = new MaterialPropertyBlock();

    block.SetColor(baseColorID, baseColor);
    GetComponent<Renderer>().SetPropertyBlock(block);
}
```

关于 `MaterialPropertyBlock.SetXXX` 和 `Material.SetXXX` 的区别见 [Material Property Blocks](../../../Notes/Unity/Material%20Property%20Blocks.md) 。概括而言 `MaterialPropertyBlock` 保证了材质不会被拷贝，虽然每个物体都设置了自己的 Material Property，但它们仍然使用的是一个材质。

但当修改了已有材质时，就会打断 `SRP Batch` ，如下所示，原先的一个 Batch （包含 76 个 DrawCalls）被打成了 2个 Batch（分别有49和3个 DrawCalls） 和两组 DrawCalls（分别有22个和2个DrawCalls）：
![|300](assets/Draw%20Calls/Untitled%2016.png)

上述的两组 DrawCalls 是完整的 DrawCalls，即每个 DrawCall 都需要完整的像 GPU 传输数据，因此会耗费较多的性能。优化方式思路是通过 `GPU Instancing` 将他们合并为一个 DrawCall。

## GPU Instancing

对于同一个材质，但是因为使用了 `MaterialPropertyBlock` 而打断 Batch 的情况，可以使用 `GPU Instancing` 将它们合并为一个 DrawCall 进行渲染。 CPU 会将这些物体各自对于材质的修改组合成一个数组（ `Instanced Data`）并一次性送给 GPU，GPU 在渲染它们时使用 index 进行区分。