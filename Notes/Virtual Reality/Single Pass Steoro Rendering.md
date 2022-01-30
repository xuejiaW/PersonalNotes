---
created: 2022-01-11
updated: 2022-01-30
tags:
    - Virtual-Reality
Alias: Multiview-Rendering
---


# Overview

在 Stereo Rendering 中，因为每一帧都需要渲染左眼和右眼的数据，因此相较于普通的应用而言，会由更大的性能压力。

在 Unity 的分类命名中，将上述左右眼各自渲染的模式称为 `MultiPass` ，对应的优化了这种渲染模式的新渲染模式都称为 `Single Pass` 。

根据不同的优化方式，又分为了 `Single Pass Double-Wide` ， `Single Pass Instanced` 和 `Single Pass Multi View` 三种方式。

# Single Pass Double-Wide rendering

传统的 `Multi Pass` 渲染，对于左右眼而言是完全独立的渲染，即左右眼各使用一个RenderTexture进行各自的渲染。如下所示：
![](assets/Single%20Pass%20Steoro%20Rendering/SinglePassStereoRendering1.gif)

在 `Single Pass Double-Wide` 中，左右眼共用一个Render Texture，该Texture的宽度是单目Texture的两倍。对于游戏场景内的物体，引擎使用 **两个** DrawCall将其分别绘制到Texture的左右两侧。但因为只使用了一个Texture，所以减少了GPU中切换渲染目标的操作。且左右眼共享相同的Culling信息和阴影计算，这减少了CPU的利用率，但可能会造成显示结果的不精确。`Single Pass Double-Wide`的示意图如下所示：

![](assets/Single%20Pass%20Steoro%20Rendering/SinglePassStereoRendering2.gif)

# Single Pass Instanced[^1]

使用了Multiview后，就无法使用 几何着色器和曲面细分着色器（geometry and tessellation shaders）

在 GL_OVR_multiview 拓展中，只有 gl_Position 可以使用该Index，而在 GL_OVR_multiview2 中移除了该限制，因此表面法线等也可以使用该 index 进行区分。

GL_OVR_multiview 拓展支持一个Drawcall 绘制到 一个 Texture Array 的不同层上，因此减少了设置不同 DrawCall 的开销。 对于 Texture Array 上的每层而言，顶点和片段着色器都会被触发（绘制内容并未减少），并根据 gl_ViewID_OVR 选择不同的 View 和 Projection 矩阵。

因此 MultiView 的功能减少了CPU的开销，而不是GPU的开销。

```ad-note
在不使用 GL_OVR_multiview 拓展的情况下，同样可以使用 layered Geometry Shader 实现。只不过 Geometry Shader 因为要兼顾不同的情况，而 GL_OVR_multiview 拓展是一个固定函数，因此可以针对这情况进行优化。
```

```ad-note
 Single Pass 也能一定程度减少 GPU 消耗 [https://en.wikipedia.org/wiki/Cache_coherence](https://en.wikipedia.org/wiki/Cache_coherence)
```


## Unity Single Pass

当定义了 `USING_STEREO_MATRICES` 后，在 Shader 中会定义 11 个新的数组

```glsl
float4x4 unity_StereoMatrixP[2];
float4x4 unity_StereoMatrixV[2];
float4x4 unity_StereoMatrixInvV[2];
float4x4 unity_StereoMatrixVP[2];
float4x4 unity_StereoCameraProjection[2];
float4x4 unity_StereoCameraInvProjection[2];
float4x4 unity_StereoWorldToCamera[2];
float4x4 unity_StereoCameraToWorld[2];
float3 unity_StereoWorldSpaceCameraPos[2];
float4 unity_StereoScaleOffset[2];
float4 unity_StereoEyeIndices[2];
```

除了矩阵 `unity_StereoEyeIndices` 和 `unity_StereoScaleOffset`，其他的 9个数组都会被用来替换 Shader 中原来使用的变量：

```glsl
#define glstate_matrix_projection unity_StereoMatrixP[unity_StereoEyeIndex]
#define unity_MatrixV unity_StereoMatrixV[unity_StereoEyeIndex]
#define unity_MatrixInvV unity_StereoMatrixInvV[unity_StereoEyeIndex]
#define unity_MatrixVP unity_StereoMatrixVP[unity_StereoEyeIndex]
#define unity_CameraProjection unity_StereoCameraProjection[unity_StereoEyeIndex]
#define unity_CameraInvProjection unity_StereoCameraInvProjection[unity_StereoEyeIndex]
#define unity_WorldToCamera unity_StereoWorldToCamera[unity_StereoEyeIndex]
#define unity_CameraToWorld unity_StereoCameraToWorld[unity_StereoEyeIndex]
#define _WorldSpaceCameraPos unity_StereoWorldSpaceCameraPos[unity_StereoEyeIndex]
```

`unity_StereoEyeIndices` 和 `unity_StereoScaleOffset` 是在 Stereo Rendering 特有的变量：

-   `unity_StereoEyeIndices` 是一个 int 的数组，大小为2，用来存储当前渲染眼镜的 Index （0：左眼，1：右眼）。
-   `unity_StereoScaleOffset` 是一个 Vector4 的数组，大小为2，用来存储当前渲染眼睛的 Texture 的 Scale 和 Offset，左眼为 $(1,1,0,0)$，右眼为 $(1,1,0.5,0)$

# Reference

[^1]: [OpenGL ES SDK for Android: Using multiview rendering (arm-software.github.io)](https://arm-software.github.io/opengl-es-sdk-for-android/multiview.html)

[Single Pass Stereo rendering (Double-Wide rendering)](https://docs.unity3d.com/Manual/SinglePassStereoRendering.html)

[OVR_Multiview](https://www.khronos.org/registry/OpenGL/extensions/OVR/OVR_multiview.txt)

[OVR_Multiview2](https://www.khronos.org/registry/OpenGL/extensions/OVR/OVR_multiview2.txt)