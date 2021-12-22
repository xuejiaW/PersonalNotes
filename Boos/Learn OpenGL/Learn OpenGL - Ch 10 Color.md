---
created: 2021-12-15
updated: 2021-12-23
tags:
    - OpenGL
---
# 颜色原理

人所看到的颜色并非物体本身的颜色，而是物体反射的颜色，光照射到物体上，物体吸收了部分光，将剩下的部分反射到人的眼睛里，人所看到的是物体这部分反射的光。

太阳光是白光（所有颜色的总和），当看到一个玩具是蓝色的，并非因为这个玩具本身是蓝的，是因为玩具吸收了除了蓝光之外所有的光，仅有蓝光反射到了我们的眼睛里，所以我们认为玩具是“蓝色的”

![|500](assets/Learn%20OpenGL%20-%20Ch%2010%20Color/Untitled%201.png)

# 代码表示

上述的原理，在代码方面可以通过简单的乘法表示，如

```cpp
glm::vec3 lightColor(0.0f,1.0f,0.0f);
glm::vec3 toyColor(1.0f,0.5f,0.3f);
glm::vec3 result=lightColor * toyColor; //(0.0f, 0.5f, 0.0f)
```

`toyColor` 中红色通道的 `1.0` 表示反射了所有的红色光，原光红色通道为 `0.0` ，虽然反射了全部光，但结果仍然为 `0`。

`toyColor` 中蓝色通道的 `0.5` 表示吸收了光一半的蓝色，原光蓝色通道为 `1.0` ，返回了一半的蓝色，即得 `0.5f` 。

`toyColor` 中绿色通道的 `0.3` 表示反射30%的绿色光，原光绿色通道为 `0.0` ，返回了30%的绿色，结果为 `0`。

因此物体的片段着色器可表示为

```glsl
#version 330 core

uniform vec3 objectColor;
uniform vec3 lightColor;
out vec4 color;

void main()
{
    color = vec4(lightColor*objectColor,1);
}
```

而光源本身是自发光，它的颜色就是光的颜色，因此片段着色器表示为：

```glsl
#version 330 core

uniform vec3 lightColor;
out vec4 color;

void main()
{
    color = vec4(lightColor,1);
}
```

# 结果与源码：

在光颜色为 $(1.0,1.0,1.0)$，物体颜色为 $(0.2,0,0)$ 的情况下，结果如下所示：
![](assets/Learn%20OpenGL%20-%20Ch%2010%20Color/Untitled%201%201.png)

[CPP](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/8.Colors/main.cpp)

[lamp.frag](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/8.Colors/lamp.frag) 

[colorObject.frag](https://raw.githubusercontent.com/xuejiaW/Study-Notes/master/LearnOpenGL_VSCode/src/8.Colors/colorObject.frag)