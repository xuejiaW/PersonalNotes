---
tags:
    - Unity
created: 2022-01-06
updated: 2022-01-06
cssclass: [table-border]
---

# Material

对于如下的使用场景：有 2500 个小球，在每帧会相应的改变颜色：

![|500](assets/Unity%20-%20Material%20Property%20Blocks/animated-spheres.gif)

最直观的实现方式是通过修改 `material.color` ，如下所示：

```glsl
GetComponent<Renderer>().material.color = color;
```

但因为这多个小球是使用了同一个材质，当对其中一个小球第一次调用了 `render.material` 时，Unity 为了保证这个小球渲染的不同，会为这个小球创建一个材质的拷贝实例，再对新建的拷贝实例进行修改。之后针对这个小球调用 `render.material` 时，就仍然是对新实例进行修改。

如下为对 2500 个小球调用 `render.material` 前后的的内存分配统计，可以看到在调用前整个场景使用了 40 个材质（其中只有一个是小球的材质，剩下的是天空盒，地面等物体的材质），当调用后整个场景使用了 2540 个材质，其中新增的 2500 个材质就是新创建的拷贝的实例。且调用前使用的内存为 $47.1 \mathbf{KB}$ 使用后的内存为 $5.9 \mathbf{MB}$

|                                                                                       |                                                                                           |
| ------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| ![调用前的材质数和内存](assets/Unity%20-%20Material%20Property%20Blocks/Untitled.png) | ![调用后的材质数和内存](assets/Unity%20-%20Material%20Property%20Blocks/Untitled%201.png) |

同时因为材质数的增加，每一次材质的数据修改后，需要用更多的时间将材质数据从 CPU 传递给 GPU。如下所示，一共消耗了 5.46 毫秒：
![](assets/Unity%20-%20Material%20Property%20Blocks/Untitled%202.png)

```ad-note
上述使用例子中使用的 Shader 为 Unity 内建的 `Standard Surface Shader` 。
```

# Material Property Block

针对上述例子中，多个物体使用同一个材质，但是每个物体需要对材质有各自的修改的情况，Unity 实现了 `MaterialPropertyBlock` 变量，该变量并不会造成多个材质的拷贝，且减少了 CPU 向 GPU 传输数据的时间。如下为使用 `MaterialPropertyBlock` 修改颜色时的内存与耗时情况，可以看到使用的材质数并没有增加，且耗时减少到 1.48 毫秒：

|                                                                               |                                                                               |
| ----------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| ![内存消耗](assets/Unity%20-%20Material%20Property%20Blocks/Untitled%203.png) | ![CPU 耗时](assets/Unity%20-%20Material%20Property%20Blocks/Untitled%204.png) | 

对于需要通过 `MaterialPropertyBlock` 设置的 Shader 变量，可以在前面加上 `[PerRenderData]` ，让该变量在 Inspector 窗口中不被显示，如下所示：

```glsl
Properties
{ 
    [PerRendererData] _Color ("Color", Color) = (1,1,1,1)
    // ...
}
```

![无颜色信息](assets/Unity%20-%20Material%20Property%20Blocks/Untitled%205.png)

```ad-note
即使不添加 `[PerRenderData]` ，也可以使用 `MaterialPropertyBlock` 进行设置。
```

使用 `MaterialPropertyBlock` 时调用 renderer 的 `SetPropertyBlock` 接口即可，如下所示：

```csharp
private MaterialPropertyBlock propertyBlock = null;

private void Start()
{
    meshRenderer = GetComponent<MeshRenderer>();
    propertyBlock = new MaterialPropertyBlock();
}

private Update()
{
		Color color = new Color(Mathf.Sin(Time.time), Mathf.Cos(Time.time), 0, 1);
		propertyBlock.SetColor("_Color", color);
		meshRenderer.SetPropertyBlock(propertyBlock);
}

```

使用 `MaterialPropertyBlock` 可以保证每个物体在不拷贝 Material 的情况下在渲染前对材质进行修改，即所有物体实际上使用的是一个材质。

<aside> 🚫

</aside>

```ad-error
 虽然所有的物体使用的一个材质，但它们仍然无法被 Dynamic batching。 但如果修改的对象是 `INSTANCED_PROP` ，则可以通过 GPU Instancing 被合并在一起绘制，具体可参考 [Object Variety](https://www.notion.so/Object-Variety-5a6cde8bed2b4640a308aab60c2e7bff) 最后绘制多个不同颜色 Shape 时使用的 Shader。
```

#