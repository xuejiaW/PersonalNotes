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

## Project Setup

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

## Pipeline Asset

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
![|500](assets/Custom%20Render%20Pipeline/Untitled%206.png)

可以通过 `Project Settings -> Graphics -> Scriptable Render Pipeline Settings` 将自定义的 `RP Asset` 设置给 Unity，如下所示：
![|500](assets/Custom%20Render%20Pipeline/Untitled%207.png)

当替换后了 `RP Asset` 后，主要有两个变化：

1.  原 `Graphics` 面板中的许多设置消失了。
    
    因为替换的 `RP Asset` 并没有提供相关的设置选项。
    
2.  Scene / Game / Material 界面都不再渲染。
    
    因为替换的 `RP Asset` 实际上返回的是空，即 Unity 此时没有任何的渲染管线可以用。
    

## Render Pipeline Instance

通过继承 `RenderPipeline` 构建自定义的渲染管线类，所有的派生自 `RenderPipeline` 的类都必须实现 `Render` 函数，Unity 在每一帧通过触发该函数进行渲染，如下所示：

```csharp
using UnityEngine;
using UnityEngine.Rendering;

public class CustomRenderPipeline : RenderPipeline
{
    protected override void Render(ScriptableRenderContext context, Camera[] cameras) { }
}
```

之前的 `CustomRenderPipelineAsset.CreatePipeline` 函数就可以返回该自定义渲染管线的示例，如下所示：

```csharp
protected override RenderPipeline CreatePipeline()
{
    return new CustomRenderPipeline();
} 
```

此时 Unity 已经可以使用 `CustomRenderPipeline` 进行绘制。但所有的界面仍然是空白的，因为定义的 `CustomRenderPipeline` 中并没有进行任何的实质渲染。

# Rendering

Unity 通过 RP 中的 `Render` 函数进行渲染，Render 函数有两个形参：

1.  `ScriptableRenderContext` ：该形参表示 `SRP` 渲染的上下文。 RP 使用该形参与 Unity Native 的渲染部分进行通信
    
2.  `Camera[]` ，该形参表示所有激活的 Cameras
    
    RP 使用该形参来控制每个摄像机的渲染与不同摄像机间的渲染顺序
    

## Camera Renderer

通过 `ScriptableRenderContext` 和 `Camera` 就可以控制每个摄像机的渲染，如可以通过自定义的 `CameraRenderer` 类来负责特定摄像机的渲染：

```csharp
public class CameraRenderer
{
    private ScriptableRenderContext renderContext = default;
    private Camera camera = null;

    public void Render(ScriptableRenderContext renderContext, Camera camera)
    {
        this.renderContext = renderContext;
        this.camera = camera;
				// ....
    }
}
```

## Drawing the Skybox

`CameraRenderer.Render` 的功能就是渲染所有该摄像机可以看到的物体。如以下的实现，可以让 `CameraRender` 渲染出天空盒：

```csharp
public void Render(ScriptableRenderContext renderContext, Camera camera)
{
    this.renderContext = renderContext;
    this.camera = camera;

    Setup();
    DrawVisibleGeometry();
    Submit();
}

private void Setup()
{
    renderContext.SetupCameraProperties(camera);
}

private void DrawVisibleGeometry()
{
    renderContext.DrawSkybox(camera);
}

private void Submit()
{
    renderContext.Submit();
}
```

其中 `SetupCameraProperties` 在 Shader 中设置摄像机相关的变量，如 View 矩阵，Projection 矩阵。 `DrawSkybox` 将渲染天空盒的命令添加到 Context 的缓冲中， `Submit` 将 Context 缓冲中的命令添加到执行队列中。

```ad-note
仅当 Camera 的 ClearFlags 是 Skybox 时， `DrawSkybox` 才会真正的将绘制天空盒的命令添加到缓冲中。
```

结果如下所示：
![|500](assets/Custom%20Render%20Pipeline/GIF_2021-5-8_19-55-17.gif)

## Command Buffers

之前的 `DrawSkybox` 命令向 Context 的缓冲中增加了一条渲染天空盒的命令。除此之外，可以通过 `CommandBuffer` 类和 `context.ExecuteCommandBuffer` 函数向 Context 中添加自定义的渲染命令。

通过如下命令创建 `CommandBuffer`， `CommandBuffer` 的 `name` 属性可以在 `FrameDebugger` 中查看：

```csharp
CommandBuffer buffer = new CommandBuffer { name = "Render Camera" };
```

```ad-note
FrameDebugger 可以通过 `Window -> Analysis -> Frame Debugger` 打开。
```

```ad-note
 Profiler 可以通过 `Window -> Analysis -> Profiler` 打开。
```

而如果想要在 `Profiler` 中增加额外信息调试 `Command Buffer` ，可以使用 `commandBuffer.BeginSample` 和 `commandBuffer.EndSample` 命令，如将之前的代码修改为如下所示：

```csharp
private void Setup()
{
    buffer.BeginSample("Render Camera");
    ExecuteCommandBuffer();
    renderContext.SetupCameraProperties(camera);
}

private void DrawVisibleGeometry()
{
    renderContext.DrawSkybox(camera);
}

private void Submit()
{
    buffer.EndSample("Render Camera");
    ExecuteCommandBuffer();
    renderContext.Submit();
}

private void ExecuteCommandBuffer()
{
    renderContext.ExecuteCommandBuffer(buffer);
    buffer.Clear();
}
```

