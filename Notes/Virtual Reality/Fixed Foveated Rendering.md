---
Alias: FFR
tags:
    - Virtual-Reality
created: 2022-01-09
updated: 2022-01-24
---

# 像素密度问题

在 VR 中，渲染到平面屏幕上的内容会进一步被投射到曲面的镜片上，如下图所示。图中的半圆表示曲面镜片，中央的横线表示屏幕。在曲面上去角度相同的区域，可以看到越靠近曲面边缘的部分，在平面屏幕上需要的像素越多。

![|300](assets/Fixed%20Foveated%20Rendering/Untitled.png)

因此，在曲面镜片上，越靠近边缘的部分，像素密度越大，这是与实际的需要相悖的。实际需求中，越重要的内容应该有更高的像素进行渲染，而在镜片边缘的内容通常来说是不重要的。

为了确定镜片上哪一部分的内容更重要，通常需要用到眼部追踪来确定用户的视线。而 Fixed Foveated Rendering 假设重要的内容永远出现在镜面的中心（绝大部分情况确实如此），因此称为 Fixed。

# 节省像素

因为一体机运行在移动平台上，而移动平台的渲染是将整个屏幕分为多个 Tile。可以给不同的 Tile 设置不同的分辨率来减少需要渲染的像素。

![|500](assets/Fixed%20Foveated%20Rendering/Untitled%201.png)

如上图所示，白色的部分为球面镜片的中心，以全分辨率渲染。红色部分以$1/2$的分辨率进行渲染，绿色部分以 $1/4$ 分辨率进行渲染，蓝色部分以 $1/8$ 分辨率渲染，紫色部分以 $1/16$ 分辨率渲染。

需要注意的是 FFR 必然会导致边缘内容的模糊，而当内容是文字时，会造成较明显的影响，如下所示，从左到右，FFR 的等级逐渐变高。

![|500](assets/Fixed%20Foveated%20Rendering/Untitled%202.png)

# 实现方法

传统做法是将 FrameBuffer，拆分成多个小块，对每个小块已更低的像素进行渲染，然后再将小块绘制到总的 FrameBuffer 上。如原先分辨率为 $100 \times 100$，将其拆分为四个 $25\times 25$的小块，但是每个小块实际上以 $10*10$ 的分辨率绘制，再绘制完后再将其拉伸到 $25\times25$，并拷贝到 FrameBuffer 上。

