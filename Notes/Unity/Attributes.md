---
created: 2021-12-22
updated: 2021-12-24
---
# RequireCompnent

`RequireComponent` 自动添加依赖的组件，如下所示会自动添加 `MeshFilter` 和 `MeshRenderer`：
```csharp
[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class Grid : MonoBehaviour
{
}
```