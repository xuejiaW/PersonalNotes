---
created: 2021-12-15
updated: 2021-12-16
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

复杂的环境光照计算需要考虑到光的反射，比如光照射到A物体上然后反射到B物体上，此时B物体上就会同时有直接的光照和从A反射来的光等等。但在冯式光照模型下，仅考虑最简化的全局光照效果，思路与 [Color](LearnOpenGL-Ch%2010%20Color.md) 中的光照效果类似，只不过需要额外添加一个光照系数，让光显得更为黑暗。

环境光的分量如下：

```glsl
float ambientStrength = 0.1;
vec3 ambientComponent = ambientStrength * lightColor;
```

# 漫反射光

漫反射光的原理是与光线方向越接近的地方可以从光源处获得更多的光亮。如下图所示，当光的方向与表面法线平行时（垂直于物体表面），漫反射分量最大。当光的方向与表面法线夹角 $\geq 90^{\circ}$时，漫反射分量为0。因此可以通过求光线方向与物体表面法线的夹角大小来判断漫反射分量的大小。

![](assets/LearnOpenGL-Ch%2011%20Basic%20Lighting/image-20211216000202500.png)

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
     ![](assets/LearnOpenGL-Ch%2011%20Basic%20Lighting/image-20211216000246152.png)

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

### 分量计算

通过点乘即可以获得 `光线方向与法线方向夹角越小，值越大的效果` 。

```glsl
float diff=max(dot(normal,lightDir),0.0);
vec3 diffuseComponent=diff*lightColor;
```