---
cssclass: [table-border]
created: 2021-12-21
updated: 2021-12-21
---

对于一个表面而言，其细节程度与建模的精度相关，如一面墙，可以使用一个简单的平面表示，也可以通过非常精细的建模表示墙上的砖块突起等。

但是精细的模型往往需要消耗大量的资源，因此还有一种方法就是用 `法线贴图（Normal Mapping / Bump Mapping）` 来为模型增加细节。因为对于光照计算而言，一个表面是通过它的法线来表示的（漫反射，镜面反射等都是个光纤与法线的计算）。如下图中，红色的线为真实的表面，黑色的箭头表示法线，绿色的虚线则表示光照计算时，假定的表面的方向：
![](assets/LearnOpenGL-Ch%2029%20Normal%20Mapping/Untitled.png)

# Normal Mapping

因为法线的每一个分量的取值都必定在 $[-1,1]$ 之间，而对于贴图而言，存储的值范围再 $[0,1]$ 之间。因此将法线存储到贴图中，需要经过以下的运算：

```glsl
vec3 rgb_normal = normal * 0.5 + 0.5; // transforms from [-1,1] to [0,1]
```

对于如下左所示的墙面漫反射贴图，就需要用到下右所示的法线贴图来表达：

|                                                                         |                                                                     |
| ----------------------------------------------------------------------- | ------------------------------------------------------------------- |
| ![](assets/LearnOpenGL-Ch%2029%20Normal%20Mapping/Untitled%201%201.png) | ![](assets/LearnOpenGL-Ch%2029%20Normal%20Mapping/Untitled%202.png) |

可以发现法线贴图整体是蓝色，因为对于面朝屏幕的平面而言，其法线是指向屏幕的，即为 $(0,0,1)$ 方向，即在 RGB 空间中表现为蓝色。

```ad-warning
仔细观察上两图会发现，发现贴图的绿色通道分量是反的。如绿色表示的是向上，即 $(0,1,0)$，因此对于砖块而言，它顶部表面的法线是向上的，所以顶部表面的法线贴图应当是偏绿色，而在上右图中，确是砖块底部表面部分的法线贴图是绿的。

这是因为大部分的导出法线贴图的软件都是运行在 Windows 上，即使用的是 DX 的图形接口，而在 DX 中，绿色表示的是向下，即 $(0,-1,0)$。因此为了让 DX 上导出的图在 OpenGL 环境下能正常的显示，需要对绿色通道的颜色取反。

注意，这与在 [Textures](LearnOpenGL-Ch%2004%20Textures.md) 中提到的 DX 和 OpenGL 纹理关于原点的定义不同并非一个问题。
```


使用法线贴图计算光照的着色器与在 [Lighting Maps](LearnOpenGL-Ch%2013%20Lighting%20Maps.md) 中使用的着色器并无太大区别，只不过之前每个片元法线的值，是在顶点着色器中根据顶点的法线计算，然后再插值得到。而现在片元的法线值是通过法线贴图求得，需要注意 RGB 通道的范围是 $[0,1]$ 而法线每个分量的范围是 $[-1,1]$ ，因此还需要进行转换。因此片段着色器中需要进行的改变如下所示：

```glsl
// ...
uniform sampler2D normalMap;

void main()
{
    // ...
    vec3 normal = texture(normalMap, fs_in.TexCoords).rgb;
    normal = normalize(normal * 2 - 1);
		// ...
}

```

如下为未使用法线贴图（左）和使用法线贴图效果（右）的比较：

|                                                                                   |                                                                                  |
| --------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| ![未使用法线贴图](assets/LearnOpenGL-Ch%2029%20Normal%20Mapping/Untitled%203.png) | ![ 使用法线贴图](assets/LearnOpenGL-Ch%2029%20Normal%20Mapping/Untitled%204.png) |
|                                                                                   |                                                                                  |

但上例存在一个问题，因为法线贴图提供的法线始终大约分布在 $(0,0,1)$ 附近，且并没有根据模型的 Model 矩阵做任何的调整，所以仅当表面是朝向屏幕时（法线为 $(0,0,1)$）时，使用法线贴图才会产生正确的效果。

如当一个平面是水平的，那么它的片元法线应当是 $(0,1,0)$ 附近，而法线贴图提供仍然是在 $(0,0,1)$ 附近，这无疑会产生问题。

