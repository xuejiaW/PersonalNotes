---
tags:
    - OpenGL
    - Computer-Graphics
cssclass: [table-border]
created: 2021-12-13
updated: 2022-01-13
---

# Perspective Projection

Projection 矩阵是用来做投影变换的矩阵，该矩阵主要有两个作用：

1.  将所有顶点从 Eye Coordinate （摄像机空间）转换到 Clip Coordinate
2.  计算出 $w$ 分量，后续管线中会通过 $w$ 进行 `FrustumClipping` 以及将顶点从 Clip Coordinate 转换到 NDC 空间中，具体的流程如下：

$$\left(\begin{array}{c}x_{\text {clip }} \\y_{\text {clip }} \\z_{c l i p} \\w_{\text {clip }}\end{array}\right)=M_{\text {projection }} \cdot\left(\begin{array}{c}x_{\text {eye }} \\y_{\text {eye }} \\z_{\text {eye }} \\w_{\text {eye }}\end{array}\right),\left(\begin{array}{l}x_{n d c} \\y_{n d c} \\z_{n d c}\end{array}\right)=\left(\begin{array}{c}x_{c l i p} / w_{c l i p} \\y_{c l i p} / w_{c l i p} \\z_{c l i p} / w_{c l i p}\end{array}\right)$$

```ad-note
下将 $x_{clip}$ 简写为 $x_c$ ，将 $x_{eye}$ 简写为 $x_e$，将 $x_{ndc}$ 简写为 $x_n$
```

```ad-note
 `Frustum Clipping` 是在 Clip Coordinate 中进行的。在除 $w$ 前，会首先对 $x,y,z$ 分量与 $w$ 进行比较，如果任何分量超过了 $-w \sim w$ 的范围，则该顶点会被抛弃。之后 OpenGL 会对有顶点被抛弃的多边形进行补面。
```

^1150b2

```ad-note
OpenGL 中的 Eye Coordinate 定义在右手坐标系中（与 OpenGL 原始坐标系相同），但 NDC 空间定义在左手坐标系中。
如下所示，左为 Eye Coordinate，右为 NDC Space：
![](assets/OpenGL-Projection%20Matrix/image-20211204110519486.png)
```


在 OpenGL 中，一个三维的点会被投影到近剪切平面，下两图分别展示了从顶部观察 Frustum 和从侧面观察 Frustum 的状态，在视锥体中的点为 $P_e = \left(\mathrm{x}_{\mathrm{e}}, y_{e}, z_{e}\right)$，投影在近剪切平面的点为 $P_p=(x_p,y_p,z_p)$。

|                                                                       |                                                                        |
| --------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| ![Top View](assets/OpenGL%20-%20Projection%20Matrix/image-20211208082200757.png) | ![Side View](assets/OpenGL%20-%20Projection%20Matrix/image-20211208082210356.png) |

```ad-warning
$P_{p}$ 并非在 Clip Coordinate 或 NDC Coordinate。它的值等于 Clip Coordinate 的值除以了 $w$ （完成了投影效果），但并未归一化到 $-1 \sim 1$ 的范围内（因此不是 NDC 空间）。
```

从顶视图分析，由相似性三角形可得：

$$\begin{aligned}\frac{x_{p}}{x_{e}} &=\frac{-n}{z_{e}} \\x_{p} &=\frac{-n \cdot x_{e}}{z_{e}}=\frac{n \cdot x_{e}}{-z_{e}}\end{aligned}$$

同理从侧视图分析，由相似三角形可得：

$$\begin{aligned}\frac{y_{p}}{y_{e}} &=\frac{-n}{z_{e}} \\y_{p} &=\frac{-n \cdot y_{e}}{z_{e}}=\frac{n \cdot y_{e}}{-z_{e}}\end{aligned}$$

可以看到 $x_p$ 和 $y_p$ 的分母都是 $-z_e$，而从 Clip Coordinate 转换到 NDC 空间时需要统一对 $x,y,z$ 分量除以 $w$。因此这里可以推断 $w_{c} = -z_{e}$，又根据投影矩阵的变换可以推断出投影矩阵的最后一行结果，如下：

