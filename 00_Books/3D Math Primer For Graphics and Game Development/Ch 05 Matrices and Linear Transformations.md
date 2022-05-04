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

# Orthographic Projection

`正射投影（Orthographic Projection）`保证所有原始点和投影点的连线时平行的，如下图所示：
![|400](assets/Ch%2005%20Matrices%20and%20Linear%20Transformations/2020-03-05-16-38-23.png)

如果投影到 $xy$ 平面上，那么即沿着 $z$ 轴缩放到0。即将$\hat{\mathbf{n}}=\begin{bmatrix}0&0&1\end{bmatrix},k=0$，代入沿任意轴缩放的矩阵中，可得：

$$ P_{xy}=S(\begin{bmatrix}0&0&1\end{bmatrix},0)=\begin{bmatrix} 1 & 0 &0 \\\\ 0 & 1 &0 \\\\ 0 & 0 &0 \\\\ \end{bmatrix} $$

同理分别可以得到投影到 $xz$ 平面和 $yz$ 平面上的矩阵，分别为：

$$ P_{xz}=S(\begin{bmatrix}0&1&0\end{bmatrix},0)=\begin{bmatrix} 1 & 0 &0 \\\\ 0 & 0 &0 \\\\ 0 & 0 &1 \\\\ \end{bmatrix} $$

$$ P_{yz}=S(\begin{bmatrix}1&0&0\end{bmatrix},0)=\begin{bmatrix} 0 & 0 &0 \\\\ 0 & 1 &0 \\\\ 0 & 0 &1 \\\\ \end{bmatrix} $$

## Projecting onto an Arbitrary Line or Plane

如果投影到任意平面上，且投影方向为平面的法向量 $\hat{\mathbf{n}}$。那么投影实际上是相当于沿着向量 进行缩放，且缩放系数$k=0$。将其代入沿任意轴进行缩放的矩阵，即：

$$ \begin{aligned} R(\hat{ \mathbf{n}})&=S(\hat{n},0)\\&=\begin{bmatrix}1+(0-1) {n_x}^2&(0-1)n_xn_y &(0-1)n_xn_z \\\\(0-1) {n_xn_y}& 1+(0-1){n_y}^2 & (0-1)n_yn_z \\\\(0-1) {n_xn_z} & (0-1){n_yn_z} & 1+(0-1){n_z}^2 \\\\\end{bmatrix} \\&=\begin{bmatrix}1-{n_x}^2&-n_xn_y &-n_xn_z \\\\-{n_xn_y}& 1-{n_y}^2 & -n_yn_z \\\\-{n_xn_z} &-{n_yn_z} & 1-{n_z}^2 \\\\\end{bmatrix} \end{aligned} $$

# Reflection

`反射（Reflection）`也称为 `镜像（Mirroring）`是针对一个轴（2D空间）或者一个平面（3D空间）进行反转的操作。

反射操作如下图所示：
![](assets/Ch%2005%20Matrices%20and%20Linear%20Transformations/2020-03-05-20-40-40.png)

针对于一个平面或一个轴的反射变换，相当于沿着垂直该平面或轴的法向量$\hat{\mathbf{n}}$进行缩放系数 $k=-1$的缩放操作。即：

$$ \begin{aligned} R(\hat{\mathbf{n}})&=S(\hat{\mathbf{n}},0)\\&=\begin{bmatrix}1+(-1-1) {n_x}^2&(-1-1)n_xn_y &(-1-1)n_xn_z \\\\(-1-1) {n_xn_y}& 1+(-1-1){n_y}^2 & (-1-1)n_yn_z \\\\(-1-1) {n_xn_z} & (-1-1){n_yn_z} & 1+(-1-1){n_z}^2 \\\\\end{bmatrix} \\&=\begin{bmatrix}1-2{n_x}^2&-2n_xn_y &-2n_xn_z \\\\-2{n_xn_y}& 1-2{n_y}^2 & -2n_yn_z \\\\-2{n_xn_z} &-2{n_yn_z} & 1-2{n_z}^2 \\\\\end{bmatrix} \end{aligned} $$

