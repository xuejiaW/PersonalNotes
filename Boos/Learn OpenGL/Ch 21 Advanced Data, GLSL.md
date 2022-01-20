---
created: 2021-12-20
updated: 2021-12-24
tags:
    - OpenGL
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
![|500](assets/Learn%20OpenGL%20-%20Ch%2021%20Advanced%20Data,%20GLSL/GIF_11-16-2020_11-53-19_AM.gif)

## gl_VertexID

`gl_VretexID` 可以读取当前处理的顶点的ID。

如在使用 `glDrawElements` 和 `glDrawArrays`时，就是当前正在绘制的顶点的索引值，但要注意的是在使用 `glDrawElements` 时，索引值是由 `EBO` 决定的。

# 片段着色器变量

## gl_FragCoord

在 [Depth Testing](Ch%2015%20Depth%20Testing.md) 中已经接触了 `gl_FragCoord` ，可以利用 `gl_FragCoord.z` 绘制出片段的深度信息。

而同样可以利用 `gl_FragCoord.x` 和 `gl_FragCoord.y` 实现一些效果，注意这两者都是针对于屏幕空间的，如屏幕的尺寸是 $800 \times 600$，则 `gl_FragCoord.x < 400` 就表示屏幕的左半边。

```glsl
if(gl_FragCoord.x <400)
    FragColor= vec4(1,0,0,1);
else
    FragColor = vec4(0,1,0,1);
```

![|500](assets/Learn%20OpenGL%20-%20Ch%2021%20Advanced%20Data,%20GLSL/half.gif)

## gl_FrontFacing

`gl_FrontFacing` 是一个布尔值，可以分辨在 [Face Culling](Ch%2018%20Face%20Culling.md) 中讨论的前向面和后向面。

可以利用 `gl_FrontFacing` 让物体在前向面和后向面分别渲染不同的贴图

```glsl
if(gl_FrontFacing)
    FragColor = texture(frontTexture,texcoord);
else
    FragColor = texture(backTexture,texcoord);
```

![|500](assets/Learn%20OpenGL%20-%20Ch%2021%20Advanced%20Data,%20GLSL/GIF.gif)

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

接口块（Interface Block）与在 [Ch 12 Materials](Ch%2012%20Materials.md) 使用的 `Struct` 有点类似，但它是为了让着色器之间传递的变量（即通过 `in` 和 `out` 传递的变量）可以组合在一起，因此必须通过 `in` 和 `out` 修饰，而不能在uniform使用。

如在顶点着色器中：
```glsl
out VS_OUT
{
    vec2 texcoord;
    vec3 normal;
} vs_out;
```

在片段着色器中：
```glsl
in VS_OUT
{
    vec2 texcoord;
    vec3 normal;
}fs_in;
```

其中 `VS_OUT` 是接口块的类型，在通信的着色器中必须保持一致，而 `vs_out` 和 `fs_in` 是在不同着色器中对于接口块的变量命名，可以不同，只是在各自的着色器中使用。

# Uniform缓冲

## Uniform缓冲对象

在之前的教程中，当使用多个着色器时，尽管大部分的uniform变量都是相同的，但仍然需要不断的设置它们，如 `View` 和 `Projection` 矩阵。

在OpenGL中提供了一个叫做 `Uniform缓冲对象（Uniform Buffer Objects）`，允许定义一个全局的 `Uniform` 数据。当使用这个数据时，只需要在GPU内存中设置一次即可。在C++端，同样通过 `glGenBuffers` 创建数据，但内存的绑定类型为 `GL_UNIFORM_BUFFER` 。

```glsl
unsigned int uboBlock;
glGenBuffers(1, &uboBlock);
glBindBuffer(GL_UNIFORM_BUFFER, uboBlock);
```

但对于每个Shader而言，仍然需要各自绑定到这个特定的 `Uniform` 数据。在Shader内部的Uniform数据需要结合在一起，以保证可以与C++端定义的数据对应。如将 `View` 和 `Projection` 定义为Uniform缓冲对象如下：

```glsl
layout (std140) uniform Matrices
{
    mat4 projection;
    mat4 view;
};
```

其中 `std140` 是对于内存对齐的规范，这类规范称为 `Uniform块布局（Uniform Block Layout）`。

## Uniform块布局

如在Shader中，定义了如下的Uniform块：

```glsl
layout (std140) uniform ExampleBlock
{
    float value;
    vec3  vector;
    mat4  matrix;
    float values[3];
    bool  boolean;
    int   integer;
};
```

