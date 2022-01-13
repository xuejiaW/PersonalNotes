---
cssclass: [table-border]
tags:
    - Computer-Graphics
created: 2022-01-06
updated: 2022-01-14
---

# 透明像素造成的失真

对于一张带有完全透明像素的纹理，从直觉上会觉得完全透明像素的RGB通道色彩是不重要的。毕竟Alpha通道值为0，无论RGB通道是什么颜色，最终都不会被显示出来，但实际并非如此。

如下，生成三张完全透明像素的RGB通道值不一样的图，从左至右，完全透明像素RGB通道颜色分别为绿色，蓝色，红色：

|                                                                              |                                                                              |                                                                              |
| ---------------------------------------------------------------------------- | ---------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| ![](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/Untitled.png)     | ![](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/Untitled%202.png) | ![](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/Untitled%204.png) |
| ![50](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/Untitled%201.png) | ![50](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/Untitled%203.png) | ![50](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/Untitled%205.png) |

在上述纹理移动的过程中，可以看到拥有不同颜色的透明像素的图，会显示出不同颜色的拖影，如下所示，最右侧的纹理的拖影是理想的状态，该纹理的不透明像素为红色：
![](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/cross_anim.gif)

不透明像素为蓝色的纹理移动过程中的具体变换如下，其中黑色线框表示纹理的边界，背后的小格子表示屏幕的像素：
![|300](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/blue_cross_move.gif)

可以看到当纹理的像素与屏幕的像素并未完全对齐时，会出现拖影。其根本原因是纹理的双线性采样导致，当纹理渲染的屏幕上时，如果屏幕的像素中点与纹理的像素中点并不完全匹配时，GPU将会采样周围多个纹理像素的颜色，并将其混合得到最终的颜色。

如果仅考虑横向两个像素的合并，且在某一帧屏幕像素中心正好处在纹理相邻像素的边界上，则GPU从该纹理上采样得到的颜色为纹理上这两个相邻像素的平均，下图中即为一个红色不透明像素和一个蓝色纯透明像素：

$$ 0.5 \cdot\left[\begin{array}{l}1 \\0 \\0 \\1\end{array}\right]+0.5 \cdot\left[\begin{array}{l}0 \\0 \\1 \\0\end{array}\right]=\left[\begin{array}{c}0.5 \\0 \\0.5 \\0.5\end{array}\right] $$

![|300](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/Untitled%206.png)

因为得到的像素颜色是半透明的（Alpha值为0.5），因此当这个像素需要被绘制到屏幕上时，会与当前纹理缓冲中的颜色（本例中为白色）进行Alpha 混合，如下公式所示，该颜色就是最终上屏的颜色，如下右所示：
$$ \begin{array}{l}\alpha_{\text {sprite}} \cdot R G B_{\text {sprite}}+\left(1-\alpha_{\text {sprite}}\right) \cdot R G B_{\text {Background}}\\ \\=0.5 \cdot\left[\begin{array}{c}0.5 \\0 \\0.5 \\ 0.5\end{array}\right]+(1-0.5) \cdot\left[\begin{array}{c}1 \\1 \\1 \\ 1\end{array} \right] \\ \\= \left[\begin{array}{c} 0.75 \\ 0.5 \\ 0.75 \\ 0.75 \end{array}\right] \end{array} $$

![|50](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/Untitled%207.png)

但这个颜色显然是不对的，因为原始纹理中不透明像素的颜色为红色，所以拖影的颜色应当是红色作为主导颜色，而在上述公式中得到的颜色红色和蓝色的占比相同（都为0.75）。

其根本原因就是在双线性采样时，GPU将完全透明的蓝色与完全不透明的红色进行了混合，纹理采样出的颜色变为 $[ 0.5 \quad 0 \quad 0.5 \quad 0.5]$，即此时红色和蓝色就已经有个相同的贡献比。而完全透明的蓝色像素不应该在双线性采样时对最终输出的像素颜色做出贡献。

直观上来说，拖影颜色应该是由红色的不透明像素与白色底共同形成，即得到的颜色应当是 $[ 1 \;\; 0 \;\; 0 ]$ 和 $[1 \;\; 1 \;\; 1 ]$ 混合得到，即应当得到 $[1 \;\; 0.5 \;\; 0.5]$。如下所示：
![|50](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/_20201223115730.png)

而例子中最右侧的红色透明像素可以处理的原因是当透明像素的颜色与不透明像素的颜色相同时，即使透明像素的颜色有了错误的贡献比，也不会对最终产生的像素颜色产生干扰。

