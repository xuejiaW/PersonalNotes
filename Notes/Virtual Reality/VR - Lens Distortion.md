---
tags:
    - Virtual-Reality
created: 2022-01-10
updated: 2022-01-10
---

# Overview

在 VR 中为了更高的沉浸感，需要有更大的 FOV。对于常规的将一个显示面板放在眼前的做法，只能实现很小的 FOV，如下所示：

![|500](assets/VR%20-%20Lens%20Distortion/Untitled.png)

```ad-note
虽然屏幕上显示的画面可能以很高的 FOV 渲染出来，但屏幕在人眼中所占据的 FOV 很小，人眼中大量区域是与屏幕显示画面不相关的 Dead Space。
```

为了获取更大的 FOV，一个粗暴的简单方法是将一个曲面显示面板放到离眼睛很近的地方，但这样的解决方法成本比较高昂。

还有一种更通用的解决方法是将一块透镜放在离眼睛很近的地方，通过该透镜去观察一个普通的显示面板。此时的效果如下所示，因为透镜离人眼足够的近，因此 Dead Space 很小，人眼的绝大部分 FOV 都用来看屏幕上的内容：

![|500](assets/VR%20-%20Lens%20Distortion/Untitled%201.png)

但渲染出的画面透过透镜显示会产生枕形畸变（Pincushion Distortion），如下所示，即人眼最终看到的画面是一个枕形的画面：
![|500](assets/VR%20-%20Lens%20Distortion/Untitled%202.png)

为了解决这个问题，需要先将渲染出的画面进行桶形畸变（Barrel Distortion），此时桶形的画面经过透镜后就会恢复为正常的形状，示意图如下所示：
![|500](assets/VR%20-%20Lens%20Distortion/Untitled%203.png)

# Barrel Distortion

对于实现桶形畸变有如下几种做法：

## Fragment based solution

通过像素着色器，对每个像素进行桶形的偏移，如下所示：
![|500](assets/VR%20-%20Lens%20Distortion/Untitled%204.png)

通过像素着色器的方法性能是最差的，因为需要对每一个像素进行处理。

## Mesh based solution

另一个做法是对顶点做桶形的偏移，即生成一个桶形的 Mesh，效果如下所示：
![|500](assets/VR%20-%20Lens%20Distortion/Untitled%205.png)

## Vertex displacement based solution

还有一种做法是在渲染物体时，就在物体的顶点着色器里直接对物体进行桶形的偏移，具体可见：

[VR Distortion Correction using Vertex Displacement](https://www.gamedeveloper.com/programming/vr-distortion-correction-using-vertex-displacement)

# Reference

[Three approaches to VR lens distortion | Boris Smus](https://smus.com/vr-lens-distortion/)