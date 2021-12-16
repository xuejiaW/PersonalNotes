---
created: 2021-12-16
updated: 2021-12-16
---
# 深度缓冲

深度缓冲是由窗口系统自动创建的，它会以 16、24、32 位 float 的形式存储它的深度值。大部分系统中，深度缓冲的进度都是 24 位的。深度缓冲的大小与颜色缓冲一致，即有相同的宽度和高度。

当深度测试打开后，OpenGL 在渲染每个片元时，会将这个这个片元的深度值与当前深度缓冲中的深度值进行比较测试，如果测试通过，则这个片元会被渲染，且深度缓冲内的值会被这个新的深度值覆盖，失败的话，则直接丢弃这个片元。

计算遮挡关系的过程被称为 `Occlusion` 。

```ad-note
理论上默认深度缓冲的监测是在片段着色器和模版测试后。 但现在大部分GPU都有提前深度测试的硬件特性，即先进行深度测试，再运行片段着色器，这样如果一个片段不可见，那么就能直接丢弃这个片段，避免片段着色器的运行
```

```ad-note
对于每一个片元，可以在片段着色器中通过内建立值 `gl_FragCoord` 获取每个片元的坐标。该值的 `x, y` 表示片元在屏幕空间中的位置， `z` 即表示这个片元的深度值。
```

深度测试默认是关闭的，开启深度测试需要用到 `GL_DEPTH_TEST` 选项
```cpp
glEnable(GL_DEPTH_TEST);
```

如果开启了深度测试，通常来说，每一帧需要将上一帧的深度缓冲清除掉
```cpp
glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
```

通常来说，在片元通过了深度检测后，会更新深度缓冲中的数据。如果只希望检测要写入的片段是否该丢弃，而不想在通过测试后，改写深度缓冲，我们可以将深度掩码设为 False
```cpp
glDepthMask(GL_FALSE);
```

# 深度检测函数

通常而言，深度检测的比较方法是判断需要写入的片段的深度之是否 ` 小于(GL_LESS)` 当前已经写入片段的深度值。但也可以通过 `glDepthFunc` 设置运算比较符：
```cpp
glDepthFunc(GL_LESS);
```

还接受以下的参数：

| Function    | Description                            |
| ----------- | -------------------------------------- |
| GL_ALWAYS   | 永远通过深度测试                       |
| GL_NEVER    | 永远不通过深度测试                     |
| GL_LESS     | 在待写入深度值小于缓冲深度值时通过     |
| GL_EQUAL    | 在待写入深度值等于缓冲深度值时通过     |
| GL_LEQUAL   | 在待写入深度值小于等于缓冲深度值时通过 |
| GL_GREATER  | 在待写入深度值大于缓冲深度值时通过     |
| GL_NOTEQUAL | 在待写入深度值大于缓冲深度值时通过     |
| GL_GEQUAL   | 在待写入深度值大于等于缓冲深度值时通过 |
 
 例如场景中存在两个立方体，红色的在绿色的前面，如下所示：
 
 ![|400](assets/LearnOpenGL-Ch%2015%20Depth%20Testing/Untitled.png)
 
 如果从红色立方体的正前方进行观察，则得到的效果为如下所示，即绿色的立方体因为在红色立方体的后方，所以被遮挡：
 
 ![|400](assets/LearnOpenGL-Ch%2015%20Depth%20Testing/Untitled%201.png)
 
 如果在绘制绿色立方体前，将检测函数设置为 GL_ALWAYS ，即绿色立方体始终进行绘制，则效果如下：
 ![|400](assets/LearnOpenGL-Ch%2015%20Depth%20Testing/Untitled%202.png)
 
 代码为：

```cpp
GO_Cube *redCube = new GO_Cube();
redCube->GetTransform()->SetPosition(vec3(-0.3, 0, 0.5));
redCube->GetMeshRender()->GetMaterial()->SetColor(vec3(1, 0, 0));
scene.AddGameObject(redCube);

glDepthFunc(GL_ALWAYS);

GO_Cube *greenCube = new GO_Cube();
greenCube->GetMeshRender()->GetMaterial()->SetColor(vec3(0, 1, 0));
scene.AddGameObject(greenCube);
```

# 深度值精度

深度缓冲包含了一个介于0.0和1.0之间的深度值，在近剪切平面为0，在远剪切平面为1。即需要一个函数将Z值变换到 $0 \sim 1$ 之间，其中最简单的就是线性变化。

$$F_{\text {depth}}=\frac{z-\text {near}}{\text {far}-\text {near}}$$

函数图如下所示：
![|500](assets/LearnOpenGL-Ch%2015%20Depth%20Testing/image-20211216223132789.png)

但在实践中几乎是永远不会使用线性变化的深度缓冲的。一般使用的都是一个非线性的深度方程。该函数在Z值较小的时候提供较大的精度，在Z值较大的时候提供较少的精度。因为人通常不会对远距离的物体的前后关系太敏感，如1000米外的两个物体，谁前谁后并不重要。实际中使用的函数如下：

$$F_{\text {depth}}=\frac{1 / z-1 / \text {near}}{1 / \text {far }-1 / \text {near}}$$

使用该函数后，Z值为 $1 \sim 2$，则对应的 $\frac{1}{z}$ 的值为 $0.5 \sim 1$，而当Z值为 $50\sim 100$时， 对应的 $\frac{1}{z}$ 值范围为 $0.01 \sim 0.02$，即随着Z值得增长，结果得变换会越来越缓慢（对Z变换越来越不敏感）。该函数的图像如下所示：

![|500](assets/LearnOpenGL-Ch%2015%20Depth%20Testing/Untitled%204.png)

如果将深度缓冲作为颜色进行输出，结果如下所示：

```cpp
FragColor= vec4(vec3(gl_FragCoord.z),1);
```