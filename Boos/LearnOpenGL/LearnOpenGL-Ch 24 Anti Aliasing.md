---
created: 2021-12-17
updated: 2021-12-21
---
 
 当渲染完一些物体后，可能会发现物体的边缘存在锯齿。锯齿是图像失真最常见的表现，减少失真的技术被称为 `Anti Aliasing` ，因为锯齿在各种失真表现中最为常见，所以 `Anti Aliasing` 常被翻译为抗锯齿。

图像的采样最小单位是像素，这是一个不连续的采样，像素的密集程度即是采样频率。如果图像的某一块频率很高（例如有颜色的跳变），而采样频率不够（未达到奈奎斯特采样频率），那么就会引起失真。

在光栅化时，会以每个像素的中点是否被图形覆盖来决定该物体是否要对这个像素的颜色做出贡献，该计算过程被称为 `Coverage` ，示意图如下：
![|400](assets/LearnOpenGL-Ch%2024%20Anti%20Aliasing/Untitled.png)

```ad-warning
`Coverage` 和 [Depth Testing](LearnOpenGL-Ch%2015%20Depth%20Testing.md) 中介绍的 `Occlusion` 共同决定了像素的可见性。
```

图中每个方块表示一个像素，方块中的点表示中心，点为红色表示像素中点在图形内，点为白色表示像素中心在图形外，采样的结果如下：
![|400](assets/LearnOpenGL-Ch%2024%20Anti%20Aliasing/Untitled%201.png)

# SSAA

`SSAA （Super Sample Anti-Aliasing）`会用比实际分辨率更高的分辨率来渲染场景（更高频率，消除了锯齿），然后再将图像下采样到实际分辨率。

但超采样将会有巨大的性能消耗，因为更高的分辨率更多的采样次数，无论是深度测试，模板测试，还是片元着色器的运行次数都会随着分辨率的上升而上升。

在上例中，如果使用了SSAA，上例中的每个方块会变的更小（同样的显示面积，像素数越多，像素大小越小），因此采样的精度会更高，最终锯齿会减少。

# MSAA

`MSAA（Multisamplaing Anti-Aliasing）` 的核心思想与 `SSAA` 类似，都是通过采样点的增加来减少锯齿。

但与 `SSAA` 不同的是，在 `MSAA` 中像素的数量仍然是不变的，但是每个像素会存在多个采样点，这些采样点被称为 `subsamples` ，如下所示：图中蓝色的是通过 `Coverage` 测试的 `subsamples` ，灰色的则是未通过的。MSAA的等级表示每个像素中 `subsamples` 的个数，如 `4X MSAA` 表示每个像素中有四个 `subsamples`。
![|400](assets/LearnOpenGL-Ch%2024%20Anti%20Aliasing/Untitled%202.png)

对于所有的 `subsamples` 都需要进行深度测试和模版测试，因此如果开启了 `4x MSAA`，则深度缓冲和模板缓冲的大小会变为四倍。

但并不是每个通过了 `Coverage` 的 `subsamples` 都需要通过片元着色器计算颜色。对于属于同一个像素的 `subsamples` ，最多需要计算一次颜色即可，且这个颜色的计算是基于像素的中心计算的，而不是 `subsamples` 的位置。但是每个 `subsamples` 还是需要存储颜色来区分它是否通过了 `Coverage` ，如下图所示，因此如果开启了 `4X MSAA`，则颜色缓冲的大小也会变为四倍。
![|500](assets/LearnOpenGL-Ch%2024%20Anti%20Aliasing/Untitled%203.png)

## MSAA Resolve

在得到 `subsamples` 的颜色后，会根据像素的各 `subsamples` 计算出该像素最后的颜色，这个过程被称为 `Resolve`。

通常而言， `Resolve` 采用的是一像素宽的 `盒滤波（Box Filter）` ，即会平均一个像素内所有 `subsamples` 的颜色。例，如果在四个 `subsamples` 中通过了两个，则这个像素的颜色为 50% 颜色缓冲中的颜色，与 50%片元计算得到的颜色的混合。如下所示：
![|500](assets/LearnOpenGL-Ch%2024%20Anti%20Aliasing/Untitled%204.png)

因为每个像素都会根据其中 subsamples 通过的数目得到一个混合的颜色，所以得到的物体的边缘会更平滑，如下所示：
![|400](assets/LearnOpenGL-Ch%2024%20Anti%20Aliasing/Untitled%205.png)

## MSAA in GLFW

如果要使用 `MSAA` ，首先需要通过 `glEnable` 开启：

```cpp
glEnable(GL_MULTISAMPLE);
```

由于MSAA影响的颜色/深度/模板缓冲都是由 [Framebuffers](LearnOpenGL-Ch%2019%20Framebuffers.md)  控制的，而如果不自定义帧缓冲，默认的帧缓冲由 `GLFW` 创建的窗口控制。因此在使用默认帧缓冲时，需要通过GLFW开启 `MSAA` ，在GLFW中开启 `MSAA` 只需要一条语句：

