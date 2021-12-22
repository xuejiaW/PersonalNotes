---
tags:
    - Unity
created: 2021-12-22
updated: 2021-12-23
---

Gizmo 是 Unity 提供的在 Editor 中调试的工具。默认情况下，它只会在 Scene 场景中显示，但在 Game 场景中可以通过按钮 `Giamos` 打开显示：
![](assets/Unity%20-%20Gizmo/GIF%2012-22-2021%209-43-23%20AM.gif)

Gizmos 可以在函数 `OnDrawGizmos` 中定义，该函数会在 Editor 中被自动触发。

可以通过 `Gizmos.Color` 设置需要画的 Gizmo 的颜色，以及通过 `Gizmos.DrawXXX` 绘制 Dizmo，如 `Gizmos.DrawSphere`