即用红色透明像素（$[1 \; 0 \; 0 \;0]$）取代上述公式中的蓝色透明像素（$[0 \; 1 \; 0 \;0]$），计算可得的颜色为 $[1 \;\; 0.5 \;\; 0.5 \;\; 0.75]$，也同样满足要求。

# 物理解释

## Conventional Alpha

对于目前大部分的程序或者纹理资源，定义透明度的方式如下：

-   RGB通道表示物体的颜色
-   A通道表示物体的透明度（How Solid It Is）

在这种定义方式下，颜色和透明度是相互独立的。如一个不透明的红色像素定义为 $[1 \;\; 0 \;\;0 \;\;1]$，一个透明的红色像素定义为 $[1 \;\; 0 \;\;0 \;\;0]$，即无论A通道如何改变，RGB通道并不会受影响。

因此在考虑透明度的情况下，计算一个像素的颜色，应该将它的颜色与透明度相乘：

$source.rgb * source.alpha$。如果要进行Alpha混合的话，公式如下：
$$ result = (source.rgb * source.a) + (dest.rgb * (1 - source.a)) $$

对于这种处理方法并没有现实中的物理概念与之对应。但从科幻角度来说，透明衣服应当是这个原理：衣服本身有它的颜色，变透明的过程中衣服的颜色并没有变化，变化的是衣服的透明度。

## Premultiplied Alpha

对于Premultiplied Alpha的资源，定义透明度的方式如下：

-   RGB通道表示对最终的显示效果贡献了多少颜色
-   A通道表示它物体的透明度

在这种定义方式下，颜色和透明度是耦合的。当一个物体的透明度下降时，它对于最终显示效果的贡献也必然会下降，因此RGB通道的值也会下降。即一个透明度为0的物体，它的RGB通道颜色必然为0。

但此处的RGB为0并不意味着颜色为黑色，而是表示对最终显示不贡献任何颜色，即无颜色。

在考虑透明度的情况下，该像素的颜色直接由RGB通道提供，即 $source.rgb$。如果要进行Alpha混合的话，公式如下：

```glsl
result =  source.rgb + (dest.rgb * (1 - source.a))
```

这种处理方法与现实中的光照类似，一块透明的玻璃，它就是没有颜色。

## 示例

对于全透明的像素在Alpha Premultiplication后会变为 $[0 \;\; 0 \;\;0 \;\;0]$，看上去与直接将Clear Color设为 $[0 \;\; 0 \;\;0 \;\;0]$ 没有区别。

但当没有进行Alpha Premultiplication时，RGB通道与A通道是相互独立的，所以在Blending时，RGB通道仍然需要与A通道相乘。使用Alpha Premultiplycation时，RGB通道与A通道耦合，在Blending时不需要与A通道再次相乘。

如有一个绿色像素（ $[0 \;\; 1 \;\;0 \;\;1]$），它的边上是一个黑色的全透明像素（$[0 \;\; 0 \;\;0 \;\;0]$），且此时背景色是红色的（$[1 \;\; 0 \;\;0 \;\;1]$）。理想上来说，将绿色的半透明像素叠加到红色像素上，应当得到黄色的像素，即RGB通道值为 $[0.5 \;\; 0.5 \;\; 0]$ 的像素。

如果使用的是传统Alpha计算，则在双线性过滤后得到的像素颜色为 $[0 \;\; 0.5 \;\;0 \;\;0.5]$，此时该像素表达的意义是，一个透明度为0.5，颜色为 $[0 \;\; 0.5 \;\; 0]$ 的像素，即一个半透明的深绿色像素。此时与背景色进行混合：

$$ \begin{array}{l}0.5 \cdot\left[\begin{array}{c} 0 \\0.5 \\0 \end{array}\right]+(1-0.5) \cdot\left[\begin{array}{c}1 \\0 \\0 \end{array} \right] \\ \\= \left[\begin{array}{c} 0.5 \\ 0.25 \\ 0 \end{array}\right] \end{array} $$

即得到最终结果为 $[0.5 \;\; 0.25 \;\;0]$，可以发现绿色通道的颜色比理想状况要低。这是因为在混合时，含义变为了一个深绿色半透明像素与红色底进行混合。

当使用Alpha Premultiplication后，虽然绿色像素和黑色像素的数值仍然不变，过滤后得到的还是 $[0 \;\; 0.5 \;\;0 \;\;0.5]$。但此时该像素的意义是，一个透明度为0.5，贡献了一半绿色的像素（透明度与颜色耦合）。此时进行混合：

$$ \begin{array}{l}\left[\begin{array}{c} 0 \\0.5 \\0 \end{array}\right]+(1-0.5) \cdot\left[\begin{array}{c}1 \\0 \\0 \end{array} \right] \\ \\= \left[\begin{array}{c} 0.5 \\ 0.5 \\ 0 \end{array}\right] \end{array} $$

