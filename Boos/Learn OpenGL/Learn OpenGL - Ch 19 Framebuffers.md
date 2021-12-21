---
created: 2021-12-17
updated: 2021-12-21
---
颜色缓冲，深度缓冲和模板缓冲都被存储在 `帧缓冲（Framebuffers）`中，当开发者不手动设置帧缓冲时，上述所有的缓冲都会存储到默认的帧缓冲中。当通过 `GLFW` 创建窗口时， `GLFW` 会自动的创建默认的帧缓冲。

当然OpenGL也提供了开发者自己定义帧缓冲以及颜色，深度，模板缓冲的方法。

# 创建帧缓冲

通过 `glGenFramebuffers` 创建帧缓冲：

```cpp
unsigned int fbo;
glGenFramebuffers(1, &fbo);
```

通过 `glBindFramebuffer` 绑定帧缓冲：

```cpp
glBindFramebuffer(GL_FRAMEBUFFER, fbo);
```

当绑定帧缓冲到 `GL_FRAMEBUFFER`后，之后所有关于帧缓冲的读和写操作都会针对于这个缓冲。

也可以通过绑定缓冲到 `GL_READ_FRAMEBUFFER` 和 `GL_DRAW_FRAMEBUFFER` 上，分别设定读操作（如 `glReadPixels`）的目标和写操作（如 `GlClear` 和 `glDrawElements`）的目标。

但绑定了帧缓冲后，还不能使用该帧缓冲，因为这个缓冲还不是完整的，对于一个完整的帧缓冲，他必须要：

1.  依附至少一个缓冲（颜色，深度，模板缓冲）
2.  至少有一个颜色附件（color attachment）
3.  所有的附件都是完整的（分配了内存）
4.  4.  所有的缓冲都有相同的采样数（见 [Anti Aliasing](Learn%20OpenGL%20-%20Ch%2024%20Anti%20Aliasing.md)）

```ad-note
由上述条件1和2可知，只有颜色附件的帧缓冲，仍然是一个完整的帧缓冲
```

可以通过函数 `glCheckFramebuffersStatus` 检查一个帧缓冲是否以及可以使用，该函数会返回一系列状态，具体状态可见[官方文档](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/glCheckFramebufferStatus.xhtml)，当返回的状态为 `GL_FRAMEBUFFER_COMPLETE` 时表示帧缓冲可用：

```cpp
if(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE)
    // Operations
```

解绑和删除帧缓冲如下，当解绑了自定义的帧缓冲后会自动激活默认的帧缓冲：

```cpp
glBindFramebuffer(GL_FRAMEBUFFER, 0);
glDeleteFramebuffers(1, &fbo);
```

# 附件

如前所述，对于一个完整的帧缓冲，应当有至少一个附件（Attachment）。附件是一个内存地址，作为帧缓冲中的一个缓冲，可以将其看作是一张图片。对于帧缓冲的附件，有两种类型， `纹理附件（Texture attachments）`和 `渲染缓冲对象附件（Renderbuffer objects attachments）`。

## 纹理附件（Texture attachments）

使用纹理附件的好处是所有的渲染操作都将被储存在一个纹理图像中，之后可以方便的在着色器中使用它。 创建纹理附件和创建一个普通的纹理差不多。

```cpp
glGenTextures(1, &texColorBuffer);
glBindTexture(GL_TEXTURE_2D, texColorBuffer);
glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, scene.GetWidth(), scene.GetHeight(), 0, GL_RGB, GL_UNSIGNED_BYTE, NULL);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
glBindTexture(GL_TEXTURE_2D, 0);
```

与创建普通纹理的区别在于，当创建作为纹理附件的纹理时，纹理的数据传的是 `Null` 。因为对于这个纹理而言，现在要做的仅仅是分配内存，而纹理数据的装填是在之后渲染时进行的。

```ad-note
因为这里创建的纹理是作为帧缓冲的纹理附件，即用来表现颜色，因此纹理的类型还是 `GL_RGB` 。如果创建的纹理需要作为帧缓冲的深度附件，则类型需要改为 `GL_DEPTH_COMPONENT` ，如在 [Shadow Map](LearnOpenGL-Ch%2099%20Shadow%20Map.md) 中的运用。
```

在创建好纹理后，要做的最后一件事就是将它附加到帧缓冲上：

```cpp
glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texColorBuffer, 0);
```

该函数参数的含义为：

-   第一个参数为帧缓冲目标
-   第二个为想要附加的附件类型，因为这里是颜色附件所以为 `GL_COLOR_ATTACHMENT0`，0意味着可以附加多个颜色附件。如果是深度或模版，可用 `GL_DEPTH_STENCIL_ATTACHMENT`
-   第三个为希望附加的纹理类型
-   第四个为附加的纹理本身
-   第五个为多级渐远纹理的级别， 这个设为0。

## 渲染缓冲对象附件（Renderbuffer object attachments）

渲染缓冲对象附件是在纹理附件后引入到OpenGL中的，过去纹理是唯一可用的附件。

