---
created: 2021-12-17
updated: 2021-12-22
---
简单来说，立方体贴图就是一个包含了6个2D纹理的纹理，每个2D纹理都组成立方体的一个面。

# 创建立方体贴图

创建立方体贴图的方法与其他纹理一样，只不过绑定的纹理类型为 `GL_TEXTURE_CUBE_MAP`。

```glsl
glGenTextures(1, &id);
glBindTexture(GL_TEXTURE_CUBE_MAP, id);
```

因为立方体有6个面，所以需要调用 `glTexImage2D` 6次，每次对应立方体的一个面。对于用于装填立方体贴图的 `glTexImage2D` 的调用，其参数与装填普通纹理时类似，但需要将纹理目标设为立方体贴图特定的面。OpenGL提供了6个特殊的纹理目标，对应立方体贴图的每一个面：

| Texture Target                 | Orientation |
| ------------------------------ | ----------- |
| GL_TEXTURE_CUBE_MAP_POSITIVE_X | Right       |
| GL_TEXTURE_CUBE_MAP_NEGATIVE_X | Left        |
| GL_TEXTURE_CUBE_MAP_POSITIVE_Y | Top         |
| GL_TEXTURE_CUBE_MAP_NEGATIVE_Y | Bottom      |
| GL_TEXTURE_CUBE_MAP_POSITIVE_Z | Back        |
| GL_TEXTURE_CUBE_MAP_NEGATIVE_Z | Front       |

这六个参数是递增的，即 `GL_TEXTURE_CUBE_MAP_POSITIVE_X + 1 = GL_TEXTURE_CUBE_MAP_NEGATIVE_X`。因此可以通过一个循环为六个面设置对应的纹理：

```glsl
int nrChannels = 0;
unsigned char *data = nullptr;
for (unsigned int i = 0; i != facesSource.size(); ++i)
{
    data = stbi_load(faceSources[i].c_str(), &width, &height, &nrChannels, 0);
    glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, nrChannels == 3 ? GL_RGB : GL_RGBA,
                 width, height, 0, nrChannels == 3 ? GL_RGB : GL_RGBA, GL_UNSIGNED_BYTE, data);
}
```

```ad-warning
在 [Textures](LearnOpenGL-Ch%2004%20Textures.md) 中为了修复纹理上下翻转的问题，在读取图片资源前会先调用 `stbi_set_flip_vertically_on_load(true)` 。但当读取 Cubemap 的纹理时，不调用该函数画面仍然不会出现翻转问题。 这是因为在OpenGL中 `Texture2D` 的原点定义在左下角，与图片定义的原点相反，因此需要翻转。而 `Cubemap` 的原点定义在左上角，与图片定义的原点相同，因此不需要翻转。
```

