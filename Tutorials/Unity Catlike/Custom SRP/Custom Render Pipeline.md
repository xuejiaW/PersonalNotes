---
tags:
    - Unity
created: 2022-01-24
updated: 2022-01-24
cssclass: [table-border]
---

# A new Render Pileline

早期的 Unity 仅支持 ` 内置渲染管线（Default Render Pipeline, DRP / Built-in Render Pipleline）`。自 Unity 2018 后，Unity 引入了 ` 可编程渲染管线（Scriptable Render Piplelines，SRP）` ，但在 2018 中该功能是试验预览的状态，在 Unity 2019 中该功能才成为 正式功能。

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

在某些情况下，无法通过 `TryGetCullingParameters` 函数获取到 Culling 的参数，如摄像机的 Viewport 为空，或者近远剪切平面的设置不合法。在这种情况下，应当不渲染任何东西，如下所示：

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

其中 `DrawingSettings` 的第一个形参决定了需要执行的 Shader Pass， 这里传递的 `SRPDefaultUnlit` 为 Unity 内置的 Tag，因为目前场景中的许多游戏物体选用的是 `Unlit` 中的 Shader，所以使用该 Tag。

```ad-note
关于 [Shader Tag](https://docs.unity3d.com/Manual/SL-PassTags.html) 的内容，查看文档 [Built-In Shader Tag](https://docs.unity3d.com/Manual/shader-predefined-pass-tags-built-in.html) 与 [SRP Shader Tag](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@11.0/manual/urp-shaders/urp-shaderlab-pass-tags.html#urp-pass-tags-lightmode)
```

