---
created: 2022-01-05
updated: 2022-01-24
tags:
    - Unity
---
# Color32

`Color32`[^1] 占据 `32 bits`，色彩中的每个通道用 `8 bits` 表示，数值范围为 $0\sim255$。

# Color
`Color`[^2] 占据 `32 bytes`，色彩中的每个通道用 `float` 表示，数值范围为 $0 \sim 1$。

# Difference

## 内存占用
`Color32` 占据的内存更小，每个通道使用 `1 bytes`，一共使用 `4 bytes`。`Color` 每个通道使用 `4 bytes`，一共使用 `16 bytes`。

```ad-note
因此 `Color` 可以提供更精确的色彩控制，如可以存储一个通道的值为 $0.2346128$，转换为 $0 \sim 255$ 范围中为 $59.82626$，该精度使用 `Color32` 就无法实现。
```

## 接口丰富度
`Color` 提供了许多 `Static Properties` 用来表示特定的颜色，如 `Color.clear` 表示 $(0,0,0,0)$。

## 数学合理性

对于数学计算而言，`Color` 有更高的合理性。

如在使用 `Color` 格式下，一个 Red 通道值为 $0.7$，Alpha 通道值为 $0.5$，则对应的 [Premultiplied Alpha](../Computer%20Graphics/Premultiplied%20Alpha.md) 为 $0.7*0.5=0.35$，仍然是一个合法 `Color` 数值。

而如果使用 `Color32`，则 Red 通道值为 $127$，Alpha 通道值为 $178$，对应的 [Premultiplied Alpha](../Computer%20Graphics/Premultiplied%20Alpha.md) 值为 $127*178=22606$，不再是一个合法 `Color32` 数值。

# Reference

[What is the difference between Color and Color32 - Unity Forum](https://forum.unity.com/threads/what-is-the-difference-between-color-and-color32.824196/)

[^1]: [Unity - Scripting API: Color32 (unity3d.com)](https://docs.unity3d.com/ScriptReference/Color32.html)
[^2]: [Unity - Scripting API: Color (unity3d.com)](https://docs.unity3d.com/ScriptReference/Color.html)