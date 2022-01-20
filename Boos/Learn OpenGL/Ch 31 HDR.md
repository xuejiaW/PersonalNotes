---
cssclass: [table-border]
created: 2021-12-21
updated: 2022-01-20
tags:
    - OpenGL
---
默认在 Framebuffer 中，亮度和颜色都会被 Clamp 到 $0.0 \sim 1.0$ 的范围中，这就会导致当多个光源的亮度叠加，且总亮度大于 $1.0$ 时，都会被 Clamp 到 $1.0$ ，即都显示为白色，这样就丢失了大量的信息。

`High Dynamic Range(HDR)` 的思路就是临时让亮度和颜色的范围大于 $1.0$，保留各种光亮信息，然后再通过后处理将其转换到 `Low Dynamic Range(LDR)` ，即 $0.0 \sim 1.0$ 的范围。将图像数值从 `HDR` 转换到 `LDR` 的过程称为 `Tone Mapping`，有各种不同的 `Tone Mapping` 算法，它们的目的都是在转换过程中尽量的保有更多的信息。

```ad-tip
无论是 OpenGL 默认的 Clamp 还是自定义的 `Tone Mapping` 算法，都是将图像数值从 `HDR` 转换到 `LDR` 。只不过 `Tone Mapping` 算法目的是在转换过程中尽可能多的保留有信息。
```

```ad-note
在实时渲染中， `HDR` 的存在让光源可以以其真实的强度被设置，如太阳的亮度可以被设置为 $100$，而普通灯泡的亮度设置为 $0.1$。在没有 `HDR` 的情况下，为了避免过量的光源造成场景一片白，只能降低光源的亮度，但这也就破坏了光照模型的物理真实性。
```

# Floating Point Framebuffers

