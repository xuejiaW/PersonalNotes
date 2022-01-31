---
cssclass: [table-border]
created: 2021-12-21
updated: 2022-01-31
tags:
    - OpenGL
---
# Parallax Mapping

[Normal Mapping](Ch%2029%20Normal%20Mapping.md) 调整了表面的法线，让表面在光照的计算中能有更真实的表现。

但一个真正的有凹凸变化的平面，即使在不考虑光照效果的情况下，也会与高度无变化的平面效果上存在区别。如以一定的角度去观察平面，如果平面存在凸出，则该凸出点会遮挡住后面的平面。如下所示，$V$ 为视线方向，如果平面是如黑线所示一样无高度变化，则视线会看到 $A$ 点，而如果平面如红线般存在高度变化，则实现会看到 $B$ 点。
![](assets/Ch%2030%20Parallax%20Mapping/Untitled.png)

为了让一个无凹凸变化的平面能展现出满足凹凸变化的平面效果，一个最直观的方法就是去调整平面的 Mesh。 Displacement Mapping 技术就是该思路。在 Displacement Mapping 中，会通过如下的一张 Height Map 去调整表面顶点的高度，即根据纹理去调整原先的 Mesh，得到一个新的有凹凸变化的 Mesh。
![|400](assets/Ch%2030%20Parallax%20Mapping/Untitled%201.png)

但 Displacement Mapping 存在的问题在于，它要求平面存在足够多的顶点数，这样根据 Height Map 做的调整才能足够的精细。想象一个平面只通过四个顶点去表示，这四个顶点无论如何变化，也无法变成一个凹凸有致的墙面。

而 `视差映射（Parallax Mapping)` 则是另一种能让平面产生凹凸导致的遮挡效果，但又不要求平面用大量顶点表示的技术。 Parallax Mapping 同样需要一张 Height Map，但此时并非去用 Height Map 调整 Mesh 的高度，而是用它去调整后续纹理（如 Diffuse Map / Normal Map）采样中需要用到的 Texcoord（假设后续使用的纹理针对平面不同的高度有不同的表现）。如下所示，
![](assets/Ch%2030%20Parallax%20Mapping/Untitled%202.png)

图中点 $A$ 为平面时会看到的点，即原先的采样点。用该点在 `Height Map` 中进行采样，并用读出的数据作为在视线方向上的偏移长度。图中 $\overline{\mathrm{P}}$ 向量的长度即为 $\mathrm{H(A)}$ 的值，注意图中的 $\overline{\mathrm{P}}$ 是一个三维的向量，图上的竖直部分为 法线方向，水平部分为 $uv$ 方向。 $\overline{\mathrm{P}}_{uv}$ 即为去后续纹理中采样的 Texcoord 的偏移量。可以看到最后采样的点（图中棕色点）与理想中的采样点（蓝色点）在高度上相差并不大，因此可以得到与理想情况较为相近的结果。

即求新的 Texcoord 的表达式为：

$$\mathbf{Texcoord}_{\mathrm{new}}=\mathbf{Texcoord}_{\mathrm{origin}}+\frac{h \cdot \mathbf{v}_{x y}}{v_{z}}$$

其中 $\mathbf{v}_{xy} / {v}_z$ 表示 $\mathbf{v}_{xy}$ 对于 $v_{z}$ 的变化率。

```ad-note
 `Displacement Mapping` 和 `Parallax Mapping` 的本质区别在于前者是去调整 Mesh，后者是去调整其他纹理的 Texcoord。 对于同一张 Height Map，可以同时被运用于这两个技术中。
```

`Parallax Mapping` 是一个模拟近似的方法，即通过从视线方向上取 $\mathrm{H(A)}$ 长度的向量并将其水平分量作为对 Texcoord 的偏移，这一操作并无特定的物理含义。只不过是基于视线方向与平面越接近偏移量越大 和 某个点高度越高其造成偏移量越大 这两个假设进行的模拟。

# Displacement Map

