---
tags:
    - Unity
---

在 Unity 中可以通过 `Texture.mipMapBias` 设置纹理的 Mipmap 偏移量，其中正数表示使用更高的 Level，纹理越模糊，负数表示更低的 Level，纹理越锐利。

但在 OpenGLES 平台下，Shader 中默认的 `tex2D` 采样函数无法支持 MipmapBias，必须使用自定义的 Shader 并使用 `tex2Dbias` 对纹理进行采样，如下所示：

```glsl
Properties
{
    ...
    _MainTexBias ("Mip Bias", float) = 0
    ...
}

SubShader
{
    ...
    Pass
    {
        ...
        half _MainTexBias;
        ...

        fixed4 frag(v2f IN) : SV_Target
        {
            ...
            #if SHADER_API_GLES3
                half4 color = (tex2Dbias(_MainTex, half4(IN.texcoord.xy, 0.0, _MainTexBias))) * IN.color;
            #else
                half4 color = (tex2D(_MainTex, IN.texcoord)) * IN.color;
            #endif
            ...
        }
    }
}

```