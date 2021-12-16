---
created: 2021-12-16
updated: 2021-12-17
---

这一章与 [Color](LearnOpenGL-Ch%2010%20Color.md) 及 [Basic Lighting](LearnOpenGL-Ch%2011%20Basic%20Lighting.md) 内容实际一致，但进行了进一步的封装。

在 [Color](LearnOpenGL-Ch%2010%20Color.md) 中通过片段着色器中的 `objectColor` 表示物体的颜色，在 [Basic Lighting](LearnOpenGL-Ch%2011%20Basic%20Lighting.md)中计算的到的 环境光，漫反射光，镜面反射光在相加后的结果，会与 `objectColor` 相乘得到最终的像素颜色。且在 [Basic Lighting](LearnOpenGL-Ch%2011%20Basic%20Lighting.md) 中通过 `ambientStrength` 和 `specularStrength` 两个参数来调整环境光和镜面反射光的强度。

# 物体材质

现实世界中，不同物体对于光的反射是不同的。比如钢材会比陶瓷玻璃更闪闪发光，木头箱子不会像钢制箱子那样对光有很强的反射等等。不同材质物体的模拟光照效果如下所示：
![|500](assets/LearnOpenGL-Ch%2012%20Materials/Untitled.png)

并且有时对于一个物体，镜面反射的光看起来的颜色与漫反射光的颜色会不一样，这就导致了之前单纯通过 `objectColor` 表示整个物体颜色的方法不再适用。

可以在片段着色器中定义一个结构体表示物体的材质，可以区分物体对于不同的光照的吸收能力：

```glsl
struct Material
{
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    float shiness;
};

uniform Material material;
```

其中环境光，漫反射光，镜面反射光都用 `vec3` 表示，因此可以调整单一分量光的颜色和强度。 `shiness` 表示计算镜面反射光时，需要进行的次幂次数。

在C++中，传递unifrom结构体数据的方法如下，与普通变量的传递方法基本一致：

```cpp
cubeShader->SetVec3("material.ambient", vec3(1.0, 0.5, 0.31));
cubeShader->SetVec3("material.diffuse", vec3(1.0, 0.5, 0.31));
cubeShader->SetVec3("material.specular", vec3(0.5, 0.5, 0.5));
cubeShader->SetFloat("material.shiness", 32.0f);
```

# 光源属性

同样可以将光源的信息也封装在着色器的结构体之中：

```glsl
struct Light
{
    vec3 position;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

uniform Light light;
```

其中 `position` 表示光源的位置，同样的光源也有环境光，漫反射光，镜面反射光三个 `vec3` 分量，可以设置三个颜色分量的贡献度。一般而言环境光的贡献很小（如果仅有环境光，物体是很昏暗的）；漫反射决定了物体主要的明亮程度，漫反射贡献较大；镜面光是高光，一般是对光的完全反射。

传递数值如下：

```cpp
cubeShader->SetVec3("light.ambient", vec3(0.1, 0.1, 0.1));
cubeShader->SetVec3("light.diffuse", vec3(0.5, 0.5, 0.5));
cubeShader->SetVec3("light.specular", vec3(1.0, 1.0, 1.0));
cubeShader->SetVec3("light.position", lamp->GetTransform()->GetPosition());
```

# 光照信息计算

新光照信息的计算，只要将 [LearnOpenGL-Ch 11 Basic Lighting](LearnOpenGL-Ch%2011%20Basic%20Lighting.md) 中计算光照信息时的参数换成相应材质和光源属性中的参数即可。

```glsl
vec3 ambientComponent = light.ambient * material.ambient;

vec3 lightDir=normalize(light.position-fragPos);
vec3 viewDir=normalize(viewPos-fragPos);
vec3 reflectDir=reflect(-lightDir,normal);

float diff=max(dot(normal,lightDir),0.0);
vec3 diffuseComponent=diff*material.diffuse*light.diffuse;

float spec=pow(max(dot(viewDir,reflectDir),0.0),material.shiness);
vec3 specularComponent=spec*material.specular*light.specular;

vec3 light=ambientComponent+diffuseComponent +specularComponent;
color = vec4(light,1);
```

# 结果与源码：
![|500](assets/LearnOpenGL-Ch%2012%20Materials/Material.gif)

[main.cpp](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/10.Materials/main.cpp)

[lamp.frag](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/10.Materials/lamp.frag)

[object.frag](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/10.Materials/object.frag)

[object.vert](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/10.Materials/object.vert)