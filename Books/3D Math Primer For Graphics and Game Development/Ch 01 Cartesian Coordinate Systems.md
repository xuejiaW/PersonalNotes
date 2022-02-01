---
tags:
    - Computer-Graphics
    - Math
created: 2022-01-30
updated: 2022-01-30
---

```ad-note
图形学第一定理：如果看起来结果是对的，那么就是对的

If it looks right, it is right.
```

# 2D Cartesian Space

对于二维坐标而言，无论X轴和Y轴选取的方向如何，都能通过旋转（包括翻转）将其互相转换。

以X轴为第一个轴，它有4种选择，此时因为Y轴必须与X轴垂直，因此Y轴只有两种可能（正向或反向），因此二维坐标系一共有8种可能， 如下图所示：
![|500](assets/Ch%2001%20Cartesian%20Coordinate%20Systems/Untitled.png)

```ad-note
从某种角度而言，所有的二维坐标都是等效的。
```


# 3D Cartesian Space

对于三维坐标而言，可以通过旋转或反转将三维坐标系中的两个坐标轴匹配，但在这种情况下第三个坐标轴的方向可能是反的。

三维坐标一共有48种可能（Z轴一共有6种可能，X和Y构成二维坐标，有8种可能，6*8 = 48）。

因此所有的三维坐标被分为两组，一组被称为左手坐标系（Left-handed coordinate spaces），另一组被称为右手坐标系（Right-handed coordinate spaces），如下所示：
![|500](assets/Ch%2001%20Cartesian%20Coordinate%20Systems/Untitled%201.png)

```ad-note
左右手坐标系只是不同的选择，两者并无其他方面的差异。
```

可以用手势表示不同的坐标系，如上图所示:食指，中指，大拇指相互垂直，大拇指指向X轴正方向，食指指向Y轴正方向，中指指向Z轴正方向。

左右手坐标系还会影响`旋转的正方向`:在每个坐标系下，如果要绕着某个轴旋转，用大拇指指向该轴的正方向，四指环绕方向即为旋转的正方向。

# Odds and Ends

## Angles, Degrees, and Radians

角度（Angles）在日常生活中用的比较多，但是在数学上弧度（Radians）用的更多。

当提及弧度，实际上是计算某角度在半径为1的圆上所占的长度。因为半径为1的圆周长为$2\pi$，所以$360^\circ = 2\pi (rad)$ ，即弧度与角度的转换关系如下：

$$ 1\text{ rad} = (180/\pi)^\circ \approx 57.29578^\circ \\\\ 1 ^ \circ = (\pi /180) \text{ rad} \approx 0.01745329 \text{ rad} $$

## Trig Functions

对于在半径为1的圆上的点 $(x,y)$，$\theta$ 为该点与原点形成的向量与$x$轴正方向的夹角，则：

$$
\begin{aligned}
x = \cos(\theta) \\
y = \sin(\theta)
\end{aligned}
$$

## Trig Identities

基本转换

$$
\begin{aligned}
\sin(-\theta)=-\sin\theta \\\\\ cos(-\theta)=\cos\theta \\\\ \tan(-\theta)=-\tan\theta \\\\\sin(\frac{\pi}{2}-\theta) = \cos\theta\\\\\cos(\frac{\pi}{2}-\theta) = \sin\theta\\\\\tan(\frac{\pi}{2}-\theta) = \cot\theta\\\\\cos \theta = -\cos(180-\theta)\\\\\sin \theta = \sin (180-\theta)
\end{aligned}
$$

勾股定理

$$
\begin{aligned}
\sin^2\theta+cos^2\theta=1 \\\\   1 + \tan^2\theta = \sec^2\theta \\\\   1 + \cot^2\theta = csc^2 \theta
\end{aligned}
$$

加减定理

$$
\begin{aligned}
\sin(a+b) = \sin a \cos b + \cos a\sin b \\\\\sin(a-b) = \sin a \cos b - \ cos a \sin b \\\\\cos(a+b) = \cos a \cos b -\sin a \sin b \\\\\cos(a-b) = \cos a \cos b + \sin a \sin b \\\\\tan(a+b) = \frac{tan a+ tan b}{1- \tan a\tan b } \\\\\tan(a-b) = \frac{tan a - tan b }{1+ \tan a \tan b} \\\\
\end{aligned}
$$

两倍角定理

$$
\begin{aligned}
\sin 2\theta = 2\sin \theta \cos \theta \\
\cos 2\theta = \cos ^2 \theta-\sin^2\theta=2cos^2\theta-1=1-2sin^2\theta \\
\tan 2 \theta=\frac{2\tan \theta}{1- \tan^2\theta} \\
\end{aligned}
$$

正弦定理

对于如下三角形，有：
![](assets/Ch%2001%20Cartesian%20Coordinate%20Systems/Untitled%202.png)

$$
\frac{\sin A}{a} = \frac{\sin B}{b}=\frac{\sin C}{c}
$$

余弦定理

对上示的三角形，有：

$$
\begin{aligned}
a^2=b^2+c^2-2bc\cos A \\\\
b^2 = a^2 +c^2 - 2ac \cos B\\\\
c^2 = a^2 +b^2 -2ab \cos C \\
\end{aligned}
$$