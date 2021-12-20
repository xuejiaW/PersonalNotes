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