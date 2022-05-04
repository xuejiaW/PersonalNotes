---
cssclass: [table-border]
created: 2021-12-22
updated: 2022-03-11
tags:
    - OpenGL
---
# Overview

对光源增加光辉（Glow）的效果，增加光辉效果的后处理称为 `Bloom` ，下图为增加了和未增加 `Bloom` 效果的对比：
![](assets/Ch%2032%20Bloom/Untitled.png)

实现 `Bloom` 的算法主要分为三步：

1.  渲染场景得到两张图：场景内高亮部分的渲染结果（记为 $a$ 图）， 整个场景（包括高亮）的渲染结果（记为 $b$ 图）
2.  将 $a$ 图进行模糊处理，得到模糊后的高亮部分渲染结果（记为 $c$ 图）
3.  将模糊后的高亮部分渲染图，与原完整场景的渲染图进行混合，得到最终图（记为 $d$ 图）

整个流程的示意图如下：
![](assets/Ch%2032%20Bloom/Untitled%201.png)

```ad-note
通常 `Bloom` 效果需要与 HDR 配合使用。因为对于高亮部分的区分，通常需要通过阈值的判断，即最终亮度大于某个值时，则认为是高亮部分。

只有在使用了 HDR 时，才能根据真实的亮度并选择阈值。否则所有的亮度值都被裁剪到 $0 \sim 1$ 的范围，即阈值必须小于等于 $1$ 。
```

# Multiple Render Targets（MRT）

在上述步骤的第一步中，需要生成两张渲染结果。为了得到两张图，最直观的方法是使用两个 Framebuffer，每个 Framebuffer 使用不同的 Shader，通过两次渲染得到需要的图。但更高效的做法是使用 `Multiple Render Targets（MRT）` 方法，仅使用一个 Framebuffer 和它对应的 Shader ，通过一次渲染直接得到需要的图。

当使用 `MRT` 方法是，在 Fragment Shader 中需要指定两个像素颜色的输出，并且通过 `layout` 来区分这两个输出，如下所示：

```glsl
layout (location = 0) out vec4 FragColor;
layout (location = 1) out vec4 BrightColor;
```

其中 `locaition = 0` 的输出对应 Framebuffer 中的 `GL_COLOR_ATTACHMENT0` ，同理 `location = 1` 的输出对应 `GL_COLOR_ATTACHMENT` ，并以此类推。

因此，使用 `MRT` 的 Framebuffer 需要绑定两个 Color Attachment，如下所示：

```cpp
glBindFramebuffer(GL_FRAMEBUFFER, hdrFBO);
for (int i = 0; i != 2; ++i)
{
    glBindTexture(GL_TEXTURE_2D, colorBuffers[i]);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA16F, scene.GetWidth(), scene.GetHeight(), 0, GL_RGBA, GL_FLOAT, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glBindTexture(GL_TEXTURE_2D, 0);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + i, GL_TEXTURE_2D, colorBuffers[i], 0);
}
```

OpenGL 默认的是仅渲染 Color Attachment 0，因此需要显式的告知 OpenGL 目前要渲染 Color Attachments 0 与 Color Attachment 1：

```cpp
unsigned int attachments[2] = {GL_COLOR_A7TTACHMENT0, GL_COLOR_ATTACHMENT1};
glDrawBuffers(2, attachments); // Tell OpenGL that this framebuffer needs draw two color attachment
```

在片段着色器中通过将像素转换为灰度图，并将灰度数值大于 $1.0$ 的像素认为是高亮部分，将高亮部分输出到 `BrightColor` 中，并将所有部分输出到 `FragColor` 中，如下所示：

```glsl
float brightness = dot(lighting,vec3(0.2126, 0.7152, 0.0722));
if(brightness > 1.0)
    BrightColor = vec4(lighting,1.0);
else
    BrightColor = vec4(0.0, 0.0, 0.0, 1.0);

FragColor = vec4(lighting, 1.0);
```

```ad-note
在本章节中，是将纹理以 `SRGB` 空间解析的，因此将 `RGB` 通道转换为灰度图的公式为： $Y= 0.2126_R+0.7152_G+0.0722*B$

如果是在非 `sRGB` 空间下，则转换公式为： $Y= 0.299_R+0.587_G+0.114*B$
```

使用如上方法，最终渲染出的 $a$ 图和 $b$ 图分别如下所示：

|                                                                   |                                                                   |
| ----------------------------------------------------------------- | ----------------------------------------------------------------- |
| ![(a)](assets/Ch%2032%20Bloom/Untitled%202.png) | ![(b)](assets/Ch%2032%20Bloom/Untitled%203.png) |

# Gaussian Blur