$$\left(\begin{array}{c}x_{c} \\y_{c} \\z_{c} \\w_{c}\end{array}\right)=\left(\begin{array}{cccc}. & \cdot & \cdot & \cdot \\. & \cdot & \cdot & \cdot \\\cdot & \cdot & \cdot & \cdot \\0 & 0 & -1 & 0\end{array}\right)\left(\begin{array}{c}x_{e} \\y_{e} \\z_{e} \\w_{e}\end{array}\right), \quad \therefore w_{c}=-z_{e}$$

对于在近剪切平面的点的 $x$ 轴分量 $x_{p}$ 需要将其转换到 $-1 \sim 1$ 的范围内，即将其转换到 NDC 空间中。因为点 $x_p$ 的范围是 $l \sim r$ ，因此整个转换过程就是一个从 $l\sim r$ 转换到 $-1 \sim 1$ 的过程，因此可用下图和如下表达式表示：

|                                                               |                                                |
| ------------------------------------------------------------- | ---------------------------------------------- |
| ![](assets/OpenGL%20-%20Projection%20Matrix/image-20211208082926058.png) | $$x_{n}=\frac{1-(-1)}{r-l} \cdot x_{p}+\beta$$ |

其中取特殊点 $(r,1)$ 代入上式，可得：

$$\begin{aligned}1 &=\frac{2 r}{r-l}+\beta \quad\left(\text { substitute }(r, 1) \text { for }\left(x_{p}, x_{n}\right)\right) \\\beta &=1-\frac{2 r}{r-l}=\frac{r-l}{r-l}-\frac{2 r}{r-l} \\&=\frac{r-l-2 r}{r-l}=\frac{-r-l}{r-l}=-\frac{r+l}{r-l} \\x_{n} &=\frac{2 x_{p}}{r-l}-\frac{r+l}{r-l}\end{aligned}$$

同理对于 $y$ 轴分量 $y_p$而言，同样可以用如下的示意图和表达式表示：

|                                                               |                                                |
| ------------------------------------------------------------- | ---------------------------------------------- |
| ![](assets/OpenGL%20-%20Projection%20Matrix/image-20211208083122264.png) | $$y_{n}=\frac{1-(-1)}{t-b} \cdot y_{p}+\beta$$ |

同样的将特殊点 $(t,1)$ 代入上式，可得：

$$\begin{aligned}1 &=\frac{2 t}{t-b}+\beta \quad\left(\text { substitute }(t, 1) \text { for }\left(y_{p}, y_{n}\right)\right) \\\beta &=1-\frac{2 t}{t-b}=\frac{t-b}{t-b}-\frac{2 t}{t-b} \\&=\frac{t-b-2 t}{t-b}=\frac{-t-b}{t-b}=-\frac{t+b}{t-b} \\y_{n} &=\frac{2 y_{p}}{t-b}-\frac{t+b}{t-b}\end{aligned}$$

将之前由相似三角形得到的 $x_p$ 与 $x_e$ 的关系表达式，与 $y_p$ 与 $y_e$ 的关系表达式代入上述求到的 $x_n$ 与 $x_p$ 和 $y_n$ 与 $y_p$ 的关系表达式中可得：

|                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| $$\begin{aligned}x_{n} &=\frac{2 x_{p}}{r-l}-\frac{r+l}{r-l} \quad\left(x_{p}=\frac{n x_{e}}{-z_{e}}\right) \\&=\frac{2 \cdot \frac{n \cdot x_{e}}{-z_{e}}}{r-l}-\frac{r+l}{r-l} \\&=\frac{2 n \cdot x_{e}}{(r-l)\left(-z_{e}\right)}-\frac{r+l}{r-l} \\&=\frac{\frac{2 n}{r-l} \cdot x_{e}}{-z_{e}}-\frac{r+l}{r-l} \\&=\frac{\frac{2 n}{r-l} \cdot x_{e}}{-z_{e}}+\frac{\frac{r+l}{r-l} \cdot z_{e}}{-z_{e}} \\&=(\underbrace{\frac{2 n}{r-l} \cdot x_{e}+\frac{r+l}{r-l} \cdot z_{e}}_{x_{c}}) /-z_{e}\end{aligned}$$ | $$\begin{aligned}y_{n} &=\frac{2 y_{p}}{t-b}-\frac{t+b}{t-b} \quad\left(y_{p}=\frac{n y_{e}}{-z_{e}}\right) \\&=\frac{2 \cdot \frac{n \cdot y_{e}}{-z_{e}}}{t-b}-\frac{t+b}{t-b} \\&=\frac{2 n \cdot y_{e}}{(t-b)\left(-z_{e}\right)}-\frac{t+b}{t-b} \\&=\frac{2 n}{t-b} \cdot y_{e}-\frac{t+b}{t z_{e}}-\frac{t+b}{t-b} \\&=\frac{\frac{2 n}{t-b} \cdot y_{e}}{-z_{e}}+\frac{\frac{t+b}{t-b} \cdot z_{e}}{-z_{e}} \\&=(\underbrace{\frac{2 n}{t-b} \cdot y_{e}+\frac{t+b}{t-b} \cdot z_{e}}_{y_{c}}) /-z_{e}\end{aligned}$$ |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |

