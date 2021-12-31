---
tags:
    - Unity
---

这三者都是 Unity 的 ShaderLab 中定义的针对 HLSL 的数据类型拓展，拓展的目的主要是为了移动端的 GPU 。

三者的精度为： `float` > `half` > `fixed` ，三者占用的内存分别为 32bits, 16bits, 11bits

在绝大部分的现代移动端 GPU 上， `half` 有更高效的性能，所以要尽可能的使用 `half` 。 但当表示 Position 和 TextCoords 时，为了有更好的精度，通常建议使用 `float` 。

`fixed` 通常是针对比较老的移动端 GPU，因为现代 GPU 通常只支持 32bits 和 16bits 的模式。此时如果定义了 `fixed` ，则会被当做 `half` 使用。

当使用桌面端 GPU 时，无论定义的是 `float` , `half` 还是 `fixed` ，都会被当作 `half` 使用。

# Reference

[Unity - Manual: Shader data types and precision (unity3d.com)](https://docs.unity3d.com/Manual/SL-DataTypesAndPrecision.html)