问题的本质在于，从贴图中读出的法线是处在 `Tangent Space` 中，而着色器中的其他变量是在世界坐标系中，因为两个坐标系的不同，导致了计算结果的错误。

# Tangent Space

`Tangent Space` 是一个以法线贴图中所表示的每个表面作为本地坐标系的坐标系，因此在 Tangent Space 中法线都大约在 $(0,0,1)$ 附近。

将三角形从 Tangent Space 转换到其他坐标系下的矩阵称为 `TBN 矩阵（Tangent, Bitangent,Normal）` ，其中 `Tangent` ， `Bittangent` 和 `Normal` 分别为三个互相垂直的单位向量， `Tangent` 与纹理定义的 `U` 方向平行， `Bitangent` 与纹理定义的 `V` 方向平行， `Normal` 即为从纹理中读出的法线方向。

```ad-note
如在 [[Camera](LearnOpenGL-Ch%2007%20Camera.md) 中定义 View 矩阵相似，使用三个互相垂直的单位向量，就能定义出一个转换到以该三个单位向量组成的坐标系的矩阵。
```

由 `TBN` 三个轴形成的 Tangent Space 的示意图如下所示， $T$ 轴即通常在纹理表示时用的 $U$ 轴， $B$ 轴即通常在纹理表示时用的 $V$ 轴：
![](assets/LearnOpenGL-Ch%2029%20Normal%20Mapping/Untitled%205.png)

因为向量 `Normal` 的值可以直接从法线贴图中读到，因此剩下要解决的问题就是如何求得 `Tangent` 和 `Bitangent` 向量的值。

## 数学实现

在 Tangent Space 中任意选取一个三角形，如下所示：
![](assets/LearnOpenGL-Ch%2029%20Normal%20Mapping/Untitled%206.png)

上图中 $E_1$ 和边 $E_{2}$ 可分别用如下的式子表示，其中 $E_1$ 为边在世界坐标系中的表示，$(\Delta U_1, \Delta V_1)$为边 $E_1$ 在纹理的 UV 坐标系下的表示， $E_2$ 和 $(\Delta U_1, \Delta V_1)$ 的含义类似。

