---
tags:
    - Unity
created: 2022-01-09
updated: 2022-01-10
---

# Interface Registry

对于一个 Native 的库，可以通过如下函数监听 Unity Load/Unloaded 该库的时机：
```csharp
extern "C" void UNITY_INTERFACE_EXPORT UNITY_INTERFACE_API  UnityPluginLoad(IUnityInterfaces* unityInterfaces);

extern "C" void UNITY_INTERFACE_EXPORT UNITY_INTERFACE_API  UnityPluginUnload();
```

```ad-note
`UnityPluginUnload` 仅在应用推出的时候会被调用。
```

在 `UnityPluginLoad` 函数中会传递 `IUnityInterfaces` 变量，该变量是与 Unity 交互的主要接口。

# Access to the graphics device

可以通过 `IUnityInterfaces` 和 `RegisterDeviceEventCallback` 注册 Unity 图形系统的回调：

```cpp

IUnityGraphics *graphics
UnityGfxRenderer renderer;

extern "C"
{
    void UNITY_INTERFACE_API UNITY_INTERFACE_API UnityPluginLoad(IUnityInterfaces* unityInterfaces)
    {
        graphics = unityInterfaces->Get<IUnityGraphics>();
        graphics->RegisterDeviceEventCallback([](UnityGfxDeviceEventType eventType){ unityRendererPlugin.OnGraphicsDeviceEvent(eventType); });
    }
}

void UnityRendererPlugin::OnGraphicsDeviceEvent(UnityGfxDeviceEventType eventType)
{
    switch (eventType)
    {
        case kUnityGfxDeviceEventInitialize:
            renderer = graphics->GetRenderer();
            if (renderer == UnityGfxRenderer::kUnityGfxRendererNull || texMgr) return;

            texMgr = new TexMgr();
            texMgr->Initialize();
            break;
        case kUnityGfxDeviceEventShutdown:
            renderer = kUnityGfxRendererNull;
            if (texMgr) delete texMgr;
        default:
            break;
    }
}

```

## UnityGfxDeviceEventType

在被注册的回调函数中，会传递一系列 `eventType`，主要需要监听 `kUnityGfxDeviceEventInitialize` 和 `kUnityGfxDeviceEventShutdown` 事件。

```ad-note
`OnGraphicsDeviceEvent` 还会传递 `kUnityGfxDeviceEventBeforeReset` 和 `kUnityGfxDeviceEventAfterReset` 事件。但该两个事件仅会在 `Direct 9` 中被触发。
```

## UnityGfxRenderer

在 `kUnityGfxDeviceEventInitialize` 的事件回调中，可以通过 `IUnityGraphics::GetRenderer` 获取 `UnityGfxRenderer`，该类型表示渲染使用的 API 类型。

需要注意的是当 `kUnityGfxDeviceEventInitialize` 被触发时，很可能图形 API 尚未被初始完毕，此时得到的 `UnityGfxRenderer` 类型为 `UnityGfxRenderer::kUnityGfxRendererNull`。

# Plug-in callbacks on the rendering thread

可以在 Native 中定义函数作为渲染线程的触发。

## GetRenderEventFunc

`GetRenderEventFunc` 触发回调支持一个 `int` 形参作为需要执行的 `Event` 的 Index 值，如下所示：
```csharp
extern "C" UnityRenderingEvent UNITY_INTERFACE_EXPORT UNITY_INTERFACE_API GetRenderEventFunc()
{
    return OnRenderEvent;
}

static void UNITY_INTERFACE_API OnRenderEvent(int eventID)
{
    switch(eventID)
    {
        // ...
    }
}
```

在 C# 中，可以通过 `GL.IssuePluginEvent` 或 `CommandBuffer.IssuePluginEvent` 触发 ：
```csharp
public class UseRenderingPlugin : MonoBehaviour
{
    [DllImport("GhostCubePlugin")]
    private static extern IntPtr GetRenderEventFunc();

    void OnRenderObject()
    {
        GL.IssuePluginEvent(GetRenderEventFunc(), 1);

        // Using Command Buffer
        CommandBuffer triggerEventCommand = new CommandBuffer();
        triggerEventCommand.IssuePluginEvent(GetRenderEventFunc(), 1);
        UnityEngine.Graphics.ExecuteCommandBuffer(triggerEventCommand);
    }
}
```

## GetRenderEventAndDataFunc

可以通过 `GetRenderEventAndDataFunc` 函数在传递 `EventID` 的同时传递数据：
```csharp
extern "C" UnityRenderingEventAndData UNITY_INTERFACE_EXPORT UNITY_INTERFACE_API GetRenderEventAndDataFunc() { return OnUnityRenderEventWithData; }


void OnUnityRenderEventWithData(int eventID, void *data)
{
    switch (eventID)
    {
        // ...
    }
}

```

对于传递数据的 RenderEvent 函数，必须通过 `CommandBuffer`：
```csharp
private CommandBuffer triggerEventCommand = new CommandBuffer();

public void IssueDataEvent(EventDataType eventType, IntPtr data)
{
    triggerEventCommand.Clear();
    triggerEventCommand.IssuePluginEventAndData(GetRenderEventAndDataFunc(), (int)eventType, data);
    UnityEngine.Graphics.ExecuteCommandBuffer(triggerEventCommand);
}
```

```ad-note
当 Unity 中开启了 multi-threading 后，Unity 会在多个不同线程中创建不同的 `GL Conntext`。

因此 `OnGraphicsDeviceEvent` 和 `OnRenderEvent` 可能在不同线程被调用
```

# Reference

[DiligentGraphics/DiligentEngine: A modern cross-platform low-level graphics library and rendering framework (github.com)](https://github.com/DiligentGraphics/DiligentEngine)

[Unity Graphics Emulator for Native Plugin Development - CodeProject](https://www.codeproject.com/Articles/1216876/Unity-Graphics-Emulator-for-Native-Plugin-Developm)

[Unity - Manual: Low-level native plug-in interface (unity3d.com)](https://docs.unity3d.com/Manual/NativePluginInterface.html)