结果是正确的，因为此时的含义是一个贡献了屏幕一半绿色的像素放到红色底上，在红色底提供了另一半红色后，即得到了黄色。

# 解决方案

要解决透明像素造成的失真：

第一个思路是保证即使像素计算时的含义发生了变化，最后的结果也是准确的，即使用 `Flodd-Filling` 方法。

第二个思路是采用 `Alpha-Premultiplication` 方法，让整个计算过程有正确的含义。

## Flood-Filling / Edge-Padding

对于设计师，可以将透明像素的颜色填充为周围不透明像素的颜色，这样的话即使因为双线性过滤让透明像素的颜色有了错误的贡献比，也不会造成最终颜色的错误。

如下是GTAV中，对于透明纹理的处理，左侧为RGBA输出，右侧为RGB输出。可以看到在透明像素的颜色做了特殊处理。

|                                                                                         |                                                                                         |
| --------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| ![](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/image-20220106224248879.png) | ![](assets/Computer%20Graphics%20-%20Premultiplied%20Alpha/image-20220106224255884.png) | 

但 `Flood-Filling` 存在两个问题：
1. 透明像素的颜色与临近的不透明像素的颜色并不是完全相同的，而这种情况下透明像素的颜色很难定义
2. 颜色不为黑的透明像素，在纹理压缩时会产生问题，因此设计师进行的Flood-Filling操作可能在纹理压缩后失效[^1]。

## Alpha Premultiplication

对于程序员而言，在很多时刻无法控制拿到的纹理素材，因此需要一个方法来保证所有的纹理都能渲染正确，无论它的透明像素是什么颜色，该方法就是 `Alpha Premultiplication` 。

采用该方法的步骤很简单，第一步改写纹理素材的RGB通道，将其与Alpha通道的数值进行相乘，即做如下的转换：

$$ \left[\begin{array}{c}R \\G \\B \\\alpha\end{array}\right] \Rightarrow \left[\begin{array}{c} \alpha \cdot R \\ \alpha \cdot G \\ \alpha \cdot B \\ \alpha \end{array}\right] $$

该变换是针对 纹理素材 的，因此需要在读取纹理时进行操作。如在Unity中可以利用 `AssetPostprocessor` 类，在纹理素材导入后，对纹理的每个像素进行改写，如下：

```csharp
public sealed class TextureAlphaPremultiplier : AssetPostprocessor
{

    public void OnPreprocessTexture()
    {
        if (ShouldPremultiplyAlpha())
            ((TextureImporter)assetImporter).alphaIsTransparency = false;
    }

    public void OnPostprocessTexture(Texture2D texture)
    {
        if (!ShouldPremultiplyAlpha()) return;

        int width = texture.width, height = texture.height;

        for (int x = 0; x < width; ++x)
            for (int y = 0; y < height; ++y)
                texture.SetPixel(x, y, PreMultiplyAlpha(texture.GetPixel(x, y)));

        texture.Apply();
        Debug.Log("Automatically premultiplied alpha for " + assetPath);
    }

    private static Color PreMultiplyAlpha(Color color)
		{
				return new Color(color.r * color.a, color.g * color.a, color.b * color.a, color.a);
		}

    private bool ShouldPremultiplyAlpha()
		{ 
				return assetPath.StartsWith("Assets/") && assetPath.EndsWith(".png", StringComparison.OrdinalIgnoreCase);
		}
}
```

```ad-error
 Unity中导入纹理资源时的选项 `Alpha Is Transparency` 并没有进行 Alpha Premultiplication操作，它只不过是对纹理的边缘像素进行了颜色调整

```

❗ 注意在片段着色器中的如下操作并不会产生 `Alpha Premultiplication`的效果。因为纹理的像素的读取在 `tex2D` 函数中发生，当函数调用后，透明像素的颜色可能导致的失真就已经发生了：

```glsl
fixed4 frag (v2f i) : SV_Target
{
    fixed4 col = tex2D(_MainTex, i.uv);
    col.rgb *= col.a;
    return col;
}
```

但这并不意味着使用片段着色器中进行 `Alpha Premultiplication` 的场景不会发生。假设在运行时生成了一张RenderTexture，并用$[0 \;\; 0 \;\;1 \;\;0 ]$作为ClearColor，且在这张纹理的某个区域画了个红色（$[1 \;\; 0 \;\;0 \;\;1 ]$）的方块。当使用双线性过滤方式读取该RenderTexture时，会因为绿色的透明像素（ClearColor）产生失真。

