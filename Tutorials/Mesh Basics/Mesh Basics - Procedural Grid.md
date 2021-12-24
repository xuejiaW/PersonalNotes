---
created: 2021-12-20
updated: 2021-12-25
cssclass: [table-border]
tags:
    - Unity
    - Catlike
---

# Rendering Things

Unity 场景内的每个物体本质上都是通过 `Mesh` 进行的渲染。

`Mesh` 最少需要一系列顶点和一系列用来连接这些顶点的三角形定义构成。

在 Unity 中如果渲染一个 Mesh，最少需要两个组件 `Mesh Filter` 和 `Mesh Renderer`，前者会包含对 Mesh 的引用，后者会负责 Mesh 的真正渲染。
![|400](assets/Mesh%20Basics%20-%20Procedural%20Grid/image-20211222083208337.png)

在 `Mesh Renderer` 中可以为需要渲染的 Mesh 设置材质，本部分使用 Unity 默认的 `Standard` 材质，并使用如下贴图作为 `Albedo` 分量：
![|300](assets/Mesh%20Basics%20-%20Procedural%20Grid/01-uv-texture.png)

# Creating a Grid of Vertices 
可通过如下代码，生成一系列 Grid 的顶点，并利用 [Gizmo](../../Notes/Unity/Unity%20-%20Gizmo.md) 绘制：
```csharp
[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class Grid : MonoBehaviour
{
    private Vector3[] vertices;
    public int xSize, ySize;

    private void Awake() { Generate(); }

    private void Generate()
    {
        vertices = new Vector3[(xSize + 1) * (ySize + 1)];
        for (int i = 0, y = 0; y <= ySize; y++)
            for (int x = 0; x <= xSize; x++, i++)
                vertices[i] = new Vector3(x, y);
    }

    private void OnDrawGizmos()
    {
        if (vertices == null) return;
        Gizmos.color = Color.black;
        for (int i = 0; i != vertices.Length; ++i)
            Gizmos.DrawSphere(vertices[i], 0.1f);
    }
}

```

此时效果如下：
![|400](assets/Mesh%20Basics%20-%20Procedural%20Grid/image-20211222094813954.png)

# Creating the Mesh

上部分已经生成了 Mesh 需要的顶点，但需要将这些顶点传递给 Unity 的 `MeshFilter` 中的 Mesh，同时需要为其创建三角形，如下所示：

```csharp
private void Generate()
{
    GetComponent<MeshFilter>().mesh = mesh = new Mesh();
    mesh.name = "Procedural Grid";

    vertices = new Vector3[(xSize + 1) * (ySize + 1)];
    for (int i = 0, y = 0; y <= ySize; y++)
    {
        for (int x = 0; x <= xSize; x++, i++)
        {
            vertices[i] = new Vector3(x, y);
        }
    }

    int[] triangles = new int[xSize * ySize * 6];
    int triangleIndex = 0, vertexIndex = 0;
    for (int y = 0; y != ySize; ++y)
    {
        for (int x = 0; x != xSize; ++x)
        {
            triangles[triangleIndex] = vertexIndex;
            triangles[triangleIndex + 1] = vertexIndex + xSize + 1;
            triangles[triangleIndex + 2] = vertexIndex + 1;

            triangles[triangleIndex + 3] = vertexIndex + 1;
            triangles[triangleIndex + 4] = vertexIndex + xSize + 1;
            triangles[triangleIndex + 5] = vertexIndex + xSize + 2;

            vertexIndex += 1;
            triangleIndex += 6;
        }
        vertexIndex += 1; // Need extra increase vertex index while one row ended
    }

    mesh.vertices = vertices;
    mesh.triangles = triangles;
}
```

在生成 Triangles 的嵌套循环中，每一次循环生成一个 Grid 的两个 Triangle，且[Face Culling](../../Boos/Learn%20OpenGL/Learn%20OpenGL%20-%20Ch%2018%20Face%20Culling.md) 的顺序是顺时针，此为 Unity 对正向面的顺序要求。

此时的效果如下所示：
![](assets/Mesh%20Basics%20-%20Procedural%20Grid/image-20211223084615932.png)

# Generating Additional Vertex Data

## Normal

