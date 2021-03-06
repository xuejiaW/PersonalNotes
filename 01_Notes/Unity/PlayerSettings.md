---
created: 2021-12-27
updated: 2022-01-28
tags:
    - Unity
---

# Strip Engine Code

当启用 IL2CPP 时，可以使用选项用来控制是否需要在编译时去除没有用到的引擎代码。

当开启该选项时，可以得到更小的包体，但有可能会引发 Bug。

![|500](assets/PlayerSettings/image-20211227225119615.png)

# Managed stripping levels

该选项用来选择 [Managed Code Stripping](Scripting%20Architecture/Scripting%20backends/Managed%20Code%20Stripping.md) 的过滤等级，其中分为 `Disabled`，`Low`，`Medium`，`High` 四个等级，随着 `Managed stripping levels` 的等级越高，过滤的策略越激进，`Disabled`  情况下不会删除任何的代码，默认的设置是 `Disabled`。  

在 `IL2CPP` 模式下，默认的等级是 `Low` ，且在 `IL2CPP` 模式下可选的最低等级就是 `Low`。

```ad-tip
关于各过滤等级下具体的过滤规则，可参考 [Unity - Manual: Managed code stripping (unity3d.com)](https://docs.unity3d.com/Manual/ManagedCodeStripping.html) 中的 `How the UnityLinker strips assemblies` 部分
```

