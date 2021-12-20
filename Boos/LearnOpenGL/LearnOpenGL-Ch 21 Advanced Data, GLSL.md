---
created: 2021-12-20
updated: 2021-12-20
---
# 缓存填充

## glBufferData && glBufferSubData

OpenGL中的缓存只是一个管理特定内存块的对象，只有在将它绑定到一个 `缓寸目标（Buffer Target）`后，这块缓存才有意义。例如当绑定缓存到`GL_ARRAY_BUFFER`后，这块缓存就是一个顶点数组缓冲。OpenGL在每个目标的内部会存储一个缓存的引用，并根据目标的不同，以不同的方式处理缓冲。

目前为止，一直使用`glBufferData`函数来填充缓冲对象所管理的内存，这个函数会分配一块内存，并将数据填充到该内存块中。如果`data`设为`Null`，则这函数只分配内存，但不进行填充，仅仅是分配内存。

```glsl
glBufferData(GL_ARRAY_BUFFER, sizeof(vertices),vertices, GL_STATIC_DRAW);
```

`glBufferData`是一次性填充整个缓冲，也可以使用`glBufferSubData`填充特定区域。

该函数需要一个缓冲目标，一个偏移量、数据的大小和数据本身作为参数。

偏移量指定了从何处开始填充这个缓冲，要注意的是，缓冲需要由足够的已分配内存，所以对一个缓冲调用`glBufferSubData`前必须先调用`glBufferData`。

```glsl
// 装填范围： [24, 24 + sizeof(data)]
glBufferSubData(GL_ARRAY_BUFFER, 24, sizeof(data), &data); 
```

## glMapBuffer

将数据导入缓冲的另一种方法是，通过`glMapBuffer`请求缓冲内存的指针，直接将数据复制到缓冲当中。

如果要直接将数据映射到缓冲中，而不事先将其存储在临时内存中，例如从文件读取数据，这个函数将非常有用。

```cpp
float data[] = {
  0.5f, 1.0f, -0.35f
  ...
};
glBindBuffer(GL_ARRAY_BUFFER, buffer);
// Get Pointer
void *ptr = glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
// Copy data to buffer
memcpy(ptr, data, sizeof(data));

glUnmapBuffer(GL_ARRAY_BUFFER);
```

# 分批顶点属性（Batching vertex attributes）

在之前的处理中对属性使用了交错处理，即将顶点的位置、发现和纹理坐标紧密的放在一起，如123123123这样的排布。然后通过 `glVertexAttribPointer` 指定顶点数组缓冲内容的属性布局。

```cpp
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void *)0);
glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void *)(3 * sizeof(float)));
glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void *)(5 * sizeof(float)));
```

但在使用了`glBufferSubData`后也可以处理将每一种属性存储在一起的缓存形式，如111222333。

```glsl
float positions[] = { ... };
float normals[] = { ... };
float tex[] = { ... };

glBufferData(GL_ARRAY_BUFFER, BufferSize, null, GL_STATIC_DRAW);
glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(positions), &positions);
glBufferSubData(GL_ARRAY_BUFFER, sizeof(positions), sizeof(normals), &normals);
glBufferSubData(GL_ARRAY_BUFFER, sizeof(positions) + sizeof(normals), sizeof(tex), &tex);

glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), 0);  
glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)(sizeof(positions)));  
glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), (void*)(sizeof(positions) + sizeof(normals)));
```

# 拷贝缓存

在装填了一个缓存后，可以使用函数 `glCopyBufferSubData` 将其拷贝至另一个缓存中，函数原型如下：

```cpp
void glCopyBufferSubData(GLenum readTarget, GLenum writeTarget, GLintptr readoffset,
                         GLintptr writeoffset, GLsizeiptr size);
```

原型中的 `readTarget` 和 `writeTarget` 表示读和写的缓存的类型，如 `readTarget` 可以设为 `GL_ARRAY_BUFFER` ，同时 `writeTarget` 设为 `GL_ELEMENT_ARRAY_BUFFER` ，则调用函数时，实际上操作的对象是当前绑定至 `GL_ARRAY_BUFFER` 和 `GL_ELEMENT_ARRAY_BUFFER` 时的缓存。

当需要对两个类型一致的缓存进行拷贝时，则需要用到 `GL_COPY_READ_BUFFER` 和 `GL_COPY_WRITE_BUFFER` 两个类型。因为不可能存在两块内存同时绑定到同一个类型上的情况出现，

如不可能同时将两个VBO绑定到 `GL_ARRAY_BUFFER` 上。

下例中，展示了如果将VBO对象 `vbo1` 拷贝至VBO对象 `vbo2` 中：

```cpp
glBindBuffer(GL_COPY_READ_BUFFER, vbo1);
glBindBuffer(GL_COPY_WRITE_BUFFER, vbo2);
glCopyBufferSubData(GL_COPY_READ_BUFFER, GL_COPY_WRITE_BUFFER, 0, 0, 8 * sizeof(float));
```

# 顶点着色器变量

之前使用的 `gl_Position` 就是顶点着色器内置变量，表示在裁剪空间输出的顶点位置。同样的还存在其他的顶点着色器变量。

