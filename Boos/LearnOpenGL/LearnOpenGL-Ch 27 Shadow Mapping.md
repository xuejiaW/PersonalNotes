---
created: 2021-12-20
updated: 2021-12-21
---

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

# 渲染阴影

在得到了 `深度贴图`后，就可以渲染带有阴影的场景了。

在渲染物体的着色器中需要利用生成的 `深度贴图` ，来计算最终生成的像素究竟是处于阴影中还是不处于。

## 顶点着色器改动

顶点着色器如下：
```glsl
#version 330 core

layout(location = 0) in vec3 Pos;
layout(location = 1) in vec2 TexCoords;
layout(location = 2) in vec3 Normal;

out VS_OUT
{
    vec3 FragPos;
    vec3 Normal;
    vec2 TexCoords;
    vec4 FragPosLightSpace;
}
vs_out;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;
uniform mat4 lightSpaceMatrix;

void main()
{
    vs_out.FragPos = vec3(model * vec4(Pos, 1.0));
    vs_out.Normal = transpose(inverse(mat3(model))) * Normal;
    vs_out.TexCoords = TexCoords;
    vs_out.FragPosLightSpace = lightSpaceMatrix * model * vec4(Pos, 1.0);
    gl_Position = projection * view * model * vec4(Pos, 1.0);
}
```

与之前的顶点着色器的差别在于，需要一个新的输入`lightSpaceMatrix` ，该输入表示光源的 `view` 和 `projection` 矩阵相乘的结果。以及一个新的输出： `FragPosLightSpace` ，该输出是 `lightSpaceMatrix` 与物体的 `model` 相乘的结果，即将物体在一个把光源当作摄像机，所表示的摄像机空间中的坐标。

```ad-warning
 `FragPosLightSpace` 等同于之前生成深度贴图时所用的顶点着色器所生成的结果。
```

## 片段着色器：

在片段着色器最后输出时，如果一个像素处在阴影中，则该像素不需要考虑漫反射和镜面反射光，（仍然考虑环境光）：

```glsl
float inShadow = ShaderCalculation(fs_in.FragPosLightSpace);
vec3 lighting = (ambient + (1.0 - inShadow) * (diffuse + specular)) * color;
```

可以看出上述代码中是通过 `ShaderCalculation` 函数来判断像素是否在阴影中，该函数的完整实现如下：

```glsl
float ShaderCalculation(vec4 FragPosLightSpace)
{
    // perform projective divide, the result value range is [-1,1]
    vec3 projCoords = FragPosLightSpace.xyz / FragPosLightSpace.w;
    // The ProjectCoords is in NDC space which value range is [-1,1]
    // change the value range to [0,1] which is equal to the texture coordinate ranges
    projCoords = projCoords * 0.5 + 0.5;
    float closetDepth = texture(depthMap, projCoords.xy).r;

    float currentDepth = projCoords.z;
    return currentDepth > closetDepth ? 1.0 : 0.0;
}
```

该函数做的第一步是将顶点着色器输出的 `FragPosLightSpace` 做投影相除，即用 `w` 对 `xyz` 进行除，相除后的输出才是 NDC空间：

```glsl
vec3 projCoords = FragPosLightSpace.xyz / FragPosLightSpace.w;
```

此时的 `projCoords` 即相当于从光源位置出发去渲染物体，得到的在 NDC 坐标系中的坐标。

```ad-warning
与前面所述， `FragPosLightSpace` 是与生成深度贴图时所采用的顶点着色器生成的结果是相同的。在 `生成深度贴图` 的过程中，当顶点着色器的结果传递到片段着色器时，实际上渲染管线隐式的做了投影相除的操作。
```

又因为现在要从深度贴图中读取出像素的数值（表示一个像素的深度），而 `Texcoord` 的范围是 $0 \sim 1$ 。因此需要对NDC空间 （$-1 \sim 1$）的数值进行转换：

```glsl
projCoords = projCoords * 0.5 + 0.5;
```

此时 `projCoords.xy` 就是从光源位置出发看物体时的 `Texcoord` 空间，所以可以用它来解析深度贴图，解析的结果深度贴图在该点所记录下的深度：

```glsl
float closetDepth = texture(depthMap, projCoords.xy).r;
```

而 `projCoords.z` 即是目前该点从光源位置出发看过去的深度。因此如果 `projCoords.z` 大于 `closetDepth` 则说明这点处于阴影中，否则就不处于。