```ad-note
 `BeginSample` 和 `EndSample` 的命名需要与 Buffer 的名称相同，否则可能会出现 `Non matching Profiler.EndSample (BeginSample and EndSample count must match` 的错误。
```

```ad-note
像 `BeginSample` 和 `EndSample` 这样的API 每次执行都会向 Command Buffer 中增加一条命令，因此在 `ExecuteCommandBuffer` 中执行后需要对 Command Buffer 进行 `Clear` 操作，否则 Command Buffer 中的命令会越来越多。
```

## Clearing the Render Target

可通过在 CommandBuffer 中添加 `ClearRenderTarget` 命令来清除渲染目标的内容，如下所示：

```csharp
private void Setup()
{
    renderContext.SetupCameraProperties(camera);
    buffer.ClearRenderTarget(true, true, Color.clear);  // Clear render target
    buffer.BeginSample("Profile Render Camera");
    ExecuteCommandBuffer();
}
```

此时可以在 Frame Debugger 中看到 `Clear` 的命令，如下所示，其中的 `+Z` 表示 Depth 与 Stencil 共用了一块 Buffer。即这次 `Clear` 操作，同时清除了颜色，深度，模板的缓存。
![|500](assets/Custom%20Render%20Pipeline/Untitled%208.png)

注意在调用 `ClearRenderTarget` 命令前，必须依据设置了摄像机的属性，即调用了 `SetupCameraProperties` 。否则会出现 `Draw GL` 命令而非 `Clear` 命令，即 Unity 通过渲染一张铺满整个渲染目标的 Quad 来达成清除的目的，而这会消费较多的性能。如下代码与结果：

```csharp
private void Setup()
{
    buffer.ClearRenderTarget(true, true, Color.clear);
    buffer.BeginSample("Profile Render Camera");
    ExecuteCommandBuffer();
    renderContext.SetupCameraProperties(camera); // Execute Clear Before Set Camera Properties
}
```

![|500](assets/Custom%20Render%20Pipeline/Untitled%208%201.png)

## Culling

在正式的渲染前，为了保证仅渲染在摄像机的视锥体的内物体，需要让 Unity 进行 `Culling` 操作。因此需要，首先需要通过函数 `TryGetCullingParameters` 根据摄像机获取到 `Culling` 相关的参数，再通过函数 `context.Cull` 将相关参数传递给渲染上下文，并得到 Culling 的结果，代码如下所示：

```csharp
private bool Cull()
{
    if (camera.TryGetCullingParameters(out ScriptableCullingParameters cullingParameters))
    {
        cullingResults = renderContext.Cull(ref cullingParameters);
        return true;
    }
    return false;
}
```

在某些情况下，无法通过`TryGetCullingParameters` 函数获取到 Culling 的参数，如摄像机的 Viewport 为空，或者近远剪切平面的设置不合法。在这种情况下，应当不渲染任何东西，如下所示：

```csharp
public void Render(ScriptableRenderContext renderContext, Camera camera)
{
    this.renderContext = renderContext;
    this.camera = camera;

    if (!Cull()) // Get Culling parameters failed
        return;

		//...
}
```

```ad-note
SRP 中许多函数都以 `ref` 传递数值，如 `context.Cull` 函数。但这通常是处于性能方面的考虑，避免数据的拷贝，而非是需要修改传入的参数。
```

## Drawing Geometry

可以通过 `context.DrawRenderers` 方法绘制具体的几何体，如下所示：

```csharp
private static ShaderTagId unlitShaderTagId = new ShaderTagId("SRPDefaultUnlit");
//...
private void DrawVisibleGeometry()
{
    SortingSettings sortingSettings = new SortingSettings(camera) { criteria = SortingCriteria.CommonOpaque };
    DrawingSettings drawingSettings = new DrawingSettings(unlitShaderTagId, sortingSettings);
    FilteringSettings filteringSettings = new FilteringSettings(RenderQueueRange.all);

    renderContext.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);
    renderContext.DrawSkybox(camera);
}
```

`FilteringSetting` 决定了渲染指定 RenderQueue 范围内的物体，这里填的 `RenderQueueRange.all` 表示无论 RenderQueue 设置的为多少，都将被渲染。

其中 `DrawingSettings` 的第一个形参决定了需要执行的 Shader Pass， 这里传递的`SRPDefaultUnlit` 为 Unity 内置的 Tag，因为目前场景中的许多游戏物体选用的是 `Unlit` 中的 Shader，所以使用该 Tag。

```ad-note
```

<aside> 💡 

</aside>

`DrawSettings` 第二个形参是物体排序相关的设置 `SortingSettings`，该变量的构造函数依赖 `camera` 变量，会根据 [`camera.transparencySortMode`](https://docs.unity3d.com/ScriptReference/Camera-transparencySortMode.html) 决定以什么规则来计算排序的数值大小：

1.  Perspective：根据摄像机与物体中心的距离
2.  Orthographic：根据沿着摄像机 View 方向的距离

另外 `SortingSettings` 中的 `criteria` 制定了排序的标准，如这里的 `CommonOpaque` 表示使用通常渲染不透明物体时的排序规则，该规则会综合考虑 RenderQueue，材质，距离等相关信息。