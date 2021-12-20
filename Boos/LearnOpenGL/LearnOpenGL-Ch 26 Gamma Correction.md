---
created: 2021-12-20
updated: 2021-12-21
---
# 人眼感知与真实物理世界的差距

如存在一个从全黑到全白的颜色变化，将这个变化的中点称为是中灰。理论上如果纯白物体的反射率为 100%，纯黑物体的反射率为0%，那么中灰物体的反射率应该为50%。 但假设有无数多的灰度逐渐变化的颜色，让人选择出其中的中灰，实际上人会选出反射率在20%左右的物体，而并非理论上的50%反射率。

人眼对于光线性变化的感知和光真实的线性变化的感知是不同的。如下所示，上半部分是人眼感知的线性变化，下半部分是真实的线性变化。

![](assets/LearnOpenGL-Ch%2026%20Gamma%20Correction/Untitled.png)

人感知到的光的变化和实际的光的变换，转换关系大致可以表示为 $Perceived = {Physical}^{2.2}$，数值范围为 $0.0 \sim 1.0$。

也因此为了让显示器的光亮变化更符合人的感知，显示器在最终画面输出前都会对其进行一个指数运算（次幂通常为2.2），即将上图中下半部分的真实颜色转换为上半部分的人眼需要感知的颜色。这个过程称为 `Gamma变换` 。

```ad-warning
早期的阴极射线管（CRT）显示器，光亮变化与电压的关系差不多也是 $v^{2.2}$ 的关系。 数值与人眼对光的感知几乎一致，但这个只是巧合。
```

因此所有使用显示器的画面都并非物理正确，而是在显示器上看起来正确。

但显示设备的转换会造成输出图像的程序产生问题，如在程序中将光亮调高一倍，但实际在显示器上亮度增长了约4.6倍（$2^{2.2}=4.59$），所以需要进行 Gamma 矫正。

```ad-warning
将所有经过了 `Gamma 变换` 的颜色空间，称为 `sRGB` 空间
```

# Gamma 矫正

为了在显示设备上展现出真实物理世界应当有的颜色就必须进行 `Gamma矫正`，消除显示器对最终显示色彩的影响。因为显示器会对输出图像进行次幂为 2.2 的指数变换，因此 Gamma矫正的实际工作就是做次幂为 $\frac{1}{2.2}$ 的指数变换，如下图所示：
![|400](assets/LearnOpenGL-Ch%2026%20Gamma%20Correction/Untitled%201.png)

如想准确的输出 $(0.5,0,0)$，先进行Gamma矫正，$(0.5,0,0)^{0.45}= (0.73,0,0)$，当显示器进行输出时会进行Gamma变换，即 $(0.73,0,0)^{2.2}=(0.5,0,0)$

# 采用Gamma 矫正

## GL_FRAMEBUFFER_SRGB

在OpenGL中可以通过 `glEnable` 开启 Gamma 矫正：

```glsl
glEnable(GL_FRAMEBUFFER_SRGB);
```

当开启时，OpenGL会自动的在每个片元着手器运行后，对输出的颜色进行Gamma矫正后再写入之后的 `Framebuffer` 。在有多个 `Framebuffer` 的情况下，通常只在最后上屏的 `Framebuffer` 前开启，这样才能保证中间 `Framebuffer` 绘制时，都是在线性空间中。

```cpp
scene.preRender = []() {
    // When using built-in gamma correction, should disable GL_FRAMEBUFFER_SRGB during intermediate processing
    // to ensure all the processing are in linear color space
    glDisable(GL_FRAMEBUFFER_SRGB);
    ...
};

scene.postRender = []() {
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    // When using built-in gamma correction, only enable GL_FRAMEBUFFER_SRGB when rendering to default framebuffer
    glEnable(GL_FRAMEBUFFER_SRGB);
    screenMeshRender->DrawMesh();
};
```

## Shader进行Gamma矫正