块中的每个数据，它的大小在OpenGL都有定义，且与C++中的大小是一致的。但是OpenGL并不知道数据与数据之间的偏移量。如一些硬件，会在 `vec3` 后直接存放 `float` ，而另一些硬件会先把 `vec3` 填充为 `vec4` ，然后再存放 `float` 。

默认情况下，OpenGL 存储Uniform内存的布局为 `shared` 。当定义为 `shared` 后，OpenGL会根据硬件定义的偏移量存储数据，且在多个Shader程序之间使用相同的存储布局。在Uniform块中数据定义的顺序不变的情况下，OpenGL会调整这些数据的位置来进行优化。因此无法准确的推算出每个数据的偏移量，而需要通过 `glGetUniformIndices` 函数来获取偏移量。

尽管 `shared` 内存布局可以节约内存，但对每个 uniform 变量都需要查询偏移量，因此也会造成很大的工作量。因此通常会使用 `std140` 布局，在 `std140` 布局下明确的定义了每个类型数据的偏移量，因此可以手动的算出每个数据的位置。

对于每一个变量，存在 `基本偏移量（Base Alignment）` 和 `对齐偏移量（Aligned Offset）` 两个概念。基本偏移量可以看作是对象的大小，对齐偏移量表示对象开始存储的位置。

变量的基本偏移量定义如下：

| type                      | Layout Rule                                                  |
| ------------------------- | ------------------------------------------------------------ |
| 标量，如 int, bool, float | 4                                                            |
| Vector                    | 8 或 16，因此 vec3 基本偏移量为 16                           |
| 标量或 Vector 的数组      | 对于其中的每个变量，基本偏移量为 16                          |
| Materials                 | 每一行或列的基本偏移量为 16                                  |
| Struct                    | 结构体内的变量按上述规则运算，且结构体整体的尺寸为 16 的倍数 |

对于对齐偏移量，必须是基本偏移量的4的倍数。如上述Uniform块的基本偏移量和对齐偏移量如下：

```glsl
layout (std140) uniform ExampleBlock
{
                     // base alignment  // aligned offset
    float value;     // 4               // 0 
    vec3 vector;     // 16              // 16  (offset must be multiple of 16 so 4->16)
    mat4 matrix;     // 16              // 32  (column 0)
                     // 16              // 48  (column 1)
                     // 16              // 64  (column 2)
                     // 16              // 80  (column 3)
    float values[3]; // 16              // 96  (values[0])
                     // 16              // 112 (values[1])
                     // 16              // 128 (values[2])
    bool boolean;    // 4               // 144
    int integer;     // 4               // 148
};
```

在知道了偏移量后，即可以通过 `glBufferSubData` 函数进行数据装填。

除了 `std140` 和 `shared` 外，还有一种 `packed` 布局。 `packed` 布局下，每个Shader都会对内存进行优化，因此连多个Shader程序之间的布局都无法保证相同。

## 使用Uniform缓冲

在C++端创建的Uniform缓冲对象内存与Shader中定义的Uniform块需要通过 `绑定点（Binding points）` 结合在一起。多个Shader可以绑定至同一个 `绑定点`，这也就达到了 Uniform缓冲对象复用的作用。如下图所示：

![](assets/Learn%20OpenGL%20-%20Ch%2021%20Advanced%20Data,%20GLSL/Untitled.png)

因此整个使用Uniform缓冲对象的流程如下：

首先需要在C++端，为Uniform缓冲对象创建内存：

```cpp
unsigned int uboExampleBlock;
glGenBuffers(1, &uboExampleBlock);
glBindBuffer(GL_UNIFORM_BUFFER, uboExampleBlock);
glBufferData(GL_UNIFORM_BUFFER, 152, NULL, GL_STATIC_DRAW); // allocate 152 bytes of memory
glBindBuffer(GL_UNIFORM_BUFFER, 0);
```

在使用 `glBufferSubData` 为不同的变量装填数据后，需要调用 `glBindBufferBase` 将其绑定至特定的绑定点，如下语句会将 Uniform缓冲对象绑定至2号绑定点。

```cpp
glBindBuffer(GL_UNIFORM_BUFFER, uboExampleBlock);
glBindBufferBase(GL_UNIFORM_BUFFER, 2, uboExampleBlock);
```

也可以是用 `glBindBufferRange` 函数将Uniform缓冲对象中的一部分数据绑定到特定的绑定点：

```cpp
glBindBufferRange(GL_UNIFORM_BUFFER, 2, uboExampleBlock, 0, 152);
```

