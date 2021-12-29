---
created: 2021-12-27
updated: 2021-12-29
tags:
    - OpenGL
---
# Overview

之前进行的渲染都称为 ` 前向渲染（Forward Rendering / Forward Shading）。在前向渲染中对于场景内的每个物体，在它们的着色器中都需要对场景内的每个光照都进行计算，如 [Light Casters, Multiple Lights](Learn%20OpenGL%20-%20Ch%2014%20%20Light%20Casters,%20Multiple%20Lights.md) 即为典型的前向渲染计算。

延迟渲染（Deferred Rendering / Deferred Shading）技术的主要目的就是为了优化场景内存在大量光照时的性能。

延迟渲染主要被拆分为两部分：
1.  Geometry Pass：渲染一次场景并将所有得到的关于场景内物体的几何信息存储到一系列称为 `G-buffer` 的纹理中，比如位置，法线，颜色，高光等等。
2.  Lighting Pass：渲染一个铺满屏幕的 Quad，在这次渲染中使用上 `Geometry Pass ` 生成的 `G-Buffer`

整体的流程如下所示：
![](assets/Learn%20OpenGL%20-%20Ch%2033%20Deferred%20Shading/image-20211227082817485.png)

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
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, screen_width, screen_height, 0, GL_RGBA, GL_FLOAT, nullptr);
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
| ![](assets/Learn%20OpenGL%20-%20Ch%2033%20Deferred%20Shading/image-20211229083438725.png) | ![](assets/Learn%20OpenGL%20-%20Ch%2033%20Deferred%20Shading/image-20211229083507958.png) |
|    ![](assets/Learn%20OpenGL%20-%20Ch%2033%20Deferred%20Shading/image-20211229083606892.png)

                                                                                       |                                                   u                                        |
|                                                                                           |                                                                                           |