在实现 Parallax Mapping 中需要用到三张纹理，Diffuse Map，Normal Map 和 HeightMap。但在一些地方会使用 `Displacement Map` 取代 `Height Map`，两者分别如下所示：

|                                                                                   |                                                                                     |
| --------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| ![Height Map](assets/Ch%2030%20Parallax%20Mapping/BrickHeight%201.jpg) | ![Displace Map](assets/Ch%2030%20Parallax%20Mapping/BrickDisplacement.jpg) |

可以看到两者几乎是反色的关系，在 `Height Map` 中黑色表示平面的位置，白色表示突起的位置。在 `Displacement Map` 中黑色同样表示平面的位置，但白色表示凹陷的部分。

当使用的是 Displacement Map 时，Parallax Mapping 的示意图变成如下所示：
![](assets/Ch%2030%20Parallax%20Mapping/Untitled%203.png)

其中 $\mathrm{A,B}$ 以及棕色点仍然分别表示 `未作处理时平面采样的点`， `理想中看到的点` 和 `使用 Parallax Mapping` 采样的点。且同样是用 $\mathrm{H(A)}$ 的长度在视线 $\overline{\mathrm{V}}$ 上截取一段 $\overline{\mathrm{P}}$ ，并将其在 $uv$ 方向上的分量作为 Texcoord的偏移量。

两者的区别在于，使用 `Height Map` 时，是在原 Texcoord 上加上偏移量得到新 Texcoord，而当使用 `Displacement Map` 时，是在原 Texcoord 上减去偏移量得到新 Texcoord。因此，求新 Texcoord 的过程应当修改为：

$$\mathbf{Texcoord}_{\mathrm{new}}=\mathbf{Texcoord}_{\mathrm{origin}}-\frac{h \cdot \mathbf{v}_{x y}}{v_{z}}$$

# Shaders

## Vertex Shader

使用 Parallax Mapping 时与在 [Normal Mapping](Ch%2029%20Normal%20Mapping.md) 中一样，需要进行 Tangent Space 的坐标转换，因此顶点着色器与在 [Normal Mapping](Ch%2029%20Normal%20Mapping.md) 中使用的顶点着色器相同。

## Fragment Shader

在片段着色器中，需要加入对 Texcoord 进行偏移的操作，如下所示：

```glsl
vec2 ParallaxMapping(vec2 originTexCoords, vec3 viewDir)
{
    float depth = texture(displacementMap, originTexCoords).r;
    vec2 p = (viewDir.xy / viewDir.z) * (depth * scale);
    return originTexCoords - p;
}
```

这里额外引入了 `scale` 变量，该变量总体控制偏移的大小。因为在 Displacement Map 或 Height Map 中，白色用来表示凹凸的程度，但该程度并未指定单位，因此白色可能是表示“凸出1米”，也可能表示“凸出1毫米”。因此需要一个变量来进行控制。

用来采样 Normal Map 和 Diffuse Map 的 Texcoord，都需要先进行 Texcoord 偏移的处理：

```glsl
// ...
vec2 texCoords = ParallaxMapping(fs_in.TexCoords,viewDir);
// ...
vec3 color = texture(diffuseTexture, texCoords).rgb;
vec3 normal = texture(normalMap, texCoords).rgb;
```

|                                                                                |                                                                                |
| ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------ |
| ![未使用 Parallex Mapping](assets/Ch%2030%20Parallax%20Mapping/Untitled%204.png) | ![使用 Parallax Mapping](assets/Ch%2030%20Parallax%20Mapping/Untitled%205.png) |

可以看到右侧使用了 Parallax Mapping 时，在 Mesh 的边缘存在一些错误，这是因为 Texcoord 的偏移，导致了边缘的 Texcoord 数值已经超过了数值 $[0,1]$。对于这些超过范围的像素，直接丢弃即可，即：

```glsl
vec2 texCoords = ParallaxMapping(fs_in.TexCoords,viewDir);
if(texCoords.x > 1.0 || texCoords.y > 1.0 || texCoords.x < 0.0 || texCoords.y < 0.0)
    discard;
```

丢弃错误像素后的结果如下：
![|400](assets/Ch%2030%20Parallax%20Mapping/Untitled%206.png)

