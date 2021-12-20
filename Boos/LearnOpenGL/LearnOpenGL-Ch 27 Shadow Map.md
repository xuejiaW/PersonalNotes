目前在使用光栅化的实时渲染中仍然没有完美的生成阴影的方法，众多方法中相对容易实现又有比较 好的效果的方法为 ` 阴影贴图（Shadow Mapping）`。

# 阴影贴图（Shadow Mapping）

阴影贴图的思路为从光源的位置作为观察方向，记录下所有能看到的点（即从光源出发的每条射线与各平面相交的最近点），那些看不到的点就必然在这个光源产生的阴影之中。如下所示，其中蓝色的线段为所能看到的点，黑色的线段表示在阴影中的部分。
![](assets/LearnOpenGL-Ch%2027%20Shadow%20Map/Untitled.png)

为了达到记录离光源最近点的效果，可以将摄像机移至光源的位置进行渲染，渲染得到的深度缓冲即为离光源所能看到的所有点的深度值。将这个深度缓冲称为 深度贴图（Depth Map） 或 阴影贴图（Shadow Map），如下图的左半部分所示：
![](assets/LearnOpenGL-Ch%2027%20Shadow%20Map/Untitled%201.png)

之后再从正常的视角方向渲染界面，得到每个点的深度值，如得到上右图中的 $P$ 点深度值。但目前得到的深度值是从摄像机出发渲染得到的，而在 ` 深度贴图 ` 中的深度值则是从光源位置出发得到的。

因此需要将 $P$ 点深度值进行一个坐标转换，将其转换到由光源出发计算得到的深度值。假设这个转换为 $T(P)$，而转换后得到的深度值为 $0.9$ ，因为 $0.9 >0.4$ ，所以点 $P$ 处在阴影中。

概括来说，阴影贴图产生阴影的步骤主要分为两步：

1.  从光源位置出发渲染场景，得到深度贴图
2.  正常从摄像机位置出发渲染场景，得到每个点的深度值，将深度值转换到从光源出发的空间。将转换后每个点的值与第一步中对应点的深度值进行比较，如果比它更大，则说明该点处在阴影中。

# 生成深度贴图（Depth Map）

## 渲染深度贴图

为了生成深度贴图，首先要生成一个帧缓冲和一张纹理，注意此时的纹理类型为 `GL_DEPTH_COMPONENT`：

```cpp
// 生成帧缓冲
GLuint depthMapFBO = -1;
glGenFramebuffers(1, &depthMapFBO);

// 生成深度贴图
GLuint texDepthMapDepthBuffer = -1;
glGenTextures(1, &texDepthMapDepthBuffer);
glBindTexture(GL_TEXTURE_2D, texDepthMapDepthBuffer);
glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, 512, 512, 0, GL_DEPTH_COMPONENT, GL_FLOAT, nullptr);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
```

然后将生成的纹理绑定至帧缓冲上，但因为这里仅生成了深度附件，因此即使将纹理绑定到了帧缓冲后，帧缓冲仍然是不完整的。所以需要显示的告诉 OpenGL，这里并不需要渲染任何的颜色数据，可以通过将 `DrawBuffer` 和 `ReadBuffer` 都设为 `GL_None` 来实现该目的：

```cpp
glBindFramebuffer(GL_FRAMEBUFFER, depthMapFBO);
glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, texDepthMapDepthBuffer, 0);
glDrawBuffer(GL_NONE); // As the depth map framebuffer do not have color attachment, thus it is required to set draw/read buffer to null
glReadBuffer(GL_NONE);
glBindFramebuffer(GL_FRAMEBUFFER, 0);
```

为了从光源位置出发渲染深度贴图，需要为渲染深度贴图定义特殊的着色器。

首先是顶点着色器，此时的顶点着色器不需要考虑顶点的法线，纹理坐标，颜色等信息，因为这里只需要渲染深度，因此唯一需要考虑的就是顶点的位置：