另一种 Gamma矫正的做法就是在片元着色器中自己实现 Gamma矫正，只需要在最后颜色输出的时候进行一个 $\frac{1}{2.2}$ 的指数运算即可：

```glsl
// linear space calculation

FragColor.rgb = pow(FragColor.rgb,vec3(1.0 / 2.2));
```

但这样做，需要对每个影响最后上屏的物体的片元着色器中都加入这句Gamma矫正。因此一个更简便的方法是用Framebuffer，在最后利用后处理完成 Gamme矫正。

## sRGB Textures

在使用了上述 Gamma矫正后，会发现纹理会变得过于亮。如下所示：
![|500](assets/LearnOpenGL-Ch%2026%20Gamma%20Correction/Untitled%202.png)

这是因为在开启Gamma矫正后，纹理实际上经过了两次矫正。如果一张纹理是由设计师制作的，设计师必然是通过显示器去创作这张纹理的，即这个纹理实际上是在 `SRGB` 空间上有设计师理想的显示效果。

即，如果这张纹理在屏幕上 `看起来` 是线性空间的，则说明纹理是以 $\frac{1}{2.2}$ 空间的颜色保存的，这样在经过了显示器 $2.2$ 的 Gamma变换后，才会是正常效果。如果在此时对纹理进行了 Gamma矫正，那么最后在屏幕上看到的颜色就是在$\frac{1}{2.2}$ 空间，所以会显得更亮。

一个解决方法是在着色器中，为纹理进行 Gamma 反矫正，即将纹理数据从 $\frac{1}{2.2}$ 空间变到线性空间。如下：

```glsl
vec3 color = pow(texture(floorTexture,fs_in.TexCoords).rgb,vec3(2.2));
```

另一个方法是在调用 `glTexImage2D` 函数时，告知OpenGL纹理是该纹理是sRGB纹理 ，如下所示：

```cpp
glTexImage2D(GL_TEXTURE_2D, 0, GL_SRGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, image);
// Or
glTexImage2D(GL_TEXTURE_2D, 0, GL_SRGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, image);
```

`GL_SRGB` 和 `GL_SRGB_ALPHA` 分别是 `GL_RGB` 和 `GL_RGBA` 的 sRGB版本。

```ad-warning
并非所有的纹理都是 sRGB 纹理，通常只有依靠人眼视觉效果产出的纹理是 sRGB纹理。如漫反射贴图通常表示物体看起来的样子，因此通常是sRGB纹理。而镜面反射系数贴图或法线贴图则通常是线性纹理。
```
当修复了 sRGB 两次Gamma矫正后，效果如下：
![|400](assets/LearnOpenGL-Ch%2026%20Gamma%20Correction/Untitled%203.png)

# 光线衰减

在真实物理世界中，光线衰减的速度基本与距离的平方相关，即

```cpp
float attenuation = 1.0 / (distance * distance);
```

但在之前的 [Light Casters, Multiple Lights](https://www.notion.so/Light-Casters-Multiple-Lights-90112da3fdbd483699bd89d1e5ea94c9) 中，是以距离的一次项为主导，而非距离的二次项。

这是因为如果使用的是二次项，则在显示器Gamma变换的作用下，衰减速度会变为 $（1/{\text{distance}^2}）^{2.2} = 1/ \text{distance}^{4.4}$。而以一次项作为衰减的主要贡献时，衰减速度则会变为： $1/ \text{distance}^{2.2}$，即与真实世界物理规律相近。

```ad-warning
引入了 Gamma校正后，衰减应当以二次项作为主导，否则以一次项主导。
```

# 源码：
[main.cpp](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/24.GammaCorrection/main.cpp)

[blinn-phone.fs](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/24.GammaCorrection/blinn-phone.fs)

[Framebuffer.frag](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/24.GammaCorrection/Framebuffer.frag)

# Reference

[色彩校正中的 gamma 值是什么？ - 知乎 (zhihu.com)](https://www.zhihu.com/question/27467127/answer/37555901)
 