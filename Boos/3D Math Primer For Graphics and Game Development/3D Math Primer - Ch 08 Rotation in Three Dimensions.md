---
created: 2021-12-21
updated: 2021-12-21
---
## Parallax Mapping

[Normal Mapping](../Learn%20OpenGL/Learn%20OpenGL%20-%20Ch%2029%20Normal%20Mapping.md) 调整了表面的法线，让表面在光照的计算中能有更真实的表现。

但一个真正的有凹凸变化的平面，即使在不考虑光照效果的情况下，也会与高度无变化的平面效果上存在区别。如以一定的角度去观察平面，如果平面存在凸出，则该凸出点会遮挡住后面的平面。如下所示，$V$ 为视线方向，如果平面是如黑线所示一样无高度变化，则视线会看到 $A$ 点，而如果平面如红线般存在高度变化，则实现会看到 $B$ 点。
![](assets/3D%20Math%20Primer%20-%20Ch%2008%20Rotation%20in%20Three%20Dimensions/Untitled%203.png)