对于上述两式中的分母 $-Z_e$ 已经可以通过 Projection 矩阵的第四行获得，而根据上述两式中的分子，可得得到 Projection 矩阵的前两行表达：

$$\left(\begin{array}{c}x_{c} \\y_{c} \\z_{c} \\w_{c}\end{array}\right)=\left(\begin{array}{cccc}\frac{2 n}{r-l} & 0 & \frac{r+l}{r-l} & 0 \\0 & \frac{2 n}{t-b} & \frac{t+b}{t-b} & 0 \\. & . & . & \\0 & 0 & -1 & 0\end{array}\right)\left(\begin{array}{c}x_{e} \\y_{e} \\z_{e} \\w_{e}\end{array}\right)$$

剩下只剩下 Projection 矩阵的第三行，因为 $z$ 分量上的变化与 $x,y$ 值并不相关，因此可假定矩阵如下所示，并得出 $z_n$ 与 $w_c$ 的关系表达式：

$\left(\begin{array}{c}x_{c} \\y_{c} \\z_{c} \\w_{c}\end{array}\right)=\left(\begin{array}{cccc}\frac{2 n}{r-l} & 0 & \frac{r+l}{r-l} & 0 \\0 & \frac{2 n}{t-b} & \frac{t+b}{t-b} & 0 \\0 & 0 & A & B \\0 & 0 & -1 & 0\end{array}\right)\left(\begin{array}{c}x_{e} \\y_{e} \\z_{e} \\w_{e}\end{array}\right), \quad z_{n}=z_{c} / w_{c}=\frac{A z_{e}+B w_{e}}{-z_{e}}$

对于在 Eye Coordinate 中的点，它的 $w_e$ 分量必然为 $1$，因此 $z_n$ 的表达式可简化为：

$$z_{n}=\frac{A z_{e}+B}{-z_{e}}$$

```ad-note
摄像机空间中的点，仍然是三维空间中的点，而对于三维空间中的点，都采用 (x,y,z,1) 表达。
```

代入特殊点 $(-n,-1)$ 和 $(-f,1)$ 可得：

