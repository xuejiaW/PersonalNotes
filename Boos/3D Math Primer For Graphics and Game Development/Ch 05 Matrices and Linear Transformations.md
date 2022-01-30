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
[Rotate about arbitary axis](Rotate%20about%20arbitary%20axis.md)

# Scale

## Scaling along the Cardinal Axes

缩放效果如下图所示：
![](assets/Ch%2005%20Matrices%20and%20Linear%20Transformations/2020-03-05-16-04-17.png)

对于基本向量而言，在进行了缩放操作后，其变为：

$$ p^{'}=k_xp=kx\begin{bmatrix}1& 0 &0\end{bmatrix} =\begin{bmatrix} k_x&0&0\end{bmatrix}，\\\\ q^{'}=k_yq=ky\begin{bmatrix}0& 1&0\end{bmatrix} =\begin{bmatrix} 0&k_y&0\end{bmatrix}，\\\\ r^{'}=k_zr=kz\begin{bmatrix}0& 0&1\end{bmatrix} =\begin{bmatrix} 0&0&k_z\end{bmatrix}，\\\\ $$

将其带入缩放矩阵的每一行，可得，如果缩放的方向是基本向量的话，那么缩放矩阵为：

$$ S(k_x,k_y,k_z)=\begin{bmatrix}k_x&0 &0 \\\\0&k_y &0 \\\\0&0 &k_z \\\\\end{bmatrix} $$

```ad-note
如果沿着各个轴的缩放大小是一样的，则称这个缩放为 `均匀缩放（Uniform Scaling）`，否则为 `非均匀缩放（Nonuniform Scaling）`。
```

## Scaling in an Arbitary Direction

向量绕着任意轴 $n$ (穿过原点的轴)缩放的计算表达式如下：

$$ S(\hat{n},k)=\begin{bmatrix}1+(k-1) {n_x}^2&(k-1)n_xn_y &(k-1)n_xn_z \\\\(k-1) {n_xn_y}& 1+(k-1){n_y}^2 & (k-1)n_yn_z \\\\(k-1) {n_xn_z} & (k-1){n_yn_z} & 1+(k-1){n_z}^2 \\\\\end{bmatrix} $$

推导过程见：
[[Scale about arbitary axis]]