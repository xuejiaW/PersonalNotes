---
tags:
    - Computer-Graphics
    - Math
created: 2022-01-30
updated: 2022-01-30
---

# Mathematical Definition of Vector, and Other Boring Stuff

从数学角度看， `向量（Vector）`只是一个数字的数组。

从数学角度而言， `向量（vector）`带有方向， `标量（scalar）` 不带有方向。如速度（有朝着某方向的含义在）是向量，位移是向量，而速率（仅仅是一个数字）是标量，距离是标量。

向量的维度表示一个向量中含有多少个数字。

向量通常通过方括号包裹，如果向量是水平方向的写，称其为行向量，否则为列向量，如：

行向量：

$$ [1,2,3] $$

列向量：

$$ \left[\begin{array}{l} 1 \\ 2 \\ 3 \end{array}\right] $$

研究向量和矩阵的数学称为 `线性代数（linear algebra）`。

在线性代数中，$n$维度的向量和矩阵是用来求解有$n$个未知数的方程的。

但在图形学中，更多关注于向量和矩阵的几何意义。

# Geometric Definition of Vector

从几何角度来说，向量是一条既有大小又有方向的线（有向线）。

向量并没有位置信息，大小和方向一致的向量出现在图中的什么位置并没有区别。

# Specifying Vectors with Cartesian Coordinates

## Vector as a Sequence of Displacements

当向量出现在笛卡尔坐标系中，向量中的每个元素表示对应的坐标的位移。

如 $[2,3]$表示沿着$x$轴方向移动了2，沿着 $y$轴方向移动了3，位移的顺序并没有关系。

## The Zero Vector

零向量是唯一一个没有方向的向量，在坐标系中，零向量不是一根线，而是一个点。

零向量是作为 `加法单位元（additive identity）`，即加到别的元素上也不会造成区别的数字。

# Vectors versus Points

`点（Points）`表示位置， `向量（Vectos）` 表示位移。

## The Relationship between Points and Vectors

```ad-note
所有关于位置的方法，都是相对的
```

向量$[x,y]$表示从原点到点 $(x,y)$的位移。

点是位置，图像上表示为一个点。向量是位移，图像上表示为一个箭头。

# Negating a Vector

## Official Linear Algebra Rules

向量求反（Vector negating）：对于每个向量，都有一个相同维度的反向量，满足$v+(-v)=0$。

向量取反：

$$ -\begin{bmatrix}a\\\\a_2 \\\\\vdots \\\\a_{n-1} \\\\a_n \\\\\end{bmatrix}=\begin{bmatrix}-a_1 \\\\-a_2 \\\\\vdots \\\\-a_{n-1} \\\\-a_n \\\\\end{bmatrix} $$


## Geometric Interpretation

向量求反几何意义：保持向量的大小，但是方向变反方向

# Vector Multiplication by a Scala

## Official Linear Algebra Rules

向量与标量相乘：

$$ k\begin{bmatrix}a_1 \\\\a_2 \\\\\vdots \\\\a_{n-1} \\\\a_n \\\\\end{bmatrix}=\begin{bmatrix}a_1 \\\\a_2 \\\\\vdots \\\\a_{n-1} \\\\a_n \\\\\end{bmatrix}k=\begin{bmatrix}ka_1 \\\\ka_2 \\\\\vdots \\\\ka_{n-1} \\\\ka_n \\\\\end{bmatrix} $$

-   向量与标量相乘，标量可以写在向量的左侧也可以写在右侧，但通常而言习惯性写在右侧
-   向量与标量相乘时不需要写乘号
-   标量不能被相乘除，向量不能除以另一个向量。


## Geometric Interpretation

向量与标量相乘几何意义：大小乘以$|k|$，如果$k$是负数，则向量的方向取反，否则不变。

# Vector Addition and Subtraction

## Official Linear Algebra Rules

向量相加：

$$ \left[\begin{array}{c}a_{1} \\a_{2} \\\vdots \\a_{n-1} \\a_{n}\end{array}\right]+\left[\begin{array}{c}b_{1} \\b_{2} \\\vdots \\b_{n-1} \\b_{n}\end{array}\right]=\left[\begin{array}{c}a_{1}+b_{1} \\a_{2}+b_{2} \\\vdots \\a_{n-1}+b_{n-1} \\a_{n}+b_{n}\end{array}\right] $$

向量相减：

$$ \left[\begin{array}{c}a_{1} \\a_{2} \\\vdots \\a_{n-1} \\a_{n}\end{array}\right]-\left[\begin{array}{c}b_{1} \\b_{2} \\\vdots \\b_{n-1} \\b_{n}\end{array}\right]=\left[\begin{array}{c}a_{1} \\a_{2} \\\vdots \\a_{n-1} \\a_{n}\end{array}\right]+\left(-\left[\begin{array}{c}b_{1} \\b_{2} \\\vdots \\b_{n-1} \\b_{n}\end{array}\right]\right)=\left[\begin{array}{c}a_{1}-b_{1} \\a_{2}-b_{2} \\\vdots \\a_{n-1}-b_{n-1} \\a_{n}-b_{n}\end{array}\right] $$


```error
向量不能与标量相加或相减，也不能与维度不同的向量相加或相减
```

## Geometric Interpretation

向量相加几何意义：如果是向量 $a+b$，可以将 $a$的头部与$b$的尾部向量，从$a$的尾部指向$b$的头部的向量即为加法结果，如下所示
![](assets/Ch%2002%20Vectors/Untitled.png)