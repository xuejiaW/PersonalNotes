---
created: 2021-12-27
updated: 2021-12-27
tags:
    - OpenGL
---
# Overview

之前进行的渲染都称为`前向渲染（Forward Rendering / Forward Shading）。在前向渲染中对于场景内的每个物体，在它们的着色器中都需要对场景内的每个光照都进行计算，如 [Light Casters, Multiple Lights](Learn%20OpenGL%20-%20Ch%2014%20%20Light%20Casters,%20Multiple%20Lights.md) 即为典型的前向渲染计算。

延迟渲染（Deferred Rendering / Deferred Shading）