对于整个Cubemap，仍需要如 [Textures](https://www.notion.so/Textures-38922728a98c4b3692ec9e3c70223ac3) 中设置纹理映射和纹理过滤的方式，但这里会多一个 `GL_TEXTURE_WRAP_R` 属性，表示在两个面之间的采样：

```glsl
glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
```

将立方体贴图绑定至着色器的流程也与普通贴图类似：

```cpp
glBindBuffer(GL_ARRAY_BUFFER, 0);
glBindVertexArray(0);
glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
```

# 天空盒着色器

天空盒是立方体贴图的一个最常见的应用。

立方体贴图的六面纹理如下所示，通过这六个面，可以折叠出一个立方体：
![](assets/Learn%20OpenGL%20-%20Ch%2020%20Cubemaps/Untitled.png)

## 片段着色器

在片段着色器中，用 `sampleCube` 取代 `sample2D` 表示纹理：

```glsl
in vec3 TexCoords;
uniform samplerCube skybox;

void main()
{
    FragColor = texture(skybox, TexCoords);
}
```

## 顶点着色器

对于立方体贴图而言，使用的纹理坐标是三维的，即 `vec3` ，可以看作是来自于原点的方向向量。

```ad-note
此方向向量并不要求必须是单位向量，其大小无所谓。因为对于Cubemap而言，在提供了方向向量后，OpenGL会获取这个向量在Cubemap上的交点，并以此采样出Cubemap纹理的值。
```

当方向向量的起点处在立方体的中心时，这个方向向量的值就等于与立方体相交点的值，即片元的位置。如下所示：
![|400](assets/Learn%20OpenGL%20-%20Ch%2020%20Cubemaps/Untitled%201.png)

因此对于使用了立方体贴图的模型而言，可直接使用模型的片元位置表示Texcoords，但需要注意这里的片元位置是本地坐标系下的，并不需要进行位移旋转等操作：

```glsl
out vec3 TexCoords;
...
TexCoords = aPos;
```

如果将立方体贴图作为天空盒使用，那么立方体贴图的所要展示的是一个不变的周围环境，而周围环境通常不会进行位移，旋转等操作，所以在片元位置时，不需要考虑 `Model` 。

```glsl
vec4 pos = projection * view *vec4(aPos, 1.0);
```

而对于摄像机而言，为了保证效果的正确，它应该始终处于天空盒的正中间。而摄像机的位移信息在 `View` 观察者矩阵中，且处在矩阵的第四列中。因此可以通过先将 `View` 矩阵转换为三维矩阵，丢失第四列的信息后，再将其转换为四维矩阵，这样在能保证摄像机始终在天空盒的正中间。

```cpp
glm::mat4 view = glm::mat4(glm::mat3(camera->GetViewMatrix()));
```

```ad-error
这个转换应该仅出现将View矩阵传递到天空盒的顶点着色器前，对于其他模型的顶点着色器仍然要考虑View矩阵的位移信息
```

# 天空盒绘制

## 先绘制天空盒

对于天空盒的绘制，一个做法是先绘制天空盒，再绘制其他的模型。

需要考虑的是，因为天空盒模型的尺寸很小（$1\times 1\times1$），因此直接绘制天空盒再绘制其他物体的话，其他物体都将无法通过深度测试。因此在绘制天空盒之前，需要关闭深度缓冲信息的写入，保证天空盒的渲染并不会影响到之后其他物体的渲染，在天空盒渲染结束后，在打开深度缓冲信息的写入。

```cpp
Skybox *skybox = new Skybox(cubemap);
skybox->preRender = []() {
    glDepthMask(GL_FALSE); // Turn off Depth Buffer
};

skybox->postRender = []() {
    glDepthMask(GL_TRUE); // Turn on Depth Buffer
};
scene.AddGameObject(skybox); // Render Skybox first

scene.AddGameObject(sthElse);
```

## 后绘制天空盒

先绘制天空盒的方法很符合直觉，但这样会浪费许多的性能。如果一个场景内的其他物体把外界环境完全遮挡住，那么天空盒的绘制实际上是没有意义的，但先绘制天空盒的话就必然会造成整个天空盒的一次渲染。

后绘制天空盒的思路是，将场景内其他的模型都先渲染完，然后渲染天空盒。

这里同样需要解决天空盒尺寸很小的问题，解决思路是将天空盒的深度信息改为1，即天空盒的深度信息值最大，此时只要深度缓冲被其他的任何模型进行过写入，那么天空盒的深度缓冲就不会通过。

在 [Depth Testing](Learn%20OpenGL%20-%20Ch%2015%20Depth%20Testing.md) 中了解到一个片元的深度信息存储在它的 `z` 分量中，又从 [Coordinate System](Learn%20OpenGL%20-%20Ch%2006%20Coordinate%20System.md) 中了解到对于一个片元而言，在投影变换时，需要进行 `z = z/w` 的操作，因此为了将最终片元的深度信息变为1，只要让 `w = z` 即可。

```glsl
vec4 pos = projection * view *vec4(aPos, 1.0);
gl_Position = pos.xyww;
```

但还要考虑到那些没有被任何模型写入过的深度缓冲，它们的默认值也为1，而这些缓冲需要让天空盒的深度测试通过，因此在渲染天空盒前，需要将深度测试的通过条件由默认的 $<$改为 $\leq$，即通过 [Depth Testing](Learn%20OpenGL%20-%20Ch%2015%20Depth%20Testing.md) 中介绍的 `glDepthFunc` 函数。

```cpp
scene.AddGameObject(sthElse);

Skybox *skybox = new Skybox(cubemap);
skybox->preRender = []() { glDepthFunc(GL_LEQUAL); };
skybox->postRender = []() { glDepthFunc(GL_LESS); };
scene.AddGameObject(skybox); // Render Skybox in the end
```

# 环境映射

通常会用一个立方体采样立方体贴图作为天空盒，即作为整个场景的环境。同样也可以让场景内的其他物体也采样立方体贴图，但这些物体的目的是作为 `环境映射（Environment Mapping）`，最常见的环境映射有 `反射（Reflection）` 和 `折射（Refraction）`。

## 反射

反射变现为物体反射周围的环境，物体的颜色或多或少等于它的周围环境的颜色。如镜子就是反射性很强的物体，它会根据观察者的视角反射周围的环境。

如下图所示，观察者的视线会在物体表面进行反射，而反射向量将击中的天空盒的某个位置，这个位置的颜色即是观察者在这个片元上应当看到的颜色。

![](assets/Learn%20OpenGL%20-%20Ch%2020%20Cubemaps/Untitled%202.png)

计算实现的反射方向的方法，如在 [Basic Lighting](Learn%20OpenGL%20-%20Ch%2011%20Basic%20Lighting.md) 中计算镜面光反射时，求光的反射方向一样。即先通过摄像机位置和片元位置求得实现方向，再利用 `reflect` 函数求得反射方向。

```glsl
vec3 viewDirection = normalize(position - cameraPos);
vec3 reflection = reflect(viewDirection, normalize(normal));
```

```ad-warning
需要注意，这里求反射方向的时候并没有考虑片元的绝对位置，即当片元与摄像机一起移动时，即使绝对位置发生了变化，所求得的反射方向也是相同的，即最终在立方体贴图上采样得到的颜色也是相同的。 这是因为通常天空盒是用来表示无穷远处的场景，因此片元的移动并不会对最终的画面造成太多的影响，所以不需要在计算环境反射时考虑片元的绝对位置。
```

利用反射方向对立方体贴图进行采样：

```glsl
FragColor = vec4(texture(skybox, reflection).rgb, 1.0);
```

![|400](assets/Learn%20OpenGL%20-%20Ch%2020%20Cubemaps/Untitled%203.png)

## 折射

折射是光线由于传播介质的改变而产生的方向变化，如下图所示：

![|400](assets/Learn%20OpenGL%20-%20Ch%2020%20Cubemaps/Untitled%204.png)

因此，对于折射物体而言，其背后的物体仍然可以被看到，但是看到它的视线路线发生了偏转。典型的折射物体如装了水的玻璃杯。

对于不同的物体而言，折射率是不同的，常见的物体与对应的折射率如下：

| 材质 | 折射率 |
| ---- | ------ |
| 空气 | 1.00   |
| 水   | 1.33   |
| 冰   | 1.309  |
| 玻璃 | 1.52   |
| 钻石 | 2.42       |

在这里的例子中假设立方体是由玻璃做的，则视线是从空气到达玻璃中，因此折射率为 $1/1.52$，折射后的光线可以通过内置函数 `refract` 计算得到，因此片元着色器主要代码如下：

```glsl
float ratio= 1.00 /1.52; // glass refraction
vec3 viewDirection = normalize(position - cameraPos);
vec3 refraction = refract(viewDirection, normalize(normal),ratio);
FragColor = vec4(texture(skybox, refraction).rgb, 1.0);
```

![|500](assets/Learn%20OpenGL%20-%20Ch%2020%20Cubemaps/Untitled%205.png)

# 结果与源码
![|500](assets/Learn%20OpenGL%20-%20Ch%2020%20Cubemaps/Untitled%206.png)

左侧立方体为反射立方体，右侧立方体为折射立方体

[main.cpp](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/18.Cubemaps/main.cpp)

[environmentMapping.vert](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/18.Cubemaps/environmentMapping.vert) [reflection.frag](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/18.Cubemaps/reflection.frag)

[refraction.frag](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/18.Cubemaps/refraction.frag)

[Cubemap.cpp](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/Framework/Components/Cubemap.cpp)

[Skybox.cpp](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/Framework/Components/Skybox.cpp)

# Reference

[3d - Convention of faces in OpenGL cubemapping - Stack Overflow](https://stackoverflow.com/questions/11685608/convention-of-faces-in-opengl-cubemapping/11690553#11690553)