---
cssclass: [table-border]
created: 2021-12-27
updated: 2022-03-11
tags:
    - OpenGL
---
# Overview

之前进行的渲染都称为 ` 前向渲染（Forward Rendering / Forward Shading）。在前向渲染中对于场景内的每个物体，在它们的着色器中都需要对场景内的每个光照都进行计算，如 [Light Casters, Multiple Lights](Ch%2014%20%20Light%20Casters,%20Multiple%20Lights.md) 即为典型的前向渲染计算。

延迟渲染（Deferred Rendering / Deferred Shading）技术的主要目的就是为了优化场景内存在大量光照时的性能。

延迟渲染主要被拆分为两部分：
1.  Geometry Pass：渲染一次场景并将所有得到的关于场景内物体的几何信息存储到一系列称为 `G-buffer` 的纹理中，比如位置，法线，颜色，高光等等。
2.  Lighting Pass：渲染一个铺满屏幕的 Quad，在这次渲染中使用上 `Geometry Pass ` 生成的 `G-Buffer`

整体的流程如下所示：
![](assets/Ch%2033%20Deferred%20Shading/image-20211227082817485.png)

整个流程的伪代码如下：
```cpp
while (...) // render loop
{
  // 1. geometry pass: render all geometric/color data to g-buffer
  glBindFramebuffer(GL_FRAMEBUFFER, gBuffer);
  glClearColor(0.0, 0.0, 0.0, 1.0); // keep it black so it doesn't leak into g-buffer
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  gBufferShader.use();
  for (Object obj : Objects)
  {
    ConfigureShaderTransformsAndUniforms();
    obj.Draw();
  }
  // 2. lighting pass: use g-buffer to calculate the scene's lighting
  glBindFramebuffer(GL_FRAMEBUFFER, 0);
  lightingPassShader.use();
  BindAllGBufferTextures();
  SetLightingUniforms();
  RenderQuad();
}
```

延迟渲染的好处在于，所有被计算光照数据的像素必然是最终会在屏幕上显示的像素（因为光照计算是基于 `G-Buffer`）。

延迟渲染的缺点在于， `G-Buffer` 的引入会导致需要额外存储一系列问题，即需要耗费大量的内存。但对于渲染 `G-Buffer` 的开销并不会太大，因为使用 `Multiple render targets（MRT）` 可以同时产生出多张想要的纹理。

同时延迟渲染也不再支持混合以及 MSAA。

# The G-buffer

在一次使用 `Blinn-Phong` 模型的前向的光照计算渲染中，需要用到如下的数据：
- 物体的每一部分在世界空间中的位置，用以计算 `lightDir` 和 `viewDir`
- Diffuse Color，也称为 `albedo`
- 物体顶点的法线向量
- Specular 强度
- 所有光源的位置和颜色
- 摄像机的位置

在延迟渲染时，也都需要上述的数据。其中光源的位置，颜色，摄像机的位置都可以通过 `Uniform` 进行传递。而剩余的部分就需要渲染进 `G-buffer` 中。

即在 `G-buffer` 中理论上需要四张贴图，`FragPos`，`Normal`，`Albedo`，`Specular`。

为了节约开销，可以将 `Albedo` 和 `Specular` 信息使用一张贴图表示，称为 `AlbedoSpec`，其中贴图的 `RGB` 通道表示 `Albedo`，`a` 通道表示 `Specular`。

为了提高计算的精准性，为 `FragPos` 和 `Normal` 申请每个通道 16 bit 的贴图，`AlbedoSpec` 贴图的每个通道仍为 8 bit。

生成渲染 `G-buffer` 的  Framebuffer，以及申请 `FragPos`，`Normal`，`AlbedoSpec` 贴图的过程如下：
```cpp
void GenerateFramebuffer()
{
    glGenFramebuffers(1, &gFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, gFramebuffer);

    unsigned int gPosition, gNormal, gAlbedospec;
    unsigned int depthStencilRBO;

    glGenTextures(1, &gPosition);
    glBindTexture(GL_TEXTURE_2D, gPosition);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA16F, screen_width, screen_height, 0, GL_RGBA, GL_FLOAT, nullptr);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, gPosition, 0);

    glGenTextures(1, &gNormal);
    glBindTexture(GL_TEXTURE_2D, gNormal);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA16F, screen_width, screen_height, 0, GL_RGBA, GL_FLOAT, nullptr);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, GL_TEXTURE_2D, gNormal, 0);

    glGenTextures(1, &gAlbedospec);
    glBindTexture(GL_TEXTURE_2D, gAlbedospec);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, screen_width, screen_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, nullptr);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT2, GL_TEXTURE_2D, gAlbedospec, 0);

    unsigned int attachments[3] = {GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1, GL_COLOR_ATTACHMENT2};
    glDrawBuffers(3, attachments);

    glGenRenderbuffers(1, &depthStencilRBO);
    glBindRenderbuffer(GL_RENDERBUFFER, depthStencilRBO);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, scene.GetWidth(), scene.GetHeight());
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, depthStencilRBO);

    glBindFramebuffer(GL_FRAMEBUFFER, 0);

    gPositionTexture = new Texture(gPosition, screen_width, screen_height);
    gNormalTexture = new Texture(gNormal, screen_width, screen_height);
    gAlbedoTexture = new Texture(gAlbedospec, screen_width, screen_height);
}
```

可以看到 `FragPos`，`Normal`，`AlbedoSpec` 被分别绑定到了 `GL_COLOR_ATTACHMENT0`，`GL_COLOR_ATTACHMENT1` 和 `GL_COLOR_ATTACHMENT2` 上，并使用了 `glDrawBuffers` 制定了 MRT。

渲染 `G-buffer` 时，使用的 Vertex Shader 如下所示：
```glsl
#version 330 core

