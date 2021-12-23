---
created: 2021-12-20
updated: 2021-12-23
tags:
    - Unity
    - Catlike
---

# Rendering Things

Unity 场景内的每个物体本质上都是通过 `Mesh` 进行的渲染。

`Mesh` 最少需要一系列顶点和一系列用来连接这些顶点的三角形定义构成。

在 Unity 中如果渲染一个 Mesh，最少需要两个组件 `Mesh Filter` 和 `Mesh Renderer`，前者会包含对 Mesh 的引用，后者会负责 Mesh 的真正渲染。
![|400](assets/Mesh%20Basics%20-%20Procedural%20Grid/image-20211222083208337.png)

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

Unity 中默认的正向 [Face Culling](../../Boos/Learn%20OpenGL/Learn%20OpenGL%20-%20Ch%2018%20Face%20Culling.md) 