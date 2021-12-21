---
cssclass: [table-border]
created: 2021-12-21
updated: 2021-12-21
---
# Parallax Mapping

[Normal Mapping](../Learn%20OpenGL/Learn%20OpenGL%20-%20Ch%2029%20Normal%20Mapping.md) 调整了表面的法线，让表面在光照的计算中能有更真实的表现。

但一个真正的有凹凸变化的平面，即使在不考虑光照效果的情况下，也会与高度无变化的平面效果上存在区别。如以一定的角度去观察平面，如果平面存在凸出，则该凸出点会遮挡住后面的平面。如下所示，$V$ 为视线方向，如果平面是如黑线所示一样无高度变化，则视线会看到 $A$ 点，而如果平面如红线般存在高度变化，则实现会看到 $B$ 点。
![](assets/3D%20Math%20Primer%20-%20Ch%2008%20Rotation%20in%20Three%20Dimensions/Untitled%203.png)

为了让一个无凹凸变化的平面能展现出满足凹凸变化的平面效果，一个最直观的方法就是去调整平面的 Mesh。 Displacement Mapping 技术就是该思路。在 Displacement Mapping 中，会通过如下的一张 Height Map 去调整表面顶点的高度，即根据纹理去调整原先的 Mesh，得到一个新的有凹凸变化的 Mesh。
![|400](assets/3D%20Math%20Primer%20-%20Ch%2008%20Rotation%20in%20Three%20Dimensions/Untitled%201.png)

但 Displacement Mapping 存在的问题在于，它要求平面存在足够多的顶点数，这样根据 Height Map 做的调整才能足够的精细。想象一个平面只通过四个顶点去表示，这四个顶点无论如何变化，也无法变成一个凹凸有致的墙面。

而 `视差映射（Parallax Mapping)` 则是另一种能让平面产生凹凸导致的遮挡效果，但又不要求平面用大量顶点表示的技术。 Parallax Mapping 同样需要一张 Height Map，但此时并非去用 Height Map 调整 Mesh 的高度，而是用它去调整后续纹理（如 Diffuse Map / Normal Map）采样中需要用到的 Texcoord（假设后续使用的纹理针对平面不同的高度有不同的表现）。如下所示，
![](assets/3D%20Math%20Primer%20-%20Ch%2008%20Rotation%20in%20Three%20Dimensions/Untitled%202.png)

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
| ![Height Map](assets/Learn%20OpenGL%20-%20Ch%2030%20Parallax%20Mapping/BrickHeight%201.jpg) | ![Displace Map](assets/Learn%20OpenGL%20-%20Ch%2030%20Parallax%20Mapping/BrickDisplacement.jpg) |

可以看到两者几乎是反色的关系，在 `Height Map` 中黑色表示平面的位置，白色表示突起的位置。在 `Displacement Map` 中黑色同样表示平面的位置，但白色表示凹陷的部分。

当使用的是 Displacement Map 时，Parallax Mapping 的示意图变成如下所示：
![](assets/Learn%20OpenGL%20-%20Ch%2030%20Parallax%20Mapping/Untitled%203.png)

其中 $\mathrm{A,B}$ 以及棕色点仍然分别表示 `未作处理时平面采样的点`， `理想中看到的点` 和 `使用 Parallax Mapping` 采样的点。且同样是用 $\mathrm{H(A)}$ 的长度在视线 $\overline{\mathrm{V}}$ 上截取一段 $\overline{\mathrm{P}}$ ，并将其在 $uv$ 方向上的分量作为 Texcoord的偏移量。

两者的区别在于，使用 `Height Map` 时，是在原 Texcoord 上加上偏移量得到新 Texcoord，而当使用 `Displacement Map` 时，是在原 Texcoord 上减去偏移量得到新 Texcoord。因此，求新 Texcoord 的过程应当修改为：

$$\mathbf{Texcoord}_{\mathrm{new}}=\mathbf{Texcoord}_{\mathrm{origin}}-\frac{h \cdot \mathbf{v}_{x y}}{v_{z}}$$

# Shaders

## Vertex Shader

使用 Parallax Mapping 时与在 [Normal Mapping](Learn%20OpenGL%20-%20Ch%2029%20Normal%20Mapping.md) 中一样，需要进行 Tangent Space 的坐标转换，因此顶点着色器与在 [Normal Mapping](Learn%20OpenGL%20-%20Ch%2029%20Normal%20Mapping.md) 中使用的顶点着色器相同。

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

|     |     |
| --- | --- |
|![](assets/Learn%20OpenGL%20-%20Ch%2030%20Parallax%20Mapping/Untitled%204.png)     |     |