---
created: 2021-12-27
updated: 2022-01-17
tags:
    - Unity
---

# Strip Engine Code

当启用 IL2CPP 时，可以使用选项用来控制是否需要在编译时去除没有用到的引擎代码。

当开启该选项时，可以得到更小的包体，但有可能会引发 Bug。

![|500](assets/Unity%20-%20PlayerSettings/image-20211227225119615.png)

# Managed stripping levels

该选项用来选择 [Managed Code Stripping](Unity%20-%20Scripting%20Architecture/Unity%20-%20Managed%20Code%20Stripping.md) 的过滤等级，其中分为 `Disabled`，`Low`，`Medium`，`High` 四个等级。

