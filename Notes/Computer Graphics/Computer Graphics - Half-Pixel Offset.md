---
created: 2021-12-31
updated: 2021-12-31
---

# Texels to Pixels

对于屏幕坐标系下，$(0,0)$ 点是左上角第一个像素的中心而不是整个屏幕的左上角，如下所示为一个 $8\times 8$ 的空间中各点的表示

![|300](assets/Computer%20Graphics%20-%20Half-Pixel%20Offset/Untitled.png)

对于纹理而言， uv 的 $(0,0)$ 点为图像的左上角，其左上角第一个像素中心的 uv 值为 $(0.5/\mathbf{texelWidth}, 0.5/\mathbf{texelHeight})$，如下所示为一个 $8 \times 8$ 的纹理的各 uv 点的表示：

![|300](assets/Computer%20Graphics%20-%20Half-Pixel%20Offset/Untitled%201.png)

因为上述纹理和像素对于坐标定义的差距，如果有一个 $4 \times 4$ 的纹理，将其 uv 的 $(0,0)$ 与像素的 $(0,0)$ 点对应，则实际如下所示，其中蓝色方块表示 $4 \times 4$ 的纹理，可以看到纹理像素和屏幕像素并未完全的对其：
![|300](assets/Computer%20Graphics%20-%20Half-Pixel%20Offset/Untitled%202.png)

根据 [Triangle Rasterization Rules](Computer%20Graphics%20-%20Triangle%20Rasterization%20Rules.md)，最终光栅化后，显示的像素仍然是 $4\time4$ 的，如下：
![|300](assets/Computer%20Graphics%20-%20Half-Pixel%20Offset/Untitled%203.png)

# Half-Pixel Offset

当考虑纹理被渲染的颜色时，Pixel 和 Texel 之间半像素的偏移就会导致采样颜色的不准确，如下左为用来渲染的 $4 \times 4$ 纹理，下中为实际渲染得到的颜色，下右为屏幕像素与纹理像素的对应关系：

|                                                                            |                                                                            |                     |
| -------------------------------------------------------------------------- | -------------------------------------------------------------------------- | --- |
| ![](assets/Computer%20Graphics%20-%20Half-Pixel%20Offset/Untitled%204.png) | ![](assets/Computer%20Graphics%20-%20Half-Pixel%20Offset/Untitled%205.png) |     |![](assets/Computer%20Graphics%20-%20Half-Pixel%20Offset/Untitled%205%201.png)