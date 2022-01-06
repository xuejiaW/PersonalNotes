---
cssclass: [table-border]
tags:
    - ComputerGraphics
created: 2022-01-06
updated: 2022-01-06
---

# 透明像素造成的失真

对于一张带有完全透明像素的纹理，从直觉上会觉得完全透明像素的RGB通道色彩是不重要的。毕竟Alpha通道值为0，无论RGB通道是什么颜色，最终都不会被显示出来，但实际并非如此。

如下，生成三张完全透明像素的RGB通道值不一样的图，从左至右，完全透明像素RGB通道颜色分别为绿色，蓝色，红色：

|                                                                          |                                                                              |                                                                              |
| ------------------------------------------------------------------------ | ---------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| ![](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/Untitled.png) | ![](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/Untitled%202.png) | ![](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/Untitled%204.png) |