# Steep Parallax Mapping

如前所述， `Parallax Mapping` 方法仅是一个模拟近似的方法，因此在平面高度陡峭变化的情况下，可能无法得到理想的结果，如下图所示：
![](assets/Ch%2030%20Parallax%20Mapping/Untitled%207.png)

图中，最终的采样点（棕色）与理想的采样点（蓝色）存在较大的高度误差，因此在后续纹理上采样到的结果可能也与理想中的情况，有较大的差距。

在上述的实现中，当以某些角度观察砖块的接缝处（高度陡峭变化处）就会看到错误的现象，如下所示：
![砖块的接缝处存在错误|400](assets/Ch%2030%20Parallax%20Mapping/Untitled%208.png)

解决该问题的方法是 陡峭视差映射（Steep Parallax Mapping），该方法用多次采样逼近得到更接近理想采样点的 Texcoord 偏移量，而不是直接用 \mathrm{H(A)} 求得偏移量，示意图如下：
![](assets/Ch%2030%20Parallax%20Mapping/Untitled%209.png)

```ad-tip
陡峭视差映射使用的是逼近求值思想
```

陡峭视差映射中，将整个深度空间划分为多层（示意图中用黄线表示），视线方向与黄线的交点（图中紫色点）的 $xy$ 方向分量即表示该层的 Texcoord 的偏移，紫色点的 $z$ 方向分量值即为该层的深度。用此偏移在 Displacement Map 中采样，得到该层的偏移量在 Displacement Map 中所表示的深度（图中蓝色点）。

```ad-note
当层划分的足够密时，就会存在某一层它所得到的紫色点和蓝色点重合，即该层的深度（紫色点的 $z$ 分量），与用该层的偏移量在 Displacement Map 中读出的深度相同。 这一层的 Texcoord 偏移量就是理想中的偏移量。
```

最终需要的 Texcoord 偏移量，来自于第一个紫点在蓝点之下或重合的层。即第一个满足以下条件的层：层的 Texcoord 偏移从 Displacement Map 中读取的值小于等于该层的深度。在上图中，需要的偏移量来自 $\mathbf{T}_{3}$ 层。

陡峭视差映射的代码视线如下：

```glsl
vec2 ParallaxMapping(vec2 originTexCoords, vec3 viewDir)
{
    const float layersCount = 10; // 层数，越大效果越好，但性能消耗越多
    float layerDepthStep = 1.0 / layersCount; // 每一层所表示的深度
    float currentLayerDepth = 0.0; // 紫色点

    vec2 P = viewDir.xy * depth_scale;
    vec2 texCoordsBiasStep = P / layersCount; // 每一层的 Texcoord 偏移量

    vec2 currentTexCoords = originTexCoords;
    float currentDisplaymentValue = texture(displacementMap,currentTexCoords).r; // 蓝色点

    while(currentLayerDepth < currentDisplaymentValue)
    {
        currentTexCoords -= texCoordsBiasStep;
        currentDisplaymentValue = texture(displacementMap,currentTexCoords).r;
        currentLayerDepth += layerDepthStep;
    }

    return currentTexCoords;
}
```

使用该方法得到的效果如下，可以看到在砖块的接缝处已经没有了之前的错误显示效果：
![|400](assets/Ch%2030%20Parallax%20Mapping/Untitled%2010.png)

根据陡峭视差映射的示意图中，可以看到，视线越平行与平面，则每层表示的 Texcoord 偏移量就越大。因此可以用如下代码根据视线与平面的关系调整需要用到的层数：

```glsl
// // Hard Code layers count
// const float layersCount = 10;

// Adjust layers count according to the view direction
const float minLayersCount = 10.0;
const float maxLayersCount = 32.0;
float layersCount = mix(maxLayersCount, minLayersCount, max(dot(vec3(0,0,1),viewDir),0.0));
```

其中的 `mix` 函数为 Shader 中支持的插值函数，其含义如下：

$$mix(x,y,a) = x(1-a)+ya$$

# Parallax Occlusion Mapping

