---
created: 2021-12-31
updated: 2021-12-31
---

# Texels to Pixels

对于屏幕坐标系下，$(0,0)$ 点是左上角第一个像素的中心而不是整个屏幕的左上角，如下所示为一个 $8\times 8$ 的空间中各点的表示

![](assets/Computer%20Graphics%20-%20Half-Pixel%20Offset/Untitled.png)

对于纹理而言， uv 的 $(0,0)$ 点为图像的左上角，其左上角第一个像素中心的 uv 值为 $(0.5/\mathbf{texelWidth}, 0.5/\mathbf{texelHeight})$，如下所示为一个 $8 \times 8$ 的纹理的各 uv 点的表示：

![](assets/Computer%20Graphics%20-%20Half-Pixel%20Offset/Untitled%201.png)