```cpp
glfwWindowHint(GLFW_SAMPLES, 4);
```

## 离屏MSAA

如果使用自定义的 `Framebuffer`，则需要为 `Framebuffer` 创建有 `subsamples` 的纹理附件或渲染缓冲对象。

创建有 `subsamples` 的纹理附件过程如下所示：

```cpp
glGenTextures(1, &multisampledTexture);
glBindTexture(GL_TEXTURE_2D_MULTISAMPLE, multisampledTexture);
glTexImage2DMultisample(GL_TEXTURE_2D_MULTISAMPLE, 4, GL_RGB, scene.GetWidth(), scene.GetHeight(), GL_TRUE);
glBindTexture(GL_TEXTURE_2D_MULTISAMPLE, 0);
```

主要区别为将纹理目标从 `GL_TEXTURE_2D` 变为了 `GL_TEXTURE_2D_MULTISAMPLE`，和纹理数据装填函数从 `glTexImage2D` 变为了 `glTexImage2DMultisample`， `glTexImage2DMultisample` 的第二个参数表示MSAA的等级

创建有 `subsamples` 的渲染缓冲对象的过程如下所示：

```cpp
glGenRenderbuffers(1, &rbo);
glBindRenderbuffer(GL_RENDERBUFFER, rbo);
glRenderbufferStorageMultisample(GL_RENDERBUFFER, 4, GL_DEPTH24_STENCIL8, scene.GetWidth(), scene.GetHeight());
glBindRenderbuffer(GL_RENDERBUFFER, 0);
```

主要区别是将 `glRenderbufferStorage` 函数变为了 `glRenderbufferStorageMultisample` 函数。

得到的有 `subsamples` 的颜色附件和渲染缓冲附件并不能直接的用于渲染，必须通过 `Resolve` 过程，该过程可以通过 `glBlitFramebuffer` 函数完成，该函数会拷贝一个范围的帧缓冲到另一个帧缓冲的部分范围中，且在拷贝的过程中会 `Resolve` 所有 `Multisampled buffers`：

```cpp
glBindFramebuffer(GL_READ_FRAMEBUFFER, multisampledFramebuffer);
glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
glBlitFramebuffer(0, 0, scene.GetWidth(), scene.GetHeight(), 0, 0, scene.GetWidth(), scene.GetHeight(), GL_COLOR_BUFFER_BIT, GL_NEAREST);
```

其中将使用了 `MSAA` 的帧缓冲作为读取对象，将默认的帧缓冲作为写入对象，在使用了 `glBlitFramebuffer` 后， `Resolved` 的缓冲会拷贝到默认帧缓冲中（不需要再一次的绘制）。

## Post-Processing with MSAA

如果需要在开启MSAA的情况下，使用后处理，则需要引入另一个无MSAA的帧缓冲。整个流程为：

1.  设置开启了MSAA的帧缓冲A，绑定颜色附件，深度/模板渲染缓冲对象
2.  设置未开启MSAA的帧缓冲B，仅需要绑定颜色附件
3.  绑定帧缓冲A，场景内容渲染至该帧缓冲A
4.  将帧缓冲B作为读取对象
5.  通过 Blit ，让帧缓冲B中的颜色附件获取 `Resolved` 的数据
6.  绑定默认帧缓冲0
7.  将帧缓冲B中的颜色附件绘制到帧缓冲0中，在绘制中可以通过片元着色器进行后处理

关键代码如下：

```cpp
MeshRender *screenMeshRender = new MeshRender(new Material(new Shader("./Framebuffer.vert", "./Framebuffer.frag")));
...
CreateMultiSampleFrameBuffer();
CreateIntermediateFrameBuffer();
...
scene.postRender = []() {
    // Blit the multiSampled framebuffer to intermediateFramebuffer
    glBindFramebuffer(GL_READ_FRAMEBUFFER, multisampledFramebuffer);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, intermediateFramebuffer);
    glBlitFramebuffer(0, 0, scene.GetWidth(), scene.GetHeight(), 0, 0, scene.GetWidth(), scene.GetHeight(), GL_COLOR_BUFFER_BIT, GL_NEAREST);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    screenMeshRender->DrawMesh();
};
```

# 结果与源码

未启用MSAA
![|500](assets/LearnOpenGL-Ch%2024%20Anti%20Aliasing/Untitled%206.png)

启用MSAA
![|500](assets/LearnOpenGL-Ch%2024%20Anti%20Aliasing/Untitled%207.png)

带后处理的MSAA

![|500](assets/LearnOpenGL-Ch%2024%20Anti%20Aliasing/Untitled%208.png)

[main.cpp](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/22.AntiAliasing/main.cpp)

[Framebuffer.frag](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/22.AntiAliasing/Framebuffer.frag)