---
created: 2021-12-20
updated: 2021-12-21
---
[Shadow Mapping](Learn%20OpenGL%20-%20Ch%2027%20Shadow%20Mapping.md) 中计算的是光源向一个方向照射时（方向光或聚光灯）产生的阴影，如下图所示：

![](assets/LearnOpenGL-Ch%2028%20Point%20Shadows/Untitled%202.png)

在这种情况下，阴影贴图可以通过一个位置与光源位置相同， `LookAt` 方向为光源方向的摄像机渲染得到，且阴影贴图是一张 `Texture 2D` 且称为 `Directional Shadow mapping` 。

对于点光源而言，它的照射方向是朝四面八方的，因此渲染深度贴图时无法使用单一的 `LookAt` 方向，如下图所示：
![](assets/LearnOpenGL-Ch%2028%20Point%20Shadows/Untitled%201.png)

这种情况下的阴影被称为 `Point Shadow` 。 `Point Shadow` 的计算过程与 [Shadow Mapping](Learn%20OpenGL%20-%20Ch%2027%20Shadow%20Mapping.md) 中计算阴影的方式基本相同，只不过需要用 Cubemap 替代 Texture2D 作为阴影贴图，该阴影贴图被称为 `Depth Cubemap` 或 `Omonidirectional shadow mapping` 。

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

还有一种方法是利用 [Geometry Shader](Learn%20OpenGL%20-%20Ch%2022%20Geometry%20Shader.md) ，通过一次绘制命令就能直接将深度信息写入到Cubemap 的六个面中。该方法将六个不同的 `LookAt` 方向（对应 Cubemap 的每个面）传入到 Geometry Shader 中，并将输入的三角形与这六个 `LookAt` 方向相乘，得到六个新的三角形。即可以理解为，使用这六个不同的 `LookAt` 方向将一个三角形转换到以 Cubemap 的每一个面作为屏幕坐标的坐标系中。

以下是使用 [Geometry Shader](Learn%20OpenGL%20-%20Ch%2022%20Geometry%20Shader.md) 方法渲染 `Depth Cubemap` 的具体步骤：

## Generate cubemap

第一步是如创建一个 Cubemap，步骤与在 [Cubemaps](Learn%20OpenGL%20-%20Ch%2020%20Cubemaps.md) 中描述的类似：

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

然后将其绑定到 Framebuffer 上，需要注意的是，因为这里要绑定的对象是 Cubemap 而不是 Texture2D，因此应当使用函数 `glFramebufferTexture` 而不是 `glFramebufferTexture2D` 。另外如同在 [Shadow Mapping](Learn%20OpenGL%20-%20Ch%2027%20Shadow%20Mapping.md) 中提到的，因为绑定的 Framebuffer 没有颜色缓冲 ，即绑定的 Framebuffer是不完整的，因此需要将 `DrawBuffer` 和 `ReadBuffer` 设定为 `GL_NONE` ：

```cpp
glGenFramebuffers(1, &depthMapFBO);
glBindFramebuffer(GL_FRAMEBUFFER, depthMapFBO);
glFramebufferTexture(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, depthCubemap, 0);
glDrawBuffer(GL_NONE); // As the depth map framebuffer do not have color attachment, thus it is required to set draw/read buffer to null
glReadBuffer(GL_NONE);
glBindFramebuffer(GL_FRAMEBUFFER, 0);
```

## Light Space transform

如在 [Shadow Mapping](Learn%20OpenGL%20-%20Ch%2027%20Shadow%20Mapping.md) 的最后所述，点光源的深度贴图渲染需要用到透视投影，因此需要首先求得透视投影的 Projection 矩阵：
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

```ad-error
需要注意的是，这里 `LookAt` 矩阵中 `Up` 方向与直觉上需要使用的方向是相反的。 如渲染 Front 面的时候， `Up` 方向是 $(0,-1,0)$ ，而直觉上应当使用 $(0,1,0)$，且在 [Shadow Mapping](LearnOpenGL-Ch%2027%20Shadow%20Mapping.md) 中使用的 `Up` 就是与直觉相符的。

这里与[Shadow Mapping](LearnOpenGL-Ch%2027%20Shadow%20Mapping.md) 需要用到相反的 `Up` 方向的原因是，OpenGL 中 Cubemap 和 Texture2D 对于原点的定义是不同的 ，在 Cubemap 中原点处在左上角，而在 Texture2D 中原点处在左下角。这一点在[LearnOpenGL-Ch 20 Cubemaps](LearnOpenGL-Ch%2020%20Cubemaps.md) 中也进行了说明。
```


## Depth shaders