使用 `HDR` 的思路为先将整个场景渲染到自定义的 Framebuffer 上，再通过 [后处理](Ch%2019%20Framebuffers.md#后处理) 将自定义 Framebuffer 上的颜色附件绘制到默认的 [Default Frambuffer](../../Notes/OpenGL/OpenGL%20-%20Default%20Frambuffer.md) 上，在这个绘制过程中使用 `Tone Mapping` 算法将画面从 `HDR` 转换到 `LDR` 。

```ad-note
因为显示设备是 `LDR` 的，所以最终的输出画面需要是 `LDR` 。
```

但当 Framebuffer 中的颜色附件的数据类型为 `Normalized Fixed-Point` 时（如 `GL_RGB`），OpenGL 会自动将颜色附件的颜色数值转换到 $0.0 \sim 1.0$，即此时后处理的输入（自定义 Framebuffer 的颜色附件）已经是 `LDR` 图像了。

因此实现 `HDR` 的第一步，就是将 Framebuffer 的颜色附件的数据类型转换为 `Floating Point` ，即如 `GL_RGBA16F`， `GL_RGBA32F` 这样的数据类型，如下所示：

```cpp
glGenTextures(1, &texColorBuffer);
glBindTexture(GL_TEXTURE_2D, texColorBuffer);
glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA16F, scene.GetWidth(), scene.GetHeight(), 0, GL_RGBA, GL_FLOAT, NULL);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
glBindTexture(GL_TEXTURE_2D, 0);
glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texColorBuffer, 0);
```

```ad-note
对于 `Floating Point` 数据类型，其后跟的数字是表示每一个通道的数据尺寸。如 `GL_RGBA32F` 是每个通道的数据为 32 bit，而 `GL_RGBA` 是四个通道一共 32 bit，即使用 `GL_RGBA32F` 会消耗 `GL_RGBA` 四倍的内存。

在很多情况下， `GL_RGBA16F` 就足够了。
```

之后使用自定义 Framebuffer 的流程与在 [Framebuffers](Ch%2019%20Framebuffers.md) 中的类似，如下所示，在 `screenMeshRender` 的渲染时会使用后处理：

```cpp
scene.preRender = []() {
		//...

		// Render the scene to custom framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, hdrFBO);
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
};

scene.postRender = []() {
    // Bind custom framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

		// Custom framebuffer's color attachment will be drawn by screenMeshRender
		// And, tone mapping will be applied while drawing
    screenMeshRender->DrawMesh();
};
```

```ad-note
为了保证光照的真实性，整个场景都经过了 [Gamma Correction](Learn%20OpenGL%20-%20Ch%2026%20Gamma%20Correction.md) ，即在 `screenMeshRender` 的 Shader 中会进行 $\frac{1}{2.2}$ 的变换，且在渲染场景内物体的 Shader 中，对于光照的衰弱计算，是以二次项为主导，并且纹理以 `SRGB` 的格式进行读取。
```

展示场景主要是由一个长方形的立方体构成，摄像机在长方体的内部，长方体表现的如同一个管道。在管道的最前端，有一个亮度为 $100$ 的白色灯光，在摄像机附近，有三个亮度在 $0.1$ 附近的颜色不同的灯。场景设置如下所示：

```cpp
lights.push_back(new GO_Cube());
lights[0]->GetTransform()->SetPosition(vec3(0, 0, -11.0f));
lights[0]->GetMeshRender()->GetMaterial()->SetColor(vec3(100, 100, 100));

lights.push_back(new GO_Cube());
lights[1]->GetTransform()->SetPosition(vec3(-1.0f, -0.8f, -1.0f));
lights[1]->GetMeshRender()->GetMaterial()->SetColor(vec3(0.1, 0, 0));

lights.push_back(new GO_Cube());
lights[2]->GetTransform()->SetPosition(vec3(0.8f, 0.5f, -1.0f));
lights[2]->GetMeshRender()->GetMaterial()->SetColor(vec3(0.0, 0.1, 0));

lights.push_back(new GO_Cube());
lights[3]->GetTransform()->SetPosition(vec3(0.0f, -1.0f, -1.0f));
lights[3]->GetMeshRender()->GetMaterial()->SetColor(vec3(0.0, 0, 0.1));

tunnel->GetTransform()->SetScale(vec3(2.5f, 2.5f, 24.0f));
tunnel->GetMeshRender()->GetMaterial()->AddTexture("diffuseTexture", woodTex);
```

当未引入 `Tone Mapping` 时，即使使用了 `Floating Point` ，最终片段着色器的输出颜色还是会被 `Clamp` 到 $0.0 ~\sim 1.0$ 的范围中。效果如下所示，可以看到远处的光亮处几乎是白色一片，信息丢失的很严重：
![](assets/Ch%2031%20HDR/Untitled.png)

# Tone Mapping

## Reinhard Tone Mapping

一个最简单的 `Tone Mapping` 算法是 `Reinhard Tone Mapping` ，该算法的实现如下：

```glsl
const float gamma = 2.2;

vec3 hdrColor = texture(screenTexture, TexCoords).rgb;

// Reinhard Tone Mapping
vec3 mapped = hdrColor / (hdrColor + vec3(1.0));

// Gamma Correction 
mapped = pow(mapped, vec3(1.0 / gamma));
  
FragColor = vec4(mapped, 1.0);
```

该算法的运行的结果如下，可以看到最亮处有了更多的信息：
![](assets/Ch%2031%20HDR/Untitled%201.png)

## Exposure Tone Mapping

可以利用 `Tone Mapping` 实现类似调整曝光度的效果，称为 `Exposure Tone Mapping` 实现如下：

```glsl
const float gamma = 2.2;
const float exposure = 1.0;

vec3 hdrColor = texture(screenTexture, TexCoords).rgb;

// Exposure Tone Mapping
vec3 mapped = vec3(1.0) - exp(-hdrColor * exposure);

// Gamma Correction 
mapped = pow(mapped, vec3(1.0 / gamma));
  
FragColor = vec4(mapped, 1.0);
```

该算法的运行结果如下所示，从左至右分别为 `Exposure` 为 $0.3$，$1$ 和 $5$ 的情况：

|                                                                 |                                                                 |                                                                 |
| --------------------------------------------------------------- | --------------------------------------------------------------- | --------------------------------------------------------------- |
| ![Exposure = 0.3](assets/Ch%2031%20HDR/Untitled%202.png) | ![Exposure = 1](assets/Ch%2031%20HDR/Untitled%203.png) | ![Exposure = 5](assets/Ch%2031%20HDR/Untitled%204.png) |


# 源码：

[main.cpp](https://www.notion.so/main-cpp-15e78baf25fc4c8a97fbbab6adab91c6)

[tunnel.vs](https://www.notion.so/tunnel-vs-a40e0d18dc2e4ab690363f84dbd8a602)

[tunnel.fs](https://www.notion.so/tunnel-fs-9a4889aa95c346808a170b2e4668963d)

[hdr.vs](https://www.notion.so/hdr-vs-6e0a6f37d8f345468806c7470be413c5)

[hdr.fs](https://www.notion.so/hdr-fs-a05d1e522ae246929341d4a88c5d97d6)