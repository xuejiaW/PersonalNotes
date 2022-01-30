---
tags:
    - Computer-Graphics
    - Math
created: 2022-01-30
updated: 2022-01-30
---

# Determinant of a Matrix

对于方阵而言，有一个重要的标量称为矩阵的 `行列式（Determinant of the matrix）`。

## Determinants of $2\times 2$ and $3\times 3$ matrices

方阵 $\mathbf{M}$的行列式写为 $|\mathbf{M}|$或者写为 $def \mathbf{M}$。

```ad-warning
非方阵的矩阵并没有行列式
```

二维行列式的计算过程如下：

$$ |\mathbf{M}|=\left|\begin{array}{ll} m_{11} & m_{12} \\ m_{21} & m_{22} \end{array}\right|=m_{11} m_{22}-m_{12} m_{21} $$