在 [Framebuffers](Ch%2019%20Framebuffers.md)  的后处理部分中说明了对生成图像进行 [模糊处理](Ch%2019%20Framebuffers.md#后处理) 的办法，该方法是对一个像素和它周围的8个像素，一共9个像素进行加权平均，并将平均值作为该像素新的颜色。

这里介绍一个更高级的模糊处理方法，称为 `Gaussian 模糊` ，其主要思路是使用一个 `Gaussian 曲线` 对像素进行模糊处理。 `Gaussian 曲线` 通常形状是一个钟形曲线，如下图所示，该曲线表示越接近中心的点，其权重越大：
![|400](assets/Ch%2032%20Bloom/Untitled%204.png)

```ad-tip
`Bloom` 效果的好坏主要取决于 `Blur` 效果的好坏。
```

因为最终需要应用 `Gaussian 曲线` 的是二维的图片，所以对单一像素一共需要进行两次 `Gaussian 模糊` 处理，即一次水平方向的模糊处理，一次垂直方向的模糊处理，如下所示：
![](assets/Ch%2032%20Bloom/Untitled%205.png)

因此应用 `Gaussian 模糊` 需要两个 Framebuffer，下称为 `FboA` 和 `FboB` 。主要实现思路为，先将需要进行模糊处理的图（本例中为 $a$ 图）作为 `FboA` 的输入，对 $a$ 图进行水平方向的模糊，再将水平模糊后的输出作为 `FboB` 的输入，对水平模糊后的图再进行垂直方向的模糊，至此就得到经过了 `Gaussian 模糊` 的图。创建 `FboA` 和 `FboB` 并实现 `Gaussian 模糊` 的代码如下：

```cpp
// Generate Framebuffer
glGenFramebuffers(2, pingpongFBO);
glGenTextures(2, pingpongColorBuffers);
for (int i = 0; i != 2; ++i)
{
    glBindTexture(GL_TEXTURE_2D, pingpongColorBuffers[i]);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA16F, scene.GetWidth(), scene.GetHeight(), 0, GL_RGBA, GL_FLOAT, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE); // Clamp to the edge as the blur filter would otherwise sample repeated texture values!
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);

    glBindFramebuffer(GL_FRAMEBUFFER, pingpongFBO[i]);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, pingpongColorBuffers[i], 0);

    // There is no depth and stencil buffer bound, and the frame buffer is still complete
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
        std::cout << "ERROR:: Pingpong Framebuffer is not complete!" << std::endl;
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

// ...

// Using two framebuffers to apply Gaussian Blur
bool horizontal = true;
for (unsigned int i = 0; i != 10; ++i)
{
    glBindFramebuffer(GL_FRAMEBUFFER, pingpongFBO[horizontal]);

    blurMeshRender->GetMaterial()->GetShader()->SetInt("horizontal", horizontal);
    if (i == 0)
        blurMeshRender->GetMaterial()->SetTexture(0, brightColor);
    else
        blurMeshRender->GetMaterial()->SetTexture(0, pingpongColor[!horizontal]);
    blurMeshRender->DrawMesh();

    horizontal = !horizontal;
}
```

```ad-note
上示代码中，为了得到更好的模糊效果，使用 for 循环对图像进行了多次 `Gaussian 模糊` 。
```

应用 `Gaussian 模糊` 的片段着色器如下所示，其中通过 `horizontal` 标志区分当前渲染是进行水平方向的模糊，还是垂直方向的模糊：

```glsl
uniform bool horizontal;
uniform float weight[5] = float[] (0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162);

void main()
{
    vec2 texelSize = 1.0 / textureSize(brightColor, 0); // gets size of single texel
     vec3 result = texture(brightColor, TexCoords).rgb * weight[0];
     if(horizontal)
     {
         for(int i = 1; i < 5; ++i)
         {
            result += texture(brightColor, TexCoords + vec2(texelSize.x * i, 0.0)).rgb * weight[i]; // Right part
            result += texture(brightColor, TexCoords - vec2(texelSize.x * i, 0.0)).rgb * weight[i]; // Left part
         }
     }
     else
     {
         for(int i = 1; i < 5; ++i)
         {
             result += texture(brightColor, TexCoords + vec2(0.0, texelSize.y * i)).rgb * weight[i]; // Up part
             result += texture(brightColor, TexCoords - vec2(0.0, texelSize.y * i)).rgb * weight[i]; // Down Part
         }
     }

     FragColor = vec4(result, 1.0);
}
```

图 $a$ 经过 `Gaussian 模糊` 的得到的图 $c$ 如下所示：
![(c)](assets/Ch%2032%20Bloom/Untitled%206.png)

## Blending both Textures

最终将目标 Framebuffer 切换为 Default Framebuffer，并在片段着色器中将 $c$ 图 和 $b$ 图进行叠加（并非是 [Blending](Ch%2017%20Blending.md) ） ，Shader 中叠加的代码如下：

```glsl

vec3 hdrColor = texture(screenTexture, TexCoords).rgb;
if(usingBloom)
{
   vec3 bloomColor = texture(blurredBrightColor,TexCoords).rgb;
   hdrColor += bloomColor;
}
```

最后叠加得到的图，如下所示：
![](assets/Ch%2032%20Bloom/Untitled%207.png)


# 源码：

[main.cpp](https://www.notion.so/main-cpp-3566af2a887443b2892e1e49749aa950)

渲染得到图 $a$ 和图 $b$：

[object.vs](https://www.notion.so/object-vs-1d763a0fc7fd44acbfed3b302c4d8f4a)

[object.fs](https://www.notion.so/object-fs-e71bfc4195664cb5ad80e060d2d761fa)

对图 $a$ 进行模糊操作得到图 $c$：

[postProcessing.vs](https://www.notion.so/postProcessing-vs-19d3be31053d461e8409e9c23fed42b7)

[blur.fs](https://www.notion.so/blur-fs-7403576398c04be68bfba9f99fa4396c)

将图 $a$ 和图 $c$ 进行叠加：

[finalOutput.fs](https://www.notion.so/finalOutput-fs-537715e97d8b4b11aab28cdfbbe86c4c)