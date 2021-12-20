想象如果一个场景中有千万棵草，每个草都只有几个顶点，但他们的世界坐标可能不同，按之前的教程，可能需要类似于如下的代码。

```glsl
for(unsigned int i = 0; i < amount_of_models_to_draw; i++)
{
    DoSomePreparations(); // bind VAO, bind textures, set uniforms etc.
    glDrawArrays(GL_TRIANGLES, 0, amount_of_vertices);
}
```

在每次调用类似于`glDrawArrays`这样的函数时，都是一个CPU向GPU通信的过程，CPU 需要告诉GPU一系列绘制相关的内容，这个过程称为 `Draw call`，而对于GPU来说绘制这些顶点是非常快的，所以游戏的瓶颈会在于CPU。

`实例化（Instancing）` 技术可以一次性将数据从CPU传递给GPU，因此可以极大的减少DrawCall的数量。

```ad-warning
Instancing 要求所有的对象都使用相同的 Mesh 。
```

使用实例化时需要将之前的渲染方式从`glDrawArrays`和`glDrawElement`改为`glDrawArraysInstanced`和`glDrawElementsInstanced`即可。两个Instanced的版本都需要一个额外的参数`Instance count`来表示需要重复绘制几次。

在顶点着色器中有一个内建的参数`gl_InstancedID`它表示当前绘制的Index，从0开始。例如一共需要绘制100个Instance物体，那么当绘制第43个时，它的`gl_InstancedID`应该为42。

对于传递Instance需要的数据，有两种方法：通过 `uniform` 和 通过 `instanced arrays`。

# Uniform

为了让不同绘制的物体有不同的位置，可以传递一个Uniform数组，数组中包含了不同对象的位置，在顶点着色器中通过 `gl_InstanceID` 选择当前对象需要的位置信息。

在顶点着色器中：

```glsl
uniform vec2 offsets[100];

void main()
{
    vec2 offset=offsets[gl_InstanceID];
		gl_Position= model*vec4(pos.xyz,1.0)+vec4(offset,0,1);
...
}
```

在C++代码中，首先计算出要传递给着色器的100个偏移量：

```glsl
glm::vec2 translations[100];
int index = 0;
float offset = 0.1f;
for (int y = -15; y < 15; y += 3)
{
    for (int x = -15; x < 15; x += 3)
    {
        glm::vec2 translation;
        translation.x = (float)x / 10.0f + offset;
        translation.y = (float)y / 10.0f + offset;
        translations[index++] = translation;
    }
}
```

然后常规的通过Uniform进行传递：

```glsl
instanceUnifromShader->Use();
for (int i = 0; i != 100; ++i)
    instanceUnifromShader->SetVec2("offsets[" + std::to_string(i) + "]", translations[i]);
```

在 `MeshRender` 中需要对应的将绘制方法改为Instancing版本：

```glsl
if (instancingCount == 0)
    glDrawElements(drawingMode, mesh->GetVertexNum(), GL_UNSIGNED_INT, 0);
else
    glDrawElementsInstanced(drawingMode, mesh->GetVertexNum(), GL_UNSIGNED_INT, 0, instancingCount);
```

结果如下：
![](assets/LearnOpenGL-Ch%2023%20Instancing/Untitled.png)