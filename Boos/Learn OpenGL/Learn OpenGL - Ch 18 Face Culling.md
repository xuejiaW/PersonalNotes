---
created: 2021-12-17
updated: 2021-12-22
tags:
    - OpenGL
---
想象一个3D立方体，从任意面看过去，最多都只能看到3个面，那么看不到的3个面就不应该被渲染。 但这存在一个问题，该如何知道一个面能不能被从观察者视角被看到？ 想象一个闭合的形状，它的每一个面都有两侧，每侧要么面向用户，要么背对用户。只要绘制面向观察者的面就能完成正常的显示， 这就是 `面剔除 (Face Culling)`的概念。

# 环绕顺序

OpenGL能检查所有面向观察者的面并渲染他们，并丢弃那些背对观察者的面。但仍然要告诉OpenGL哪些面是正向的，哪些是背向的。OpenGL通过计算顶点数据的环绕顺序来判断正向面与反向面：

当定义一组三角形顶点时，可能是正向的，也可能是逆时针的：
![|500](assets/Learn%20OpenGL%20-%20Ch%2018%20Face%20Culling/Untitled.png)

![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/9cf03fdd-4d6e-4914-a1ce-f684ba7facc9/Untitled.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/9cf03fdd-4d6e-4914-a1ce-f684ba7facc9/Untitled.png)

```cpp
float vertices[] = {
    // 顺时针
    vertices[0], // 顶点1
    vertices[1], // 顶点2
    vertices[2], // 顶点3
    // 逆时针
    vertices[0], // 顶点1
    vertices[2], // 顶点3
    vertices[1]  // 顶点2
};
```

默认情况下，OpenGL会将逆时针顶点定义的三角形处理为正向三角形。当定义三角形时，应想象当前被定义的三角形是面向自己的，从自己的方向看过去它是逆时针的。
![|500](assets/Learn%20OpenGL%20-%20Ch%2018%20Face%20Culling/Untitled%201.png)

# 面剔除

OpenGL默认是关闭面剔除的，即一个面的两面都会被渲染。当移动摄像机进入一个立方体后，仍然能看到每个面的渲染：
![|400](assets/Learn%20OpenGL%20-%20Ch%2018%20Face%20Culling/Untitled%202.png)

打开面剔除的方法为，当打开后进入立方体就不再能从内部看到面的渲染：

```cpp
glEnable(GL_CULL_FACE);
```

可以通过 `glCullFace`决定剔除正向面还是背向面，默认是剔除背向面：

```cpp
glCullFace(GL_BACK);
glCullFace(GL_FRONT);
glCullFace(GL_FRONT_AND_BACK);
```

剔除正向面的效果如下：
![|400](assets/Learn%20OpenGL%20-%20Ch%2018%20Face%20Culling/Untitled%203.png)

可以通过 `glFrontFace` 设置是用顺时针（ `GL_CW`）还是逆时针（ `GL_CCW`）表示正向面：

```cpp
glFrontFace(GL_CCW); // 默认逆时针
glFrontFace(GL_CW);
```

```ad-warning
如果剔除的是背面，但设置顺时针表示正向面，效果与剔除正面，但设置逆时针为正向面相同。
```

# 源码
[main.cpp](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/16.FaceCulling/main.cpp)