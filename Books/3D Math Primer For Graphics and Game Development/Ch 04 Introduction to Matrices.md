---
tags:
    - Computer-Graphics
    - Math
created: 2022-01-30
updated: 2022-01-30
---

# Mathematical Definition of Matrix

在线性代数中，矩阵是由一系列数字按行和列排布组成。可以将向量看作是标量的集合，把矩阵看作是向量的集合。

## Matrix Dimensions and Notation

将一个有 $r$ 行，$c$列的矩阵称为是 $r\times c$ 矩阵，矩阵中的数字由方括号包围，如下为一个 $3 \times 3$ 的矩阵：

$$ M=\begin{bmatrix}m_{11}&m_{12}&m_{13}\\\\m_{21}&m_{22}&m_{23}\\\\m_{31}&m_{32}&m_{33}\\\\\end{bmatrix} $$

## Square Matrices

将行数和列数相同的矩阵，称为`方阵（Square Matrices）`。

将下标的行数和列数相同的元素，称为`对角元素（Diagonal elements）`，如上矩阵中的$m_{11}$，$m_{22}$，$m_{33}$为对角元素。

如果一个矩阵（并不一定是方阵）中，所有的非对角元素都是0，那么整个矩阵称为 `对角矩阵（diagonal matrix）` ，如下所示：

$$ M=\begin{bmatrix}m_{11}& 0 & 0\\\\0 &m_{22}& 0\\\\0 &0 & m_{33}\\\\\end{bmatrix} $$

在对角矩阵中，如果所有的元素都为1，那么就变成了`单位矩阵（Identity Matrix）`，单位矩阵通常用 $\mathbf{I}$ 表示，如下所示：

$$ \mathbf{I}_{3}=\left[\begin{array}{lll} 1 & 0 & 0 \\ 0 & 1 & 0 \\ 0 & 0 & 1 \end{array}\right] $$

```ad-note
如果一个矩阵与单位矩阵相乘，那么得到的还是该矩阵本身。
```

## Vectors as Matrices

向量可以看作是一个 $1\times n$ 或者 $n \times 1$ 的矩阵，即 $1\times n$ 的矩阵可以称为行向量，$n\times 1$ 可以称为列向量。

## Matrix Transposition

给定一个 $r\times c$ 矩阵 $\mathbf{M}$，其转置写为 $\mathbf{M^T}$，转置矩阵是一个 $c\times r$ 的矩阵。其中 $\mathbf{M}$ 中的 `行` 变为 $\mathbf{M^T}$ 中的 `列` ，即$\mathbf{M^T_{ij}}=\mathbf{M_{ji}}$。如下：

$$ {\begin{bmatrix}a&b&c\\\\d&e&f\\\\g&h&i\\\\\end{bmatrix}}^T=\begin{bmatrix}a&d&g\\\\b&e&h\\\\c&f&i\\\\\end{bmatrix} $$

$$ {\begin{bmatrix}x & y &z\end{bmatrix}}^T=\begin{bmatrix}x\\\\y\\\\z\\\\\end{bmatrix} $$

转置矩阵有如下性质：

1.  矩阵转置的转置等于本身，$(\mathbf{M^T})^T=\mathbf{M}$
2.  如果一个矩阵的转置等于矩阵本身，那么 $\mathbf{D^T}=\mathbf{D}$，那么这个矩阵就是是单位矩阵。

## Multiplying a Matrix with a Scalar

矩阵与标量的相乘如下表示：

$$ kM=k\begin{bmatrix}m_{11}&m_{12}&m_{13}\\\\m_{21}&m_{22}&m_{23}\\\\m_{31}&m_{32}&m_{33}\\\\\end{bmatrix}=\begin{bmatrix}km_{11}&km_{12}&km_{13}\\\\km_{21}&km_{22}&km_{23}\\\\km_{31}&km_{32}&km_{33}\\\\\end{bmatrix} $$

## Multiplying Two Matrices

对于 $r\times n$ 的矩阵 $\mathbf{A}$，如果与 $n\times c$ 的矩阵 $\mathbf{B}$ 相乘，结果为 $r\times c$ 的矩阵 $\mathbf{AB}$

