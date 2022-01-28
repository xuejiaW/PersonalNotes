---
created: 2022-01-06
updated: 2022-01-28
tags:
    - OpenGL
---
# Overview

在之前的光照计算中，都添加了一个固定值作为全局光反射的模拟（Ambient Light）。在现实生活中，因为遮挡关系的存在，并非所有地方都受到相同的光。如墙角，小洞等地方因为被周围物体遮挡的原因，会显得较为昏暗。

`Screen-Space Ambient Occulsion（SSAO）` 就是模拟这种因遮挡关系导致不同全局光效果的技术。

如下为使用了 `SSAO` 与否的对比，可以看到右侧开启了 `SSAO` 的图像在墙角，电话亭背面处因为被遮挡的关系显得更暗，更符合现实情况：
![|500](assets/Ch%2034%20SSAO/image-20220106080946026.png)

因为 `SSAO` 是基于屏幕空间的计算，相较于真实的计算所有几何的遮挡关系虽然准确度存在差异，但能节省大量性能。

`SSAO` 会在屏幕空间中为每个像素生成一个 `Occlusion Factor`，该数值越大，之后计算光照时该像素使用的 `Ambient Light` 系数就越低 ，以此体现几何的遮挡关系。

`Occlusion Factor` 的计算依赖于 `Screen-Space` 的 3D 位置信息，该信息可以通过 [G-buffer](Ch%2033%20Deferred%20Shading.md#The%20G-buffer) 获得。

```ad-note
因为 `SSAO` 同样需要  [G-buffer](Learn%20OpenGL%20-%20Ch%2033%20Deferred%20Shading.md#The%20G-buffer) ，因此 `SSAO` 通常与 [Deferred Shading](Learn%20OpenGL%20-%20Ch%2033%20Deferred%20Shading.md) 一起使用。
```

```ad-note
此处 [G-buffer](Learn%20OpenGL%20-%20Ch%2033%20Deferred%20Shading.md#The%20G-buffer) 存储的位置是基于 `View-Space` 而非 `World-Space`，因为物体的遮挡关系会随着视线的变化而产生变化。
```

对于屏幕空间的每个像素而言，会为其生成一系列的采样点，每个采样点表示表示该像素在 `ViewSpace` 中的周围位置。通过比较采样点与该采样点在同屏幕空间中像素的 z 值，就能知晓该采样点是否会被几何遮挡。  

如一个像素屏幕空间中的位置是 $(0.29, 0.29)$，查询 `G-Buffer` 得该像素在 `View-Space` 的位置为 $(10.1,10.1,-10.1)$。该像素的一个采样点在 `View-Space` 的偏移量为 $(0.25,0.25,0.25)$，则该采样点在 `View-Space` 的位置为 $(10.35,10.35,-9.85)$。如果该采样点转换到屏幕空间中的位置是 $(0.3, 0.3)$，则再进一步通过 $(0.3,0.3)$ 查询该像素在 `G-Buffer` 中记录的 `View-Space` 位置为 $(10.35, 10.35, -8)$。即采样点的 $Z$ 值为 $-9.85$，对应在 `G-Buffer` 中的 $z$ 值为 $-8$，所以该采样点会被真实的几何所遮挡。每有一个采样点被遮挡，该像素的 `Occlusion Factor` +1。

```ad-important
在 OpenGL 的右手坐标系下， `View-Space` 的 Z 值都为负数，数值越大越靠近摄像机。因此当采样点的 Z 小于 `G-Buffer` 中的值说明被遮挡。
```

整个流程的示意图如下所示：
![曲线表示 G-Buffer 中的位置，黑色为当前点，灰色为被遮挡的采样点 | 500](assets/Ch%2034%20SSAO/image-20220106082121010.png)

对于一个 Fragment 而言，如果采样的周围 Fragment 处于当前 Fragment 下方，则它必然会被遮挡，也就会造成 `Occlusion Factor` 过大。为了解决这个问题，应当只采样当前 Fragment 上半侧的其他 Fragments，通过法线方向决定上半侧的朝向。如下图所示，可以看到获取周围采样点的范围由之前的球变成了半球：
![|500](assets/Ch%2034%20SSAO/image-20220106083942529.png)

```ad-note
对于一个 Fragment 而言，在基于该 Fragment 法线的 TBN 空间中，Z 值正数即表示在该 `Fragment `的上半侧。
```

`SSAO` 的精度取决于计算每个 Fragment 时取的周围 Fragments 的数量，数量太低则精度不够，会引发一种称为 `Banding` 的失真效果，但数量太高则会引发性能问题。

为了在采样 Fragments 数量尽量小的情况下（为节约性能）取得更好的效果，可以为采样的周围 Fragments 引入随机值。即对每个 Fragment，在采样它周围的 Fragments 时，随机将这些 Fragments 旋转一定角度，保证采样点并不会仅计算某个特定方向。但随机值的引入会导致噪声的产生，为了解决噪声问题，可以再对结果进行一个模糊化处理。

下图为采样值过少时的 `Banding` 现象，当引入随机值后的噪声表现，以及对噪声进行模糊处理后的结果：
![](assets/Ch%2034%20SSAO/image-20220106082927518.png)

因此整个计算 `SSAO` 的流程如下所示：

![](assets/Ch%2034%20SSAO/image-20220115232055258.png)


# Sample buffers

## G-Buffer

首先需要通过 `G-Buffer` 生成 `SSAO` 贴图，生成 `SSAO` 贴图需要依赖到 `G-Buffer` 中的 `Position` 及 `Normal` 贴图。

与在 [Deferred Shading](Ch%2033%20Deferred%20Shading.md) 中不
同的是，此处生成的 `Position` 和 `Normal`是在 `View - Space` 空间而非 `World-Space` 空间。

生成 `View-Space` 的 `Position` 和 `Normal` 的 `G-Buffer` 顶点着色器如下所示：
```glsl
void main()
{
    Texcoord = tex;

    vec4 viewPos = view * model * vec4(pos, 1.0);
    FragPos = viewPos.xyz; // FragPos in view space

    mat3 normalMatrix = transpose(inverse(mat3(view * model)));
    Normal = normalMatrix * norm;

    gl_Position = projection * viewPos;
}
```

`G-Buffer` 的片段着色器与在 [Ch 33 Deferred Shading](Ch%2033%20Deferred%20Shading.md) 使用的几乎相同。只不过此处为了方便，不再采样模型的 Diffuse 和 Specular 纹理，直接将固定值赋值给 `albedo` 贴图：
```glsl
void main()
{
    gPoisition = FragPos;
    gNormal = normalize(Normal);
    gAlbedoSpec.rgb = vec3(0.95);
}
```

因为需要为 `gPosition` 中的每个像素生成多个偏移的采样点，而采样点很可能会超出 `gPosition` 的范围。为了保证结果的准确性，需要将纹理的 Warp 模式设置为 `GL_CLAMP_TO_EDGE`，如下所示：
```cpp
glGenTextures(1, &gPosition);
glBindTexture(GL_TEXTURE_2D, gPosition);
glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA16F, screen_width, screen_height, 0, GL_RGBA, GL_FLOAT, nullptr);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, gPosition, 0);
```

## Normal-oriented hemisphere

这一部分会生成如下所示的基于法线的半球 Samples 点：
![|500](assets/Ch%2034%20SSAO/image-20220116134443972.png)

依赖 [Random Number](../../Notes/C++/Random%20Number.md) 生成 64 个 Simple 采样点。每个采样点的 $x,y$ 范围在 $[-1,1]$ 之间，$z$ 的范围在 $[0,1]$ 之间：
```cpp
std::uniform_real_distribution<float> randomFloats(0.0, 1.0);
std::default_random_engine generator;
std::vector<glm::vec3> ssaoKenels;
for (unsigned int i = 0; i != 64; ++i)
{
    glm::vec3 sample(randomFloats(generator) * 2.0 - 1.0, randomFloats(generator) * 2.0 - 1.0, randomFloats(generator));
    sample = glm::normalize(sample);
    sample *= randomFloats(generator);
    ssaoKenels.push_back(sample);
}
```

上述的代码让在半球内随机的分配采样点，但采样点应该在接近原点的地方更密集，如下所示：
```cpp
float lerp(float a, float b, float f) { return a + f * (b - a); }


float scale = (float)i / 64.0;
scale = lerp(0.1f, 1.0f, scale * scale);
sample *= scale;
```

通过 `lerp(0.1f, 1.0f, scale*scale)` 让采样点如下左曲线分配，最后采样点的分布点如下右所示：
![|500](assets/Ch%2034%20SSAO/image-20220116140944091.png)

## Random kernel rotations

如果所有的像素使用的一系列采样点都相同，那么很可能测试出来的遮挡关系并不准确。如场景中有一系列垂直和水平的墙，如果采样点是固定的，那么对垂直墙有良好效果的采样点就会对水平墙有较差的效果。

因此需要生成随机向量用来旋转采样点，生成随机向量的过程如下所示：
```cpp
std::vector<glm::vec3> ssaoNoise;
for (unsigned int i = 0; i != 16; ++i)
{
    glm::vec3 noise(randomFloats(generator) * 2.0 - 1.0, randomFloats(generator) * 2.0 - 1.0, 0.0f);
    ssaoNoise.push_back(noise);
}
```

```ad-note
之前所有的采样点的生成都是在基于 $z$ 轴正方向的半球分布的，因此随机向量的生成是绕着 $Z$ 轴旋转的，所以生成随机向量时 $z$ 分量为 0。
```

可以用生成的 $4\times4$ 个随机向量作为像素的颜色，生成一张 $4\times4$的贴图，代码如下所示，注意此时贴图的 `Warp` 方式为 `Repeat`：
```cpp
unsigned int noiseTexID;
glGenTextures(1, &noiseTexID);
glBindTexture(GL_TEXTURE_2D, noiseTexID);
glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA16F, 4, 4, 0, GL_RGB, GL_FLOAT, &ssaoNoise[0]);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
```

## The SSAO shader

这一部分是为了生成 `SSAO` 贴图，为了生成 `SSAO` 贴图同样需要一个单独的 Framebuffer，示例如下：
```cpp
glGenFramebuffers(1, &ssaoFBO);
glBindFramebuffer(GL_FRAMEBUFFER, ssaoFBO);

unsigned int ssaoColorBuffer;
glGenTextures(1, &ssaoColorBuffer);
glBindTexture(GL_TEXTURE_2D, ssaoColorBuffer);
glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, screen_width, screen_height, 0, GL_RED, GL_FLOAT, NULL);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, ssaoColorBuffer, 0);

ssaoTexture = new Texture(ssaoColorBuffer, screen_width, screen_height);
```

因为 `SSAO` 只需要关系每个像素的 `Ambient Occlusion` 数据，所以每个像素返回一个数值即可，所以上述创建 Color Buffer 时的格式为 `GL_RED`。

所以生成 `SSAO` 贴图的整个流程如下所示：
```cpp
glBindFramebuffer(GL_FRAMEBUFFER, gBuffer);

[Draw scene]

//Use G-Buffer to render ssao texture
glBindFramebuffer(GL_FRAMEBUFFER, ssaoFBO);
glClear(GL_COLOR_BUFFER_BIT);
    // Bind G-Buffer position texture
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, gPosition);
    // Bind G-Buffer normal texture
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, gNormal);
    // Bind Noist texture
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, noiseTexture);
    shaderSSAO.use();
    // Set Samples to shader
    SendKernelSamplesToShader();
    // Set projection matrix
    shaderSSAO.setMat4("projection", projection);
    RenderQuad();
glBindFramebuffer(GL_FRAMEBUFFER, 0);
```

在生成 `SSAO` 的 Shader 中首先需要将 `G-Buffer` ，随机值构成的纹理（噪声纹理），采样点及投影矩阵（用来将采样点从 `View-Space` 转换到 `Screen-Space`）作为输入，同时因为生成 `SSAO` 的 Framebuffer 的 Color Buffer 仅需要是 `GL_RGB` 类型，所以 Fragment Shader 的输出也不再是 `vec4` 而是 `float`：
```glsl
out float FragColor;

in vec2 TexCoords;

uniform sampler2D gPosition;
uniform sampler2D gNormal;
uniform sampler2D texNoise;

uniform vec3 samples[64];

int kernalSize = 64;
float radius = 0.5;
float bias = 0.025;

uniform mat4 projection;

const vec2 noiseScale = vec2(1024 / 4.0, 1024.0 / 4.0);
```

在 Shader 中首先会使用 `View-Space` 的 Normal 向量，以及噪声向量生成从 `Local-Space` 转换到 `View-Space` 的 `TBN` 矩阵：
```glsl
vec3 FragPos = texture(gPosition, TexCoords).rgb;
vec3 normal = texture(gNormal, TexCoords).rgb;
vec3 randomVec = texture(texNoise, TexCoords * noiseScale).xyz;

vec3 tangent = normalize(randomVec - normal * dot(randomVec, normal));
vec3 bitangent = cross(normal, tangent);
mat3 TBN = mat3(tangent, bitangent, normal);
```

其中生成 `tangent` 向量时使用了 `格拉姆-施密特正交化 Gramm-Schmidt process`，即用 `randomVec` 向量减去 `randomVec` 在 `normal` 的分量就能到垂直于 `normal` 的 `tangent` 向量。

之后用 TBN 向量讲过所有 sample 变换到 `View-Space` 并将其添加到 `FragPos` 上，此时便得到了在 `View-Space` 的采样点坐标：
```glsl
float occlusion = 0.0;
for(int i = 0; i != kernelSize; ++i)
{
    vec3 samplePos = TBN * samples[i];
    samplePos = FragPos + samplePos * radius;
    // ...
}
```

可以通过 `projection` 矩阵将采样点从 `view-space` 转换到 `clipping-space`，通过将 $xyz$ 除以 $w$ 将其转换到 `NDC-space`，最后将其转换到 $0 \sim 1$ 的 `screen-space`：
```glsl
vec4 offset = vec4(samplePos, 1.0);
offset = projection * offset;
offset.xyz /= offset.w;
offset.xyz = offset.xyz * 0.5 + 0.5;
```

可以用该处于 `screen-space` 的 `offset` 采样 `gPosition` 贴图，并用贴图中的数据（作为场景中几何的位置）与 `samplePos`（采样点）做比较。如果贴图中的 $z$ 值大于采样点的 $z$ 值，那么即说明该采样点会被遮挡，此时 `occlusion` 值 $+1$。

```glsl
occlusion += sampleDepth >= sample.z + bias ? 1.0 :0.0;
```

但此时还存在一个问题，对于平行于模型表面的采样点，会被认为被表面本身的深度遮挡，如下部分：
![|500](assets/Ch%2034%20SSAO/image-20220117000532915.png)

为了解决这个问题，需要引入一个 `range check` 的机制，只有在遮挡采样点的几何深度与采样点的深度值差距小于半径的情况下，才认为该遮挡是有效的。使用的代码如下：
```glsl
float rangeCheck = smoothstep(0.0, 1.0, radius / abs(FragPos.z - sampleDepth));
occlusion += (sampleDepth >= samplePos.z + bias ? 1.0 : 0.0) * rangeCheck;
```

在上述代码中使用 `smoothstep` 获取 `rangeCheck`。如果 `FragPos.z` 与 `sampleDepth` 的差距越大，那么 `radius / abs(FragPos.z - sampleDepth))` 的值就会越接近 $0$，仅当差距小于等于 `radius` 时，返回值才会等于 $1$。

如下为使用 `range check`与否的对比，左侧为未使用，右侧为使用：
![|500](assets/Ch%2034%20SSAO/image-20220118085147269.png)

最后求得被遮挡的采样点比例，该比例越高，环境光的贡献值就应该越低：
```glsl
occlusion = 1.0 - (occlusion / kernalSize);

FragColor = occlusion;
```

此时的渲染结果如下所示：
![|500](assets/Ch%2034%20SSAO/image-20220118085719515.png)

# Ambient occlusion blur

如之前所述，现在得到的 `SSAO` 贴图存在着较明显的噪声，如下部分所示：
![|200](assets/Ch%2034%20SSAO/image-20220118092206841.png)


为了解决噪声问题，需要将 `SSAO` 进行模糊操作。同样使用一个 Framebuffer 在后处理时进行模糊操作：
```cpp
void GenerateBlurFramebuffer()
{
    glGenFramebuffers(1, &ssaoBlurFBO);
    glBindFramebuffer(GL_FRAMEBUFFER, ssaoBlurFBO);

    unsigned int ssaoBlurColorBuffer;
    glGenTextures(1, &ssaoBlurColorBuffer);
    glBindTexture(GL_TEXTURE_2D, ssaoBlurColorBuffer);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, screen_width, screen_height, 0, GL_RED, GL_FLOAT, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, ssaoBlurColorBuffer, 0);

    ssaoBlurTexture = new Texture(ssaoBlurColorBuffer, screen_width, screen_height);
}
```

进行模糊操作的 Shader 主体如下：
```glsl
void main()
{
    vec2 texelSize = 1.0 / vec2(textureSize(ssaoInput, 0));
    float result = 0.0;
    for (int x = -2; x != 2; ++x)
    {
        for (int y = -2; y != 2; ++y)
        {
            vec2 offset = vec2(float(x), float(y)) * texelSize;
            result += texture(ssaoInput, TexCoords + offset).r;
        }
    }

    FragColor = result / (4 * 4);
}
```

进行模糊后的 `SSAO` 图如下所示：
![|500](assets/Ch%2034%20SSAO/image-20220118092428821.png)

# Applying ambient occlusion

在最后的渲染贴图中，相较于 [Deferred Shading](Ch%2033%20Deferred%20Shading.md) 中使用 `G-Buffer` 计算光照的方式。此处需要使用 `SSAO` 贴图作为 Ambient 光照的输出系数：
```glsl
// ...
float ambientOcclusion = texture(ssao, TexCoords).r;
vec3 ambient = vec3(0.1 * Diffuse * ambientOcclusion);
```

C++ 传输的数据与在 [Deferred Shading](Ch%2033%20Deferred%20Shading.md) 中也类似，只不过此处需要传输 `ssao` 贴图，且只传输一盏灯的信息：
```cpp
glBindFramebuffer(GL_FRAMEBUFFER, 0);
screenMeshRender->GetMaterial()->AddTexture("gPosition", geoPosTexture);
screenMeshRender->GetMaterial()->AddTexture("gNormal", geoNormalTexture);
screenMeshRender->GetMaterial()->AddTexture("gAlbedoSpec", geoAlbedoTexture);
screenMeshRender->GetMaterial()->AddTexture("ssao", ssaoBlurTexture);

screenMeshRender->GetMaterial()->GetShader()->SetVec3("light.Position", vec3(1, 1, 0));
screenMeshRender->GetMaterial()->GetShader()->SetVec3("light.Color", vec3(1, 1, 0));
screenMeshRender->GetMaterial()->GetShader()->SetFloat("light.Linear", 0.7f);
screenMeshRender->GetMaterial()->GetShader()->SetFloat("light.Quadratic", 0.9f);

screenMeshRender->GetMaterial()->GetShader()->SetVec3("viewPos", camera->GetTransform()->GetPosition());

screenMeshRender->DrawMesh();
```

此时的渲染结果如下所示：
![|500](assets/Ch%2034%20SSAO/image-20220119093003493.png)