`DrawSettings` 第二个形参是物体排序相关的设置 `SortingSettings`，该变量的构造函数依赖 `camera` 变量，会根据 [`camera.transparencySortMode`](https://docs.unity3d.com/ScriptReference/Camera-transparencySortMode.html) 决定以什么规则来计算排序的数值大小：

1.  Perspective：根据摄像机与物体中心的距离
2.  Orthographic：根据沿着摄像机 View 方向的距离

另外 `SortingSettings` 中的 `criteria` 制定了排序的标准，如这里的 `CommonOpaque` 表示使用通常渲染不透明物体时的排序规则，该规则会综合考虑 RenderQueue，材质，距离等相关信息。

此时在 Frame Debugger 中查看渲染的顺序与结果，如下所示，可以看到基本是先渲染一个特定的材质，然后再渲染下一个：
![|500](assets/Custom%20Render%20Pipeline/GIF_2021-5-11_23-51-01.gif)

如果将 `SortingSettings` 中的 `criteria` 去除，即：
```csharp
private void DrawVisibleGeometry()
{
    SortingSettings sortingSettings = new SortingSettings(camera);
    DrawingSettings drawingSettings = new DrawingSettings(unlitShaderTagId, sortingSettings);
    FilteringSettings filteringSettings = new FilteringSettings(RenderQueueRange.all);

    renderContext.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);
    renderContext.DrawSkybox(camera);
}
```

则渲染的结果如下所示，几乎是一个无规律的状态在渲染：
![|500](assets/Custom%20Render%20Pipeline/GIF_2021-5-11_23-54-57.gif)

## Drawing Opaque and Transparent Geometry Separately

在之前的最终渲染结果中，天空盒将半透明物体的一部分遮挡掉了，如下所示：
![|500](assets/Custom%20Render%20Pipeline/Untitled%2010.png)

这是因为天空盒在半透明物体的之后进行渲染，而在 `Unlit/Transparent` 的 Shader 中，设置了 `ZWrite Off` ，即半透明物体不会写入深度缓冲，因此在绘制了半透明物体的部分，天空盒仍然能通过深度检测，即覆盖半透明物体。

解决这个问题的方式，就是调整渲染顺序为 ` 不透明物体 -> 天空盒 -> 半透明物体 ` 。实现方法如下所示：

```csharp
private void DrawVisibleGeometry()
{
    // Render Opaque objects
    SortingSettings sortingSettings = new SortingSettings(camera) { criteria = SortingCriteria.CommonOpaque };
    DrawingSettings drawingSettings = new DrawingSettings(unlitShaderTagId, sortingSettings);
    FilteringSettings filteringSettings = new FilteringSettings(RenderQueueRange.opaque);
    renderContext.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);

    renderContext.DrawSkybox(camera);

    // Render Transparent objects
    sortingSettings.criteria = SortingCriteria.CommonTransparent;
    drawingSettings.sortingSettings = sortingSettings;
    filteringSettings.renderQueueRange = RenderQueueRange.transparent;
    renderContext.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);
}
```

渲染结果如下：
![|500](assets/Custom%20Render%20Pipeline/Untitled%2011.png)

# Editor Rendering

## Drawing Legacy Shaders

之前通过在初始化 `DrawingSettings` 时，设置的 Shader Tag 为 `SRPDefaultUnlit` 的 Shader，因此仅会渲染 Unlit Shader 的物体。

而其余的物体，如使用了 `Standard` Shader 的物体，可以通过 Built-in 的 Shader Tag 找到并渲染，如下所示：

```csharp
private static ShaderTagId[] legacyShaderTagIds =
{
    new ShaderTagId("Always"),
    new ShaderTagId("ForwardBase"),
    new ShaderTagId("PrepassBase"),
    new ShaderTagId("Vertex"),
    new ShaderTagId("VertexLMRGBM"),
    new ShaderTagId("VertexLM")
 };

public void Render(ScriptableRenderContext renderContext, Camera camera)
{
        //...
    Setup();
    DrawVisibleGeometry();
    DrawUnSupportedShadersGeometry();
    Submit();
}

private void DrawUnSupportedShadersGeometry()
{
    DrawingSettings drawingSettings = new DrawingSettings();
    drawingSettings.sortingSettings = new SortingSettings(camera);
    for (int i = 0; i != legacyShaderTagIds.Length; ++i)
        drawingSettings.SetShaderPassName(i, legacyShaderTagIds[i]);

    FilteringSettings filteringSettings = FilteringSettings.defaultValue;

    renderContext.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);
}
```

其中的 `legacyShaderTagIds` 中指定了常用的 Built-in 的 Shader Tag，即会尝试渲染 Built-in Shader 的物体。结果如下所示：
![|500](assets/Custom%20Render%20Pipeline/Untitled%2012.png)

虽然用了 `Standard` Shader 的物体被渲染了出来，但显示的是黑色。这是因为 `SRP` 并没有设置这些 Built-in Shader 所需要的参数。

## Error Material

上节中黑色的纹理实际上是因为其中包含了 `SRP` 无法设置的参数而导致渲染错误，可以使用 Unity 内置的表示 Shader 错误的特殊 Shader 来渲染这些物体，只需要修改 `DrawingSettings` 中的 `overrideMaterial` 即可，如下所示：

```csharp
private static Material errorMaterial = null;

private void DrawUnSupportedShadersGeometry()
{
    if (errorMaterial == null)
        errorMaterial = new Material(Shader.Find("Hidden/InternalErrorShader"));

    DrawingSettings drawingSettings = new DrawingSettings();
    drawingSettings.sortingSettings = new SortingSettings(camera);
    drawingSettings.overrideMaterial = errorMaterial;

        // ...
}
```

此时结果如下：
![|500](assets/Custom%20Render%20Pipeline/Untitled%2013.png)

## Partial Class

可以 Scripting Smbols 让不支持的 Shader 部分仅在 Editor 和 Development Build 才被显示，即将相关代码定义放到如下的代码块中：

```csharp
#if UNITY_EDITOR || DEVELOPMENT_BUILD
//...
#endif
```

同时为了更好的管理代码，可以将 Editor 部分放到 `CameraRenderer.Editor` 中，如下所示：

```csharp
// In CameraRenderer.Editor.cs
public partial class CameraRenderer
{

#if UNITY_EDITOR || DEVELOPMENT_BUILD
    private static ShaderTagId[] legacyShaderTagIds =
    {
                // ...
    };

    private static Material errorMaterial = null;

    partial void DrawUnSupportedShadersGeometry()
    {
        // ...
    }
#endif
}

// in CameraRenderer.cs
partial void DrawUnSupportedShadersGeometry();

```

这里使用了 Partial Class 拆分 `CameraRenderer` 类，方便代码管理。并将 `DrawUnSupportedShaderGeometry` 函数定义为 Partial Method，保证在非 Editor 和 Development Build 时，即使 `DrawUnSupportedShaderGeometry` 未被定义实现，代码仍然能正常编译。

```ad-note
因为在 `CameraRenderer.Editor` 中定义了 `#if UNITY_EDITOR` ，因此其中的代码都仅在 Editor 下运行。
```

## Drawing Gizmos

目前在 Scene 场景中并没有绘制 `Gizmo` ，如场景中并没有摄像机的显示，也没有摄像机的视锥体的展示。

可以通过 `Handles.ShouldRenderGizmos` 判断当前帧是否需要渲染 `Gizmos` ，如需要的话可通过函数 `context.DrawGizmos` 进行绘制。 `Gizmos` 的绘制应当在整个流程的最后。

最终绘制 `Gizmos` 的代码如下：
```csharp
// In CameraRenderer
partial void DrawGizmos();

public void Render(ScriptableRenderContext renderContext, Camera camera)
{
        // ...
        Setup();
    DrawVisibleGeometry();
    DrawUnSupportedShadersGeometry();
    DrawGizmos();
    Submit();
}

// In CameraRenderer.Editor
partial void DrawGizmos()
{
    if (Handles.ShouldRenderGizmos())
    {
        renderContext.DrawGizmos(camera, GizmoSubset.PreImageEffects);
        renderContext.DrawGizmos(camera, GizmoSubset.PostImageEffects);
    }
}
```

其中 `context.DrawGizmos` 需要两个参数，第一个是表示当前 View 的 Camera， 第二个表示哪种 `Gizmos` 需要被绘制， `GizmoSubset.PreImageEffects` 表示受后处理影响的 `Gizmos` ， `GizmoSubset.PostImageEffects` 表示不受后处理影响的部分。这里选择渲染所有种类的 `Gizmos` 。渲染的结果如下：
![|500](assets/Custom%20Render%20Pipeline/Untitled%2014.png)

## Drawing Unity UI

在场景中添加了一个 UGUI 的 Button 后，可以看到按钮在 Game 界面中被正常的渲染了出来，如下所示：
![|500](assets/Custom%20Render%20Pipeline/Untitled%2015.png)

但通过 Frame Debugger 可以发现此时 UI 的渲染并没有经过自定义的 SRP 如下所示：
![|500](assets/Custom%20Render%20Pipeline/Untitled%2016.png)

而当将 `Canvas` 中的 `Render Mode` 修改为 `Screen Space - Camera` 或 `World Space` 后，UI 的渲染被放到了渲染半透明物体的部分中，如下所示，且此时因为在半透明的队列中先渲染了 UI，所以 UI 几乎被其他物体遮挡住了：

|     |     |
| --- | --- |
| ![](assets/Custom%20Render%20Pipeline/Untitled%2017.png)    |  ![](assets/Custom%20Render%20Pipeline/Untitled%2018.png)   |

但无论 `Render Mode` 是什么格式，在 Scene 界面中，UI 都没有被正常的渲染出来，能看到的只有 UI 的 `Gizmo` ，如下：
![](assets/Custom%20Render%20Pipeline/Untitled%2019.png)

这是因为 UI 在 Scene 界面下，都是以 `World Space` 模式被渲染出来，而且用了不同的几何信息，且 UI 在 Scene 下的几何信息默认并没有被添加到 SRP 中。对于在 Scene 中显示的 UI 的几何信息，需要通过函数 `ScriptabEmitWorldGeometryForSceneView` 添加到 SRP 中。且需要在调用 `Cull` 函数前被添加，保证这些几何信息同样会被进行正常裁剪。

整体代码如下所示：

```csharp
// In CameraRenderer
partial void PrepareForSceneWindow();

public void Render(ScriptableRenderContext renderContext, Camera camera)
{
        // ...
    PrepareForSceneWindow();
    if (!Cull()) // Get Culling parameters failed
        return;
        // ...
}

// In CameraRenderer.Editor
partial void PrepareForSceneWindow()
{
    if (camera.cameraType == CameraType.SceneView)
    {
      ScriptableRenderContext.EmitWorldGeometryForSceneView(camera);
    }
}
```

# Multiply Cameras

## Two Cameras

在场景中可以将 `Main Camera` 进行拷贝，并将新的 Camera 命名为 `Second Camera` ，并将 `Second Camera` 的 `Depth` 参数设置为 0，即此时会先渲染 `Main Camera` ，然后再渲染 `Second Camera` ：

|                                                                   |                                                                     |                                                                       |
| ----------------------------------------------------------------- | ------------------------------------------------------------------- | --------------------------------------------------------------------- |
| ![Hierarchy](assets/Custom%20Render%20Pipeline/Untitled%2020.png) | ![Main Camera](assets/Custom%20Render%20Pipeline/Untitled%2021.png) | ![Second Camera](assets/Custom%20Render%20Pipeline/Untitled%2022.png) |

此时在 Frame Debugger 中可以看到两个摄像机的渲染被合并在了一起，如下所示：
![](assets/Custom%20Render%20Pipeline/Untitled%2023.png)

这是因为此时两个 Camera 对应的 `CameraRenderer` 中的 `Command Buffer` 命名相同，因此 Frame Debugger 将两者的信息合并在了一起。

可以通过分别对两个 Command Buffer 进行命令来分开两者的渲染信息，如下所示：

```csharp
// In CameraRenderer
partial void PrepareBuffer();
public void Render(ScriptableRenderContext renderContext, Camera camera)
{
        // ...
        PrepareBuffer();
    PrepareForSceneWindow();
    if (!Cull()) // Get Culling parameters failed
        return;
        // ...
}

// In CameraRenderer.Editor
partial void PrepareBuffer()
{
    buffer.name = camera.name;
}
``` 

```ad-note
`camera.name` 会造成内存分配，但因为 `PrepareBuffer` 是定义在 `CameraRender.Editor` 中，因此仅在 Editor 模式下运行，不会造成运行时的性能浪费。
```

此时 Frame Debugger 界面如下：
![|500  ](assets/Custom%20Render%20Pipeline/Untitled%2024.png)

## Layers

可以调整物体的 `Layer` 以及摄像机的 `Culling Mask` 来控制摄像机仅渲染特定的游戏物体。

如将所有使用了 `Standard` 的游戏物体的 `Layer` 调整为 `Ignore Raycast` ，并将两个摄像机的 `Culling Mask` 设置为如下：

 |                                                                     |                                                                       |
 | ------------------------------------------------------------------- | --------------------------------------------------------------------- |
 | ![Main Camera](assets/Custom%20Render%20Pipeline/Untitled%2025.png) | ![Second Camera](assets/Custom%20Render%20Pipeline/Untitled%2026.png) |

此时的渲染结果如下，因为 Second Camera 仅渲染 `Ignore Raycast` Layer 的物体，又 Second Camera 会覆盖 Main Camera 的内容：

![|500](assets/Custom%20Render%20Pipeline/Untitled%2027.png)

```ad-note
UI 的 Render Mode 为 `Screen Space - Camera` ，因此会无视 Camera 的 Culling Mask 设置，必然会被渲染到屏幕上。
```

## Clear Flags

可以通过修改两个摄像机的 Clear Flags 来合并两个摄像机的渲染内容。并根据摄像机的 Clear Flags 调整 ClearRenderTarget 的逻辑，如下所示：

```csharp
private void Setup()
{
		// ...
    CameraClearFlags flags = camera.clearFlags;
    buffer.ClearRenderTarget(flags <= CameraClearFlags.Depth, flags == CameraClearFlags.Color,
                flags == CameraClearFlags.Color ? camera.backgroundColor.linear : Color.clear);
		// ...
}
```

其中 `CameraClearFlags` 是 Unity 定义的一个枚举值，有四个参数，参数数值从 1 到 4，分别为 `Skybox` , `Color` , `Depth` , `Nothing` 。

上述代码中，除了 `Nothing` 的情况，都会将 Depth Buffer 清除，而仅在为 `Color` 的时候会对 Color Buffer 进行清除。在清除时，仅当为 `Color` 时使用 `camera.backgroundColor` 其余时候都用 `Color.clear` 。

```ad-note
使用 `camera.backgroundColor.linear` 是因为项目建立时，将颜色空间设置为了 `Linear` 。
```

```ad-note
理论上，在 `CameraClearFlags` 为 `Skybox` 时也应当清除 `Color Buffer` ，但因为 `Skybox` 时擦除了 Depth Buffer，又会在渲染的最后绘制 Skybox，所以上一帧的颜色内容即使不清除，也会被这一帧渲染的 Skybox 覆盖，因此不会造成显示的错误。
```

`Main Camera` 作为第一个渲染的摄像机，为了保证渲染的正确性，必须使用 `Skybox` 或 `Color` 作为 Clear Flags。 `Second Camera` 为了不 Clear 掉 `Main Camera` 渲染的内容，则必须使用 `Depth` 或 `Nothing` 保证 `Main Camear` 渲染的 Color Buffer 被保持。

当 `Second Camera` 选择 `Depth` 时， `Main Camera` 渲染的 Depth Buffer 会被 Clear，此时 `Second Camera` 渲染的内容就都会叠加到 `Main Camera` 的内容上。

当 `Second Camera` 选择 `Nothing` 时， `Main Camera` 渲染的 Depth Buffer 会被保留，此时 `Second Camera` 渲染的内容就仍要与 `Main Camera` 渲染的内容进行深度检测。

当 `Main Camera` Clear Flags 为 `Skybox` ， `Second Camera` 的 Clear Flags 分别为 `Skybox` , `Color` , `Depth` , `Nothing` 的结果如下：

|                                                              |                                                          |
| ------------------------------------------------------------ | -------------------------------------------------------- |
| ![](assets/Custom%20Render%20Pipeline/Untitled%2027%201.png) | ![](assets/Custom%20Render%20Pipeline/Untitled%2030.png) |
|                                                              |                                                          |