layout(location = 0) in vec3 pos;
layout(location = 1) in vec2 tex;
layout(location = 2) in vec3 norm;

out vec2 Texcoord;
out vec3 Normal;
out vec3 FragPos;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
    Texcoord = tex;

    vec4 worldPos = model * vec4(pos, 1.0);
    FragPos = worldPos.xyz;

    Normal = normalize(mat3(transpose(inverse(model))) * norm);

    gl_Position = projection * view * worldPos;
}
```

Fragment Shader 如下所示：
```glsl
#version 330 core

layout(location = 0) out vec3 gPoisition;
layout(location = 1) out vec3 gNormal;
layout(location = 2) out vec4 gAlbedoSpec;

in vec2 Texcoord;
in vec3 FragPos;
in vec3 Normal;

uniform sampler2D texture_diffuse0;
uniform sampler2D texture_specular0;

void main()
{
    gPoisition = FragPos;
    gNormal = normalize(Normal);
    gAlbedoSpec.rgb = texture(texture_diffuse0, Texcoord).rgb;
    gAlbedoSpec.a = texture(texture_specular0, Texcoord).r;
}
```

在 Vertex Shader 中，将 `FragPos` 和 `Normal` 都变换到了世界空间，以保证光照计算时空间的统一。

在 Fragment Shader 中定义了三个输出，分别表示 `FragPos`，`Normal`，`AlbedoSpec`纹理。

此时 `FragPos`，`Normal`，`AlbedoSpec` 的 `RGB` 通道及 `A` 通道的渲染结果如下所示：

|                                                                                           |                                                                                           |
| ----------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| ![FragPos](assets/Ch%2033%20Deferred%20Shading/image-20211229083438725.png) | ![Normal](assets/Ch%2033%20Deferred%20Shading/image-20211229083507958.png) |
| ![AlbedoSepc.rgb](assets/Ch%2033%20Deferred%20Shading/image-20211229083606892.png) | ![AlbedoSpec.aaa](assets/Ch%2033%20Deferred%20Shading/image-20211229083702196.png) |

# The deferred lighting pass

在 `Lighting Pass` 中，会使用 G-Buffer 的一系列纹理作为光照计算的输入。

绘制全屏 Quad 时，使用的 Fragment Shader 中需要定义三个 `sampler2D` 分别作为之前 `FragPos`，`Normal`，`AlbedoSpec`的输入，并通过采样这三个纹理获取计算光照时需要的数据，如下所示：

```glsl
uniform sampler2D gPosition;
uniform sampler2D gNormal;
uniform sampler2D gAlbedoSpec;