因此当该纹理进行了更新后，需要使用片段着色器进行一个后处理，后处理的内容就是 `Alpha Premultiplicaton` 。保证在之后其他部分使用该纹理时，不会因为双线性过滤产生错误。

`Alpha Premultiplication` 的第二步是，当使用Blending时，需要将Blending的方式从 `SrcAlpha OneMinusSrcAlpha` 改为 `One OneMinusSrcAlpha` ，如下：

```glsl
// Blend SrcAlpha OneMinusSrcAlpha // Default Blending method
Blend One OneMinusSrcAlpha // Handle for the alpha premultiplication texture
```

需要采取这个步骤的原因是因为纹理素材的RGB通道已经与A通道的值进行过相乘，如果在Blending是仍然采用 `SrcAlpha OneMinusSrcAlpha` RGB通道会再一次 与A通道的值进行相乘，即整个过程中乘了两遍。但Alpha通道仍然以正常的方式进行计算。

# 图层混叠（Image Composition）

`Alpha Premultiplication` 的另一个好处是保证图层混叠时不会产生错误。

如有一系列的图层进行混叠构成最后的结果，图层自上而下顺序为 $A，B，C，D$，即$Result = A \rightarrow B \rightarrow C \rightarrow D$

但在渲染的过程中，因为$D$在最下层，所以渲染的顺序是$C$ 先渲染到 $D$ 上，然后$B$ 渲染到 $C, D$ 构成的图集上，最后 $A$ 渲染到 $B,C,D$ 构成的图集上。即 Blending的结构为：

$$ Result = Blend(A,Blend(B,Blend(C,D))) $$

但在某些时刻，会期望将一些中间变量先渲染到一张RenderTexture上，之后直接渲染这张RT就可以减少一部分的DrawCall。如将$B$和$C$图层合并为$temp$图层，之后整个流程就变为了：$Result = A \rightarrow temp \rightarrow D$，Blending流程的顺序也相应的发生了改变：

$$ Result = Blend(A,Blend(D,Blend(C,B))) $$

所以中间变量渲染到RT上的过程是否会对最终结果造成影响，取决于Blend操作是否是线性变换。如果是的话，那么则满足交换律，即交换操作的顺序并不会影响操作的结果。

## 线性变换证明

💡 以一个简化流程为例子来论证 `传统 Alpha Blending`与 `Premultiplicated Alpha Blending` 是否是线性变换：$A$ 先渲染到 $B$ 上，再将结果渲染到 $C$ 上。且为了进一步简化流程，规定混合后的图层Alpha值直接来源于Source的Alpha值，即$A$渲染到$B$的结果的Alpha值等于 $A$ 的 alpha，即 ${AB}_{a}=A_{a}$

-   对于 `传统 Alpha Blending`
    
    $A\rightarrow B$ 结果的$RGB$通道值为：
    
    $$ AB_{rgb}=A_{rgb} \cdot A_{a} +(1-A_{a})\cdot B_{rgb} $$
    
    该结果再与$C$进行混叠的结果的RGB通道值为：
    
    $$ \begin{array}{l} ABC_{rgb} = AB_{rgb} \cdot AB_{a} +(1- AB_{a})\cdot C_{rgb} \\\\ = [A_{rgb} \cdot A_{a} +(1-A_{a})\cdot B_{rgb}] \cdot A_{a} +(1- A_{a})\cdot C_{rgb} \end{array} $$
    
    可以看到式子中已经出现了 $A_{a}$ 的二次项，即传统的Alpha Blending必然不是线性变化，即Blending流程顺序的变化会造成最终结果的不同。
    
-   对于 `Premultiplicated Alpha Blending`
    
    $A\rightarrow B$ 结果的$RGB$通道值为：
    
    $$ AB_{rgb}=A_{rgb} +(1-A_{a})\cdot B_{rgb} $$
    
    该结果再与$C$进行混叠的结果的RGB通道值为：
    
    $$ \begin{array}{l} ABC_{rgb} = AB_{rgb} +(1- AB_{a})\cdot C_{rgb} \\\\ = [A_{rgb} +(1-A_{a})\cdot B_{rgb}] +(1- A_{a})\cdot C_{rgb} \end{array} $$
    
    可以看到式子中所有的项都只存在一次项，即 `Premultiplicated Alpha Blending` 是线性变化，不会造成最终结果的不同。

```ad-important
当多图层混叠时需要引入中间图层时，纹理应当保证是 `Alpha Premultiplicated` 的
```

## 实例：

不考虑纹理过滤（不会造成像素失真）的情况下，将一个半透明的灰色纹理叠加到白色背景上，那么正确结果为 $[0.75 \;\; 0.75 \;\; 0.75]$：

