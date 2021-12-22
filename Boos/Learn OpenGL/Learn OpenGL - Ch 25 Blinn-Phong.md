---
created: 2021-12-20
updated: 2021-12-22
cssclass: [table-border]
tags:
    - OpenGL
---
# Phone 镜面反射效果

在  [Ch 11 Basic Lighting](Learn%20OpenGL%20-%20Ch%2011%20Basic%20Lighting.md) 中介绍的都是 `Phone`式光照模型， `Phone`式光照模型在镜面反射时会存在一些不合理的情况，如下所示：
![|500](assets/Learn%20OpenGL%20-%20Ch%2025%20Blinn-Phong/Untitled.png)

```ad-warning
这里为了更清晰的说明现象，进计算镜面反射，且为了让反射效果更分散，将镜面反射的次幂等级选为0.5。
```

上图中可以看到在镜面反射光到达边界后会迅速的变为0，在超过了边界点的情况下，视线方向与光线反射方向的夹角大于了90°。如下图右部分所示：
![|500](assets/Learn%20OpenGL%20-%20Ch%2025%20Blinn-Phong/Untitled%201.png)

在 `Phone`模型中，是用点乘来计算镜面反射光的贡献，当两个方向的角度大于等于90°时，贡献为0。

```glsl
spec = pow(max(dot(viewDir, reflectDir),0.0), exponent);
```

但在现实生活中，当光反射方向和视线方向的夹角大于90°时，镜面反射光仍然会产生效果，可以想象从光的方向看一个镜子的效果。

# Blinn-Phone 模型

`Blinn-Phone` 模型是由 `James F.Blinn` 提出的 `Phone` 模型的改善。这两个模型的区别就在于对与镜面反射光的计算。

在 `Blinn-Phone` 模型中，会计算得到视线方向与光源方向两者的中线，再用这个中线（Halfway）与表面的法线进行比较，两者夹角越小，说明镜面反射光贡献越大，如下所示：
![|500](assets/Learn%20OpenGL%20-%20Ch%2025%20Blinn-Phong/Untitled%202.png)

因为在计算过程中，视线方向和光源方向都是从表面向外的，所以 $\overline{H}$ 的计算方法如下表示：

$$\bar{H}=\frac{\bar{L}+\bar{V}}{\|\bar{L}+\bar{V}\|}$$

计算代码如下：

```glsl
vec3 lightDir=normalize(lightPos - fs_in.FragPos);
vec3 viewDir = normalize(viewPos - fs_in.FragPos);
vec3 halfwayDir= normalize(lightDir+viewDir);
spec = pow(max(dot(normal, halfwayDir),0.0), exponent);
```

当采用了 `Blinn-Phone` 模型后，镜面反射的效果如下：
![|500](assets/Learn%20OpenGL%20-%20Ch%2025%20Blinn-Phong/Untitled%203.png)

# 幂次系数调整

`Phone` 模型和 `Blinn-Phone` 模型还存在一个微妙的区别。通常来说， `Blinn-Phone` 中线与法线的夹角会小于 `Phone` 中反射光方向与视线方向的夹角。

这就导致了 `Blinn-Phone` 中点乘出来的结果要比 `Phone` 中大，为了弥补这个误差，通常 `Blinn-Phone` 中 次幂数也要更大，通常是 `Phone` 中的 $2 \sim 4$ 倍。

# 结果与源码：

下图左侧为 `Phone` 模型效果，右图为 `Blinn-Phone` 效果：

|                                                                |                                                                |
| -------------------------------------------------------------- | -------------------------------------------------------------- |
| ![](assets/Learn%20OpenGL%20-%20Ch%2025%20Blinn-Phong/Untitled%204.png) | ![](assets/Learn%20OpenGL%20-%20Ch%2025%20Blinn-Phong/Untitled%205.png) |

[main.cpp](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/23.Blinn-Phong/main.cpp)

[blinn-phone.vs](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/23.Blinn-Phong/blinn-phone.vs)

[blinn-phone.fs](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/23.Blinn-Phong/blinn-phone.fs)