渲染缓冲对象的好处是，它会将数据存储为OpenGL原生的渲染格式。 因为它直接将所有的渲染数据存储到缓存中，不会做任何针对纹理格式的转换，所以对于纹理缓冲对象的写入操作会很快。

但也因为渲染缓冲对象存储的是原生的渲染格式，因此开发者无法直接读取（如在着色器中使用）。唯一获取数据的方法，是通过函数 `glReadPixels`，但该方法也是从当前绑定的帧缓冲中得到数据，而不是纹理缓冲对象附件本身。

创建和绑定渲染缓冲对象的代码与普通类型类似：

```cpp
unsigned int rbo;
glGenRenderbuffers(1, &rbo);
glBindRenderbuffer(GL_RENDERBUFFER, rbo);
```

因为开发者一般都只关心深度和模版测试，而不需要从深度和模版缓冲中读值。所以渲染缓冲对象经常作为深度和模版附件。 分配深度缓冲和模板缓冲的内存，可以调用 `glRenderbufferStorage`函数来完成：

```cpp
glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, scene.GetWidth(), scene.GetHeight());
```

最后同样是将渲染缓冲对象附加到帧缓冲上：

```cpp
glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, rbo);
```

# 帧缓冲渲染流程

当创建完了帧缓冲，并将附件附加到帧缓冲后，使用帧缓冲渲染的流程如下：

1.  绑定自定义帧缓冲，并调用 `glClear` 清除信息
2.  如未使用帧缓冲一样，正向渲染场景内所有物体。但此时渲染的目标已经不是默认的帧缓冲，而是在第一步中绑定的自定义帧缓冲
3.  解绑自定义帧缓冲，此时默认帧缓冲会自动被绑定上。取出自定义帧缓冲中的颜色附件，将该颜色附件渲染到一个充满屏幕的平面上。

```cpp
// Bind framebuffer before rendering the screen
scene.preRender = []() {
    glEnable(GL_DEPTH_TEST);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
};

// Unbind framebuffer, and draw the framebuffer color component to default framebuffer
scene.postRender = []() {
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    screenMeshRender->DrawMesh();
};
```

渲染的结果如下，深度缓冲，模板缓冲都能正常计算：
![|500](assets/Learn%20OpenGL%20-%20Ch%2019%20Framebuffers/Untitled.png)

# 后处理

当使用帧缓冲渲染后，所有的场景显示内容被绘制到了帧缓冲的颜色附件中，该附件本质上就是一张图。因此可以对这张图进行后期的处理，如反色，变灰度值等，这些操作都可以在渲染颜色附件到默认帧缓冲的片段着色器中完成：

反色处理：

```glsl
FragColor = vec4(vec3(1.0 - texture(screenTexture, TexCoords)), 1.0);
```

灰度值处理：

灰度值处理本质上是将颜色的输出变为三个通道的平均值，但因为人眼对三原色的敏感度不同，因此不是完全的平均，而要额外乘一个系数：

```glsl
FragColor = texture(screenTexture, TexCoords);
float average = 0.2126 * FragColor.r + 0.7152 * FragColor.g + 0.0722 * FragColor.b;
FragColor = vec4(average, average, average, 1.0);
```

模糊处理：

模糊处理的本质是卷积矩阵，即对于每一个像素而言，取它周围几个像素的颜色，将这些像素和自身的颜色取平均值，达到模糊的效果

```glsl
const float offset = 1.0 / 300.0; 
vec2 offsets[9] = vec2[](
    vec2(-offset,  offset), // top-left
    vec2( 0.0f,    offset), // top-center
    vec2( offset,  offset), // top-right
    vec2(-offset,  0.0f),   // center-left
    vec2( 0.0f,    0.0f),   // center-center
    vec2( offset,  0.0f),   // center-right
    vec2(-offset, -offset), // bottom-left
    vec2( 0.0f,   -offset), // bottom-center
    vec2( offset, -offset)  // bottom-right    
);

float kernel[9] = float[](
    1.0 / 16, 2.0 / 16, 1.0 / 16,
    2.0 / 16, 4.0 / 16, 2.0 / 16,
    1.0 / 16, 2.0 / 16, 1.0 / 16  
);

vec3 sampleTex[9];

for(int i = 0; i < 9; i++)
    sampleTex[i] = vec3(texture(screenTexture, TexCoords.st + offsets[i]));

vec3 col = vec3(0.0);

for(int i = 0; i < 9; i++)
    col += sampleTex[i] * kernel[i];

FragColor = vec4(col, 1.0);
```

其中的 `offset` 是用来对 `Texcoords` 做一个偏移量，达到采样周围像素的效果。

# 结果与源码：

模糊效果：
![|500](assets/Learn%20OpenGL%20-%20Ch%2019%20Framebuffers/Untitled%201.png)

[main.cpp](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/17.Framebuffers/main.cpp)

[Framebuffer.vert](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/17.Framebuffers/Framebuffer.vert)

[Framebuffer.frag](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/17.Framebuffers/Framebuffer.frag)