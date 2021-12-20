---
created: 2021-12-20
updated: 2021-12-20
---
在顶点着色器和片段着色器之间，可以插入可选的着色器 `几何着色器（Geometry Shader`。几何着色器将构成一个图元一系列的顶点作为输入，然后将这些顶点数据重新组合（也可以生成更多的顶点数据），再传递给片段着色器。如下为一个几何着色器的例子，之后会逐渐对这个集合着色器进行解释：

```glsl
#version 330 core
layout (points) in;
layout (line_strip, max_vertices = 2) out;

void main() {    
    gl_Position = gl_in[0].gl_Position + vec4(-0.1, 0.0, 0.0, 0.0); 
    EmitVertex();

    gl_Position = gl_in[0].gl_Position + vec4( 0.1, 0.0, 0.0, 0.0);
    EmitVertex();
    
    EndPrimitive();
}
```

# Layout

在几何着色器的开始，需要指定输入和输出的图元类型，如上例子中的：

```glsl
layout (points) in;
layout (line_strip, max_vertices = 2) out;
```

输入图元的类型与在C++中调用的绘制函数 `glDrawElements` 或 `glDrawArrays` 的参数是对应的，如下所示：

| 图元类型                | 绘制参数                                                 |
| ----------------------- | -------------------------------------------------------- |
| points (1)              | `GL_POINTS`                                              |
| lines (2)               | `GL_LINES` / `GL_LINE_STRIP`                             |
| lines_adjacency (4)     | `GL_LINES_ADJACENCY` / `GL_LINE_STRIP_ADJACENCY`         |
| triangles (3)           | `GL_TRIANGLES` / `GL_TRIANGLE_STRIP` / `GL_TRIANGLE_FAN` |
| triangles_adjacency (6) | `GL_TRIANGLES_ADJACENCY` / `GL_TRIANGLE_STRIP_ADJACENCY` |

对于输出而言，只能使用 points ， line_strip 和 triangle_strip 三种图元类型。输出图元还需要指定最大的顶点数 max_vertices，当输出的顶点数大于这个数目时，OpenGL 将不会绘制额外的顶点。

💡 `line_strip` 是一系列由当前点和上一个点给构成的线段，如定义了五个顶点，则会构成如下的图：
![|500](assets/LearnOpenGL-Ch%2022%20Geometry%20Shader/Untitled.png)

💡 triangle_strip 则是由当前点和前两个构成的三角形，即四个点可以构成 2 个三角形，5个点可以构成 3 个三角形，如下图所示：

|                                                                                                                                                |     |
| ---------------------------------------------------------------------------------------------------------------------------------------------- | --- |
| ![](assets/LearnOpenGL-Ch%2022%20Geometry%20Shader/Untitled%201%201.png) | ![](assets/LearnOpenGL-Ch%2022%20Geometry%20Shader/Untitled%202.png)      |