void main()
{
    vec3 FragPos = texture(gPosition, TexCoords).rgb;
    vec3 Normal = texture(gNormal, TexCoords).rgb;
    vec3 Diffuse = texture(gAlbedoSpec, TexCoords).rgb;
    float Specular = texture(gAlbedoSpec, TexCoords).a;
    // ...
}
```

另外，在 Fragment Shader 中，还定义了一个 Lights 数组，表示一系列点光源的输出：
```glsl
struct Light
{
    vec3 Position;
    vec3 Color;

    float Linear;
    float Quadratic;
};

const int NR_LIGHTS = 32;
uniform Light lights[NR_LIGHTS];
uniform vec3 viewPos;

void main()
{
    vec3 FragPos = texture(gPosition, TexCoords).rgb;
    vec3 Normal = texture(gNormal, TexCoords).rgb;
    vec3 Diffuse = texture(gAlbedoSpec, TexCoords).rgb;
    float Specular = texture(gAlbedoSpec, TexCoords).a;

    vec3 lighting = Diffuse * 0.1;
    vec3 viewDir = normalize(viewPos - FragPos);

    for (int i = 0; i != NR_LIGHTS; ++i)
    {
        // diffuse
        vec3 lightDir = normalize(lights[i].Position - FragPos);
        vec3 diffuse = max(dot(Normal, lightDir), 0.0) * Diffuse * lights[i].Color;

        // specular
        vec3 halfwayDir = normalize(lightDir + viewDir);
        float spec = pow(max(dot(Normal, halfwayDir), 0.0), 16.0);
        vec3 specular = spec * Specular * lights[i].Color;

        float distance = length(lights[i].Position - FragPos);
        float attenuation = 1.0 / (1.0 + lights[i].Linear * distance + lights[i].Quadratic * distance * distance);
        diffuse *= attenuation;
        specular *= attenuation;

        lighting += diffuse + specular;
    }

    FragColor = vec4(lighting, 1.0);
}
```

在 C++ 部分，需要在绘制 Lighting Pass 的 Quad 前激活三张纹理：
```cpp
scene.postRender = []()
{
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    screenMeshRender->GetMaterial()->AddTexture("gPosition", gPositionTexture);
    screenMeshRender->GetMaterial()->AddTexture("gNormal", gNormalTexture);
    screenMeshRender->GetMaterial()->AddTexture("gAlbedoSpec", gAlbedoTexture);
    
    // ...
};
```

在定义场景时需要随机生成一系列表示点光源的数据：
```cpp
const unsigned int NR_LIGHTS = 32;
srand(13);
for (unsigned int i = 0; i != NR_LIGHTS; ++i)
{
    // calculate slightly random offsets
    float xPos = ((rand() % 100 / 100.0f) * 6.0 - 3.0);
    float yPos = ((rand() % 100 / 100.0f) * 6.0 - 4.0);
    float zPos = ((rand() % 100 / 100.0f) * 6.0 - 3.0);
    lightPosition.push_back(bagPosBias + vec3(xPos, yPos, zPos));

    float rColor = (rand() % 100 / 200.0f) + 0.5f;
    float gColor = (rand() % 100 / 200.0f) + 0.5f;
    float bColor = (rand() % 100 / 200.0f) + 0.5f;
    lightColors.push_back(vec3(rColor, gColor, bColor));
}
```

在绘制 Light Pass Quad 前，将这些数据传递给 Shader，同时也需要将摄像机的位置作为光照的 `viewPos` 传入：
```cpp
scene.postRender = []()
{
    // ...

    for (unsigned int i = 0; i != lightPosition.size(); ++i)
    {
        screenMeshRender->GetMaterial()->GetShader()->SetVec3("lights[" + std::to_string(i) + "].Position", lightPosition[i]);
        screenMeshRender->GetMaterial()->GetShader()->SetVec3("lights[" + std::to_string(i) + "].Color", lightColors[i]);
        screenMeshRender->GetMaterial()->GetShader()->SetFloat("lights[" + std::to_string(i) + "].Linear", 0.7);
        screenMeshRender->GetMaterial()->GetShader()->SetFloat("lights[" + std::to_string(i) + "].Quadratic", 1.8);
    }
    screenMeshRender->GetMaterial()->GetShader()->SetVec3("viewPos", camera->GetTransform()->GetPosition());
    screenMeshRender->DrawMesh();
};

