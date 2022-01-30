---
tags:
    - Computer-Graphics
    - Math
created: 2022-01-30
updated: 2022-01-30
---

# Rotation

## Rotation in 2D

在二维空间中的旋转是基于一个点的。

对于基于原点的二维旋转，只有一个变量即旋转角度 $\theta$。且通常而言顺时针旋转为正方向，逆时针旋转为反方向。

旋转矩阵如下：
$$ \mathbf{R}(\theta)=\begin{bmatrix}\cos\theta & \sin\theta \\\\-\sin\theta & \cos\theta \\\\\end{bmatrix} $$

其中的每一行都是变换后的标准向量，即将$(1,0)$，变为了$(\cos\theta , \sin\theta)$，将 $(0,1)$变成了$( -\sin\theta , \cos\theta )$，如下图所示：
![|400](assets/Ch%2005%20Matrices%20and%20Linear%20Transformations/Untitled.png)

## 3D Rotation about Cardinal Axes

这里讨论的三维旋转矩阵也同样是基于原点旋转的。但在三维空间中，可以围绕不同的轴进行旋转。

绕着$x$轴的旋转矩阵如下：

$$ R_x(\theta)=\begin{bmatrix}1&0&0\\\\0& \cos\theta&\sin\theta\\\\0& -sin\theta&\cos\theta\\\\\end{bmatrix} $$

绕着$y$轴的旋转矩阵如下：

$$ R_y(\theta)=\begin{bmatrix}\cos\theta&0 &-\sin\theta\\\\0& 1&0\\\\\sin\theta&0 &\cos\theta\\\\\end{bmatrix} $$

绕着$z$轴的旋转矩阵如下：

$$ R_z(\theta)=\begin{bmatrix}\cos\theta& \sin\theta&0\\\\-\sin\theta& \cos\theta&0\\\\0&0 &1\\\\\end{bmatrix} $$

```ad-note
三个矩阵的推导同样是通过基本向量的变换。如果某个轴作为旋转轴，那么这个轴在旋转过程中是不会发生变化的，而剩下的两个轴就可以看作是一个二维空间的旋转。
```

## 3D Rotation about an Arbitrary Axis

向量绕着任意轴 $n$ (穿过原点的轴)旋转 $\theta$ 角度的计算表达式如下：

$$ R({\hat{n},\theta})=\begin{bmatrix}{n_x}^2(1-\cos \theta) + \cos\theta &n_xn_y(1-\cos \theta)+n_z\sin\theta &n_xn_z(1-\cos \theta) -n_y\sin\theta\\\\n_xn_y(1-\cos \theta) -n_z\sin\theta&{n_y}^2(1-\cos \theta)+\cos\theta &n_yn_z(1-\cos \theta) +n_x\sin\theta\\\\n_xn_z(1-\cos \theta) +n_y\sin\theta &n_yn_z(1-\cos \theta)-n_x\sin\theta &{n_z}^2(1-\cos \theta) +\cos \theta\end{bmatrix} $$

推导过程见：
