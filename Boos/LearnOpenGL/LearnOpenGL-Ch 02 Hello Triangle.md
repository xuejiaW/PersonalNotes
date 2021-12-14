---
created: 2021-12-14
updated: 2021-12-14
---
# 渲染管线

将三维坐标系的内容转换为二维像素的过程是通过OpenGL的渲染管线控制的，渲染管线可以被进一步拆分为两个部分：第一个是将三维坐标系内容转换为二维坐标系内容，第二个是将二维坐标系内容转换为二维像素。

在渲染管线的每一步上，都可能会有一些在GPU上运行的小程序，这些小程序被称为 `shaders`。 `shaders` 是通过GLSL（OpenGL Shading Language）语言进行编写。下图展示了渲染管线的基本流程，其中蓝色的部分是可以通过 `shader`进行控制的。

![|500](assets/LearnOpenGL-Ch%2002%20Hello%20Triangle/image-20211214232921673.png)

其中步骤包括：

1.  顶点输入：传递一系列顶点数据作为渲染管线的输入，这些顶点数据不仅仅包含位置信息，还可以包含颜色，法线等信息，所有信息统称为 `vertex attributes`。
   
    为了让OpenGL程序知道这些顶点数据是如何构成图形的，在调用绘制绘制API时，需要指定这些图元类型，如 `GL_POINTS, GL_TRIANGLES, GL_LINE_STRIP` 等。
    
2.  顶点着色器：顶点着色器的目的是转换三维坐标系，如从世界坐标系转换到裁剪坐标系。还可以在其中对顶点信息做一些基本处理。
    
3.  图元装配：图元装配是将顶点着色器输出的顶点构成需要的图元，如三角形
    
4.  图元着色器：（可选）将图元装配后的顶点作为输入，但图元着色器可以重新修改顶点，构成新的图形
    
5.  光栅化：光栅化将图元转换为最终屏幕上的像素，即片段着色器需要处理的像素。在将像素传递给片段着色器前会进行裁剪，将实现外的像素抛弃掉。
    
6.  片段着色器：计算像素的最终颜色
    
7.  测试和混合：深度检测，模板检测等，还有半透明颜色的混合

# 顶点数据

```cpp
float vertices[] = {
    -0.5f, -0.5f, 0.0f,
     0.5f, -0.5f, 0.0f,
     0.0f,  0.5f, 0.0f
};
```

顶点的位置定义是放在 `标准化设备坐标系（Normalized Device Coordinates, NDC）` 下的，该坐标系是一个从$-1.0\sim 1.0$的坐标系，其中$(0,0)$点处于屏幕的中心。而屏幕坐标系下，坐标系的数值是 $0\sim 1$，其中$(0,0)$出现在屏幕的左上角。标准化设备坐标系如下图所示：

![|500](assets/LearnOpenGL-Ch%2002%20Hello%20Triangle/image-20211214233002415.png)

从标准化设备坐标系转换到屏幕坐标系是依赖 `glViewport` 函数。

```ad-warning
在OpenGL的NDC坐标系下，$(-1,-1)$点处在屏幕的左下角。而在 DX 和VulKan中$(-1,-1)$在左上角
```

# 顶点缓冲对象

为了存储顶点数据，需要再GPU上开辟出一块内存，在OpenGL中通过 `顶点缓冲对象（vertex buffer objects， VBO）`管理这块内存。通过VBO，可以一次性的发送多个顶点数据，避免重复运行从CPU发送顶点数据到GPU这一复杂的操作。

生成顶点缓冲对象的步骤如下所示

```cpp
GLuint VBO;
glGenBuffers(1, &VBO);
glBindBuffer(GL_ARRAY_BUFFER, VBO);
glBufferData(GL_ARRAY_BUFFER, sizeof(vertices),vertices, GL_STATIC_DRAW);
```

-   `glGenBuffers` 函数为新对象生成了一个ID，并将新ID值赋值给传入的引用。
-   `glBindBuffer` 函数将新缓冲绑定至目标类型，VBO的类型为 `GL_ARRAY_BUFFER`。
-   `glBufferData` 函数将数据填充到缓冲中，前三个参数都好理解，最后一个参数会决定GPU将如何管理这块内存，因为这里装填了顶点信息后，后期并不会有关于顶点的修改，所以这里设为了 `GL_STATIC_DRAW`。如果有大量修改，可以设为 `GL_DYNAMIC_DRAW` ，这样GPU就会将信息放到高速访问的内存中，保证之后修改时的效率。

```ad-warning
vertices 数据是定义在内存中的， glBufferData 操作是将内存中的 vertices 数据拷贝到显存中由 VBO 表示的地址中去。 虽然是拷贝，但在调用 glBufferData 后仍然不建议修改 vertices ，因为可能会造成 [管线堵塞](/7ebf3d886c334d2b8995e86215f3fdcf) 的问题
```

# 索引缓冲对象

<aside> 💡 

</aside>

通常来说，图形都是由三角形构成，如一个四边形就是由两个三角形构成的。这两个三角形可以通过设置六个点来进行绘制，但这样实际上浪费了内存，一个四边形最少需要四个点就可以确定。而当设置四个点时，需要告诉OpenGL，这些点该如何组合构成两个三角形。这个步骤需要通过 `索引缓冲对象（Element Buffer Objects，EBO）`来完成。