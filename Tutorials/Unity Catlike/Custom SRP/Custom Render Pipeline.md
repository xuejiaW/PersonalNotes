---
tags:
    - Unity
created: 2022-01-24
updated: 2022-01-24
cssclass: [table-border]
---

# A new Render Pileline

早期的 Unity 仅支持 `内置渲染管线（Default Render Pipeline, DRP / Built-in Render Pipleline）`。自 Unity 2018 后，Unity 引入了 `可编程渲染管线（Scriptable Render Piplelines，SRP）` ，但在 2018 中该功能是试验预览的状态，在 Unity 2019 中该功能才成为 正式功能。

基于 `SRP` ，Unity 官方在 2018 的版本中实现了两套管线， `Lightweight Render Pipeline` 和 `High Definition Render Pipeline` 。前者针对于移动端这样的轻量级平台，而后者针对如 PC，主机这样的高性能平台。在 Unity 2019 的版本中， `Lightweight Render Pipeline` 被拓展为 `Universal Render Pipeline` 。

```ad-note
 `Lightweight Render Pipeline` 和 `Universal Render Pipeline` 实际上是同一套管线，`Lightweight Render Pipeline` 仅是 Unity 2018 中的早期实现版本的命名。
```

```ad-tip
<aside> 🔥 `Universal Render Pipeline` 最终会取代目前的内置渲染管线，成为 Unity 渲染的默认渲染管线。
```

# Project Setup

```ad-tip
该笔记使用的 Unity 版本为 2019.4.10
```

Unity 工程的默认色彩空间 Gamma，而为了保证后续光照等计算的准确性，首先需要将颜色空间切换为线性空间，可通过 `Edit -> Project Setings -> Player -> Other Settings -> Rendering -> Color Space` 修改。

在场景中随意放置一些 Cube 和 Sphere，并附加不同的材质，结果如下图所示：

![](assets/Custom%20Render%20Pipeline/Untitled.png)

所使用的材质设置如下图所示：

|                                                         |                                                         |                                                         |
| ------------------------------------------------------- | ------------------------------------------------------- | ------------------------------------------------------- |
| ![](assets/Custom%20Render%20Pipeline/Untitled%201.png) | ![](assets/Custom%20Render%20Pipeline/Untitled%202.png) | ![](assets/Custom%20Render%20Pipeline/image-20220124092928056.png)

# Pipeline Asset

```ad-tip
`SRP` 的脚本基本都在 `UnityEngine.Rendering` 命名空间下。
```

当使用 `SRP` 时，Unity 引擎需要通过 `RenderPipe Asset(RP Asset)` 来获取渲染管线的实例，同时也会从 `RP Asset` 中读取关于渲染管线的设置。

为了创建 `RP Asset` ，首先需要创建对应的 ScriptableObject 。可以通过继承 `RenderPipelineAsset` 基类创建出可以构建 `RP Asset` 的 ScriptableObject 。如下所示：

```csharp
using UnityEngine;
using UnityEngine.Rendering;

[CreateAssetMenu(menuName = "Rendering/Custom Render Pipeline")]
public class CustomRenderPipelineAsset : RenderPipelineAsset
{
    protected override RenderPipeline CreatePipeline() { return null; }
}
```

```ad-note
所有派生自 `RenderPipelineAsset` 的类都必须实现 `CreatePipeline` 函数，Unity 使用该函数获取渲染管线的实例。
```

之后可以通过 `Assets -> Create -> Rendering -> Custom Render Pipeline` 创造出 `RP Asset` ，结果如下所示：