```ad-warning
对于两个矩阵相乘，前者的列数必须与后者的行数匹配
```

假设将两个矩阵的相乘结果中的每个元素称为 $c_{ij}$，其值为第一个矩阵的的第$i$行中所有元素与第二个矩阵的第$j$列中的元素一一相乘并累加，即：
![](assets/Ch%2004%20Introduction%20to%20Matrices/Untitled.png)

矩阵相乘有如下性质：

1.  $\mathbf{MI=IM=M}$
    
2.  矩阵的相乘不是可交换的，$\mathbf{AB\neq BA}$
    
3.  矩阵的相乘满足结合律，$\mathbf{(AB)C=A(BC)}$。
    
    矩阵与标量或向量的乘法同样满足结核性，即：
    
    $$    \mathbf{(kA)B=k(AB)=A(kB)}，\\\\   \mathbf{(vA)B=v(AB)} $$
    
4.  乘积的转置，等于乘数与被乘数的转置以相反的顺序相乘，$\mathbf{(AB)^T=B^TA^T}$

## Multiplying a Vector and a Matrix

向量与矩阵的乘法如下：

$$ \begin{bmatrix}x & y &z\end{bmatrix}\begin{bmatrix}  m_{11}&m_{12}&m_{13}\\\\m_{21}&m_{22}&m_{23}\\\\m_{31}&m_{32}&m_{33}\\\\\end{bmatrix}= \\\\\begin{bmatrix}xm_{11}+ym_{21}+zm_{31} & xm_{12}+ym_{22}+zm_{32} &xm_{13}+ym_{23}+zm_{33}\end{bmatrix} $$

$$ \begin{bmatrix}  m_{11}&m_{12}&m_{13}\\\\m_{21}&m_{22}&m_{23}\\\\m_{31}&m_{32}&m_{33}\\\\\end{bmatrix}\begin{bmatrix}x\\\\y\\\\z\\\\\end{bmatrix}=\begin{bmatrix}  xm_{11}+ym_{12}+zm_{13}\\\\  xm_{21}+ym_{22}+zm_{23}\\\\  xm_{31}+ym_{22}+zm_{33}\\\\\end{bmatrix} $$


矩阵和向量的乘法满足分配律， $\mathbf{(v+w)M=vM+wM}$

## Row versus Column Vectors

行向量与列向量本质上并没有区别，但需要注意使用行列向量与矩阵相乘时的顺序是不同的。

假设向量 $\mathbf{v}$ 需要与矩阵 $\mathbf{A,B,C}$ 依次相乘。如果 $\mathbf{v}$ 是列向量，那么向量应该出现在右侧，即写为$\mathbf{CBAv}$。如果 $\mathbf{v}$ 是行向量，那么向量应该出现在左侧，即写为$\mathbf{vABC}$。

行向量与列向量与同一个矩阵相乘后，结果对应的元素是不同的（如行向量计算结果的第一个元素与列向量计算结果的第一个元素不同）。

因此如果想要使用行向量进行计算和使用列向量进行计算的结果向量元素一一对应相等的话，则它们各自使用的矩阵必须是不同的，且为转置关系。

行向量的优点在于，阅读的顺序和相乘的顺序是一致的，即从左到右，而列向量乘积的相乘顺序则是从右到左。

行向量的主要缺点在于，当向量的维度增加时，会让表达式变得非常的长，造成书写的不便，而使用列向量就不会有这个问题。

```ad-warning
此书后续的运算，若无特殊说明，都是基于行向量
```

```ad-warning
DirectX使用行向量，OpenGL使用列向量。 当使用别人的表达式或者代码时，需要特别注意它使用的是行向量还是列向量。
```


# Geometric Interpretation of Matrix

从几何意义角度来说，方阵可以描述任何的`线性变化（Linear transformation）`。

线性变化保证了图形中的线条不会被弯曲，且线条们的平行性质不会给改变，但其他的几何性质，如角度，面积，体积，长度都可能发现变化。线性变化包括：

