---
created: 2021-12-17
updated: 2021-12-17
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
![](assets/LearnOpenGL-Ch%2020%20Cubemaps/Untitled.png)

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
![](assets/LearnOpenGL-Ch%2020%20Cubemaps/Untitled%201.png)

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

在 [LearnOpenGL-Ch 15 Depth Testing](LearnOpenGL-Ch%2015%20Depth%20Testing.md) 中了解到一个片元的深度信息存储在它的 `z` 分量中，又从 [Coordinate System](https://www.notion.so/Coordinate-System-33c1c9fee16c46e09899e1bf65a70d69) 中了解到对于一个片元而言，在投影变换时，需要进行 `z = z/w` 的操作，因此为了将最终片元的深度信息变为1，只要让 `w = z` 即可。


# Reference

[3d - Convention of faces in OpenGL cubemapping - Stack Overflow](https://stackoverflow.com/questions/11685608/convention-of-faces-in-opengl-cubemapping/11690553#11690553)