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
余子式和代数余子式在之后求任意维度的行列式时会用到
```

## Determinants of Arbitrary $n\times n$ Matrices

任意 $n\times n$ 矩阵的行列式计算过程如下：

1.  任意选取一行或一列
2.  对这行或这列中的每一个元素，将它和它所在行列的代数余子式相乘。
3.  将第二步中的所有结果累加

即：

$$ |\mathbf{M}|=\sum_{j=1}^{n} m_{i j} C^{\{i j\}}=\sum_{j=1}^{n} m_{i j}(-1)^{i+j} M^{\{i j\}} $$

如果一个三维矩阵通过上述方法计算：

$$ \begin{aligned} \left|\begin{array}{lll} m_{11} & m_{12} & m_{13} \\ m_{21} & m_{22} & m_{23} \\ m_{31} & m_{32} & m_{33} \end{array}\right|&=m_{11}\left|\begin{array}{cc} m_{22} & m_{23} \\ m_{32} & m_{33} \end{array}\right| \\&-m_{12}\left|\begin{array}{cc} m_{21} & m_{23} \\ m_{31} & m_{33} \end{array}\right| \\ &+m_{13}\left|\begin{array}{cc} m_{21} & m_{22} \\ m_{31} & m_{32} \end{array}\right| \end{aligned} $$

以下为行列式的一些重要特性：

1.  如果矩阵是单位矩阵，那么行列式为1
    
    $$ |\mathbf{I}|=1 $$
    
2.  矩阵乘积的行列式等于矩阵行列式的乘积
    
    $$ |\mathbf{A B}|=|\mathbf{A} \| \mathbf{B}| $$
    
3.  矩阵转置的行列式等于矩阵的行列式
    
    $$ \left|\mathbf{M}^{\mathrm{T}}\right|=|\mathbf{M}| $$
    
4.  有任意行或列全为0，则该矩阵行列式为0
    
    $$ \left|\begin{array}{cccc} ? & ? & \cdots & ? \\ ? & ? & \cdots & ? \\ \vdots & \vdots & & \vdots \\ 0 & 0 & \cdots & 0 \\ \vdots & \vdots & & \vdots \\ \vdots & ? & \cdots & ? \end{array}\right|=\left|\begin{array}{cccccc} ? & ? & \cdots & 0 & \cdots & ? \\ ? & ? & \cdots & 0 & \cdots & ? \\ \vdots & \vdots & & \vdots & & \vdots \\ ? & ? & \cdots & 0 & \cdots & ? \end{array}\right|=0 $$

5.  交换矩阵的任意两行或两列，行列式取反
    
    $$ \left|\begin{array}{cccc} m_{11} & m_{12} & \cdots & m_{1 n} \\ m_{21} & m_{22} & \cdots & m_{2 n} \\ \vdots & \vdots & & \vdots \\ m_{i 1} & m_{i 2} & \cdots & m_{i n} \\ \vdots & \vdots & & \vdots \\ m_{j 1} & m_{j 2} & \cdots & m_{j n} \\ \vdots & \vdots & & \vdots \\ m_{n 1} & m_{n 2} & \cdots & m_{n n} \end{array}\right|=-\left|\begin{array}{cccc} m_{11} & m_{12} & \cdots & m_{1 n} \\ m_{21} & m_{22} & \cdots & m_{2 n} \\ \vdots & \vdots & & \vdots \\ m_{j 1} & m_{j 2} & \cdots & m_{j n} \\ \vdots & \vdots & & \vdots \\ m_{i 1} & m_{i 2} & \cdots & m_{i n} \\ \vdots & \vdots & & \vdots \\ m_{n 1} & m_{n 2} & \cdots & m_{n n} \end{array}\right| $$
    
6.  将矩阵的一行或一列乘以系数后加到零一行或列上不改变行列式的值（因此切变的行列式为1）
    
    $$ \left|\begin{array}{cccc} m_{11} & m_{12} & \cdots & m_{1 n} \\ m_{21} & m_{22} & \cdots & m_{2 n} \\ \vdots & \vdots & & \vdots \\ m_{i 1} & m_{i 2} & \cdots & m_{i n} \\ \vdots & \vdots & & \vdots \\ m_{j 1} & m_{j 2} & \cdots & m_{j n} \\ \vdots & \vdots & & \vdots \\ m_{n 1} & m_{n 2} & \cdots & m_{n n} \end{array}\right|=\left|\begin{array}{cccc} m_{11} & m_{12} & \cdots & m_{1 n} \\ m_{21} & m_{22} & \cdots & m_{2 n} \\ \vdots & \vdots & & \vdots \\ m_{i 1}+k m_{j 1} & m_{i 2}+k m_{j 2} & \cdots & m_{i n}+k m_{j n} \\ \vdots & \vdots & & \vdots \\ m_{j 1} & m_{j 2} & \cdots & m_{j n} \\ \vdots & \vdots & & \vdots \\ m_{n 1} & m_{n 2} & \cdots & m_{n n} \end{array}\right| $$

## Geometric Interpretation of Determinant

在2D中，行列式实际上是表达了两个向量（每一行表示一个向量）所构成的平行四边形的有向面积，如：
![|400](assets/Ch%2006%20More%20on%20Matrices/image-20200307221134452.png)

同理，在3D中即表示由三条向量构成的平行六面体体积。

```ad-note
行列式的大小表示了一个变换是否改变了多个向量所构成物体的面积或体积。 行列式的正负表示了变换是否存在反转。 如果行列式为0，那么说明这个变换存在投影。
```

# Inverse of a Matrix

矩阵 $\mathbf{M}$ 的逆矩阵为 $\mathbf{M^{-1}}$，矩阵与逆矩阵的乘积为单位矩阵，即：

$$ \mathbf{M}\left(\mathbf{M}^{-1}\right)=\mathbf{M}^{-1} \mathbf{M}=\mathbf{I} $$


并不是所有的矩阵都有逆矩阵，如零矩阵无论与哪个矩阵相乘都不会成为单位矩阵。

如果一个矩阵有逆矩阵，就称该矩阵为 `可逆矩阵或非奇异矩阵（Invertible or nonsingular）`。

🔥 可逆矩阵有如下性质：

1.  对于任何可逆矩阵，当前仅当 $\mathbf{v=0}$ 时有 $\mathbf{vM=0}$。
    
    而再奇异矩阵中，有一系列的输入向量都会导致输出为零向量，这些输入向量称为矩阵的 `零空间（Null Space）`。

    ```ad-note
     对于 [Orthographic Projection](Ch%2005%20Matrices%20and%20Linear%20Transformations.md#Orthographic%20Projection) 矩阵而言，垂直于投影平面的所有向量都在零空间中，因为这些向量在投影后会变成一个点。
    ```

    
2.  任何可逆矩阵的行和列都是线性不相关的。
    
3.  可逆矩阵的行列式不为0。因此检查一个矩阵的行列式是否为零是最通用且最快的检查矩阵是否可逆的方法。


## The Classical Adjoint

`伴随矩阵（Classical Adjoint）`是计算逆矩阵的方法，将矩阵 $\mathbf{M}$ 的伴随矩阵称为 $\operatorname{adj} \mathbf{M}$。

伴随矩阵是原矩阵所有代数余子式构成的矩阵的转置。如下以一个 $3\times 3$ 矩阵作为例子：

$$ \mathbf{M}=\left[\begin{array}{ccc}-4 & -3 & 3 \\0 & 2 & -2 \\1 & 4 & -1\end{array}\right] $$

要求伴随矩阵，首先要求出所有的代数余子式，即：

$$ \begin{aligned}&C^{\{11\}}=+\left|\begin{array}{cc}2 & -2 \\4 & -1\end{array}\right|=6, \quad C^{\{12\}}=-\left|\begin{array}{cc}0 & -2 \\1 & -1\end{array}\right|=-2, \quad C^{\{13\}}=+\left|\begin{array}{cc}0 & 2 \\1 & 4\end{array}\right|=-2\\&C^{\{21\}}=-\left|\begin{array}{cc}-3 & 3 \\4 & -1\end{array}\right|=9, \quad C^{\{22\}}=+\left|\begin{array}{cc}-4 & 3 \\1 & -1\end{array}\right|=1, \quad C^{\{23\}}=-\left|\begin{array}{cc}-4 & -3 \\1 & 4\end{array}\right|=13\\&C^{\{31\}}=+\left|\begin{array}{cc}-3 & 3 \\2 & -2\end{array}\right|=0, \quad C^{\{32\}}=-\left|\begin{array}{cc}-4 & 3 \\0 & -2\end{array}\right|=-8, \quad C^{\{33\}}=+\left|\begin{array}{cc}-4 & -3 \\0 & 2\end{array}\right|=-8\end{aligned} $$