## gl_PointSize

当使用 `GL_POINTS` 作为渲染图元时，每个顶点会被渲染为一个点，可以通过 `gl_PointSize` 设置点的大小（float类型，单位为像素）。

默认情况下， 对于 `gl_PointSize` 的设置是不生效的，需要先开启 `GL_PROGRAM_POINT_SIZE` 。

```cpp
glDrawElements(drawingMode, mesh->GetVertexNum(), GL_UNSIGNED_INT, 0);
glEnable(GL_PROGRAM_POINT_SIZE);
```

```glsl
// 顶点着色器下
gl_PointSize = gl_Position.z; 
```

例子中，将 `gl_PointSize` 设置为 `gl_Position.z` ，这也随着顶点的深度越大（距离摄像机越远），绘制的点的尺寸也会越大。
![|500](assets/LearnOpenGL-Ch%2021%20Advanced%20Data,%20GLSL/GIF_11-16-2020_11-53-19_AM.gif)

## gl_VertexID

`gl_VretexID` 可以读取当前处理的顶点的ID。

如在使用 `glDrawElements` 和 `glDrawArrays`时，就是当前正在绘制的顶点的索引值，但要注意的是在使用 `glDrawElements` 时，索引值是由 `EBO` 决定的。

# 片段着色器变量

## gl_FragCoord

在 [Depth Testing](LearnOpenGL-Ch%2015%20Depth%20Testing.md) 中已经接触了 `gl_FragCoord` ，可以利用 `gl_FragCoord.z` 绘制出片段的深度信息。

而同样可以利用 `gl_FragCoord.x` 和 `gl_FragCoord.y` 实现一些效果，注意这两者都是针对于屏幕空间的，如屏幕的尺寸是 $800 \times 600$，则 `gl_FragCoord.x < 400` 就表示屏幕的左半边。

```glsl
if(gl_FragCoord.x <400)
    FragColor= vec4(1,0,0,1);
else
    FragColor = vec4(0,1,0,1);
```

![|500](assets/LearnOpenGL-Ch%2021%20Advanced%20Data,%20GLSL/half.gif)

## gl_FrontFacing

`gl_FrontFacing` 是一个布尔值，可以分辨在 [Face Culling](LearnOpenGL-Ch%2018%20Face%20Culling.md) 中讨论的前向面和后向面。

可以利用 `gl_FrontFacing` 让物体在前向面和后向面分别渲染不同的贴图

```glsl
if(gl_FrontFacing)
    FragColor = texture(frontTexture,texcoord);
else
    FragColor = texture(backTexture,texcoord);
```

![|500](assets/LearnOpenGL-Ch%2021%20Advanced%20Data,%20GLSL/GIF.gif)

## gl_FragDepth

之前提到的 [gl_FragCoord](https://www.notion.so/Advanced-Data-GlSL-f4b535afd6214117a2c67de570820008) 是一个只读变量。但这里的 `gl_FragDepth` 可以改写一个像素的深度值，可写的范围是 $0 \sim 1$。

```glsl
gl_FragDepth = 0.0; // this fragment now has a depth value of 0.0
```

但如果对 `gl_FragDepth` 进行了写入，在 [Depth Testing](https://www.notion.so/Depth-Testing-bf9abf89048c4d72bdceee5ca5ab059c) 中提及的[提前深度测试](https://www.notion.so/Depth-Testing-bf9abf89048c4d72bdceee5ca5ab059c) 就无法进行，因为OpenGL在进行片段着色器前不再能保证每个像素的深度值。这可能会引发巨大的性能问题。

但在OpenGL版本 4.2 之后，引入了 `深度条件（Depth Condition）` 概念，指可以在片段着色器中，指明对于深度值的改写一定会满足一定的条件，如大于或小于片元原先的深度（`gl_FragCoord.z`）。

```glsl
layout (depth_<condition>) out float gl_FragDepth;
```

其中 `condition` 可选项如下：

| Condition | Descripton                                   |
| --------- | -------------------------------------------- |
| any       | 填写值与原片元深度无关系，提前深度测试被关闭 |
| greater   | 填写值一定大于原片元深度                     |
| less      | 填写值一定小于原片元深度                     |
| unchanged | 填写值与原片元深度相同                                             |

示例代码如：
```glsl
#version 420 core // note the GLSL version!
out vec4 FragColor;
layout (depth_greater) out float gl_FragDepth;

void main()
{             
    FragColor = vec4(1.0);
    gl_FragDepth = gl_FragCoord.z + 0.1;
}
```

# 接口块（Interface Block）

接口块（Interface Block）与在 [Materials](https://www.notion.so/Materials-930c6844a30a42cea025650076650443) 使用的 [Struct](https://www.notion.so/Materials-930c6844a30a42cea025650076650443) 有点类似，但它是为了让着色器之间传递的变量（即通过 `in` 和 `out` 传递的变量）可以组合在一起，因此必须通过 `in` 和 `out` 修饰，而不能在uniform使用。

如在顶点着色器中：

```glsl
out VS_OUT
{
    vec2 texcoord;
    vec3 normal;
} vs_out;
```