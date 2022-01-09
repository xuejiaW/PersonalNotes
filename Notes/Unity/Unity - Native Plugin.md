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

可以通过 `IUnityInterfaces` 注册 Unity 图形系统被jia'zai'shi



# Reference

[Unity Graphics Emulator for Native Plugin Development - CodeProject](https://www.codeproject.com/Articles/1216876/Unity-Graphics-Emulator-for-Native-Plugin-Developm)

[Unity - Manual: Low-level native plug-in interface (unity3d.com)](https://docs.unity3d.com/Manual/NativePluginInterface.html)