```glsl
uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

void main()
{
    gl_Position = projection * view * model * vec4(pos, 1.0);
}
```

但顶点着色器中，仍然还是要进行坐标转换。只是这里的 `View` 矩阵表示的是光源的位置，且 `Projection` 矩阵使用的是正交矩阵：

``` ad-tip
关于为什么这里要使用正交投影，可以看后续部分的解释
```

```cpp
// The model is setting by MeshRender as normal
glm::mat4 projection = glm::ortho(-10.0f, 10.0f, -10.0f, 10.0f, 1.0f, 7.5f);
glm::mat4 view = glm::lookAt(lamp->GetTransform()->GetPosition(), glm::vec3(0.0f), glm::vec3(0, 1, 0));
drawDepthMapping->SetMat4("projection", projection)->SetMat4("view", view);
```

对于片段着色器，由于不需要输出颜色，因此可以直接为空：

```glsl
void main() { }
```

因此，要将场景渲染到深度贴图的步骤如下，其中需要注意的是为了适配深度贴图的尺寸，需要对应的修改 `Viewport` ：

```cpp
glEnable(GL_DEPTH_TEST);
drawDepthMapShader->Use();
// The model is setting by MeshRender
glm::mat4 projection = glm::ortho(-10.0f, 10.0f, -10.0f, 10.0f, 1.0f, 7.5f);
glm::mat4 view = glm::lookAt(lamp->GetTransform()->GetPosition(), glm::vec3(0.0f), glm::vec3(0, 1, 0));
drawDepthMapShader->SetMat4("projection", projection)->SetMat4("view", view);

glViewport(0, 0, 512, 512);
glBindFramebuffer(GL_FRAMEBUFFER, depthMapFBO);
glClear(GL_DEPTH_BUFFER_BIT);

scene.Render();
```

至此整个场景的深度信息被渲染到了创建的深度贴图上。

## 展示深度贴图

为了展示深度贴图，需要用一个Quad将它渲染出来。

但因为深度贴图的格式为 `GL_DEPTH_COMPONENT`，所以深度信息用一个 `float` 表示，即所有的深度信息仅在 `RGB` 中的 `R` 通道。为了正确的展示深度贴图，渲染Quad的片段着色器需要修改为：

```glsl
uniform sampler2D depthMap;

void main()
{
    float depthValue = texture(depthMap, TexCoords).r;

    FragColor = vec4(vec3(depthValue), 1.0);
}
```

其余部分与普通的渲染一个有纹理的四边形没有太大区别，只不过要记住之前的 `Viewport` 为了适配深度贴图被调整过，这里需要重新调整回来：

```cpp

// Create Quad Render
screenQuadRender->GetShader()->Use();
Texture *colorComponent = new Texture(texDepthMapDepthBuffer, scene.GetWidth(), scene.GetHeight());
screenQuadRender->GetMaterial()->AddTexture("screenTexture", colorComponent);

glDisable(GL_DEPTH_TEST);
scene.renderingDepthMap = false;
glViewport(0, 0, 1024, 1024);
glBindFramebuffer(GL_FRAMEBUFFER, 0);
screenQuadRender->DrawMesh();
```

## 结果与源码

![|500](assets/LearnOpenGL-Ch%2027%20Shadow%20Map/Untitled%202.png)

[main.cpp](https://www.notion.so/main-cpp-927c29f38c744b26b0fec711353f30af)

[debugDepth.fs](https://www.notion.so/debugDepth-fs-8dda47d6fdd54c9fb1cdfaf571bf858b)

[DrawDepthMapping.fs](https://www.notion.so/DrawDepthMapping-fs-1ea5ed7215da43f7a1c07d4c5c31b084)

[DrawDepthMapping.vs](https://www.notion.so/DrawDepthMapping-vs-0ddf8a58a6a34dc0a9089000b0c13b37)