# Shearing

`切变（Shearing）`是歪斜（skews）坐标轴的变化，因此有时也会被称为 `斜变变换（skew transform）`。

切边的基本思想是把一个方向轴上的元素乘以系数后加到另一个方向轴上。如 $x^{'}=x+sy$，对应的矩阵为：

$$ H_x(s)=\begin{bmatrix}    1 & 0 \\\\    s & 1\end{bmatrix} $$

从矩阵可以看出基本向量$\begin{bmatrix}1 &0 \end{bmatrix}$并没有发生变化，而基本向量 $\begin{bmatrix}0 &1 \end{bmatrix}$ 变为了 $\begin{bmatrix}s &1 \end{bmatrix}$。

$H_x(s)$表示 $x$ 被 $y$ 轴切变，即 $x$ 轴的值受 $y$ 轴的影响，如下图所示：
![|400](assets/Ch%2005%20Matrices%20and%20Linear%20Transformations/2020-03-05-21-01-30.png)

同理，如果在三维坐标中，$H_{xy}$ 表示 $xy$ 平面被 $y$ 轴坐标影响。所有的三维空间切变矩阵如下所示：

$$ \mathbf{H_{xy}}(s, t)=\begin{bmatrix} 1 & 0 & 0 \\\\ 0 & 1 & 0 \\\\ s & t & 1 \end{bmatrix} $$

$$ \mathbf{H_{xz}}(s, t)=\begin{bmatrix} 1 & 0 & 0 \\\\ s & 1 & t \\\\ 0 & 0 & 1 \end{bmatrix} $$

$$ \mathbf{H_{yz}}(s, t)=\begin{bmatrix} 1 & s & t \\\\ 0 & 1 & 0 \\\\ 0 & 0 & 1 \end{bmatrix} $$

```ad-note
切边是一个比较少用到的变换，因为使用切变变换和缩放变换（无论是均匀还是非均匀）后的图形完全可以通过旋转和非均匀缩放来达成。
```

# Combining Transformations

因为几个变换矩阵的大小是相同的，所以多个变换矩阵可以被结合在一起。如在物体坐标系中的物体，需要转换到世界坐标系中，此时需要用矩阵 $\mathbf{M_{obj\rightarrow wld}}$ ，将物体从世界坐标系中转换到摄像机坐标系，需要用到矩阵 $\mathbf{M_{wld\rightarrow cam}}$ ，则将物体从物体坐标系转换到摄像机坐标系的表达式如下：

$$ \begin{aligned}\mathbf{P_{\mathrm{cam}}} &=\mathbf{p_{\mathrm{wld}}} \mathbf{M_{\mathrm{wld} \rightarrow \mathrm{cam}}}\\&=\left(\mathbf{p_{\mathrm{obj}}} \mathbf{M_{\mathrm{obj} \rightarrow \mathrm{wld}}}\right) \mathbf{M_{\mathrm{wld} \rightarrow \mathrm{cam}}}\end{aligned} $$

而矩阵是满足[结合律](Ch%2004%20Introduction%20to%20Matrices.md) 的，因此上式可以进一步简化为：

$$ \begin{aligned} \mathbf{P_{\mathrm{cam}}} &=\left(\mathbf{p_{\mathrm{obj}}} \mathbf{M_{\mathrm{obj} \rightarrow \mathrm{wld}}}\right) \mathbf{M_{\mathrm{wld} \rightarrow \mathrm{cam}}} \\ &=\mathbf{p_{\mathrm{obj}}}\left(\mathbf{M_{\mathrm{obj} \rightarrow \mathrm{wld}}} \mathbf{M_{\mathrm{wld} \rightarrow \mathrm{cam}}}\right)\\ &=\mathbf{p_{\mathrm{obj}} }\mathbf{M_{\mathrm{obj} \rightarrow \mathrm{cam}}} \end{aligned} $$

# Classes of Transformations

```ad-note
映射和函数的关系：映射指的是输入按照一定的规则变成特定的输出，而函数是用来描述映射关系的。 如将 $F$ 将 $a$ 映射至 $b$ ，可以表示为函数 $F(a)=b$
```

## Linear Transformations

如果 $F(a)$ 是线性变化，那么 $F(a)$ 满足以下特性：

$$ \begin{aligned} F(\mathbf{a}+\mathbf{b}) &=F(\mathbf{a})+F(\mathbf{b}) \\\\ F(k \mathbf{a}) &=k F(\mathbf{a}) \end{aligned} $$

线性变化还有两个重要推论：

1.  如果满足， $F(a)=\mathbf{aM}$ ，其中 $\mathbf{M}$ 是一个方阵。那么 $F(a)$ 是线性变换。
    
    证明如下：
    
    $$ F(\mathbf{a}+\mathbf{b})=(\mathbf{a}+\mathbf{b}) \mathbf{M}=\mathbf{a} \mathbf{M}+\mathbf{b} \mathbf{M}=F(\mathbf{a})+F(\mathbf{b})\\\\F(k \mathbf{a})=(k \mathbf{a}) \mathbf{M}=k(\mathbf{a} \mathbf{M})=k F(\mathbf{a}) $$
    
    即可以满足线性变换的定义

2.  对于一个线性变换而言，如果输入是零向量，那么输出必然是零向量。
    
    证明如下：
    
    如果 $F(0)=a$, 那么 $F(K0)=F(0)=a$ ，且 $KF(0)=Ka$ 如果 $a\neq 0$，则 $F(k0)\neq KF(0)$，即不满足线性代数的性质二。
    
    因此 $a=0$ ，即输出必然必然是零向量
    ```ad-note
    这一章中介绍的所有变化，旋转，缩放，正交投影，镜像，切边都是线性变化
    ```

## Affine Transformations

`仿射变换（Affine Transformation）`是在线性变换后加上位移变换，因此仿射变换是线性变换的超集，任何的线性变换都是仿射变换（只不过后面的位移为零）。

任何形式为 $\mathbf{v'=vM+b}$ 的变换都是仿射变换

## Invertible Transformations

如果一个变换是可逆的，即存在一个相反的变换可以重置之前的变换，表达式如下：

$$ F^{-1}(F(\mathbf{a}))=F\left(F^{-1}(\mathbf{a})\right)=\mathbf{a}
$$

因为位移操作必然是可逆的，所以仿射变换是否可逆的关键在于线性变换是否可逆。主要的线性变换，除了投影外都是可逆的。

```ad-note
因为投影变换将一个维度的数值变为了零，即一个维度的数据消失了。
```

找出一个变换的相反操作，相当于找出这个变换矩阵的逆矩阵。

## Angle-Preserving Transformations

如果一个变换是 `保角变换（Angle-Preserving Transformation）`，那么在变换前后图形中的两个向量的夹角是不会发生变换的。

只有位移，旋转，和均匀缩放是保角变换。对于反射变换，虽然角度的绝对值不会发生改变，但是角度的方向发生了改变，因此也不能算是保角变换。

```ad-note
所有的保角变换都是仿射变换且都是可逆的。
```

## Orthogonal Transformations

`正交变换（Orthogonal Transformation）` 保证变换前后，图像的长度，角度的绝对值，面积和体积不会发生改变。

只有位移，旋转和反射是正交变换。

```ad-note
所有的正交变换都是可逆的，且是仿射变换。
```

```ad-note
正交变换的逆矩阵即为其转置
```

## Rigid Body Transformations

`刚体变换（Rigidbody Transformation，proper transformations）`只改变图像的位置和角度，但不会改变其形状。

位移和旋转是唯二的刚体变换，反射变换因为改变了图形的角度方向所以不是刚体变换。

```ad-note
刚体变换几乎是最严格的变换。所有的刚体变换，都是正交的，保角的，可逆的和仿射的。
```

```ad-note
刚体变换的行列式大小为1。
```

# Summary of Types of Transformations

![](assets/Ch%2005%20Matrices%20and%20Linear%20Transformations/image-20200306141537944.png)