对于Shader中的Uniform块，首先需要通过 `glGetUniformBlockIndex` 获取Uniform块的索引，再 使用函数 `glUniformBlockBinding` 函数同样将其绑定至绑定点，如下所示：

```cpp
unsigned int lights_index = glGetUniformBlockIndex(shaderA.program, "Lights");   
glUniformBlockBinding(shaderA.program, lights_index, 2);
```

至此，C++部分的Uniform缓冲对象与Shader中的Uniform块绑定在了一起，其余的部分与使用Uniform相同。

## 使用Uniform缓冲传递 View/Projection 例子

在顶点着色器中定义Uniform块

```glsl
layout (std140) uniform Matrices
{
    mat4 projection;
    mat4 view;
};
```

修改框架的 `MeshRender` 组件，在构造函数中根据需求创建 Uniform缓存，并将其绑定至绑定点 0。同时将着色器中的 `Matrices` Uniform 块也绑定至绑定点0。

```cpp
if (usingSharedCameraState)
{
    if (!uboDataCreated)
    {
        glGenBuffers(1, &UBO);
        glBindBuffer(GL_UNIFORM_BUFFER, UBO);
        glBufferData(GL_UNIFORM_BUFFER, 2 * sizeof(mat4), nullptr, GL_STATIC_DRAW);
        glBindBufferBase(GL_UNIFORM_BUFFER, 0, UBO); // bind to 0 binding point
        glBindBuffer(GL_UNIFORM_BUFFER, 0);
        uboDataCreated = true;

        Scene::GetInstance()->preRender = []() {
            uboDataUpdated = false;
        };
    }

    uint uniformBlockIndex = glGetUniformBlockIndex(this->material->GetShader()->Program, "Matrices");
    glUniformBlockBinding(this->material->GetShader()->Program, uniformBlockIndex, 0); // Binding to Binding Point 0
}
```

注意上述代码中 `uboDataCreated` 和 `uboDataUpdated` 是静态变量。前者保证在有多个 `MeshRender` 的情况下，Uniform 缓存只会被创建一次。后者在每帧的渲染前，需要被清空，保证数据每帧进行更新，且只更新一次。

`MeshRender`在每帧更新时，根据是否使用Uniform缓冲对象，决定是直接通过 `glUnifromXXX` 函数更新数据，还是通过 `glBufferSubData` 装填Uniform缓冲对象。

```cpp
if (!usingSharedCameraState)
{
    glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "view"), 1, GL_FALSE, glm::value_ptr(view));
    glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "projection"), 1, GL_FALSE, glm::value_ptr(projection));
}
else
{
    if (!uboDataUpdated)
    {
        glBindBuffer(GL_UNIFORM_BUFFER, UBO);
        glBufferSubData(GL_UNIFORM_BUFFER, 0, sizeof(mat4), glm::value_ptr(projection));
        glBufferSubData(GL_UNIFORM_BUFFER, sizeof(mat4), sizeof(mat4), glm::value_ptr(view));
        glBindBuffer(GL_UNIFORM_BUFFER, 0);
    }
}
```

将之前使用 `gl_FragCoord` 和 `gl_FrontFacing` 的两个立方体，设为使用Uniform 缓冲。

```cpp
Shader *halfShader = new Shader("../Framework/Shaders/DefaultUBO.vert", "./half.frag");
GO_Cube *halfCube = new GO_Cube(new MeshRender(halfShader, true));

Shader *frontFacingShader = new Shader("../Framework/Shaders/DefaultUBO.vert", "./frontFacing.frag");
GO_Cube *frontFacingCube = new GO_Cube(new MeshRender(frontFacingShader, true));
```

# 结果与源码：
![](assets/Learn%20OpenGL%20-%20Ch%2021%20Advanced%20Data,%20GLSL/AdvancedDataGLSL.gif)

[main.cpp](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/19.AdvancedData%26%26AdvancedGLSL/main.cpp)

[half.frag](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/19.AdvancedData%26%26AdvancedGLSL/half.frag)

[pointRender.vert](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/19.AdvancedData%26%26AdvancedGLSL/interfaceBlock.vert)

[frontFacing.frag](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/19.AdvancedData%26%26AdvancedGLSL/frontFacing.frag)

[interfaceBlock.vert](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/19.AdvancedData%26%26AdvancedGLSL/interfaceBlock.vert)

[MeshRender.cpp](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/Framework/Components/MeshRender.cpp)