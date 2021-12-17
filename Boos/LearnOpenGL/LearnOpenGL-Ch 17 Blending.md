混合是在OpenGL中实现物体透明度的一种技术。

透明物体指的是一个非纯色的物体，在他后面的物体的颜色将会叠加到他上面，比如窗子就是一种透明物体，窗子会将他后面的物体的颜色叠加在他上面。所以将其称为混合（混合多个物体的颜色）。

透明物体分为全透明和半透明，全透明物体所有的颜色都来自其背后的物体，半透明物体的颜色则是背后物体的颜色和自身的颜色叠加。

颜色的第四个参数Alpha设为1，这表示为不透明物体，为0则是全透明，0-1之间为半透明，alpha值为0.5意味这个物体最终显示的颜色，一半来自于自身，一般来自于它背后的物体。

# 丢弃片段

对于不透明物体，首先要确保其 Alpha值被正确的加载，即对于不带有透明通道的物体，使用 `GL_RGB` ，对于带有透明通道的物体，使用 `GL_RGBA` 。

```cpp
int nrChannels = 0;
unsigned char *data = stbi_load(texturePath.c_str(), &width, &height, &nrChannels, 0);
...
glTexImage2D(GL_TEXTURE_2D, 0, nrChannels == 3 ? GL_RGB : GL_RGBA, width, height, 0, nrChannels == 3 ? GL_RGB : GL_RGBA, GL_UNSIGNED_BYTE, data);
```

因为OpenGL默认不知道如何处理alpha值的，因此直接渲染带有Alpha通道的物体，其透明部分会显示为白色。
![|300](assets/LearnOpenGL-Ch%2017%20Blending/Untitled.png)

在片段着色器中可使用 `discard` 命令丢弃某一个片元，可以通过设置当alpha值小于某个阈值时，认为该像素是完全透明的，对该像素进行丢弃，代码如下：

```cpp
void main()
{
    vec4 texColor=texture(ourTexture,texcoord);
    if(texColor.a<0.1)
        discard;
    FragColor=texColor;
}
```

结果为：
![|300](assets/LearnOpenGL-Ch%2017%20Blending/Untitled%201.png)

# 混合

在上面的例子中，只区分了不透明物体和全透明物体，并对于全透明物体做了直接丢弃片段的操作。

但这样的做法无法满足半透明效果，半透明效果需要用到混合（Blending）。

```cpp
glEnable(GL_BLEND);
```

启用混合后，OpenGL使用如下方程来实现颜色叠加

$$C_{result}= C_{source}F_{source}+C_{destination}F_{destination}$$

-   $C_{source}$： 需要画的片段的颜色
-   $C_{destination}$： 在颜色缓冲中该片段对应位置已经有的颜色
-   $F_{source}$:：指定的alpha对source颜色的影响
-   $F_{destination}$： 指定的alpha对destination颜色的影响

着色器运行后，在所有的测试都通过后，这个混合方程才会被执行。如有红色和绿色两个平面，透明度分别为1 和 0.6，两者示意图如下：
![|400](assets/LearnOpenGL-Ch%2017%20Blending/Untitled%202.png)
![|400](assets/LearnOpenGL-Ch%2017%20Blending/Untitled%203.png)

```ad-warning
Alpha通道同样需要进行混合，上述例子中计算后alpha通道值为0.76，表示计算后的像素为半透明。但这并不意味着例子中红色面板背后的颜色会透出来，因为渲染顺序是从红色面板后逐渐向前，即先红色面板背后物体，再是红色面板，再是绿色面板。因此这里得到的新半透明颜色只会影响后续盖在它上面的其他像素。
```

## glBlendFunc

对于上式中的 $F_{source}$和 $F_{destination}$ 可使用 `glBlendFunc`函数设置，该函数的设置的选项同时对RGB和Alpha通道生效：

```cpp
glBlendFunc(Glunum sourceFactor,Glnum destinationFactor)
```

也可以使用 `glBlendFuncSeparate` 函数分别对 RGB和Alpha 进行设置：

```cpp
glBlendFuncSeparate(Glunum sourceRGB, Glnum destRGB, Glnum sourceAlpha, Glnum destAlpha);
```

上述两个函数中参数的可选项如下所示：

| 选项                        | 含义      |
| --------------------------- | --------- |
| GL_ZERO                     | 因子等于0 |
| GL_ONE                      |    因子等于1       |
| GL_SRC_COLOR                |    因子等于yuan       |
| GL_ONE_MINUS_SRC_COLOR      |           |
| GL_DST_COLOR                |           |
| GL_ONE_MINUS_DST_COLOR      |           |
| GL_STC_ALPHA                |           |
| GL_ONE_MINUS_SRC_ALPHA      |           |
| GL_DST_ALPHA                |           |
| GL_ONE_MINUS_DST_ALPHA      |           |
| GL_CONSTANT_COLOR           |           |
| GL_ONE_MINUS_CONSTANT_COLOR |           |
| GL_CONSTANT_ALPHA           |           |
| GL_ONE_MINUS_CONSTANT_ALPHA |           |
|                             |           |
