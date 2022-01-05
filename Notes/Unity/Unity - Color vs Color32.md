---
created: 2022-01-05
updated: 2022-01-05
---
# Color32

`Color32`[^1] 占据 `32 bits`，色彩中的每个通道用 `8 bits` 表示，数值范围为 $0\sim255$。

# Color
`Color`[^2] 占据 `32 bytes`，色彩中的每个通道用 `float` 表示，数值范围为 $0 \sim 1$。

# Difference

`Color32` 占据的内存更小，所有通道使用 `4 bytes`，`Color` 每个通道使用 `4 bytes`。

`Color` 提供了许多 `Static Properties` 用来表示特定的颜色，如 `Color.clear` 表示 $(0,0,0,0)$。

# Reference

[What is the difference between Color and Color32 - Unity Forum](https://forum.unity.com/threads/what-is-the-difference-between-color-and-color32.824196/)

[^1]: [Unity - Scripting API: Color32 (unity3d.com)](https://docs.unity3d.com/ScriptReference/Color32.html)
[^2]: [Unity - Scripting API: Color (unity3d.com)](https://docs.unity3d.com/ScriptReference/Color.html)