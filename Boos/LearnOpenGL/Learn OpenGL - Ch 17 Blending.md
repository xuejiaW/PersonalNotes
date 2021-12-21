---
created: 2021-12-17
updated: 2021-12-18
---
混合是在 OpenGL 中实现物体透明度的一种技术。

透明物体指的是一个非纯色的物体，在他后面的物体的颜色将会叠加到他上面，比如窗子就是一种透明物体，窗子会将他后面的物体的颜色叠加在他上面。所以将其称为混合（混合多个物体的颜色）。

透明物体分为全透明和半透明，全透明物体所有的颜色都来自其背后的物体，半透明物体的颜色则是背后物体的颜色和自身的颜色叠加。

颜色的第四个参数 Alpha 设为 1，这表示为不透明物体，为 0 则是全透明，0-1 之间为半透明，alpha 值为 0.5 意味这个物体最终显示的颜色，一半来自于自身，一般来自于它背后的物体。

# 丢弃片段

对于不透明物体，首先要确保其 Alpha 值被正确的加载，即对于不带有透明通道的物体，使用 `GL_RGB` ，对于带有透明通道的物体，使用 `GL_RGBA` 。

```cpp
int nrChannels = 0;
unsigned char *data = stbi_load(texturePath.c_str(), &width, &height, &nrChannels, 0);
...
glTexImage2D(GL_TEXTURE_2D, 0, nrChannels == 3 ? GL_RGB : GL_RGBA, width, height, 0, nrChannels == 3 ? GL_RGB : GL_RGBA, GL_UNSIGNED_BYTE, data);
```

因为 OpenGL 默认不知道如何处理 alpha 值的，因此直接渲染带有 Alpha 通道的物体，其透明部分会显示为白色。
![|300](assets/LearnOpenGL-Ch%2017%20Blending/Untitled.png)

在片段着色器中可使用 `discard` 命令丢弃某一个片元，可以通过设置当 alpha 值小于某个阈值时，认为该像素是完全透明的，对该像素进行丢弃，代码如下：

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

启用混合后，OpenGL 使用如下方程来实现颜色叠加

$$C_{result}= C_{source}F_{source}+C_{destination}F_{destination}$$

- $C_{source}$： 需要画的片段的颜色
- $C_{destination}$： 在颜色缓冲中该片段对应位置已经有的颜色
- $F_{source}$:：指定的 alpha 对 source 颜色的影响
- $F_{destination}$： 指定的 alpha 对 destination 颜色的影响

着色器运行后，在所有的测试都通过后，这个混合方程才会被执行。如有红色和绿色两个平面，透明度分别为 1 和 0.6，两者示意图如下：
![|400](assets/LearnOpenGL-Ch%2017%20Blending/Untitled%202.png)
![|400](assets/LearnOpenGL-Ch%2017%20Blending/Untitled%203.png)

```ad-warning
Alpha通道同样需要进行混合，上述例子中计算后alpha通道值为0.76，表示计算后的像素为半透明。但这并不意味着例子中红色面板背后的颜色会透出来，因为渲染顺序是从红色面板后逐渐向前，即先红色面板背后物体，再是红色面板，再是绿色面板。因此这里得到的新半透明颜色只会影响后续盖在它上面的其他像素。
```

## glBlendFunc

对于上式中的 $F_{source}$和 $F_{destination}$ 可使用 `glBlendFunc` 函数设置，该函数的设置的选项同时对 RGB 和 Alpha 通道生效：

```cpp
glBlendFunc(Glunum sourceFactor,Glnum destinationFactor)
```

也可以使用 `glBlendFuncSeparate` 函数分别对 RGB 和 Alpha 进行设置：

```cpp
glBlendFuncSeparate(Glunum sourceRGB, Glnum destRGB, Glnum sourceAlpha, Glnum destAlpha);
```

上述两个函数中参数的可选项如下所示：

| 选项                        | 含义                                          |
| --------------------------- | --------------------------------------------- |
| GL_ZERO                     | 因子等于 0                                    |
| GL_ONE                      | 因子等于 1                                    |
| GL_SRC_COLOR                | 因子等于源颜色向量 $C_{source}$               |
| GL_ONE_MINUS_SRC_COLOR      | 因子等于 $1-C_{source}$                       |
| GL_DST_COLOR                | 因子等于目标颜色向量 $C_{destination}$        |
| GL_ONE_MINUS_DST_COLOR      | 因子等于 $1-C{destination}$                   |
| GL_STC_ALPHA                | 因子等于 $C_{source}$ 的 $alpha$ 分量         |
| GL_ONE_MINUS_SRC_ALPHA      | 因子等于 1- $C_{source}$ 的 $alpha$ 分量      |
| GL_DST_ALPHA                | 因子等于 $C_{destination}$ 的 $alpha$ 分量    |
| GL_ONE_MINUS_DST_ALPHA      | 因子等于 1- $C_{destination}$ 的 $alpha$ 分量 |
| GL_CONSTANT_COLOR           | 因子等于常数颜色向量 $C_{constant}$           |
| GL_ONE_MINUS_CONSTANT_COLOR | 因子等于 $1- C{constant}$                     |
| GL_CONSTANT_ALPHA           | 因子等于 $C_{constant}$ 的 $alpha$ 分量       |
| GL_ONE_MINUS_CONSTANT_ALPHA | 因子等于 $1-C_{constant}$ 的 $alpha$ 分量     |

其中的 $C_{constant}$ 可以通过 `glBlendColor` 设置：

```cpp
glBlendColor(GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha)
```

## glBlendEquation

可以通过 `glBlendEquation` 函数设置运算符：

```cpp
glBlendEquation(GLnum mode)
```

`mode` 有以下五种选项：

| 选项                     | 含义                       | 公式                          |
| ------------------------ | -------------------------- | ----------------------------- |
| GL_FUNC_ADD              | 两个向量相加，默认设置     | $C_{result} = Src + Dest$     |
| GL_FUNC_SUBTRACT         | 两个向量相减               | $C_{result} = Src - Dest$     |
| GL_FUNC_REVERSE_SUBTRACT | 将两个向量以相反的顺序相减 | $C_{result} = Dest - Src$     |
| GL_MIN                   | 取两个向量中较小的那个     | $C_{result} = min(Dest, Src)$ |
| GL_MAX                   | 取两个向量中较大的那个     | $C_{result} = max(Dest, Src)$ |

## 混合渲染流程

1.  启用混合并设置相应函数：

    ```cpp
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    ```

2.  当开启混合后，着色器中就不需要丢弃片段

    ```cpp
    void main()
    {
        FragColor=texture(ourTexture,texcoord);
    }
    ```

3.  因为在进行深度测试时，深度缓冲是不会检查片段是否是透明的，所以当存在混合时，应该先渲染离我们较远的物体，再渲染离我们较近的物体。当渲染一个有不透明物体和透明物体的场景时，大致的原则为：

    - 先绘制所有不透明物体
    - 对所有透明物体进行排序
    - 先渲染离得较远的透明物体

# 结果与源码
![|500](assets/LearnOpenGL-Ch%2017%20Blending/Untitled%204.png)

 [main.cpp](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/15.Blending/main.cpp)

 [Grass.frag](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/15.Blending/Grass.frag)
