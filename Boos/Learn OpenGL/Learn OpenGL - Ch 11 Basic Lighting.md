---
created: 2021-12-15
updated: 2021-12-23
tags:
    - OpenGL
---

# 概述

现实世界的光很复杂，受到很多因素的影响，所以计算机很难完全模拟现实中的光，往往采用了简化模型的方式。

冯氏光照模型是比较流行的光照模型，该光照模型，将光的影响分为三个部分：环境光，漫反射光，镜面反射光

-   环境光：即使在黑暗环境下，也会有一些光源的存在，如远处的光，月光等，所以物体不会是完全黑暗的。为了模拟这个现象，我们指定一个环境光，始终给物体一些颜色。
-   漫反射光：漫反射光是物体颜色的最主要来源，其颜色的强度决定于物体是否正对着光源（同一个立立方体，正对着光的部分较亮，背对着的面较暗）
-   镜面反射光：镜面反射光模拟光滑表明受光照射后的亮点，镜面反射光的颜色一般受光的颜色影响更大。

在计算出三种光各自的分量后，将它们相加并乘以光的颜色，即是最终表面反射的光的颜色，即：

```glsl
vec3 light=ambientComponent+diffuseComponent +specularComponent;
color = vec4(light*objectColor,1);
```

# 环境光

复杂的环境光照计算需要考虑到光的反射，比如光照射到A物体上然后反射到B物体上，此时B物体上就会同时有直接的光照和从A反射来的光等等。但在冯式光照模型下，仅考虑最简化的全局光照效果，思路与 [Color](Learn%20OpenGL%20-%20Ch%2010%20Color.md) 中的光照效果类似，只不过需要额外添加一个光照系数，让光显得更为黑暗。

环境光的分量如下：

```glsl
float ambientStrength = 0.1;
vec3 ambientComponent = ambientStrength * lightColor;
```

# 漫反射光

漫反射光的原理是与光线方向越接近的地方可以从光源处获得更多的光亮。如下图所示，当光的方向与表面法线平行时（垂直于物体表面），漫反射分量最大。当光的方向与表面法线夹角 $\geq 90^{\circ}$时，漫反射分量为0。因此可以通过求光线方向与物体表面法线的夹角大小来判断漫反射分量的大小。

![300](assets/Learn%20OpenGL%20-%20Ch%2011%20Basic%20Lighting/image-20211216000202500.png)

因此为了计算漫反射，需要额外获取两个信息，一个是表面的法线方向，一个是光线的方向。前者可以通过传递顶点的法线，并由顶点法线自动插值得到表面的法线。后者可以传递光源的位置，并计算出表面上每个点的位置，两者相减就能获得光线的方向。

## 顶点法线

顶点的法线可以通过 `layout` 进行传递，即分别在着色器和CPP文件中加入如下代码：

```glsl
layout (location=2) in vec3 norm;
```

```cpp
glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void *)(5 * sizeof(float)));
glEnableVertexAttribArray(2);
```

而每个顶点的信息变为类似于如下的形式，前三个数值表示位置，后两个数值表示Texcoord，最后三个数值表示法线。

```cpp
-0.5f, -0.5f, 0.5f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 
```

又因为光照的计算在片段着色器中，因此法线信息需要传递到片段着色器中。法线信息不需要考虑投影变换和视角变换，但需要应用模型变换（物体的角度，大小改变后，法线也会相应改变）。但在应用模型变换时，需要考虑两点：

1.  方向是没有位移概念的，因此物体的模型变换中的位置信息需要去除，在原模型变换矩阵中取不含位置信息的左上$3\times3$子矩阵即可。
2.  如果模型包含了非等比例的缩放，模型矩阵与法线直接相乘会导致法线不再垂直于物体表面，如下图所示，为了处理非等比例的缩放，正确的变换矩阵为 原模型矩阵的逆矩阵的转置。证明见 //TODO
     ![|400](assets/Learn%20OpenGL%20-%20Ch%2011%20Basic%20Lighting/image-20211216000246152.png)

因此最后片段着色器中，对法线的处理为：

```glsl
out vec3 normal;

...

normal=normalize(mat3(transpose(inverse(model))) * norm);
```

## 光线方向

物理角度上看，光线方向应该是从光源出发，指向表面上的点的。但是因为这里需要光线方向与法线方向求角度差距，而法线的方向是从表面出发指向外侧的，因此在求漫反射时，实际上计算的是 `光线方向的反方向` 。