更高效的做法是通过修改渲染管线，在移动端的 GPU 上，通常 [Tile-Based Rendering](../Computer%20Graphics/Tiled-Baed%20Rendering.md#Tile-Based%20Rendering) ，可以直接通过修改Tile绘制到Framebuffer上时的流程来实现FFR，即对每一个Tile进行更低分辨率的渲染，最后再将每个Tile进行拉伸并绘制到最终FrameBuffer上。

## 高通 Foveat FrameBuffer API

### FramebufferFoveationConfigQCOM

```cpp
void glFramebufferFoveationConfigQCOM( uint fbo, uint numLayers,
    uint focalPointsPerLayer, uint requestedFeatures, uint *providedFeatures);
```
- `fbo` ：绑定的 Framebuffer Object
- `numLayers` ：一共需要多少层 Layer
- `focalPointsPerLayer` ：每层 Layer 有多少个聚焦点
    - 如果使用一张两倍宽的图作为左右眼时，则需要两个聚焦点，一个表示左眼聚焦点，一个表示右眼聚焦点
- `requestedFeatures` ：需要的功能
    - `FOVEATION_ENABLE_BIT_QCOM` ：开启 Foveation
    - `FOVEATION_SCALED_BIN_METHOD_BIT_QCOM` ：使用常规的实现方法来实现 Foveation
- `providedFeatures` ：支持的功能
    - 通过引用返回告诉引用支持哪些 Foveation 功能。

```ad-warning
如果要使用Foveationn，则必须在程序一开始就调用该函数。如果先绘制到非Foveat的FrameBuffer上，再调用此函数，则结果是未定义的。
```

### FramebufferFoveationParametersQCOM

```cpp
glFramebufferFoveationParametersQCOM( uint fbo,uint layer, uint focalPoint,
    float focalX, float focalY, float gainX, float gainY, float foveaArea);
```

- `fbo`：绑定的 Framebuffer Object
- `layer`：当前处理的 Layer
- `focalPoint`：当前处理的 focalPoint
- `focalX`：聚焦点，X
- `focalY`：聚焦点，Y
- `gainX`：X 轴分辨率下降速度，越大越快
- `gainY`：Y 周分辨率下降速度，越大越快
- `foveaArea`：聚焦区域，在该区域内分辨率不会下降

```ad-warning
当不调用该参数时，默认值： focalX=focalY=0; gainX=gainY=0; foveaArea=0; 表示整个Framebuffer分辨率不下降
```

### 像素密度计算方法

设某一点的像素为 $(P_x, P_y)$，焦点为 $(Focal_x,Focal_y)$，则像素密度计算公式为：

$$ \frac{1}{(focal_x-p_x)^2\times {gain_x}^2 + (focal_y-p_y)^2\times {gain_y}^2 - foveaArea} $$

```ad-tip
所有数值在NDC空间下
```

### 示例：

```cpp
GLuint fbo = createFramebufferAndAttachments();
GLuint providedFeatures;
glFramebufferFoveationConfigQCOM(fbo,1,1, GL_FOVEATION_ENABLE_BIT_QCOM, &providedFeatures);
if(!(providedFeatures & GL_FOVEATION_ENABLE_BIT_QCOM))
{
// Failed to enable foveation
}

GLfloat focalX=0.f, focalY=0.f;  // Setup focal point at the center of screen
GLfloat gainX=4.f, gainY=4.f;  // Increase these for stronger foveation
glFramebufferFoveationParametersQCOM(fbo, 0, 0, focalX, focalY, gainX, gainY, 0.0f);
```

## 高通 Foveat Texture API

该相关API是用来设置Framebuffer的颜色附件的Foveat属性，它与上述 Foveat Framebuffer 相关设置是冲突的，即两者不能同时设置为开启，否则 `glCheckFramebufferStatus` 函数会返回 `FRAMEBUFFER_INCOMPLETE_FOVEATION_QCOM`。

```ad-warning
关于深度缓冲和模板缓冲，并没有相应的设置Foveation的接口。但当颜色附件设置Foveation后，深度缓冲和模板缓冲都会继承颜色附件的相应设置。
```

### glGetTexParameteriv

可以通过 `TEXTURE_FOVEATED_FEATURE_QUERY_QCOM` 和 `TEXTURE_FOVEATED_NUM_FOCAL_POINTS_QUERY_QCOM` 两个参数，查询 Foveat Texture 支持的功能能和所能支持的焦点数。
```cpp
glGetTexParameteriv(GL_TEXTURE_2D,
                        GL_TEXTURE_FOVEATED_FEATURE_QUERY_QCOM,
                        &query);
```

### glTexParameteri

关于Foveat Texture的开启/关闭和使用的方法等相关设置，通过 `GL_TEXTURE_FOVEATED_FEATURE_BITS_QCOM` 目标进行修改，可选参数与 Foveat Framebufer 相同，有 `FOVEATION_ENABLE_BIT_QCOM` 和 `FOVEATION_SCALED_BIN_METHOD_BIT_QCOM` 。设置如下：
```cpp
glTexParameteri(GL_TEXTURE_2D,
                    GL_TEXTURE_FOVEATED_FEATURE_BITS_QCOM,
                    GL_FOVEATION_ENABLE_BIT_QCOM |
                    GL_FOVEATION_SCALED_BIN_METHOD_BIT_QCOM);
```

关于最低像素密度的设置，可以通过 `GL_TEXTURE_FOVEATED_MIN_PIXEL_DENSITY_QCOM` 目标进行修改，可以设置 $0.0 \sim 1.0$ 的值。
```cpp
glTexParameteri(GL_TEXTURE_2D, 
	GL_TEXTURE_FOVEATED_MIN_PIXEL_DENSITY_QCOM, 0.5f);
```

### TextureFoveationParametersQCOM

与 `glFramebufferFoveationParametersQCOM` 函数类似，设置Foveat相关参数：
```cpp
void GL_TextureFoveationParametersQCOM(uint  texture,
                                        uint  textureIndex, // 当texture是 Texture 数组时有用
                                        uint  focalPoint,
                                        float focalX,
                                        float focalY,
                                        float gainX,
                                        float gainY,
                                        float foveaArea);
```

### 示例：
```cpp
GLuint foveatedTexture;
glGenTextures(1, &foveatedTexture);
glBindTexture(GL_TEXTURE_2D, foveatedTexture);
...
// Set texture as foveated
 glTexParameteri(GL_TEXTURE_2D,
                 GL_TEXTURE_FOVEATED_FEATURE_BITS_QCOM,
                 GL_FOVEATION_ENABLE_BIT_QCOM | GL_FOVEATION_SCALED_BIN_METHOD_BIT_QCOM);
...
// Rendering to foveatedTexture
...
// Set foveation parameters on texture
glTextureFoveationParametersQCOM(foveatedTexture, 0, 0, focalX, focalY, gainX, gainY, 0.0f);
glFlush();
```

### FOVEATION_SUBSAMPLED_LAYOUT_METHOD_BIT_QCOM

- `GL_FOVEATION_SUBSAMPLED_LAYOUT_METHOD_BIT_QCOM` 与 `GL_FOVEATION_SCALED_BIN_METHOD_BIT_QCOM` 相同，都是设置Foveation方法的参数，通过 `glTexParameteri` 函数进行设置。
- `GL_FOVEATION_SCALED_BIN_METHOD_BIT_QCOM` 采用的方法是将每一个Tile以更低分辨率渲染后，再进行拉伸并填充到整个FrameBuffer上。
- `GL_FOVEATION_SUBSAMPLED_LAYOUT_METHOD_BIT_QCOM` 则是在每个Tile以更低分辨率渲染后，直接对这些更低分辨率的结果进行采样，即减少了拉伸和填充的操作，可以减少一部分的内存消耗。

# Reference

[Optimizing Oculus Go for Performance](https://developer.oculus.com/blog/optimizing-oculus-go-for-performance/)
https://www.khronos.org/registry/OpenGL/extensions/QCOM/QCOM_framebuffer_foveated.txt
https://www.khronos.org/registry/OpenGL/extensions/QCOM/QCOM_texture_foveated.txt
https://www.khronos.org/registry/OpenGL/extensions/QCOM/QCOM_texture_foveated_subsampled_layout.txt