```glsl
float currentDepth = projCoords.z;
return currentDepth > closetDepth ? 1.0 : 0.0;

// 1.0 -> in shadow
// 0.0 -> not in shadow
```

## 结果与源码：

![|500](assets/LearnOpenGL-Ch%2027%20Shadow%20Map/Untitled%203.png)

```ad-note
可以看到阴影确实被生成出来，但也出现了许多错误的阴影（黑色条状），这种错误的阴影称为 `shadow acne`
```

[main.cpp](https://www.notion.so/main-cpp-26d01a47aac64358b381d2b68f5d67e3)

[shadow.vs](https://www.notion.so/shadow-vs-9bef492e924e4d41b0b43b1c74c22b10)

[Shadow.fs](https://www.notion.so/Shadow-fs-11d99475372a41cd805813134e5d1cd6)

# 解决 Shadow Acne

上述结果中产生的错误条状阴影可以由下图解释：
![](assets/LearnOpenGL-Ch%2027%20Shadow%20Map/Untitled%204.png)

对于深度贴图而言，它已经是一个离散的结果（由深度贴图中的像素表示），而要渲染的平面仍然还是连续的。因此当用一个离散的结果（上图中的紫色线条）与连续对象（上图中黑色的平面）比较时就可能产生问题。

这就会导致，对于深度贴图中的一个像素而言，待渲染平面中的像素一部分深度值比它大（在阴影中），一部分深度值比它小（不在阴影中），所以就出现了上面的条纹状的错误阴影，称为 `shadow acne` 。

```ad-tip
`shadow acne` 的本质是因为离散采样的误差，让物体自己对自己产生了阴影
```

解决 `shadow acne` 的方法主要有 `Bias` 法和 `Front Face Culling` 法：

## Bias

一个最直接的解决方法就是将从深度贴图中读到的深度加上一个偏移量，如下图所示：
![](assets/LearnOpenGL-Ch%2027%20Shadow%20Map/Untitled%205.png)

代码实现如下：

```glsl
float bias = 0.01;
float shadow = currentDepth > closestDepth + bias ? 1.0 : 0.0;
```

加上 `bias` 后的运行结果如下，可以看到 `shadow acne` 都消除了：
![|400](assets/LearnOpenGL-Ch%2027%20Shadow%20Map/Untitled%206.png)

但是一个固定值的偏移量必然无法满足所有的情况。可以发现，当光源与平面的法线夹角越大，则需要的偏移量越多。可以想象，如果光线方向几乎与平面平行，那么上述示意图中的黄色折线则会几乎垂直于平面，因此需要更多的偏移量。加上根据光线方向调整偏移量的代码如下：

```glsl
float bias = max(0.05 * (1.0 - dot(normal, lightDir)), 0.01);
```

完整的使用了 `Bias` 法的片段着色器如下：

[shadow.fs - Bias](https://www.notion.so/shadow-fs-Bias-98f881b9513b41089f089e454f1d0475)

但 `Bias` 法存在一个问题，当 `Bias` 的数值选择不准确（过大），它会让阴影与物体产生一种分离的感觉，这种失真称为 `Peter panning` 。如上例中，将 `Bias` 调整为 $0.3$ ，结果如下图所示，可以看到阴影与物体的距离过远。

![|400](assets/LearnOpenGL-Ch%2027%20Shadow%20Map/image-20211220191908042.png)

该现象可由下图解释，原先因为蓝色点的深度值比红色点大，因此蓝色点必然会处在阴影中。而加上 Bias 的过程，相当于是让红点的深度更大，如果增加的 Bias 值大于了红蓝两点本来的深度差，那么蓝色点就会被误认为不处于阴影中。即 Bias 会导致阴影的偏移。
![|400](assets/LearnOpenGL-Ch%2027%20Shadow%20Map/Untitled%208.png)

因此在使用 `Bias` 法绘制阴影时，需要选择合适的偏移值。

## Front Face Culling

`Front Face Culling` 方法是另一种消除 `shadow acne` 的方法，且该方法不会引起 `Peter panning` 的问题。

`Front Face Culling` 的流程为，在渲染深度贴图时，裁剪掉前向面（渲染后向面）。在正常渲染场景时，再正常的裁剪掉后向面（渲染前向面）。

如下图所示，在渲染深度贴图时，渲染的是红色的边，在渲染场景时，渲染的是灰色的边。
![](assets/LearnOpenGL-Ch%2027%20Shadow%20Map/Untitled%209.png)

因此在渲染灰色边时，它的深度必然比红色边的深度小不少，因此即使存在因离散而造成的采样误差，也不会出现 `shadow acne` 。

而对于地板而言，因为它只有一边，即不存在后向面，因此地板并不会出现在深度贴图中，也就不会产生 `shadow acne` 。如下所示：
![](assets/LearnOpenGL-Ch%2027%20Shadow%20Map/Untitled%2010.png)

对于被物体遮挡的地板而言，也不会有引入 `Bias` 而造成的阴影偏移，也就没了 `Peter Panning` 。

使用 `Front Face Culling` 方法的渲染结果如下：
![](assets/LearnOpenGL-Ch%2027%20Shadow%20Map/Untitled%2011.png)

[main.cpp](https://www.notion.so/main-cpp-b46211259c274e39a18fdba2906bf073)

[shadow.fs](https://www.notion.so/shadow-fs-4eb23cee60c442f5887f0643bfa17f18)

# Over-Sampling 问题

这里的 `over-sampling` 并不是指超采样，而是指超过了深度贴图所能采样的范围。

因为深度贴图是通过一个从光源出发的摄像机渲染得到的，因此如果在这个摄像机的视锥体外的部分就无法被采样到深度贴图中。

之前在生成深度贴图时，为 [Texture](LearnOpenGL-Ch%2004%20Textures.md) 设置的 `warpmode`为 `repeat` ，如下：

```cpp
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
```

因此超过了视锥体的部分的深度信息，会重复视锥体内的深度信息（被采集到深度贴图中）。

将上例中的地板扩大，修改下光源的位置，并将视锥体尺寸改小，可得如下结果：

```cpp
glm::mat4 projection = glm::ortho(-1.0f, 1.0f, -1.0f, 1.0f, 1.0f, 7.5f);
...
floorObj->GetTransform()->SetScale(vec3(20, 20, 5));
...
lamp->GetTransform()->SetPosition(vec3(3, 5, 2));
```

![](assets/LearnOpenGL-Ch%2027%20Shadow%20Map/Untitled%2012.png)

解决方法为，将 `warpmode` 改为 `Clamp to border` 并将 `border color` 设为1，这样视锥体外的深度信息就永远为深度的最大值1，即视锥体外的像素不会被认为在阴影中。

```cpp
float borderColor[]{1.0f, 1.0f, 1.0f, 1.0f};
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);
glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, borderColor);
```

修改后的运行结果如下：
![](assets/LearnOpenGL-Ch%2027%20Shadow%20Map/Untitled%2013.png)

可以看到，因为深度贴图重复而产生的错误阴影消失，但是仍然有一大块区域仍然错误的在阴影中。

这是因为那部分区域超过了计算深度贴图的视锥体的远裁剪平面，因此在原深度贴图中根本无信息，即深度值为0，即远裁剪平面外的所有像素点都会被认为在阴影中。

修改方法为调整像素着色器中关于阴影判断的计算，修改为：当像素超过了深度贴图视锥体的远裁剪平面，便直接判定该像素不会在阴影中：

```cpp
float ShaderCalculation(vec4 FragPosLightSpace, vec3 normal, vec3 lightDir)
{
...
if (projCoords.z > 1.0)
        return 0.0f;
...
}
```

调整后，运行结果如下，可正确渲染阴影：
![](assets/LearnOpenGL-Ch%2027%20Shadow%20Map/Untitled%2014.png)

[main.cpp](https://www.notion.so/main-cpp-1e3f54d9a56e441faee09767edf8063f)

[shadow.fs](https://www.notion.so/shadow-fs-c5ca8daa5b5d4337bc4d5a77e18303c6)

# 减少阴影锯齿

如果仔细观察上述渲染出的阴影，可以看到再阴影的边缘存在比较明显的锯齿，如当窗口的分辨率为 `1024*1024` ，而深度贴图的分辨率为 `256*256` 时，阴影的锯齿如下：
![](assets/LearnOpenGL-Ch%2027%20Shadow%20Map/Untitled%2015.png)

产生锯齿的原因是，深度贴图的分辨率较小，因此当渲染场景时，会有多个像素采样原深度贴图中的同一个像素点，即会产生较大的锯齿。

## 提高阴影贴图分辨率

在上例中，如果将深度贴图的分辨率调整为 `1024*1024` 则效果如下，可以看到锯齿明显的减少：
![](assets/LearnOpenGL-Ch%2027%20Shadow%20Map/Untitled%2016.png)

## PCF

增加深度贴图分辨率的方法，会很大程度的增加消耗的性能。还有一种方法称为 `percentage-closer filtering（PCF）` 。

`PCF` 方法是一种产生软阴影的方法，主要思想思路如双线性过滤类似，即从深度贴图中采样多个点，每个点都判断是否处在阴影之中，将所有采样的结果结合在一起并做平均。

如下列代码就是一个最简单的 `PCF` 实现，它取包括目标采样点的周围9个像素，判断其是否处于阴影之中，并最终将平均值作为结果：

```glsl
float ShaderCalculation(vec4 FragPosLightSpace, vec3 normal, vec3 lightDir)
{
		...

    float shadow = 0.0f;
    vec2 texelSize = 1.0 / textureSize(depthMap, 0);

    float currentDepth = projCoords.z;
    float bias = max(0.05 * (1 - dot(normal, lightDir)), 0.01);
    for (int x = -1; x <= 1; ++x)
    {
        for (int y = -1; y <= 1; ++y)
        {
            float closetDepth = texture(depthMap, projCoords.xy + vec2(x, y) * texelSize).r;
            shadow += (currentDepth > closetDepth + bias ? 1.0 : 0.0);
        }
    }

    return shadow /= 9.0;
}
```

其中的 `textureSize` 函数会返回图片的分辨率，可利用这个函数算出一个像素的大小。

使用了 `PCF` 绘制阴影的结果如下：
![](assets/LearnOpenGL-Ch%2027%20Shadow%20Map/Untitled%2017.png)

# 正交投影与透视投影

在之前计算阴影贴图的时候，使用的是 `正交投影`。在正交投影下，所有的光线都是平行的，所以正交投影特别适合于用来作为 `平行光` 的投影矩阵。

而在使用 `透视投影` 时，光线则会表现的如同在一个点像各个方向发射出去，因此 `透视投影` 更适合于作为 `点光源` 和 `聚光灯` 的投影矩阵。

`正交投影` 和 `透视投影` 两者差别的示意图如下：
![](assets/LearnOpenGL-Ch%2027%20Shadow%20Map/Untitled%2018.png)

还有一定需要注意的是，在使用 `正交投影` 时，生成的深度贴图，其深度变化是线性。而当使用 `透视投影` 时，深度变化则是非线性的。

因此在调试两者的深度贴图时，会看到 `透视投影` 时生成的深度贴图几乎是全白的，如同在 [Depth Testing](LearnOpenGL-Ch%2015%20Depth%20Testing.md) 中看到的。如果想要在使用 `透视投影` 的情况下，调试深度贴图，则首先需要将深度信息转换到线性空间中，可以使用如下的代码：

```glsl
float LinearizeDepth(float depth)
{
    float z = depth * 2.0 - 1.0; // Back to NDC
    return (2.0 * near_plane * far_plane) / (far_plane + near_plane z * (far_plane - near_plane));
}

void main()
{
    float depthValue = texture(depthMap, TexCoords).r;
    FragColor = vec4(vec3(LinearizeDepth(depthValue) / far_plane), 1.0); // Prospective
    // FragColor = vec4(vec3(depthValue), 1.0); // Orthographic
}
```

- [ ] 转换到线性空间的公式是怎么推导的？

```ad-warning
上述将深度转换到线性空间的操作仅在调试深度贴图时有用。并不会影响使用深度贴图来产生阴影的结果，因为无论是线性还是非线性，在将实际渲染场景时的深度信息与深度贴图中存储的信息做比较时，两者都是在处于同一个空间下。
```

# Reference

[opengl - Cause of shadow acne - Computer Graphics Stack Exchange](https://www.notion.so/opengl-Cause-of-shadow-acne-Computer-Graphics-Stack-Exchange-c739e44c139d4209a1b024cd38aeefcc)

[制作shadow map时，为什么剔除正面可以解决物体悬浮问题（Peter panning问题）？ - 知乎](https://www.notion.so/shadow-map-Peter-panning-7a8e8fa4fe984ac19a21a8fb7d53839a)

[glsl - How to render depth linearly in modern OpenGL with gl_FragCoord.z in fragment shader? - Stack Overflow](https://www.notion.so/glsl-How-to-render-depth-linearly-in-modern-OpenGL-with-gl_FragCoord-z-in-fragment-shader-Stack-457af68fb62743ec98302b355a8ab7e6)