---
created: 2021-12-15
updated: 2022-03-11
tags:
    - OpenGL
---

# GLM

因为OpenGL没有自带的矩阵和向量，所以相关的变换操作需要自定义，可以选择依赖 [GLM](../../01_Notes/Libraries/GLM.md) 解决。

# 变换

使用GLM表示变换时，通常先定义一个四维的矩阵，并依靠GLM中提供的函数，对矩阵进行相应操作：

```cpp
glm::mat4 trans;
trans = glm::translate(trans, glm::vec3(1.0f, 1.0f, 0.0f));
trans = glm::rotate(trans, 90.0f, glm::vec3(0.0, 0.0, 1.0));
trans = glm::scale(trans, glm::vec3(0.5, 0.5, 0.5));
```

```ad-warning
在OpenGL中，vec4是列矩阵，所以所有的乘法都是左乘。因此虽然通常变换的顺序是缩放，旋转，位移。但代码中表现为位移，旋转，缩放。
```

在Shader中对应的矩阵类型 `mat4`，可通过Uniform进行赋值

```glsl
uniform mat4 transform;
void main()
{
    gl_Position = transform * vec4(position, 1.0f);
    ...
}
```

```cpp
GLuint transformLoc = glGetUniformLocation(ourShader.Program, "transform");
glUniformMatrix4fv(transformLoc, 1, GL_FALSE, glm::value_ptr(trans));
```

`glUniformMatrix4fv` 的第一个参数为Uniform参数的地址，第二个参数为需要传递的矩阵数量，第三个参数指定矩阵是否要进行转置操作，第四个参数传递的是指针，因为glm定义的数据并不是OpenGL原生支持的数据，所以要用GLM的库进行转换。

## 结果与源码

![|400](assets/Ch%2005%20Transformations/GIF.gif)

[CPP](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/5.Transformations/main.cpp)

[Vertex](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/5.Transformations/vertex.vert)

[Fragment](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/5.Transformations/fragment.frag)