`陡峭视差映射`可以解决高度陡峭变化引发的失真问题，但因为是选取不同的层来决定 Texcoord 的偏移量，而不同层的偏移量又是离散的，这就会导致在高度陡峭变化的部分出现分层的现象，如下所示：
![|300](assets/Ch%2030%20Parallax%20Mapping/Untitled%2011.png)

这一问题最简单的解决方式就是增加层数，层数越多，分层的效果就越不明显。但这种解决方法会消耗非常多的性能。

还有一种解决思路，就是避免直接使用某一层的 Texcoord 偏移量进行采样，而是用相邻层的 Texcoord 偏移量进行插值，并用插值得到的偏移量进行采样。有两种方法使用了这种思路， `浮雕视差映射（Relief Parallax Mapping）` 和 `视差遮蔽映射（Parallax Occlusion Mapping）` 。因为前者消耗的性能更多，而相对于后者效果提升并不明显，因此 `视差遮蔽映射（Parallax Occlusion Mapping）` 被使用的更多。

```ad-note
这里仅说明视差遮蔽映射
```

视差遮蔽映射的示意图如下：
![](assets/Ch%2030%20Parallax%20Mapping/Untitled%2012.png)

图中 $\mathrm{T_3}$ 为陡峭视差映射中使用的层，$\mathrm{T_{2}}$ 为上一层。对于这两层，都用从 Displacement Map 中读取的深度值，减去层的深度值，即用蓝色点的深度值减去紫色点的深度值，该差值表示理想深度与实际层深度的差距。对于 $\mathrm{T_3}$ 层，该差值用 $below$ 表示，对于 $\mathrm{T_{2}}$ 层，该插值用 $beyond$ 表示。

```ad-note
$below$ 为负数， $beyond$ 为正数。
```

当 $below =0$ 时，应当用 $\mathrm{T_3}$ 层 Texcoord 偏移量，当 $below = \infty$ 时，应当用 $\mathrm{T_{2}}$ 层 Texcoord 的偏移量。因此定义插值的表达式为：

$$\begin{array}{l} &weight = \frac{below}{below-beyond} \\\\ &texcoord = texcoord_{T_2}_weight + texcoord_{T_3}_(1-weight) \end{array}$$

代码实现如下：

```glsl
vec2 ParallaxMapping(vec2 originTexCoords, vec3 viewDir)
{
		// Same part in Steep Parallax Mapping
		// ...

    vec2 prevTexCoord = currentTexCoords + texCoordsBiasStep;
    float previousLayerDepth = currentLayerDepth - layerDepthStep;

    float belowSurfaceDepth = currentDisplaymentValue - currentLayerDepth; // Negative value
    float beyondSurfaceDepth = texture(displacementMap,prevTexCoord).r - previousLayerDepth;

    float weight = belowSurfaceDepth / (belowSurfaceDepth - beyondSurfaceDepth);

    vec2 finalTexCoords = prevTexCoord * weight + currentTexCoords*(1.0 - weight);

    return finalTexCoords;
}
```

使用视差遮蔽映射的效果如下：
![|500](assets/Ch%2030%20Parallax%20Mapping/Untitled%2013.png)

```ad-note
陡峭视差映射和视差遮蔽映射解决的是当要表现的高度陡峭变化时引发的失真问题。
```

# View Direction Issue

使用了视差映射的平面，在视线与平面夹角过小时会产生错误的现象，如下所示：
![|300](assets/Ch%2030%20Parallax%20Mapping/Untitled%2014.png)

这种错误现象是视差映射的缺陷，无法被解决。也因此视差映射通常被用在地面或墙体这样不太会被平行观察的平面。

# 源码：

[main.cpp](https://www.notion.so/main-cpp-616f9835d1bb410288b22cdadb6a85c3)

[parallaxMapping.vs](https://www.notion.so/parallaxMapping-vs-2b2e3c366d1342d189da007de83669a3)

[parallaxMapping.fs](https://www.notion.so/parallaxMapping-fs-d1123bcab8d840fbbe168331c489d76d)