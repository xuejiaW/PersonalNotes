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

|                                                                              |                                                                              |                                                                              |
| ---------------------------------------------------------------------------- | ---------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| ![](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/Untitled.png)     | ![](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/Untitled%202.png) | ![](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/Untitled%204.png) |
| ![50](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/Untitled%201.png) | ![50](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/Untitled%203.png) | ![50](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/Untitled%205.png) |

在上述纹理移动的过程中，可以看到拥有不同颜色的透明像素的图，会显示出不同颜色的拖影，如下所示，最右侧的纹理的拖影是理想的状态，该纹理的不透明像素为红色：
![](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/cross_anim.gif)

不透明像素为蓝色的纹理移动过程中的具体变换如下，其中黑色线框表示纹理的边界，背后的小格子表示屏幕的像素：
![|300](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/blue_cross_move.gif)

可以看到当纹理的像素与屏幕的像素并未完全对齐时，会出现拖影。其根本原因是纹理的双线性采样导致，当纹理渲染的屏幕上时，如果屏幕的像素中点与纹理的像素中点并不完全匹配时，GPU将会采样周围多个纹理像素的颜色，并将其混合得到最终的颜色。

如果仅考虑横向两个像素的合并，且在某一帧屏幕像素中心正好处在纹理相邻像素的边界上，则GPU从该纹理上采样得到的颜色为纹理上这两个相邻像素的平均，下图中即为一个红色不透明像素和一个蓝色纯透明像素：

$$ 0.5 \cdot\left[\begin{array}{l}1 \\0 \\0 \\1\end{array}\right]+0.5 \cdot\left[\begin{array}{l}0 \\0 \\1 \\0\end{array}\right]=\left[\begin{array}{c}0.5 \\0 \\0.5 \\0.5\end{array}\right] $$

![|300](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/Untitled%206.png)

因为得到的像素颜色是半透明的（Alpha值为0.5），因此当这个像素需要被绘制到屏幕上时，会与当前纹理缓冲中的颜色（本例中为白色）进行Alpha 混合，如下公式所示，该颜色就是最终上屏的颜色，如下右所示：
$$ \begin{array}{l}\alpha_{\text {sprite}} \cdot R G B_{\text {sprite}}+\left(1-\alpha_{\text {sprite}}\right) \cdot R G B_{\text {Background}}\\ \\=0.5 \cdot\left[\begin{array}{c}0.5 \\0 \\0.5 \\ 0.5\end{array}\right]+(1-0.5) \cdot\left[\begin{array}{c}1 \\1 \\1 \\ 1\end{array} \right] \\ \\= \left[\begin{array}{c} 0.75 \\ 0.5 \\ 0.75 \\ 0.75 \end{array}\right] \end{array} $$