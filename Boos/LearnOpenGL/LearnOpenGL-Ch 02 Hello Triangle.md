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

```ad-tip
索引缓冲对象并不是必须的
```

通常来说，图形都是由三角形构成，如一个四边形就是由两个三角形构成的。这两个三角形可以通过设置六个点来进行绘制，但这样实际上浪费了内存，一个四边形最少需要四个点就可以确定。而当设置四个点时，需要告诉OpenGL，这些点该如何组合构成两个三角形。这个步骤需要通过 `索引缓冲对象（Element Buffer Objects，EBO）`来完成。

索引缓冲对象的类型为 `GL_ELEMENT_ARRAY_BUFFER`，其余的绑定流程与VBO即为类似，如下所示：

```cpp
GLuint EBO;
glGenBuffers(1, &VBO);
glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indics), indics, GL_STATIC_DRAW);
```

其中的 `indices` 为索引值，顶点数据和索引值可以如下设置：

```cpp
float vertices[] = {
     0.5f,  0.5f, 0.0f,  // top right
     0.5f, -0.5f, 0.0f,  // bottom right
    -0.5f, -0.5f, 0.0f,  // bottom left
    -0.5f,  0.5f, 0.0f   // top left 
};
unsigned int indices[] = {  // note that we start from 0!
    0, 1, 3,   // first triangle
    1, 2, 3    // second triangle
};
```

表示第0，1，3个顶点构成一个三角形，第1，2，3个顶点构成另一个三角形。

# 链接顶点数据

如之前所述，顶点数据中可能会包含多种信息，如位置，颜色，法线。因此在通过VBO传递了顶点数据后，OpenGL仍然不知道该如何正确的解析顶点数据，这里就需要用到函数 `glVertexAttribPointer` 。

```cpp
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
glEnableVertexAttribArray(0);
```

`glVertexAtrribPointer` 函数中：

-   第一个参数为需要配置的顶点数据，0即表示顶点着色器中的 `Position 0`，1则表示顶点着色器中的 `Position 1`。
-   第二个参数是顶点数据的大小，如果传递的是 `vec3` ，则参数应该为3。
-   第三个是参数类型，这里是GL_FLOAT
-   第四个是是否 需要标准化，即换到0~1的区间内
-   第五个是步长，即一组数据的总大小，比如有一组顶点数据同时存有位置和颜色，各3个数值，则这里应该是6_sizeof(GLfloat)，我们这里仅有位置，所以是3_sizeof(GLfloat)
-   最后一个是偏移量，同时有位置和颜色，前3为位置，后3为颜色，则传递颜色是偏移量应该是 `(GLvoid*)3*sizeof(GLfloat)`

`glEnableVertexAttribArray` 则是应用之前的操作，其参数与 `glVertexAttribPointer` 的第一个参数相同。

```ad-tip
链接顶点数据是针对于当前绑定的VBO而言的
```

# 顶点数组对象

`顶点数组对象（vertex array object，VAO）` 如同VBO类似，也是个物体，因此同样需要经过生成数组ID，绑定数组等操作。VAO的存在是为了管理顶点数据的链接操作，当绑定了一个VAO后，各种关于顶点属性的解释都会被存储在这个VAO中。

因此关于顶点数据的整个流程如下图所示，VAO管理了一系列顶点数据的链接过程，而每个数据的链接又与当前绑定的VBO相关。同时，VAO也可以管理索引缓冲对象。

![|500](assets/LearnOpenGL-Ch%2002%20Hello%20Triangle/image-20211214233259386.png)

VAO创建代码如下：

```cpp
unsigned int VAO = 0;
glGenVertexArrays(1, &VAO);
```

完整流程代码如下：

```cpp
// 绑定VAO
glBindVertexArray(VAO);

// 绑定VBO
glBindBuffer(GL_ARRAY_BUFFER, VBO);
glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

// 绑定EBO
glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

// 链接顶点数据
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void *)0);
glEnableVertexAttribArray(0);

glBindBuffer(GL_ARRAY_BUFFER, 0);
glBindVertexArray(0);
glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0); // 必须在解绑VAO后才能解绑EBO
```

```ad-note
在解绑 VAO 前不可解绑 EBO，因为VAO中包含了EBO的设置，如果在VAO解绑前解绑EBO，相当于在VAO中删除了相关的设置。 

但在解绑VAO前可以解绑VBO，这是因为VAO中包含的并不是VBO本身，而是关于VBO中数据该如何解析的设置
```

# 着色器

完整的着色器编译和链接头文件为 [SHADER.h](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/SHADER.h)

## 顶点着色器

最简单的顶点着色器如下所示：

```glsl
#version 330 core
layout (location = 0) in vec3 aPos;

void main()
{
    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
}
```

其中 `gl_Position` 为OpenGL预定义的变量，为顶点的位置信息

## 片段着色器

最简单的片段着色器如下：

```glsl
#version 330 core
out vec4 FragColor;

void main()
{
    FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
}
```

片段着色器必须返回一个 `vec4` 变量表示像素最终的颜色。

## 着色器编译

编译着色器的流程如下：

```cpp
unsigned int shader;
shader = glCreateShader(GL_FRAGMENT_SHADER);
glShaderSource(fragmentShader, 1, &shaderSource, NULL);
glCompileShader(fragmentShader);
```

还是传统的生成ID，绑定ID的流程，数据操作的流程。

其中函数 `glShaderSource` 用来绑定shader的源码，第一个形参为ID，第二个形参为源码的数量，第三个参数类型必须是 `const GLchar*`，即需要将着色器文件读取成C风格字符串后传递给形参 `shaderSource`，第四个参数设为NULL表示源码长度不限定长度。

顶点着色器和片段着色器都应该用类似的流程进行编译。

编译结果可以通过以下代码进行检查：

```cpp
GLint success;
GLchar infoLog[512];
glGetShaderiv(id, GL_COMPILE_STATUS, &success);
if(!success)
	glGetShaderInfoLog(id, 512, nullptr, infoLog);
std::cout << "Error in shader"<< infoLog << std::endl;
```