---
created: 2021-12-21
updated: 2022-01-30
tags:
    - Computer-Graphics
    - Math
---

# What Exactly is "Orientation"

`方向（direction）`只需要两个参数表示，而`朝向（orientation）`需要三个参数表示。如下图中确认飞机的朝向需要两个参数，而朝向还需要图中的绿圈方向来决定其旋转角度。

`朝向（orientation）`，`旋转（rotation）`和`角位移（angular displacement）`三者的关系为，`旋转`将物体从一个`朝向`转换为另一个`朝向`，这个转换的数值为`角位移`。

角位移与朝向的关系与线段和点的关系有点类似，前者都是表示一个变换，后者都是表示一个状态。

# Matrix Form

这一节是描述用 $3 \times 3$ 的矩阵来描述旋转。

## Direction Consines Matrix

通过矩阵来进行旋转实际上是从 `方向余弦（Direction cosines）`这个概念中得到的，ji一个方向余弦矩阵就是一个旋转矩阵。

假设变换前的三个坐标轴分别为 $\hat{\mathbf{x1}}, \hat{\mathbf{x2}}, \hat{\mathbf{x3}}$，变换后的三个坐标轴分别为 $\hat{\mathbf{e1}}, \hat{\mathbf{e2}}, \hat{\mathbf{e3}}$。

通过点乘求得将 $\hat{\mathbf{ei}}$ 在 $\hat{\mathbf{xj}}$ 上的分量，即 $(\hat{\mathbf{xj}} \cdot \hat{\mathbf{ei}})\hat{\mathbf{xj}}$

又 $\hat{\mathbf{ei}}$ 和 $\hat{\mathbf{xj}}$ 的夹角为：

$$ \cos \left(\theta_{i j}\right)=\frac{\hat{\mathbf{e}}{i} \cdot \hat{\mathbf{x}}{j}}{|\hat{\mathbf{e}}{i}||\hat{\mathbf{x}}{j}|}= \hat{\mathbf{e}}{i} \cdot \hat{\mathbf{x}}{j} $$

因此 $\hat{\mathbf{e}}{i}$ 在 $\hat{\mathbf{x}}{j}$ 上的分量可简化为：$\cos \left(\theta_{i j}\right)\hat{\mathbf{xj}}$

因为坐标轴 $\hat{e_{i}}$ 可以通过在不同的 $\hat{x_{i}}$ 上的分量累加进行表示，于是可得变换后坐标轴的等式表示：

$$ \begin{aligned}&\hat{\mathbf{e1}}=\cos \left(\theta_{11}\right) \hat{\mathbf{x1}}+\cos \left(\theta_{12}\right) \hat{\mathbf{x2}}+\cos \left(\theta_{13}\right) \hat{\mathbf{x3}}\\&\hat{\mathbf{e}}_{2}=\cos \left(\theta_{21}\right) \hat{\mathbf{x1}}+\cos \left(\theta_{22}\right) \hat{\mathbf{x2}}+\cos \left(\theta_{23}\right) \hat{\mathbf{x3}}\\&\hat{\mathbf{e}}_{3}=\cos \left(\theta_{31}\right) \hat{\mathbf{x1}}+\cos \left(\theta_{32}\right) \hat{\mathbf{x2}}+\cos \left(\theta_{33}\right) \hat{\mathbf{x3}}\end{aligned} $$

如果将这个变换用矩阵表示，即为：

$$ \left[\begin{array}{l} \hat{\mathbf{x1}}\\ \hat{\mathbf{x2}} \\ \hat{\mathbf{x3}} \end{array}\right]\mathbf{A}=\left[\begin{array}{l} \hat{\mathbf{e1}}\\ \hat{\mathbf{e2}} \\ \hat{\mathbf{e3}} \end{array}\right] $$