在 [Shadow Mapping](https://www.notion.so/Shadow-Mapping-b996d273749f4a72a82ee88fd72f73ed) 中，顶点着色器需要负责使用 MVP 矩阵对输入的顶点进行变换。而在这里，如之前所述，需要用几何着色器将一个三角形转换为六个不同的三角形，因此这里的顶点着色器只需要负责用 Model 矩阵与输入顶点进行变换：

```cpp
#version 330 core

layout (location = 0) in vec3 pos;

uniform mat4 model;

void main()
{
    gl_Position= model * vec4(pos, 1.0) ;
}
```

在几何着色器中，首先需要用 Uniform 将之前定义的六个 `shadowTransform` 矩阵传入着色器，然后用输入的一个三角形，分别与六个不同的矩阵相乘，输出六个三角形：

```cpp
#version 330 core

layout (triangles) in;
layout (triangle_strip, max_vertices = 18) out;

uniform mat4 shadowMatrices[6];

out vec4 FragPos;

void main()
{
    for(int face = 0; face != 6; ++face)
    {
        gl_Layer = face;
        for(int i = 0; i < 3; ++i)
        {
            FragPos = gl_in[i].gl_Position;
            gl_Position = shadowMatrices[face] * FragPos;
            EmitVertex();
        }
        EndPrimitive(); // Output a triangle
    }
}
```

在 [Shadow Mapping](Learn%20OpenGL%20-%20Ch%2027%20Shadow%20Mapping.md) 中使用的是平行光，所以用的是正交投影，也因此得到的深度信息是线性的。所以在得到平行光需要使用的深度贴图的过程中，片段着色器不需要做任何处理，渲染管线就会将线性的深度信息写入到绑定的 Framebuffer中。

而在这里，因为使用的是透视投影，而透视投影产生的深度信息是非线性的，所以这里的片段着色器需要手动的计算出线性的深度信息：

```cpp
#version 330 core

in vec4 FragPos;

uniform vec3 lightPos;
uniform float far_plane;

void main()
{
    float lightDistance = length(FragPos.xyz - lightPos);
    lightDistance = lightDistance / far_plane; // convert to [0,1]

    gl_FragDepth = lightDistance;
}
```

# Omnidirectional shadow maps

上一节给出了渲染 `Depth Cubemap` 所需要用到的着色器，而这里会给出实际渲染中利用 `Depth Cubemap` 计算阴影的着色器。

## Vertex Shader

这里的顶点着色器与 [Shadow Mapping](Learn%20OpenGL%20-%20Ch%2027%20Shadow%20Mapping.md) 中的基本相同。只不过在  [Shadow Mapping](https://www.notion.so/Shadow-Mapping-b996d273749f4a72a82ee88fd72f73ed) 中，需要计算出 `FragPosLightSpace` 值，表示以光源为摄像机的摄像机坐标系下的坐标。在片段着色器中，会进一步利用该坐标采样二维的深度贴图。

而这里生成得到的深度贴图是 Cubemap，如在 [Cubemaps](Learn%20OpenGL%20-%20Ch%2020%20Cubemaps.md) 中的描述，采样 Cubemap 使用的是方向，在这里需要用的就是从光源指向片元的方向，即不需要在顶点着色器中做额外计算，所以顶点着色器如下所示：
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
}
vs_out;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

void main()
{
    vs_out.FragPos = vec3(model * vec4(Pos, 1.0));
    vs_out.Normal = transpose(inverse(mat3(model))) * Normal;
    vs_out.TexCoords = TexCoords;
    gl_Position = projection * view * model * vec4(Pos, 1.0);
}
```

## Fragment shadow

在片元着色器中，首先需要通过 uniform 传入之前得到的用来表示深度信息的 Cubemap：

```glsl
uniform samplerCube depthMap;
```

另外还需要通过 uniform 传入 `far_plane` 信息，因为在计算 Depth Cubemap 时，为了得到线性的深度信息，将光源与片元的距离除以了 `far_plane` ，所以这里需要重新乘以 `far_plane` ，即从 Depth Cubemap 中读到的深度信息应当表示为：

```glsl
float closestDepth = texture(depthMap,fragToLight).r;
closestDepth *= far_plane;
```

而当前的片元的深度计算方法为：

```glsl
vec3 fragToLight = fragPos - lightPos;
float currentDepth = length(fragToLight);
```

将两者对比，并引入 bias， 就能算出是否在阴影中，即：

```glsl
float ShaderCalculation(vec3 fragPos, vec3 normal, vec3 lightDir)
{
    vec3 fragToLight = fragPos - lightPos;
    float currentDepth = length(fragToLight);

    // Without PCF
    float closestDepth = texture(depthMap,fragToLight).r;
    closestDepth *= far_plane;

    float bias = max(0.05 * (1 - dot(normal, lightDir)), 0.01);
    float shadow =(currentDepth>closestDepth + bias ? 1.0 : 0.0);
    return shadow;
}
```

片段着色器的其他部分与 [Shadow Mapping](Learn%20OpenGL%20-%20Ch%2027%20Shadow%20Mapping.md) 中类似，结果如下，其中红色方块表示光源位置：
![](assets/LearnOpenGL-Ch%2028%20Point%20Shadows/Untitled%202%201.png)

在 [Shadow Mapping](Learn%20OpenGL%20-%20Ch%2027%20Shadow%20Mapping.md)  中，为了产生软阴影，使用的 PCF 方法，在点光源的计算中同样可以运用。只不过在 [Shadow Mapping](Learn%20OpenGL%20-%20Ch%2027%20Shadow%20Mapping.md)中 PCF 的计算是通过一个二维的嵌套循分别在 $x,y$ 方向上取采样点，而这里因为用的是 Depth Cubemap，所以需要额外的 $z$ 方向，即需要使用三维的嵌套循环：

```glsl
float bias = max(0.05 * (1 - dot(normal, lightDir)), 0.01);
float shadow = 0.0;
float offset = 0.1;
float samples = 4.0;

for(float x = -offset; x < offset; x += (offset*2)/samples )
{
        for(float y = -offset; y < offset; y += (offset*2)/samples )
        {
            for(float z = -offset; z < offset; z += (offset*2)/samples )
            {
                float closestDepth = texture(depthMap,fragToLight + vec3(x, y, z)).r;
                closestDepth *= far_plane;
                shadow += (currentDepth>closestDepth + bias ? 1.0 : 0.0);
            }
        }
}
shadow /= (samples * samples *samples);
```

使用上述的方法计算阴影，可以得到如下的软阴影结果：
![](assets/LearnOpenGL-Ch%2028%20Point%20Shadows/Untitled%203.png)

但是这个方法存在的问题是，它需要采样过多的点。如在上例中，实际上采样了 $4_4_4=64$ 个点，且这些点朝向很可能是非常接近的，因此可能有大量的性能消耗在了提升并不明显的采样方向上。

因此，一个优化方向为，仅使用那些相差较远的方向进行 PCF，对于 $x,y,z$ 方向而言，各取 $(0,1,-1)$ 这三种值，且保证一个方向上至多出现一个 $0$，即不要采样如 $(1,0,0)$ 这样的方向，这样就一共有 $20$ 种可能的方向（$3_3_3-3P2-1=20$）。使用该方法的 PCF 如下：

```glsl
float bias = max(0.1 * (1 - dot(normal, lightDir)), 0.05);
float shadow = 0.0;
float diskRadius = 0.05;
vec3 sampleOffsetDirections[20] = vec3[]
(
   vec3( 1,  1,  1), vec3( 1, -1,  1), vec3(-1, -1,  1), vec3(-1,  1,  1), 
   vec3( 1,  1, -1), vec3( 1, -1, -1), vec3(-1, -1, -1), vec3(-1,  1, -1),
   vec3( 1,  1,  0), vec3( 1, -1,  0), vec3(-1, -1,  0), vec3(-1,  1,  0),
   vec3( 1,  0,  1), vec3(-1,  0,  1), vec3( 1,  0, -1), vec3(-1,  0, -1),
   vec3( 0,  1,  1), vec3( 0, -1,  1), vec3( 0, -1, -1), vec3( 0,  1, -1)
);

for(int i = 0; i != 20; ++i)
{
    float closestDepth = texture(depthMap,fragToLight + sampleOffsetDirections[i] * diskRadius  ).r;
    closestDepth *= far_plane;
    shadow += (currentDepth>closestDepth + bias ? 1.0 : 0.0);
}

shadow /= 20;
```

结果如下所示，可以看到同样产生了软阴影，但是阴影的显示效果并不如完全的 PCF 好：
![](assets/LearnOpenGL-Ch%2028%20Point%20Shadows/Untitled%204.png)

## 源码：

[main.cpp](https://www.notion.so/main-cpp-ac094df96e754cb1b9bca728f2361a8c)

[DrawDepthCubemap.vs](https://www.notion.so/DrawDepthCubemap-vs-aac8c49f2d66469497b61253f5704c1b)

[DrawDepthCubemap.fs](https://www.notion.so/DrawDepthCubemap-fs-6c664c06eff843ebb0a4300e21c883d5)

[DrawDepthCubemap.gs](https://www.notion.so/DrawDepthCubemap-gs-07ade4622af34867809b7321fbbb0b70)

[PointShadow.vs](https://www.notion.so/PointShadow-vs-621c413af029406ebfbdb9150d6beadc)

[PointShadow.fs](https://www.notion.so/PointShadow-fs-04fdfe808a324524befd6f7074768bde)