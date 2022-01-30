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

三维行列式的计算过程如下：

$$ \begin{aligned} \left|\begin{array}{lll} m_{11} & m_{12} & m_{13} \\ m_{21} & m_{22} & m_{23} \\ m_{31} & m_{32} & m_{33} \end{array}\right|&=\begin{array}{l} &m_{11} m_{22} m_{33}+m_{12} m_{23} m_{31}+m_{13} m_{21} m_{32} \\ &-m_{13} m_{22} m_{31}-m_{12} m_{21} m_{33}-m_{11} m_{23} m_{32} \end{array} \\\\ &=\begin{array}{l} & m_{11}\left(m_{22} m_{33}-m_{23} m_{32}\right) \\ &+m_{12}\left(m_{23} m_{31}-m_{21} m_{33}\right) \\ &+m_{13}\left(m_{21} m_{32}-m_{22} m_{31}\right) \end{array} \end{aligned} $$

## Minors and Cofactors

对于矩阵 $\mathbf{M}$ 来， $\mathbf{M}^{\{ij\}}$ 表示删除了第 $i$ 行和第 $j$ 的子矩阵，而子矩阵的行列式称为 `余子式（Minors）`，计算过程如下所示：

$$ \mathbf{M}=\left[\begin{array}{ccc} -4 & -3 & 3 \\\\ 0 & 2 & -2 \\\\ 1 & 4 & -1 \end{array}\right] \quad \Longrightarrow \quad M^{\{12\}}=\left|\begin{array}{cc} 0 & -2 \\\\ 1 & -1 \end{array}\right|=2 $$

`代数余子式（Cofactors）`是在余子式上再加上一个系数，该系数由子矩阵所删除的行列决定，即：

$$ C^{\{i j\}}=(-1)^{i+j} M^{\{i j\}} $$

```ad-note
```
<aside> 💡 

</aside>

### Determinants of Arbitrary $n\times n$ Matrices

任意 $n\times n$ 矩阵的行列式计算过程如下：

1.  任意选取一行或一列
2.  对这行或这列中的每一个元素，将它和它所在行列的代数余子式相乘。
3.  将第二步中的所有结果累加