$$ \begin{array}{l}0.5 \cdot\left[\begin{array}{c} 0.5 \\0.5 \\0.5 \end{array}\right]+(1-0.5) \cdot\left[\begin{array}{c}1 \\1 \\1 \end{array} \right] \\ \\= \left[\begin{array}{c} 0.75 \\ 0.75 \\ 0.75 \end{array}\right] \end{array} $$

如果流程变为，先将半透明灰色纹理渲染到Clear Color为 $[0 \;\;0 \;\;0\;\;0]$ 的RenderTexture上，再将RT渲染到白色纹理上。

-   当使用 `传统Alpha Blending`时，当渲染到RT后，颜色为 $[0.25 \;\; 0.25 \;\; 0.25 \;\; 0.25]$：
    
    $$ \begin{array}{l}0.5 \cdot\left[\begin{array}{c} 0.5 \\0.5 \\0.5 \\0.5 \end{array}\right]+(1-0.5) \cdot\left[\begin{array}{c}0 \\0 \\0 \\ 0\end{array} \right] \\ \\= \left[\begin{array}{c} 0.25 \\ 0.25 \\ 0.25 \\ 0.25 \end{array}\right] \end{array} $$
    
    再将RT渲染到白色背景上，得到的RGB结果为 $[0.8125 \;\; 0.8125 \;\; 0.8125]$，得到的结果与预期不符
    
    $$ \begin{array}{l}0.25 \cdot\left[\begin{array}{c} 0.25 \\0.25 \\0.25 \\0.25 \end{array}\right]+(1-0.25) \cdot\left[\begin{array}{c}1 \\1 \\1 \\ 1\end{array} \right] \\ \\= \left[\begin{array}{c} 0.8125 \\ 0.8125 \\ 0.8125 \\ 0.8125 \end{array}\right] \end{array} $$

-   当使用 `Premultiplicated Alpha Blending` 时，首先需要将 RGB通道与A通道相乘，即得到 $[0.25 \;\; 0.25 \;\; 0.25 \;\;0.5]$，渲染到RT后，结果仍然为 $[0.25 \;\; 0.25 \;\; 0.25 \;\;0.5]$：
    
    $$ \begin{array}{l}\left[\begin{array}{c} 0.25 \\0.25 \\0.25 \\0.5 \end{array}\right]+(1-0.25) \cdot\left[\begin{array}{c}0 \\0 \\0 \\ 0\end{array} \right] \\ \\= \left[\begin{array}{c} 0.25 \\ 0.25 \\ 0.25 \\ 0.5 \end{array}\right] \end{array} $$
    
    再将RT渲染到白色背景上，得到的RGB结果为 $[0.5 \;\; 0.5 \;\; 0.5]$，得到的结果与预期相符：
    
    $$ \begin{array}{l}\left[\begin{array}{c} 0.25 \\0.25 \\0.25 \end{array}\right]+(1-0.5) \cdot\left[\begin{array}{c}1 \\1 \\1 \end{array} \right] \\ \\= \left[\begin{array}{c} 0.75 \\ 0.75 \\ 0.75 \end{array}\right] \end{array} $$

# Reference

[Beware of Transparent Pixels - Adrian Courrèges (adriancourreges.com)](http://www.adriancourreges.com/blog/2017/05/09/beware-of-transparent-pixels/)

[Shawn Hargreaves Blog Index](https://shawnhargreaves.com/blogindex.html#premultipliedalpha)

[Real-Time Rendering · GPUs prefer premultiplication (realtimerendering.com)](http://www.realtimerendering.com/blog/gpus-prefer-premultiplication/)

[TomF's Tech Blog - It's only pretending to be a wiki. (tomforsyth1000.github.io)](https://tomforsyth1000.github.io/blog.wiki.html#%5B%5BPremultiplied%20alpha%5D%5D)

[TomF's Tech Blog - It's only pretending to be a wiki. (tomforsyth1000.github.io)](https://tomforsyth1000.github.io/blog.wiki.html#%5B%5BPremultiplied%20alpha%20part%202%5D%5D)

[Alpha Blending: To Pre or Not To Pre | NVIDIA Developer](https://developer.nvidia.com/content/alpha-blending-pre-or-not-pre)

[Pre-multiply alpha channel when importing Unity textures (github.com)](https://gist.github.com/MrJul/1042aa75493a58ceeb6d2fa7d7d039c3)

[^1]:  [纹理压缩](https://tomforsyth1000.github.io/blog.wiki.html#%5B%5BPremultiplied%20alpha%5D%5D) 

