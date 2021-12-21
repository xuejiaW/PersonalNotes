---
created: 2021-12-20
updated: 2021-12-21
---
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
![|500](assets/Learn%20OpenGL%20-%20Ch%2023%20Instancing/Untitled.png)

# Instanced arrays

一个程序中可使用的Uniform变量是有上限的，因此还有种方法为 `instanced arrays`。该方法实际依赖于顶点着色器中的 `layout`。

在顶点着色器中新增一个关于偏移量的 `layout`，并可以直接使用这个 `layout`。

```glsl
layout (location = 3) in vec2 offset;
...
vec3 aPos= pos*(gl_InstanceID) / 100;
gl_Position= model*vec4(aPos,1.0) + vec4(offset, 0, 1);
```

```ad-warning
这里使用的 `gl_InstanceID` ，只是用来调整Pos的大小。
```

在C++中，如传递普通的 `layout` 数据一样，传递需要用的offset变量：

```glsl
unsigned int instanceVBO;
glGenBuffers(1, &instanceVBO);
glBindBuffer(GL_ARRAY_BUFFER, instanceVBO);
glBufferData(GL_ARRAY_BUFFER, sizeof(glm::vec2) * 100, &translations[0], GL_STATIC_DRAW);

glEnableVertexAttribArray(3);
glVertexAttribPointer(3, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), (void *)0);
glVertexAttribDivisor(3, 1);
```

唯一与之前不同的是需要调用 `glVertexAttribDivisor` 函数。该函数指定特定的 `layout` 数据以怎么样的频率从绑定的 `BufferData` 中去取。如例子中：

第一个参数为 3，表示设置的对象为 `layout` 中 `Position = 3` 的对象。
第二个参数为1，表示在画每个Instance时从设置的 `translations` 数组中去一次参数。如果设为2，表示每画两个Instance时取一次参数。该参数的默认值为0，表示画每个顶点时去一次参数。

运行结果为：
![|500](assets/Learn%20OpenGL%20-%20Ch%2023%20Instancing/Untitled%201.png)

# 源码：

[main.cpp](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/21.Instancing/main.cpp)

[instancingLayout.vert](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/21.Instancing/instancingLayout.vert)

[instancingUniform.vert](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/21.Instancing/instancingUniform.vert)