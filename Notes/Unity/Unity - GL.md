---
tags:
    - Unity
    - OpenGL
created: 2021-12-30
updated: 2021-12-31
---

# Overview

Unity GL 是 Unity 封装的模拟类似于 OpenGL Immdiate Mode API （GLUT）的库。

```ad-note
 在大多数情况下，推荐使用 `Graphics.DrawMesh` 或 `CommandBuffer` ，而非直接使用 GL。
```

GL 绘制时使用的材质是 GL 命令运行时正在被使用的材质。因此如果使用 GL 时未显式的指定需要用的 Material，则结果是未定义的。因此在绘制前应当使用 `Material.SetPass` 来指定绘制时的材质。

GL 使用的 MVP 矩阵也是当前正在设置的矩阵，因此也需要设置矩阵。可以通过 `PushMatrix` 保存当前的矩阵，在通过类似于 `LoadIdentity` 函数设置绘制需要的矩阵， 在绘制完后使用 `PopMatrix` 恢复保存的矩阵。

```ad-note
`LoadIdentity` 表示绘制的矩阵不做任何额外处理，即 MVP 矩阵都为单位矩阵
```

GL 中类似于 `Color` ， `Vertex3` 等函数都是设置一个顶点的参数，因此在设置前需要保证 Shader 的顶点数据中包含了相应的数据。如 Shader 中有 Color 数据，`GL.Color` 函数才是有效的。

GL Drawing 绘制是立即执行的，因此如果在 `Update` 函数（在 Camera 渲染前）中调用 GL，则当 Camera 正常渲染时会将 GL 绘制的内容覆盖。因此通常的做法是将 GL 的绘制写在 `OnPostRender` 函数中，并将该函数依附在 Camera 组件上。

GL 的实例代码与效果如下所示：

```csharp
public class GLDemo : MonoBehaviour
{
    public Shader drawingShader = null;
    private Material drawingMaterial = null;

    private void Start()
    {
        drawingMaterial = new Material(drawingShader);
    }

		private void OnPostRender()
    {
        drawingMaterial.SetPass(0);

        GL.PushMatrix();
        GL.LoadIdentity();

        // In DX, (-1,-1) is at the upper-left corner of the screen
        GL.Begin(GL.QUADS);
        GL.Color(Color.black);
        GL.Vertex3(-0.75f, -0.25f, 0);
        GL.Color(Color.green);
        GL.Vertex3(-0.25f, -0.25f, 0);
        GL.Color(Color.blue);
        GL.Vertex3(-0.25f, -0.75f, 0);
        GL.Color(Color.red);
        GL.Vertex3(-0.75f, -0.75f, 0);
        GL.End();

        GL.Begin(GL.TRIANGLES);
        GL.Vertex3(0.25f, 0.75f, 0);
        GL.Vertex3(0.75f, 0.75f, 0);
        GL.Vertex3(0.5f, 0.25f, 0);
        GL.End();

        GL.PopMatrix();
    }
}
```

在代码中通过了 GL 绘制了一个 Quad 和一个 Triangles。需要注意因为这里设置了 `LoadIdentity` 矩阵，所以设的顶点是在 NDC 空间中的。而 NDC 空间中 $(-1,1)$ 点在不同图形 API 中是不同的，如 DX 在左上角，OpenGL 在右下角。

其中使用的 Shader 如下：

```glsl
Shader "GL/UnlitColor"
{
    Properties { }
    SubShader
    {
        Cull front ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                fixed4 color: COLOR0;
            };

            struct v2f
            {
                fixed4 color: COLOR0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = v.vertex;
                o.color  = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
}
```

在 Shader 中，在顶点数据中定义了 color，因此 GL 中设置的 Color 也可以正常显示。另外在顶点着色器中，直接将传入的顶点传出，因为此时的 MVP 矩阵都为单位矩阵。

此时的效果如下：

![|500](assets/Unity%20-%20GL/image-20211230232006099.png)

# Reference

[Unity - Scripting API: GL (unity3d.com)](https://docs.unity3d.com/ScriptReference/GL.html)