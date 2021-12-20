---
created: 2021-12-20
updated: 2021-12-20
---
[Shadow Mapping](LearnOpenGL-Ch%2027%20Shadow%20Mapping.md) 中计算的是光源向一个方向照射时（方向光或聚光灯）产生的阴影，如下图所示：

![](assets/LearnOpenGL-Ch%2028%20Point%20Shadows/Untitled%202.png)

在这种情况下，阴影贴图可以通过一个位置与光源位置相同， `LookAt` 方向为光源方向的摄像机渲染得到，且阴影贴图是一张 `Texture 2D` 且称为 `Directional Shadow mapping` 。

对于点光源而言，它的照射方向是朝四面八方的，因此渲染深度贴图时无法使用单一的 `LookAt` 方向，如下图所示：
![](assets/LearnOpenGL-Ch%2028%20Point%20Shadows/Untitled%201.png)

这种情况下的阴影被称为 `Point Shadow` 。 `Point Shadow` 的计算过程与 [Shadow Mapping](LearnOpenGL-Ch%2027%20Shadow%20Mapping.md) 中计算阴影的方式基本相同，只不过需要用 Cubemap 替代 Texture2D 作为阴影贴图，该阴影贴图被称为 `Depth Cubemap` 或 `Omonidirectional shadow mapping` 。

# Generating the depth cubemap

因为需要将深度信息渲染到 Cubemap 中，最容易想到的方法就是使用六次绘制命令，每次采用不同的 `LookAt` 方向，每次绘制对应 Cubemap 的一个面，伪代码如下所示：

```cpp
for(unsigned int i = 0; i < 6; i++)
{
    GLenum face = GL_TEXTURE_CUBE_MAP_POSITIVE_X + i;
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, face, depthCubemap, 0);
    BindViewMatrix(lightViewMatrices[i]);
    RenderScene();
}
```

还有一种方法是利用 [Geometry Shader](LearnOpenGL-Ch%2022%20Geometry%20Shader.md) ，通过一次绘制命令就能直接将深度信息写入到Cubemap 的六个面中。该方法将六个不同的 `LookAt` 方向（对应 Cubemap 的每个面）传入到 Geometry Shader 中，并将输入的三角形与这六个 `LookAt` 方向相乘，得到六个新的三角形。即可以理解为，使用这六个不同的 `LookAt` 方向将一个三角形转换到以 Cubemap 的每一个面作为屏幕坐标的坐标系中。

以下是使用 [Geometry Shader](LearnOpenGL-Ch%2022%20Geometry%20Shader.md) 方法渲染 `Depth Cubemap` 的具体步骤：

## Generate cubemap

第一步是如创建一个 Cubemap，步骤与在 [Cubemaps](LearnOpenGL-Ch%2020%20Cubemaps.md) 中描述的类似：

```cpp
glGenTextures(1, &depthCubemap);
glBindTexture(GL_TEXTURE_CUBE_MAP, depthCubemap);
for (int i = 0; i != 6; ++i)
{
    glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, GL_DEPTH_COMPONENT, shadow_width, shadow_height, 0, GL_DEPTH_COMPONENT, GL_FLOAT, nullptr);
}
glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);
glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_BORDER);
```

然后将其绑定到 Framebuffer 上，需要注意的是，因为这里要绑定的对象是 Cubemap 而不是 Texture2D，因此应当使用函数 `glFramebufferTexture` 而不是 `glFramebufferTexture2D` 。另外如同在 [Shadow Mapping](LearnOpenGL-Ch%2027%20Shadow%20Mapping.md) 中提到的，因为绑定的 Framebuffer 没有颜色缓冲 ，即绑定的 Framebuffer是不完整的，因此需要将 `DrawBuffer` 和 `ReadBuffer` 设定为 `GL_NONE` ：

```cpp
glGenFramebuffers(1, &depthMapFBO);
glBindFramebuffer(GL_FRAMEBUFFER, depthMapFBO);
glFramebufferTexture(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, depthCubemap, 0);
glDrawBuffer(GL_NONE); // As the depth map framebuffer do not have color attachment, thus it is required to set draw/read buffer to null
glReadBuffer(GL_NONE);
glBindFramebuffer(GL_FRAMEBUFFER, 0);
```

## Light Space transform

如在 [Shadow Mapping](LearnOpenGL-Ch%2027%20Shadow%20Mapping.md) 的最后所述，点光源的深度贴图渲染需要用到透视投影，因此需要首先求得透视投影的 Projection 矩阵：
```cpp
float near = 1.0f;
float far = 25.0f;
glm::mat4 shadowProject = glm::perspective(glm::radians(90.0f), aspect, near, far);
```

使用 `glm::lookAt` 方法求得 View 矩阵，为了渲染到 Cubemap 的六个面上，因此需要六个不同的 View 矩阵。将这六个 View 矩阵与 Projection 矩阵相乘的结果存储到 `vector` 容器中：

```cpp
std::vector<glm::mat4> shadowTransforms;
shadowTransforms.push_back(shadowProject *glm::lookAt(lightPos, lightPos + glm::vec3(1, 0, 0), glm::vec3(0, -1, 0)));  // Right
shadowTransforms.push_back(shadowProject *glm::lookAt(lightPos, lightPos + glm::vec3(-1, 0, 0), glm::vec3(0, -1, 0))); // Left
shadowTransforms.push_back(shadowProject *glm::lookAt(lightPos, lightPos + glm::vec3(0, 1, 0), glm::vec3(0, 0, 1)));   // Top
shadowTransforms.push_back(shadowProject *glm::lookAt(lightPos, lightPos + glm::vec3(0, -1, 0), glm::vec3(0, 0, 1)));  // Bottom
shadowTransforms.push_back(shadowProject *glm::lookAt(lightPos, lightPos + glm::vec3(0, 0, 1), glm::vec3(0, -1, 0)));  // Back
shadowTransforms.push_back(shadowProject *glm::lookAt(lightPos, lightPos + glm::vec3(0, 0, -1), glm::vec3(0, -1, 0))); // Front
```