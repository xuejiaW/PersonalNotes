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