计算光线方向，需要知道光源位置和被照射的片元的位置。光源可通过Uniform传递，即：
```glsl
// 片段着色器
uniform vec3 lightPos;

// CPP
cubeShader->SetVec3("lightPos", lamp->GetTransform()->GetPosition());
```

片元位置可通过顶点位置和模型矩阵相乘获得，即：

```glsl
// 顶点着色器
out vec3 fragPos;

...
fragPos=vec3(model*vec4(pos,1.0));
...

```

光线方向通过两者相减即可获得：

```glsl
vec3 lightDir=normalize(lightPos-fragPos);
```

## 分量计算

通过点乘即可以获得 `光线方向与法线方向夹角越小，值越大的效果` 。

```glsl
float diff=max(dot(normal,lightDir),0.0);
vec3 diffuseComponent=diff*lightColor;
```

# 镜面反射光

镜面反射光取决于光的反射方向和人眼注视方向的夹角。如下图所示，想象有一面镜子，人的注视方向正好对着光反射的反向，此时人看到的就是一个巨大的光斑。因此人眼注释的方向与光反射方向的夹角越小，镜面反射光越大。

![|400](assets/Learn%20OpenGL%20-%20Ch%2011%20Basic%20Lighting/image-20211216000345055.png)

## 光的反射方向

为了得到光的反射方向，需要知道表面的法线方向和光的入射方向，这两个参数在之前已经进行了传递，之后使用 `GLSL` 中的内置函数 `reflect` 即可。

```glsl
vec3 reflectDir = reflect(-lightDir,normal);
```

```ad-warning
注意这里需要对 `lightDir` 取反，因为之前求得的 `lightDir` 方向是从表面指向光源的，但求反射光时需要的入射光方向是从光源指向表面的。
```

## 注视方向

为了求得注视方向，需要知道人眼的位置。

如同在求光线方向一样，物理上人的注视方向应当是从人眼位置出发指向表面片元，而这里求得的注视方向是为了与法线求夹角，因此这里求的注视方向是从表面片元指向人眼。

人眼位置可以通过 `uniform` 进行传递

```glsl
// 片段着色器
uniform vec3 viewPos;

// CPP
cubeShader->SetVec3("viewPos", camera->GetTransform()->GetPosition());
```

表面片元的位置在求漫反射光时已经得到，因此注视方向为：

```glsl
vec3 viewDir=normalize(viewPos-fragPos);
```

## 分量计算

当得到了反射方向和注释方向后，计算镜面反射光分量的步骤如下，其中 `specularStrength` 为调整镜面反射光亮度的光亮系数。

```glsl
float spec=pow(max(dot(viewDir,reflectDir),0.0),32);
vec3 specularComponent=spec*lightColor*specularStrength;
```

在计算物体镜面反射光时，在取得了了视线方向和光反射方向的点乘后，还做了一个次幂运算。这里的次幂运算表示高光的反射度。次幂越高表示一个物体反射度越高，反射能力越强，散射越少，高光点越小。如下所示：
![|400](assets/Learn%20OpenGL%20-%20Ch%2011%20Basic%20Lighting/image-20211216000433025.png)

# Phong Shading / Gouraud Shading

这里将光照计算都放到了片段着色器中，因此可以为每个像素计算光照后的颜色。 光照计算也可以放到顶点着色器中，这样是为每个顶点计算光照后的颜色，而像素的颜色是通过顶点颜色插值得到。

顶点着色器中计算光照，效果不如在片段着色器中得到的效果，但因为顶点数量通常远小于像素数量，因此效率更高。

用 `Phone Shading` 指代在片段着色器中计算光照效果，用 `Gouraud Shading` 指代在顶点着色器中计算光照效果。两者对比如下所示：

![|400](assets/Learn%20OpenGL%20-%20Ch%2011%20Basic%20Lighting/image-20211216000452574.png)

# 结果与源码

将三个颜色的光亮分量合并就能得到最终的效果：

```glsl
vec3 light=ambientComponent + diffuseComponent + specularComponent;
color = vec4(light*objectColor,1);
```

![|500](assets/Learn%20OpenGL%20-%20Ch%2011%20Basic%20Lighting/Basic_Lighting.gif)

[main.cpp](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/9.BacisLighting/main.cpp)

[object.frag](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/9.BacisLighting/object.frag)

[object.vert](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/9.BacisLighting/object.vert)

[lamp.frag](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/9.BacisLighting/lamp.frag)