---
created: 2021-12-16
updated: 2021-12-17
---
```ad-warning
多光源章节相对于投光物章节实际并没有新内容的增加，因此将两章节合并
```

一个将光投射到其他物体上的物品称为 `投光物`，有三种主要的投光物类型，平行光，点光源，聚光。

无论是哪种投光物类型，他们光照信息的计算是与 [Lighting Maps](LearnOpenGL-Ch%2013%20Lighting%20Maps.md) 中类似的，即每种投光物都的效果都是由环境光，漫反射光，镜面反射光构成。

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
![|400](assets/LearnOpenGL-Ch%2014%20%20Light%20Casters,%20Multiple%20Lights/Untitled.png)

平行光作为全局光照，不太需要考虑光亮度的衰减，因为光源处在无限远处，在考虑的世界范围内，实际上衰减非常的小。

因此平行光的计算与 [Lighting Maps](LearnOpenGL-Ch%2013%20Lighting%20Maps.md) 中计算的唯一区别就是对于不同的片元而言，光线方向始终是一样的。

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
![|400](assets/LearnOpenGL-Ch%2014%20%20Light%20Casters,%20Multiple%20Lights/Untitled%201.png)

在 [Lighting Maps](LearnOpenGL-Ch%2013%20Lighting%20Maps.md) 等章节中的光源计算，与点光源的计算十分类似，只不过之前的章节中并没有引入光源的衰减。

## 衰减

光的衰减现象通常可由以下的公式进行表示：

$$
F_{a t t}=\frac{1.0}{K_{c}+K_{l} * d+K_{q} * d^{2}}
$$

-   $d$ 表示距离
-   常数项 $K_{c}$ 一般设为1，用来计算的结果不会大于1。
-   一次项 $K_{l}$ 用来以线性方式减少光的强度
-   二次项 $K_{q}$ 以二次递减的方式减少光的强度，使得光在一定范围内几乎是以线性方式减少，而距离足够大时，光强度会以更快的速度下降。

```ad-note
光的衰减不仅仅出现在点光源中，聚光灯中同时需要衰减
```

为了让光覆盖不同的范围，需要为 $K_{c}$，$K_{l}$，$K_{q}$ 选取不同的值。根据 [Ogre3D](http://wiki.ogre3d.org/tiki-index.php?page=-Point+Light+Attenuation) 的实验，不同距离的三值参考值如下：
![|200](assets/LearnOpenGL-Ch%2014%20%20Light%20Casters,%20Multiple%20Lights/Untitled%202.png)

## 衰减计算

点光源的数据中，需要包含公式中的 $K_{c}$，$K_{l}$，$K_{q}$ ：

```glsl
struct PointLight
{
    vec3 position;
    vec3 diffuse;
    vec3 specular;

    float constant;
    float linear;
    float quadratic;
};
uniform PointLight pointLights[2]; // 设置了两个点光源
```

衰减系数计算如下：

```glsl
float lightDist = length(light.position - fragPos);
float attenuation = 1 / (light.constant + light.linear*lightDist + light.quadratic*lightDist*lightDist);
```

在计算得到漫反射光和镜面反射光分量后，与衰减系数相乘后即可：

```glsl
vec3 diffuseComponent=GetDiffuseValue(normal,lightDir,light.diffuse) * attenuation;
vec3 specularComponent=GetSpecularValue(normal,lightDir,viewDir,light.specular) * attenuation;
```

# 聚光灯（Spotlight）

聚光是位于环境中某个位置的光源，且只朝一个特定的方向照射光线，所以只有在聚光方向特定半径内的物体才会被照亮，其余部分保持黑暗。如下所示：

![|350](assets/LearnOpenGL-Ch%2014%20%20Light%20Casters,%20Multiple%20Lights/Untitled%203.png)

其中：
$LightDir$：黑线，光线方向
$SpotDir$：红线，聚光灯所指方向
$\phi$：蓝线与红线夹角，最大照亮角度的一半
$\theta$：黑线与红线的夹角，应当始终小于 $\phi$

如果以 `light.cutoff` 表示 $\phi$，以 `-light.direction` 表示 $SpotDir$，以 `lightDir` 表示 $LightDir$。聚光灯最简的计算如下：

```glsl
float theta = dot(lightDir, normalize(-light.direction));
    
if(theta > light.cutOff) 
{       
  // 光照计算
}
```

```ad-note
 对 `-light.direction` 和 `lightDir` 进行点乘计算，可求得它们方向的相近程度。在两向量都为单位向量时，点乘结果即为余弦值，而角度越小，余弦值越大。所以所求值大于 `light.cutoff` 的情况，才是在范围内的情况。
```

但这样会造成强硬的边界，即在范围外后聚光效果马上消失。而真实的光在边缘处应当逐渐减少亮度，为了创建出边缘光滑的聚光，需要模拟一个内圆锥和一个外圆锥，让光从内圆锥逐渐变暗直到外圆锥边界。公式如下：

$$I=\frac{\theta-\gamma}{\epsilon}$$

其中$\epsilon$ 为内外圆锥角度的余弦差值（内圆锥余弦值减去外圆锥余弦值），$\gamma$ 为外圆锥的余弦值，$\theta$ 为当前角度的余弦值。当 $\theta$ 小于内圆锥角度时，最终计算的结果会大于1，而当 $\theta$ 大于外圆锥角度时，最终计算结果会小于0，因此需要用 `clamp` 函数将其约束到 $0.0 \sim 1.0$的范围内。

所以聚光灯强度系数计算如下：

```glsl
float theta = dot(lightDir, normalize(-light.direction)); 
float epsilon = light.cutOff - light.outerCutOff;
float intensity = clamp((theta - light.outerCutOff) / epsilon, 0.0, 1.0);
```

对于聚光灯，光的衰减同样需要考虑，因此最终聚光灯的漫反射和镜面反射效果为;

```glsl
vec3 diffuseComponent = GetDiffuseValue(normal,lightDir,light.diffuse) * attenuation * intensity;
vec3 specularComponent = GetSpecularValue(normal,lightDir,viewDir,light.specular) * attenuation * intensity;
```

# 多光源

多光源的计算将上述各种投光物的结果累加在一起即可：

```glsl
vec3 ambientComponent = ambient * vec3(texture(material.diffuse,texcoord));

vec3 result = ambientComponent;
result += CalculateDirLight(dirLight,normal,viewDir);

for(int i = 0; i != 2; ++i)
    result += CalculatePointLight(pointLights[i],normal,fragPos,viewDir);
result += CalculateSpotLight(spotLight,normal,fragPos,viewDir);

color = vec4(result,1);
```

# 结果与源码
![|500](assets/LearnOpenGL-Ch%2014%20%20Light%20Casters,%20Multiple%20Lights/LightCasters.gif)

[main.cpp](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/12.LightCasters%26%26MultipleLights/main.cpp)

[lamp.frag](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/12.LightCasters%26%26MultipleLights/lamp.frag)

[object.vert](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/12.LightCasters%26%26MultipleLights/object.vert)

[object.frag](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/12.LightCasters%26%26MultipleLights/object.frag)