```ad-note
Unity 默认的顶点法线方向为 $(0,0,1)$
```

```ad-note
在现实生活中，法线是针对一个平面而言的，但在图形学中往往为顶点中添加法线信息。在由法线构成的平面中，平面上的法线会由顶点中的法线插值决定。
在有光照计算时，当构成平面的两个顶点有不同的法线值时，这样的插值做法就可以让平面 “看起来” 有弧度，相对于通过顶点细分构成的全面更节省性能。
```

在 Unity 中可以调用函数 `RecalculateNormals` 自动为顶点生成 Normal 数据，如下所示：
```csharp
mesh.RecalculateNormals();
```

## UV

可以在生成顶点时同时计算顶点的 UV 值。通常而言，为一个平面设定的 UV 值会覆盖 $0 \sim 1$ 的范围。生成 `UV` 部分代码如下所示：
```csharp
private void Generate()
{
    // ...
    Vector2[] uv = new Vector2[vertices.Length];
    for (int i = 0, y = 0; y <= ySize; y++)
    {
        for (int x = 0; x <= xSize; x++, i++)
        {
            vertices[i] = new Vector3(x, y);
            uv[i] = new Vector2((float)x / xSize, (float)y / ySize);
        }
    }

    // ...
    mesh.uv = uv;
    // ...
}

```

此时效果如下所示：
![](assets/Mesh%20Basics%20-%20Procedural%20Grid/image-20211223090352014.png)

因为此时生成的 Mesh 的 `xSize` 和 `ySize` 分别为 `10` 和 `5` ，即长宽比例为 $2:1$，因此可以看到图形存在一部分的拉伸。

为了解决这个问题，可以修改材质中的 `Tiling` ，将其由 $(1,1)$ 修改为 $(2,1)$，此时效果如下所示：

|                                                                               |                                                                               |
| ----------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| ![](assets/Mesh%20Basics%20-%20Procedural%20Grid/image-20211223094251492.png) | ![](assets/Mesh%20Basics%20-%20Procedural%20Grid/image-20211223094402735.png) |

## Normal Map

为了增加细节还可以使用 [Normal Mapping](../../Boos/Learn%20OpenGL/Learn%20OpenGL%20-%20Ch%2029%20Normal%20Mapping.md)

![|400](assets/Mesh%20Basics%20-%20Procedural%20Grid/image-20211223094537578.png)

但因为 Normal Map 中的法线是定义在 [Tangent Space](../../Boos/Learn%20OpenGL/Learn%20OpenGL%20-%20Ch%2029%20Normal%20Mapping.md#Tangent%20Space) 中，因此为了让法线贴图能正常的被解析，还需要为其指定 `Tangent` 及 `Bitangent` 方向。

在 Unity 中仅需要为顶点指明 `Tangent` 方向，`Bitangent` 方向可以通过 `Tangent` 方向与 `Normal` 方向叉乘得到。

在 Unity 中，`Tangent` 方向用一个 `Vector4` 表示，其中第四个分量必然是 $1$ 或 $-1$，该分量主要用来决定 `Bitangent` 方向是否需要进行取反操作，该值通常为 $-1$。

在示例中，因为定义的是一个平面，因此可以直接设定 `Tangent` 为 $(1,0,0,-1)$。

指定 `Tangent` 的代码如下：
```csharp
private void Generate()
{
    //...
    Vector4[] tangents = new Vector4[vertices.Length];
    Vector4 tangent = new Vector4(1f, 0f, 0f, -1f);

    for (int i = 0, y = 0; y <= ySize; y++)
    {
        for (int x = 0; x <= xSize; x++, i++)
        {
            vertices[i] = new Vector3(x, y);
            uv[i] = new Vector2((float)x / xSize, (float)y / ySize);
            tangents[i] = tangent;
        }
    }

    // ...
    mesh.tangents = tangents;
    // ...
}

```

此时的效果如下所示：

|                                                                               |                                                                               |     |
| ----------------------------------------------------------------------------- | ----------------------------------------------------------------------------- | --- |
| ![](assets/Mesh%20Basics%20-%20Procedural%20Grid/image-20211224080244159.png) | ![](assets/Mesh%20Basics%20-%20Procedural%20Grid/image-20211224080254193.png) |     | 