```

此时的渲染结果如下所示，可以看到所有的模型被正常的点亮：
![|500](assets/Ch%2033%20Deferred%20Shading/image-20211231083201155.png)

在 Deferred Lighting 渲染中，所有需要显示的物体需要首先被绘制在 `G-Buffer ` 中，再通过 Lighting Pass 添加光照效果。但这会引起两个问题：
1. 无法绘制不被光照效果影响的物体，如无法绘制表示光源的 Cube。如果将 Cube 放置在 `G-Buffer` 中，即变为了光源本身被光照影响，显然不合理。
2. 所有的被渲染物体都必须使用相同的光照模型和参数，这是因为所有被渲染的物体都是统一在 Lighting Pass 阶段被上色。

第二个问题可以通过在 Lighting Pass 中添加更多的数据来一定程度规避。第一个问题则需要通过通过结合 `Deferred Rendering` 及 `Forward Rendering` 实现。即将场景中大部分物体通过延迟渲染的前提下，将一些不适合延迟渲染的物体（如例子中的光源 Cube）通过前向渲染绘制。

# Combining deferred rendering with forward rendering

结合 `Forward Rendering` 和 `Deferred Rendering` 的最简单的方法，就是在渲染完使用 G-Buffer 的整个屏幕的 Quad 后再使用 Forward Rendering。

示例代码如下所示：
```cpp
scene.postRender = []()
{
    glDisable(GL_DEPTH_TEST);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    // ...
    screenMeshRender->DrawMesh();
    
   glEnable(GL_DEPTH_TEST);


    for (unsigned int i = 0; i != lightGOs.size(); ++i)
    {
        colorShader->SetVec3("baseColor", lightColors[i]);
        lightGOs[i]->GetMeshRender()->Update();
    }
};

```

需要注意的是，此时在 `PostRender` 中需要首先关闭深度检测。否则的话，在绘制了全屏的 Quad 后，之后表示 Lighting 的 Cube 就会因为深度测试不够而失败。

此时的结果如下所示，可以看到所有的 Cube 都显示在了模型之上，并没有正确的正当关系，因为： 
![|500](assets/Ch%2033%20Deferred%20Shading/image-20220102182816556.png)

为了解决这个问题，需要将 `GBuffer` 中的深度缓冲拷贝到 Default Framebuffer 中再进一步绘制，这样所有被绘制的 Cube 都能正常的进行深度检测。

```cpp
scene.postRender = []()
{
    glDisable(GL_DEPTH_TEST);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    // ...
    screenMeshRender->DrawMesh();

    glEnable(GL_DEPTH_TEST);
    glBindFramebuffer(GL_READ_FRAMEBUFFER, gFramebuffer);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
    glBlitFramebuffer(0, 0, screen_width, screen_height, 0, 0, screen_width, screen_height, GL_DEPTH_BUFFER_BIT, GL_NEAREST);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

    for (unsigned int i = 0; i != lightGOs.size(); ++i)
    {
        colorShader->SetVec3("baseColor", lightColors[i]);
        lightGOs[i]->GetMeshRender()->Update();  // Directly draw light pos
    }
};