根据在 [Chapter 3: Multiple Coordinate Spaces](https://www.notion.so/Chapter-3-Multiple-Coordinate-Spaces-cac22e53147a4edb9a63ea5f19fb1dcf) 中关于[坐标转换公式](https://www.notion.so/Chapter-3-Multiple-Coordinate-Spaces-cac22e53147a4edb9a63ea5f19fb1dcf)的定义 ，可得：

$$\begin{array}{l}E_{1}=\Delta U_{1} T+\Delta V_{1} B \\E_{2}=\Delta U_{2} T+\Delta V_{2} B\end{array}$$

上式可改写为：

$$\begin{array}{l}\left(E_{1 \mathrm{x}}, E_{1 \mathrm{y}}, E_{1 \mathrm{z}}\right)=\Delta U_{1}\left(T_{\mathrm{x}}, T_{\mathrm{y}}, T_{\mathrm{z}}\right)+\Delta V_{1}\left(B_{\mathrm{x}}, B_{\mathrm{y}}, B_{\mathrm{z}}\right) \\\left(E_{2 \mathrm{x}}, E_{2 \mathrm{y}}, E_{2 \mathrm{z}}\right)=\Delta U_{2}\left(T_{\mathrm{x}}, T_{\mathrm{y}}, T_{\mathrm{z}}\right)+\Delta V_{2}\left(B_{\mathrm{x}}, B_{\mathrm{y}}, B_{\mathrm{z}}\right)\end{array}$$

而该表达可以进一步用线性矩阵表示，即：

$$\left[\begin{array}{lll}E_{1 \mathrm{x}} & E_{1 \mathrm{y}} & E_{1 \mathrm{z}} \\E_{2 \mathrm{x}} & E_{2 \mathrm{y}} & E_{2 \mathrm{z}}\end{array}\right]=\left[\begin{array}{ll}\Delta U_{1} & \Delta V_{1} \\\Delta U_{2} & \Delta V_{2}\end{array}\right]\left[\begin{array}{lll}T_{\mathrm{x}} & T_{\mathrm{y}} & T_{\mathrm{Z}} \\B_{\mathrm{X}} & B_{\mathrm{y}} & B_{\mathrm{Z}}\end{array}\right]$$

此时所需要求的 $T$ 和 $B$ 就能通过线性变换求得，即：

$$\left[\begin{array}{ll}\Delta U_{1} & \Delta V_{1} \\\Delta U_{2} & \Delta V_{2}\end{array}\right]^{-1}\left[\begin{array}{lll}E_{1 \mathrm{x}} & E_{1 \mathrm{y}} & E_{1 \mathrm{z}} \\E_{2 \mathrm{x}} & E_{2 \mathrm{y}} & E_{2 \mathrm{z}}\end{array}\right]=\left[\begin{array}{ccc}T_{\mathrm{x}} & T_{\mathrm{y}} & T_{\mathrm{z}} \\B_{\mathrm{X}} & B_{\mathrm{y}} & B_{\mathrm{z}}\end{array}\right]$$

根据 [Chapter 6: More on Matrices](https://www.notion.so/Chapter-6-More-on-Matrices-ac44b1bbedbf4314a688d50f9b608356) 中对于矩阵求逆的描述，可知：

$$\mathbf{M}^{-1}=\frac{\operatorname{adj} \mathbf{M}}{|\mathbf{M}|}$$

其中 $\operatorname{adj} \mathbf{M}$ 为伴随矩阵，$|\mathbf{M}|$ 为矩阵的行列式， 因此上式进一步求解的过程如下：

$$\left[\begin{array}{ll}\Delta U_{1} & \Delta V_{1} \\\Delta U_{2} & \Delta V_{2}\end{array}\right]^{-1} =\frac{\left[\begin{array}{ll}\Delta V_{2} & -\Delta U_{2} \\-\Delta V_{1} & \Delta V_{1}\end{array}\right]}{\left(\Delta U_{1} \Delta{V}_{2}-\Delta U_{2} \Delta V_{1}\right)}$$

$$\left[\begin{array}{lll}T_{\mathrm{X}} & T_{\mathrm{y}} & T_{\mathrm{Z}} \\B_{\mathrm{X}} & B_{\mathrm{y}} & B_{\mathrm{Z}}\end{array}\right]=\frac{\left[\begin{array}{cc}\Delta V_{2} & -\Delta V_{1} \\-\Delta U_{2} & \Delta U_{1}\end{array}\right]\left[\begin{array}{lll}E_{1 \mathrm{x}} & E_{1 \mathrm{y}} & E_{1 \mathrm{z}} \\E_{2 \mathrm{x}} & E_{2 \mathrm{y}} & E_{2 \mathrm{z}}\end{array}\right]}{\left(\Delta U_{1} \Delta{V}_{2}-\Delta U_{2} \Delta V_{1}\right)}$$

即：

$$\begin{array}{l}T_{x}=\left(\Delta V_{2} E_{1 x}-\Delta V_{1} E_{2 x} \right)/ \left(\Delta U_{1} \Delta{V}_{2}-\Delta U_{2} \Delta V_{1}\right) \\T_{y}=\left(\Delta V_{2} E_{1 y} -\Delta V_{1} E_{2 y} \right) / \left(\Delta U_{1} \Delta{V}_{2}-\Delta U_{2} \Delta V_{1}\right) \\T_{z}=\left( \Delta V_{2} E_{1 z}-\Delta V_{1} E_{2 z} \right)/ \left(\Delta U_{1} \Delta{V}_{2}-\Delta U_{2} \Delta V_{1}\right) \end{array}$$

$$\begin{array}{l} B_{x}=\left(-\Delta U_{2} E_{1x}+\Delta U_{1} E_{2 x} \right)/ \left(\Delta U_{1} \Delta{V}_{2}-\Delta U_{2} \Delta V_{1}\right) \\B_{y}=\left(-\Delta U_{2} E_{1y} +\Delta U_{1} E_{2 y}\right)/ \left(\Delta U_{1} \Delta{V}_{2}-\Delta U_{2} \Delta V_{1}\right) \\B_{z}=\left( -\Delta U_{2} E_{1 z}+\Delta U_{1} E_{2 z} \right)/ \left(\Delta U_{1} \Delta{V}_{2}-\Delta U_{2} \Delta V_{1}\right) \end{array}$$

至此，向量 $T$ 和 $B$ 都已求得。

## 代码实现

以下部分展示求一个三角形的向量 $T$ 和 $B$ 的过程，首先三角形的三个顶点的位置和 UV 定义如下：

```cpp
// positions
glm::vec3 pos0(-0.5f, -0.5f, 0.5f);
glm::vec3 pos1(0.5f, -0.5f, 0.5f);
glm::vec3 pos2(0.5f, 0.5f, 0.5f);

// texture coordinates
glm::vec2 uv0(0.0f, 0.0f);
glm::vec2 uv1(1.0f, 0.0f);
glm::vec2 uv2(1.0f, 1.0f);
```

根据这三个顶点，即可以求出两条边在世界坐标中的表示为：

```cpp
glm::vec3 edge1 = pos1 - pos0;
glm::vec3 edge2 = pos2 - pos0;
```

两条边在 UV 空间下的表示为：

```cpp
glm::vec2 edge1UV = uv1 - uv0;
glm::vec2 edge2UV = uv2 - uv0;
```

套用上一节得出的公式，即能求出 $T$ 和 $B$ 向量：

```cpp
glm::vec3 tangent1, bitangent1;
float determinant = 1.0f / (edge1UV.x * edge2UV.y - edge2UV.x * edge1UV.y);

tangent1.x = (edge2UV.y * edge1.x - edge1UV.y * edge2.x) * determinant;
tangent1.y = (edge2UV.y * edge1.y - edge1UV.y * edge2.y) * determinant;
tangent1.z = (edge2UV.y * edge1.z - edge1UV.y * edge2.z) * determinant;
bitangent1.x = (-edge2UV.x * edge1.x + edge1UV.x * edge2.x) * determinant;
bitangent1.y = (-edge2UV.x * edge1.y + edge1UV.x * edge2.y) * determinant;
bitangent1.z = (-edge2UV.x * edge1.z + edge1UV.x * edge2.z) * determinant;
```

当有了向量 $T$ 和 向量 $B$ 后，就可以将这两个向量作为顶点数据的一部分，如下代码所示：

```cpp
vertices = new float[84]{
    pos0.x, pos0.y, pos0.z, uv0.x, uv0.y, nm.x, nm.y, nm.z, tangent1.x, tangent1.y, tangent1.z, bitangent1.x, bitangent1.y, bitangent1.z,
    pos1.x, pos1.y, pos1.z, uv1.x, uv1.y, nm.x, nm.y, nm.z, tangent1.x, tangent1.y, tangent1.z, bitangent1.x, bitangent1.y, bitangent1.z,
    pos2.x, pos2.y, pos2.z, uv2.x, uv2.y, nm.x, nm.y, nm.z, tangent1.x, tangent1.y, tangent1.z, bitangent1.x, bitangent1.y, bitangent1.z,

    pos0.x, pos0.y, pos0.z, uv0.x, uv0.y, nm.x, nm.y, nm.z, tangent2.x, tangent2.y, tangent2.z, bitangent2.x, bitangent2.y, bitangent2.z,
    pos2.x, pos2.y, pos2.z, uv2.x, uv2.y, nm.x, nm.y, nm.z, tangent2.x, tangent2.y, tangent2.z, bitangent2.x, bitangent2.y, bitangent2.z,
    pos3.x, pos3.y, pos3.z, uv3.x, uv3.y, nm.x, nm.y, nm.z, tangent2.x, tangent2.y, tangent2.z, bitangent2.x, bitangent2.y, bitangent2.z};
```

```ad-note
理论上，不需要计算 Bitangle 向量，因为 Normal 向量与 Tangent 向量的乘积即为 Bitangle 向量。但这里为了说明完整，仍然计算了 Bitangle 向量。
```


将数据传递给 Shader 的代码也需要相应修改：

```cpp
// Position
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, singleDataSize * sizeof(float), (void *)0);
glEnableVertexAttribArray(0);
// Texcoord
glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, singleDataSize * sizeof(float), (void *)(3 * sizeof(float)));
glEnableVertexAttribArray(1);
// Normal
glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, singleDataSize * sizeof(float), (void *)(5 * sizeof(float)));
glEnableVertexAttribArray(2);
// Tangent
glVertexAttribPointer(3, 3, GL_FLOAT, GL_FALSE, singleDataSize * sizeof(float), (void *)(8 * sizeof(float)));
glEnableVertexAttribArray(3);
// Bitangent
glVertexAttribPointer(4, 3, GL_FLOAT, GL_FALSE, singleDataSize * sizeof(float), (void *)(11 * sizeof(float)));
glEnableVertexAttribArray(4);
```

# Tangent Space 和 Normal Mapping

在顶点着色器中首先需要做的是接收新增的 $T$ 和 $B$ 向量，并利用 `mat3` 函数，生成由 $T, B, N$ 构成的 TBN 矩阵：

```glsl
#version 330 core

layout(location = 0) in vec3 Pos;
layout(location = 1) in vec2 TexCoords;
layout(location = 2) in vec3 aNormal;
layout (location = 3) in vec3 aTangent;
layout (location = 4) in vec3 aBitangent;

void main()
{
		mat3 normalMatrix = transpose(inverse(mat3(model)));
	  vec3 T = normalize(normalMatrix* aTangent);
    vec3 B = normalize(normalMatrix* aBitangent);
    vec3 N = normalize(normalMatrix * aNormal);

    mat3 TBN = mat3(T,B,N);
		
		....
}
```

上述计算从数学上是可行的，但是因为浮点数精度的问题，可能当传入的 $T,B,N$ 矩阵与 `normalMatrix` 相乘后，就变得不再相互垂直，该问题称为[矩阵蠕变](https://www.notion.so/Chapter-8-Rotation-in-Three-Dimensions-36e64d259cf648ceb3efb3d74d12dabd) ，可以通过 [矩阵的正交化](https://www.notion.so/Chapter-6-More-on-Matrices-ac44b1bbedbf4314a688d50f9b608356) 解决，如通过如下的代码解决 TBN 矩阵可能存在的蠕变：

```glsl
vec3 T = normalize(normalMatrix* aTangent);
vec3 N = normalize(normalMatrix * aNormal);
// dot(T,N)*N 为T在N方向上的分量，理想情况下该分量为0，但当蠕变时则不为0
T = normalize(T - dot(T, N) * N);
vec3 B = cross(N, T); //直接通过叉乘得到 B
mat3 TBN = mat3(T,B,N);

```

当获取到 TBN 矩阵后，对于之前 Normal 与其他变量所处坐标系不同的问题，就有了两种解决思路，一是将所有的变量转换到世界坐标系下，二是将所有的变量全部转换到 Tangent 坐标系下。

## 全部转换到世界坐标系

对在片段着色器中从法线贴图中读出的法线数据，最简单的做法就是将法线值与 TBN 矩阵相乘，将法线转换到世界坐标系中：

```glsl
// Fragment Shader
normal = normalize(fs_in.TBN * normal); // Transform
...
```

此时着色器中的所有变量都在世界坐标系下，后续光照的计算与之前章节类似。

## 全部转换到 Tangent 坐标系

为了将在世界坐标系中变量转换到 Tangent 坐标系下，首先需要得到 TBN 矩阵的逆。

因为 TBN 矩阵做的仅是坐标系的转换，根据 [Chapter 6: More on Matrices](https://www.notion.so/Chapter-6-More-on-Matrices-ac44b1bbedbf4314a688d50f9b608356) 中对于[正交矩阵的定义](https://www.notion.so/Normal-Mapping-e600bc26b9124c0fac91cc8467b45516) ，TBN 为正交矩阵，对于正交矩阵而言，矩阵的转置就是矩阵的逆，因此可以通过 `transpose` 函数得到 TBN 矩阵的逆，即：

```glsl
// Vertex Shader
mat3 inverseTBN = transpose(TBN)
```

在片段着色器中计算光照时，所需要用到的变量 `LightPos, ViewPos, FragPos` 都是在顶点着色器中计算得到，因此也可以在顶点着色器中，将它们直接转换到 Tangent 坐标系下，即：

```glsl
// Vertex Shader
vs_out.TangentLightPos = inverseTBN * lightPos;
vs_out.TangentViewPos = inverseTBN * viewPos;
vs_out.TangentFragPos = inverseTBN * vs_out.FragPos;
```

之后在片段着色器中，不需要转换从法线贴图中读出的法线（已经在 Tangent 空间中），全都使用 `TangentLightPos, TangentViewPos, TangentFragPos` 运算即可。