1.  旋转(Rotation)
2.  缩放(Scale)
3.  正交投影(Orthographic projection)
4.  反射(Reflection)
5.  切边（shearing）

## Multiplying a Vector and a Matrix

假设 $\mathbf{i}=[1,0,0],\mathbf{j}=[0,1,0],\mathbf{k}=[0,0,1]$，且矩阵 $\mathbf{M}$ 为：

$$ \left[\begin{array}{lll}m_{11} & m_{12} & m_{13} \\m_{21} & m_{22} & m_{23} \\m_{31} & m_{32} & m_{33}\end{array}\right] $$

则向量 $\mathbf{v}$ 可写作 $\mathbf{v}=v_x\mathbf{i}+v_y\mathbf{j}+v_z\mathbf{k}$ ，且矩阵与向量的乘法可以看作为：

$$ \begin{aligned}\mathbf{v} \mathbf{M} &=\left(v_{x} \mathbf{i}+v_{y} \mathbf{j}+v_{z} \mathbf{k}\right) \mathbf{M} \\&=\left(v_{x} \mathbf{i}\right) \mathbf{M}+\left(v_{y} \mathbf{j}\right) \mathbf{M}+\left(v_{z} \mathbf{k}\right) \mathbf{M} \\&=v_{x}(\mathbf{i} \mathbf{M})+v_{y}(\mathbf{j} \mathbf{M})+v_{z}(\mathbf{k M}) \\&=v_{x}\left[\begin{array}{llll}m_{11} & m_{12} & m_{13}\end{array}\right]+v_{y}\left[\begin{array}{lll}m_{21} & m_{22} & m_{23}\end{array}\right]+v_{z}\left[\begin{array}{lll}m_{31} & m_{32} & m_{33}\end{array}\right]\end{aligned} $$


将上述结果的每一行都看作是一个基本向量，即 $\begin{bmatrix}m_{11} & m_{12} &m_{13} \end{bmatrix}$，$\begin{bmatrix}m_{21} & m_{22} &m_{23} \end{bmatrix}$和$\begin{bmatrix}m_{31} & m_{32} &m_{33} \end{bmatrix}$都作为基本向量，并将他们分别命名为 $\mathbf{p,q,r}$，则上式结果可以改写为：

$$ \mathbf{vM}=v_x\mathbf{p}+v_y\mathbf{q}+v_z\mathbf{r} $$

与原式 $\mathbf{v}=v_x\mathbf{i}+v_y\mathbf{j}+v_z\mathbf{k}$ 比较，可以得出，原来的基本向量 $\mathbf{i,j,k}$ 经过了线性变化，变成了新的基本向量 $\mathbf{p,q,r}$。

```ad-note
不同的的基本向量就构成了不同的坐标系。因此可以将矩阵 $\mathbf{M}$ 看作是一个坐标系转换的矩阵，它让向量（或点）从由 $\mathbf{i,j,k}$ 构成的坐标系转换到由 $\mathbf{p,q,r}$ 构成的坐标系。
```

可以通过上述的方法来直接判断一个矩阵所代表的线性变化，方阵的每一行都是变换后的基本向量，如有方阵：

$$ \mathbf{M}=\left[\begin{array}{cc}2 & 1 \\-1 & 2\end{array}\right] $$

其中，$\mathbf{p}=\begin{bmatrix}2 &1 \end{bmatrix},\mathbf{q}=\begin{bmatrix}-1 &2 \end{bmatrix}$。即原坐标$(0,1)$变成了$(2,1)$，原坐标$(1,0)$变成了坐标$(-1,2)$，如下图所示：
![|300](assets/Ch%2004%20Introduction%20to%20Matrices/Untitled%201.png)

```ad-warning
此书中，默认计算的向量都是行向量。如果是计算的向量是列向量，则结论是： 方阵的每一列都是变换后的基本向量
```

如果对一个二维图片使用该矩阵进行变化，则如下图所示：
![|400](assets/Ch%2004%20Introduction%20to%20Matrices/Untitled%202.png)

```ad-note
对于三维空间可以同样的方式判断矩阵所表示的线性变化
```
