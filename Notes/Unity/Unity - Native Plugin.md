---
tags:
    - Unity
created: 2022-01-09
updated: 2022-01-09
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
UnityRendererPlugin unityRendererPlugin;

extern "C"
{
    void UNITY_INTERFACE_API UNITY_INTERFACE_API UnityPluginLoad(IUnityInterfaces* unityInterfaces)
    {
        unityRendererPlugin.graphics = unityInterfaces->Get<IUnityGraphics>();
        unityRendererPlugin.graphics->RegisterDeviceEventCallback([](UnityGfxDeviceEventType eventType){ unityRendererPlugin.OnGraphicsDeviceEvent(eventType); });
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

在被注册的回调函数中，会传递一系列 `eventType`，主要需要监听 `kUnityGfxDeviceEventInitialize` 和 `kUnityGfxDeviceEventShutdown` 事件。

```ad-note
`OnGraphicsDeviceEvent` 还会传递 `kUnityGfxDeviceEventBeforeReset` 和 `kUnityGfxDeviceEventAfterReset` 事件。但该两个事件仅会在 `Direct 9` 中被触发。
```


# Reference

[Unity Graphics Emulator for Native Plugin Development - CodeProject](https://www.codeproject.com/Articles/1216876/Unity-Graphics-Emulator-for-Native-Plugin-Developm)

[Unity - Manual: Low-level native plug-in interface (unity3d.com)](https://docs.unity3d.com/Manual/NativePluginInterface.html)