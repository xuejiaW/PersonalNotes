---
created: 2021-12-15
updated: 2021-12-22
tags:
    - OpenGL
---
着色器是运行在GPU上的小程序，这些小程序是为了在图形渲染管线上完成特定的任务。着色器的任务只是将输入转换为特定的输出。并且各种着色器之间是无法访问到对方的，他们之间唯一的交流是通过输入和输出。

# GLSL

Shader 是由 `GLSL（OpenGL Shading Language）`语言写成，在每个Shader的一开始，都通过 `#version` 声明版本，接着是一系列的输入和输出声明，之后声明unifrom变量（非必须），然后是main函数。

典型的结构如下：

```cpp
#version version_number
in type in_variable_name;
in type in_variable_name;

out type out_variable_name;
  
uniform type uniform_name;
  
void main()
{
  // process input(s) and do some weird graphics stuff
  ...
  // output processed stuff to output variable
  out_variable_name = weird_stuff_we_processed;
}
```

所有的输入被称为 `顶点属性（vertex attribute`。顶点属性是有上限的，但OpenGL保证，最少可以传递16个四通道（如 `vec4`）的数据。可以通过以下代码查询最大的顶点属性数量：

```cpp
int nrAttributes;
glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &nrAttributes);
std::cout << "Maximum nr of vertex attributes supported: " << nrAttributes << std::endl;
```

# 属性

GLSL定义了一系列的基础类型，都以以下的形式表示：

- `vecn` ：有n个通道，且通道用float表示的vector
- `bvecn`：有n个通道，且通道用bool表示的vector
- `ivecn`：有n个通道，且通道用int表示的vector
- `uvecn`：有n个通道，且通道用unsigned int表示的vector
- `dvecn`：有n个通道，且通道用double表示的vector

对于属性中的通道，可以使用 `x, y, z` 来访问其中的一个通道。也可以通过这些通道组合来访问，如 `xy, xyz`。实例代码如下：

```cpp
vec2 someVec;
vec4 differentVec = someVec.xyxx;
vec3 anotherVec = differentVec.zyw;
vec4 otherVec = someVec.xxxx + anotherVec.yxzy;
```

# 输入输出

GLSL定义了 `in`和 `out`关键字，当输出变量与下一个着色器阶段的输入变量名字匹配他们就会传递下去。但顶点着色器和片段着色器作为整个管线的开头与结尾，有较为特殊的处理。

顶点着色器中需要特殊的输入， `layout (location = 0)` 。这种输入需要在C++代码中通过 `glVertexAttribPointer` 进行传递，并在传递后通过 `glEnableVertexAttribArray`激活。 例子可见 [Hello Triangle](Learn%20OpenGL%20-%20Ch%2002%20Hello%20Triangle.md)。

顶点的数据可以不仅仅包含位置信息，因此 `layout` 也可以存在多个，每个单独处理一种数据。如顶点数据定义为如下形式，同时包含顶点的位置和顶点的颜色：

```cpp
float vertices[] = {
    // positions         // colors
     0.5f, -0.5f, 0.0f,  1.0f, 0.0f, 0.0f,   // bottom right
    -0.5f, -0.5f, 0.0f,  0.0f, 1.0f, 0.0f,   // bottom left
     0.0f,  0.5f, 0.0f,  0.0f, 0.0f, 1.0f    // top 
};
```

因此需要两个 `layout` 来处理数据，一个负责位置信息，一个负责顶点的颜色。顶点着色器定义如下：

```glsl
#version 330 core
layout (location = 0) in vec3 aPos;   // the position variable has attribute position 0
layout (location = 1) in vec3 aColor; // the color variable has attribute position 1
  
out vec3 ourColor; // output a color to the fragment shader

void main()
{
    gl_Position = vec4(aPos, 1.0);
    ourColor = aColor; // set ourColor to the input color we got from the vertex data
}
```

在CPP中传递数据的代码如下：

```cpp
// position attribute
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)0);
glEnableVertexAttribArray(0);
// color attribute
glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)(3* sizeof(float)));
glEnableVertexAttribArray(1);
```

其中参数说明，在这个例子中，一个顶点的数据由6个float组成，因此第五个参数为 `6 * sizeof(float)`。而对于颜色这个信息而言，是由第4-6个float组成，因此最后一个参数为 `(void*)(3* sizeof(float))` 表示偏移量为三个float大小。

在例子中的顶点着色器中，输出了一个名为 `ourColor` 的 `vec3` 变量，因此片段着色器中，有对应的名为 `ourColor` 的输入。而片段着色器中必须要有一个 `vec4` 的输出，表示像素的颜色。片段着色器实例如下：

```glsl
#version 330 core
out vec4 FragColor;  
in vec3 ourColor;
  
void main()
{
    FragColor = vec4(ourColor, 1.0);
}
```

# Uniforms

`Uniform`是另一种将数据从CPU发送给GPU的方式。Unifrom有以下特征：

- Uniform类似于全局变量的概念，因此可以整个Shader程序中的任意Shader定义。
- 在设置了Uniform变量的值后，除非重置或更新数据，否则整个Shader程序中，Uniform的值是保持不变的。
- 同名的Uniform可以在Shader程序中重复声明

```ad-error
如果在Shader中声明了一个Uniform变量，但从未使用。在编译Shader的时候，会将这个Uniform变量删除。这可能会造成CPP段传输数据时的Bug。
```

Uniform变量传递的过程如下所示：

```cpp
float greenValue = (sin(timeValue) / 2.0f) + 0.5f;
int vertexColorLocation = glGetUniformLocation(shaderProgram, "ourColor");
glUseProgram(shaderProgram);
glUniform4f(vertexColorLocation, 0.0f, greenValue, 0.0f, 1.0f);
```

`glGetUniformLocation` 函数从shader程序中，找到Uniform变量的地址。第一个参数为Shader程序，第二个参数为Uniform变量的名称。如果返回值为-1，说明未找到。

`glUniform4f` 函数通过获取到的地址，传递参数。 `glUniform4f` 有很多的函数变种（不是重载），变种都依靠函数最后的两个字符决定：

- f 表示传递的通道类型为float
- i 表示传递的通道类型为int
- ui 表示传递的通道类型为 unsigned int
- fv 表示传递的是 float 的向量或数组
- 3f 表示有三个通道

```ad-warning
当通过`glGetUniformLocation` 获取地址时，不要求Shader程序被使用。但是通过类似于`glUniform4f` 等函数赋值时，必须保证Shader程序被使用。因此在例子中，调用了 `glUseProgram` 函数
```

## 结果与源码

![|500](assets/Learn%20OpenGL%20-%20Ch%2003%20Shaders/GIF.gif)

[CPP](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/3.Shaders/main.cpp)

[Vertex](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/3.Shaders/vertex.vert)

[Fragment](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/3.Shaders/fragment.frag)
