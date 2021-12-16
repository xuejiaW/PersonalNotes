```ad-warning
多光源章节相对于投光物章节实际并没有新内容的增加，因此将两章节合并
```

一个将光投射到其他物体上的物品称为 `投光物`，有三种主要的投光物类型，平行光，点光源，聚光。

无论是哪种投光物类型，他们光照信息的计算是与 [Lighting Maps](LearnOpenGL-CH%2013%20Lighting%20Maps.md) 中类似的，即每种投光物都的效果都是由环境光，漫反射光，镜面反射光构成。

其中环境光只需要计算一次，而且并不与任何的光源性质相关，投光物实际影响的是漫反射光和镜面反射光的计算。因此可以将获取漫反射分量和镜面反射分量的计算抽象为函数，减少重复的代码量。

```glsl
vec3 GetDiffuseValue(vec3 normal,vec3 lightDir,vec3 lightDiffuse)
{
    return max(dot(normal, lightDir),0.0) * vec3(texture(material.diffuse,texcoord)) * lightDiffuse;
}

vec3 GetSpecularValue(vec3 normal,vec3 lightDir,vec3 viewDir, vec3 lightSpecular)
{
    vec3 reflectDir=reflect(-lightDir,normal);
    float spec=pow(max(dot(viewDir,reflectDir),0.0),material.shininess);
    vec3 specularComponent=spec*lightSpecular* vec3(texture(material.specular,texcoord));

    return specularComponent;
}
```

# 平行光（Direction Light）

在[Basic Lighting](LearnOpenGL-Ch%2011%20Basic%20Lighting.md) 中，光的方向是由光源的位置减去每个片元的位置来获得的。如果假设光源处在无限远处，那么光的方向就固定为一个平行线。太阳光就是典型的平行光，如下图所示：
![](assets/LearnOpenGL-Ch%2014%20%20Light%20Casters,%20Multiple%20Lights/Untitled.png)

平行光作为全局光照，不太需要考虑光亮度的衰减，因为光源处在无限远处，在考虑的世界范围内，实际上衰减非常的小。

因此平行光的计算与 [Lighting Maps](LearnOpenGL-CH%2013%20Lighting%20Maps.md) 中计算的唯一区别就是对于不同的片元而言，光线方向始终是一样的。

```glsl
struct DirLight
{
    vec3 direction;
    vec3 diffuse;
    vec3 specular;
};

uniform DirLight dirLight;

...

vec3 CalculateDirLight(DirLight light,vec3 normal,vec3 viewDir)
{
    vec3 lightDir=normalize(-light.direction); // 传入的光方向为物理意义的方向

    vec3 diffuseComponent= GetDiffuseValue(normal,lightDir,light.diffuse);
    vec3 specularComponent=GetSpecularValue(normal,lightDir,viewDir,light.specular);

    return diffuseComponent + specularComponent;
}
```

# 点光源（Point Light）

点光源就是处在世界中某个点的光源，它几乎是均匀的像各个方向发射光，且光会随着距离而逐渐衰减，所以点光源仅会照亮场景中的一部分。点光源示意图如下所示：
![](assets/LearnOpenGL-Ch%2014%20%20Light%20Casters,%20Multiple%20Lights/Untitled%201.png)