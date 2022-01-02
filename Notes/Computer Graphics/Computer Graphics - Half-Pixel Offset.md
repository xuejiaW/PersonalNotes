---
cssclass: [table-border]
created: 2021-12-31
updated: 2022-01-02
---

# Texels to Pixels

对于屏幕坐标系下，$(0,0)$ 点是左上角第一个像素的中心而不是整个屏幕的左上角，如下所示为一个 $8\times 8$ 的空间中各点的表示

![|300](assets/Computer%20Graphics%20-%20Half-Pixel%20Offset/Untitled.png)

对于纹理而言， uv 的 $(0,0)$ 点为图像的左上角，其左上角第一个像素中心的 uv 值为 $(0.5/\mathbf{texelWidth}, 0.5/\mathbf{texelHeight})$，如下所示为一个 $8 \times 8$ 的纹理的各 uv 点的表示：

![|300](assets/Computer%20Graphics%20-%20Half-Pixel%20Offset/Untitled%201.png)

因为上述纹理和像素对于坐标定义的差距，如果有一个 $4 \times 4$ 的纹理，将其 uv 的 $(0,0)$ 与像素的 $(0,0)$ 点对应，则实际如下所示，其中蓝色方块表示 $4 \times 4$ 的纹理，可以看到纹理像素和屏幕像素并未完全的对其：
![|300](assets/Computer%20Graphics%20-%20Half-Pixel%20Offset/Untitled%202.png)

根据 [Triangle Rasterization Rules](Computer%20Graphics%20-%20Triangle%20Rasterization%20Rules.md)，最终光栅化后，显示的像素仍然是 $4\time4$ 的，如下：
![|300](assets/Computer%20Graphics%20-%20Half-Pixel%20Offset/Untitled%203.png)

# Half-Pixel Offset

当考虑纹理被渲染的颜色时，Pixel 和 Texel 之间半像素的偏移就会导致采样颜色的不准确，如下左为用来渲染的 $4 \times 4$ 纹理，下中为实际渲染得到的颜色，下右为屏幕像素与纹理像素的对应关系：

|                                                                                    |                                                                                    |                                                                                              |
| ---------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| ![纹理渲染](assets/Computer%20Graphics%20-%20Half-Pixel%20Offset/Untitled%204.png) | ![渲染结果](assets/Computer%20Graphics%20-%20Half-Pixel%20Offset/Untitled%205.png) | ![屏幕像素与纹理像素](assets/Computer%20Graphics%20-%20Half-Pixel%20Offset/Untitled%206.png) |

```ad-note
渲染时纹理边界使用了 Repeat，过滤为双线性
```

根据上右的屏幕像素与纹理像素的关系，以屏幕像素的 $(1,1)$ 点为例，它对应的 uv 为 $(0.25,0.25)$，在纹理中为左上角四个纹理像素的交点处，所以屏幕像素的 $(1,1)$ 点的颜色实际上是纹理左上角四个像素颜色经过双线性采样混合后的结果，即三个灰色+一个红色的混合结果，因此表现为暗红色。
![|400](assets/Computer%20Graphics%20-%20Half-Pixel%20Offset/Untitled%207.png)

# Fix in DX 9

在 DX 9 中，为了修复该问题，可以在对顶点着色器中，对采样的 UV 左半个像素的偏移，如：

```glsl
o.uv += float2(texelWidth, texHeight) * 0.5;
```

这样 Pixel 的中心点与 Texel 的中心点就匹配了起来。

# Fix in DX 10/11

在 DX 10之后，引入了关键字 `SV_POSITION` ，该关键字表示进行了偏移的像素位置，如下所示：
![](assets/Computer%20Graphics%20-%20Half-Pixel%20Offset/Untitled%208.png)

```ad-note
 未进行偏移的像素位置通过关键字 `SV_POSITION` 表示。
```

此时 Pixel 的中心点与 Texel 的原点定义就是相同的，即 $(0,0)$ 都是表示左上角。因此当使用 `SV_POSITION` 时就不会出现像素偏移的问题，如下所示为利用 `SV_POSITION` 作为采样的 uv：

```glsl
// Fragment Shader
void PixelShader(float2 Position : SV_Position, out float4 Color : SV_Target)
{
    Color = g_Texture.Sample(g_SamplerState, Position / g_ScreenResolution);
}
```

或者在顶点着色器中标明输出为 `SV_POSITION` ，此时在片段着色器中正常的使用 uv 即可，如下所示：

```csharp
struct Attributes
{
    float3 positionOS : POSITION;
};

float4 UnlitPassVertex(Attributes input) : SV_POSITION
{
    float3 positionWS = TransformObjectToWorld(input.positionOS);
    return TransformWorldToHClip(positionWS);
}
```

```ad-note
Unity 的 ShaderLab 中默认使用的就是 `SV_POSITION` ，因此不会产生像素偏移的问题。
```

# Reference

[Directly Mapping Texels to Pixels (Direct3D 9) - Win32 apps | Microsoft Docs](https://docs.microsoft.com/en-us/windows/win32/direct3d9/directly-mapping-texels-to-pixels)

[Half-Pixel Offset in DirectX 11 (asawicki.info)](https://www.asawicki.info/news_1516_half-pixel_offset_in_directx_11)