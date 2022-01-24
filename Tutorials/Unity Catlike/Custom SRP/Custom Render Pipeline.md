---
tags:
    - Unity
created: 2022-01-24
updated: 2022-01-24
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

|     |     |     |
| --- | --- | --- |
|![](assets/Custom%20Render%20Pipeline/Untitled%201.png)     |  ![](assets/Custom%20Render%20Pipeline/Untitled%202.png)   |  ![](assets/Custom%20Render%20Pipeline/Untitled%203.png)   |