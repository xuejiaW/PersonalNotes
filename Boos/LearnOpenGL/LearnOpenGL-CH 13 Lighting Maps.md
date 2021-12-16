
这一章实际上只是 [Materials](LearnOpenGL-Ch%2012%20Materials.md)和 [Textures](LearnOpenGL-Ch%2004%20Textures.md) 两章内容的结合。

[Materials](LearnOpenGL-Ch%2012%20Materials.md) 中，在片段着色器里定义了 `Material` 来表示物体对于光照的吸收性。但这样的做法下，一个物体所有的地方都是相同的 `Material` 属性，这肯定是与现实世界不符合的。

因此这一章中使用贴图的颜色信息来取代 `Material` 中的 `vec3` 属性，这样就能做到物体不同的地方有不同的属性（对应贴图上不同点的颜色）。

# 漫反射贴图

![|300](assets/LearnOpenGL-CH%2013%20Lighting%20Maps/Untitled.png)

漫反射贴图主要提供物体不同区域的颜色。

# 镜面反射贴图

![|300](assets/LearnOpenGL-CH%2013%20Lighting%20Maps/image-20211216082651605.png)

镜面反射贴图中的黑色部分对应漫反射贴图中的木头部分，在现实中木头几乎不会产生镜面反射，因此图中用黑色表示，及为 `vec3(0 ,0, 0)`，这样计算出的镜面反射强度与木头部分贴图值相乘后为0，即没有镜面反射。

# 光照贴图计算

在片段着色器中，用光照贴图取代之前材质中用来表示环境光，漫反射光，镜面反射光的颜色向量。

```glsl
struct Material
{
    sampler2D diffuse;
    sampler2D specular;
    float shiness;
};

uniform Material material;
```

因为物体反射漫反射光与环境光表现的颜色基本是一样的，所以这里仅用漫反射光贴图。

计算时用漫反射贴图和镜面反射贴图采样后的颜色取代 [LearnOpenGL-Ch 11 Basic Lighting](LearnOpenGL-Ch%2011%20Basic%20Lighting.md) 中材质的颜色分量。

```glsl
vec3 ambientComponent = light.ambient * vec3(texture(material.diffuse,texcoord));
vec3 diffuseComponent=diff*light.diffuse*vec3(texture(material.diffuse,texcoord));
vec3 specularComponent=spec*light.specular* vec3(texture(material.specular,texcoord));
```