$$\left\{\begin{array} { l } { \frac { - A n + B } { n } = - 1 } \\{ \frac { - A f + B } { f } = 1 }\end{array} \rightarrow \left\{\begin{array}{l}-A n+B=-n \\-A f+B=f\end{array}\right.\right.$$

此时剩下的即为一个二元一次方程，可求得：

$$\begin{aligned} A&=-\frac{f+n}{f-n} \\ B&=- \frac{2fn}{f-n} \end{aligned}$$

即：

$$z_{n}=\frac{-\frac{f+n}{f-n} z_{e}-\frac{2 f n}{f-n}}{-z_{e}}$$

```ad-note
对于求出的 $z_e$ 与 $z_n$ 的关系式，可通过如下函数图像表达：
![](assets/Projection%20矩阵推导/image-20211208083547983.png)

当 $[-n,-f]$ 覆盖范围过大时，图像就会变成如下所示，在接近 $-f$ 的部分就会出现 Z-Fighting 的现象：
![](assets/Projection%20矩阵推导/image-20211208083608634.png)
```

因此完整的投影矩阵为：

$$\left(\begin{array}{cccc}\frac{2 n}{r-l} & 0 & \frac{r+l}{r-l} & 0 \\0 & \frac{2 n}{t-b} & \frac{t+b}{t-b} & 0 \\0 & 0 & \frac{-(f+n)}{f-n} & \frac{-2 f n}{f-n} \\0 & 0 & -1 & 0\end{array}\right)$$

因为大多数情况下，投影矩阵的视锥体都是对称的，因此可得：

$$\left\{\begin{array}{l} r+l=0 \\ r-l=2 r(\text { width }) \end{array} \quad, \quad\left\{\begin{array}{l} t+b=0 \\ t-b=2 t \text { (height) } \end{array}\right.\right.$$

也因此 Projection 矩阵可以化简为：

$$\left(\begin{array}{cccc}\frac{n}{r} & 0 & 0 & 0 \\0 & \frac{n}{t} & 0 & 0 \\0 & 0 & \frac{-(f+n)}{f-n} & \frac{-2 f n}{f-n} \\0 & 0 & -1 & 0\end{array}\right)$$

# Orthographic Projection

正交投影示意图如下所示，可以看到并没有 Perspective 投影中的投影关系：
![](assets/OpenGL%20-%20Projection%20Matrix/image-20211208083636280.png)

因此在 Orthographic 中对于 x_e 和 y_e 而言，可以直接通过线性关系将它们转换到 NDC 的 -1 \sim 1 中，方法与在求 Perspective 投影时相同，如下所示：

|                                                               |                                                                                                                                                                                                                                                        |
| ------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| ![](assets/OpenGL%20-%20Projection%20Matrix/image-20211208083659558.png) | $$\begin{aligned} x_{n} &=\frac{1-(-1)}{r-l} \cdot x_{e}+\beta \\ 1 &=\frac{2 r}{r-l}+\beta \quad({ substitute (r,1) })\\ \beta &=1-\frac{2 r}{r-l}=-\frac{r+l}{r-l} \\ \therefore x_{n} &=\frac{2}{r-l} \cdot x_{e}-\frac{r+l}{r-l} \end{aligned}$$   |
| ![](assets/OpenGL%20-%20Projection%20Matrix/image-20211208083718922.png) | $$\begin{aligned} y_{n} &=\frac{1-(-1)}{t-b} \cdot y_{e}+\beta \\ 1 &=\frac{2 t}{t-b}+\beta \quad({substitute(t,1)})\\ \beta &=1-\frac{2 t}{t-b}=-\frac{t+b}{t-b} \\ \therefore y_{n} &=\frac{2}{t-b} \cdot y_{e}-\frac{t+b}{t-b} \end{aligned}$$      |
| ![](assets/OpenGL%20-%20Projection%20Matrix/image-20211208083739997.png) | $$\begin{aligned}z_{n} &=\frac{1-(-1)}{-f-(-n)} \cdot z_{e}+\beta \\1 &=\frac{2 f}{f-n}+\beta \quad( { substitute(-f,1) }) \\\beta &=1-\frac{2 f}{f-n}=-\frac{f+n}{f-n} \\\therefore z_{n} &=\frac{-2}{f-n} \cdot z_{e}-\frac{f+n}{f-n}\end{aligned}$$ |

因此可得 Orthogaphic 投影矩阵的表达式为：

$$\left(\begin{array}{cccc}\frac{2}{r-l} & 0 & 0 & -\frac{r+l}{r-l} \\0 & \frac{2}{t-b} & 0 & -\frac{t+b}{t-b} \\0 & 0 & \frac{-2}{f-n} & -\frac{f+n}{f-n} \\0 & 0 & 0 & 1\end{array}\right)$$

如果是对称正交投影矩阵，则可得：

$$\left\{\begin{array}{l}r+l=0 \\r-l=2 r(\text { width })\end{array} \quad,\left\{\begin{array}{l}t+b=0 \\t-b=2 t \text { (height) }\end{array}\right.\right.$$

即矩阵可以简化为：

$$\left(\begin{array}{cccc}\frac{1}{r} & 0 & 0 & 0 \\0 & \frac{1}{t} & 0 & 0 \\0 & 0 & \frac{-2}{f-n} & -\frac{f+n}{f-n} \\0 & 0 & 0 & 1\end{array}\right)$$

# Reference

[OpenGL Projection Matrix (songho.ca)](http://www.songho.ca/opengl/gl_projectionmatrix.html)