```

此时的效果如下，可以看到 Cube 与 模型间的遮挡关系正常：
![|500](assets/Ch%2033%20Deferred%20Shading/image-20220103140503675.png)

# A larget number of lights

对于有大量的光源的情况下，使用 `Deferred Rendering` 虽然能一定程度的节约性能，但还是很可能出现卡顿。

因为在 `Defrred Rendering` 使用的 Shader 中，仍然会计算所有光源对光照的贡献。但实际上，有许多的光源离 Fragment 太远，并不会对最后的效果产生任何的贡献。

为了解决这个问题，引入了 `体积光（Light Volume）` 的概念，即每个光源都有一个自己的一个体积范围。对于 Fragment 而言，仅当它处在某个光源的体积范围内，才需要计算这个光源的贡献。  

## Calculating a light's volume 

计算光源体积光的方法就是求解光源 [衰减](Ch%2014%20%20Light%20Casters,%20Multiple%20Lights.md#衰减) 为 0 时的距离，即衰减公式为：

$$
F_{a t t}=\frac{I_{max}}{K_{c}+K_{l} * d+K_{q} * d^{2}}
$$

这个表达式无法求得一个值让表达式正好等于 0 ，因此只需要让表达式等于一个接近 0 的数，此时光源的贡献也近乎于 0 ，即人无法感知到光源的贡献。 在下述例子中，将该接近 0 的数设为 $\frac{5}{256}$。

```ad-note
求解的数，越接近 0，求得的 Distance 也就越大，耗费更多的性能。但如果取值太大，求得的 Distance 过小，就能看到明显的光照边界。
```

求解的过程如下所示：
$$
\begin{aligned}
&\frac{5}{256}=\frac{I_{max}}{k_{c}+k_{1} \cdot d+k_{q} \cdot d^{2}} \\
&k_{q} \cdot d^{2}+k_{1} \cdot d+k_{c}-\frac{256}{5} * I_{max}*=0 \\
&d=\frac{-k_{1}+\sqrt{k_{1}^{2}-4 k_{q}\left(k_{c}- I_{max}* \frac{256}{5}\right)}}{2 * k_{q}}
\end{aligned}
$$

上述过程转换为计算代码即为：
```cpp
float lightConstant = 1.0;
float lightLinear = 0.7f;
float lightQuadratic = 1.8f;

float lightMax = std::fmaxf(std::fmaxf(color.r, color.g), color.b);
float radius = (-lightLinear + std::sqrtf(lightLinear * lightLinear - 4 * lightQuadratic * (lightConstant - (256.0f / 5.0f) * lightMax))) /
                       2 * lightQuadratic;
```

对 Shader 的改动如下所示：
```glsl
struct Light
{
    // ...
    float Radius;
};

void main()
{
    for (int i = 0; i != NR_LIGHTS; ++i)
    {
        float distance = length(lights[i].Position - FragPos);
        if (distance < lights[i].Radius)
        {
            // lighting calculation
        }
    }
    
    FragColor = vec4(lighting, 1.0);
}

```

## How we really use light Volums

在 GPU 中，Shader 中的语句都是并行执行的，且 GPU 要求所有的运行 Shader 代码的核需要执行相同的代码。

因此在 Shader 中 If 语句的每个 Case 都会被执行，只不过不符合条件的 Case 的结果会被舍弃，也因此上述通过 If 语句的代码优化很可能效果有限。

另一种更高效的解决方法是在 `Lighting Pass` 阶段不再绘制铺满屏幕的 Quad，而是绘制一系列以光源位置为中心，以求得的 Attenuation Radius 作为半径的球。

绘制球的 Shader 统一使用 `GBuffer` 作为输入，但在光照中仅计算该球所表示的光源的贡献。将一系列球绘制的结果叠加在一起即为最终的结果。示意图如下所示：

![](assets/Ch%2033%20Deferred%20Shading/image-20220103212954596.png)

```ad-note
使用这种方法绘制时，需要开启 Face Culling，否则的话所有的像素会被重复计算两次。开启 Face Culling 后应当绘制球的 Back face，否则的话当进入某个球的内部时，该球的色彩贡献就不会被正常绘制。
```

# Deferred rendering vs Forward Rendering

`Deferred Rendering` 让屏幕上的每一个像素都运行一次关于光照的计算，相对于 `Forward Rendering` 中让每个 Fragment Shader 都需要计算光照，节省了较多德军i算。但同时 `Deferred Rendering` 耗费了更多的内存，无法使用 MSAA 和 Blending。

当在一个简单场景且没有太多光源的情况下，`Deferred Rendering` 并不能提升很多的性能，有时甚至会降低效率。但在负责场景下，`Deferred Rendering` 则会带来巨大的优化，且在使用其他后处理计算时也可以依赖 `G-Buffer` 带来更多的性能提升。

