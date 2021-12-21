---
created: 2021-12-16
updated: 2021-12-21
---
# 模板缓冲

当片段着色器处理完一个片段后，模版测试会开始执行，没有通过测试的片段将被丢弃，剩下的进入深度测试。模版测试也是根据缓冲来进行的，称为 ` 模板缓冲 ` 。

一个模版缓冲中，一般每个 ` 模版值(Stencil Value)` 都是 8 位的，所以每个片段有 256 种不同的模版值,可以根据这个值来决定是否要丢弃这个片段

使用模块的大致步骤为：

1.  启用模版缓冲的写入
2.  渲染物体，更新模版缓冲的内容
3.  禁用模版缓冲的写入
4.  渲染其他物体，此时将根据模版缓冲值丢弃特定的片段

使用 `GL_STENCIL_TEST` 启用模版测试：

```cpp
glEnable(GL_STENCIL_TEST);
```

当开启后，每帧需要清除模板缓冲：

```cpp
glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
```

在 [Depth Testing](Learn%20OpenGL%20-%20Ch%2015%20Depth%20Testing.md) 中我们可以通过 `glDepthMask`来控制ZWrite，在模版中则可以使用 `glStencilMas`来设置。 这个函数需要我们提供一个掩码（BitMask），它会与将要写入模版缓冲的值进行位运算。掩码默认设置为 `1`，这样就不会造成任何改变。如果我们想要关闭Stencil写入，则可以将其设置为0x00，这样所有写入的Stencil都为0，此时就等同于 `glDepthMask(GL_False)` 。

# 模板函数

## glStencilFunc

在深度测试中，可以通过 `glDepthFunc` 来指定当前片段的 Z 与缓冲中的 Z 将通过何种方式比较。在模版测试中，对应使用 `glStencilFunc`：

```cpp
glStencilFunc(GLenum func, GLint ref, GLuint mask)
```

- `func` 设置模版测试函数，这个测试函数将会用在模版数据参考值 `ref` 和保存在缓存中的模版数据上。可选选项有 `GL_NEVER`、 `GL_LESS`、 `GL_LEQUAL`、 `GL_GREATER`、 `GL_GEQUAL`、 `GL_EQUAL`、 `GL_NOTEQUAL` 和 `GL_ALWAYS` 这些值的含义与深度测试中的相同。
- `ref` 为模板数据的参考值，模板缓存中的值将它进行比较
- `mask` 为掩码，在 `ref` 和缓存中的数据比较前， `mask` 会分别与它们先进行与运算。 `mask` 默认为 0xff

如调用 `glStencilFunc(GL_EQUAL,1,0xff)` 表示只有当片段对应的模版缓存中的值为 1，才会被绘制，否则被抛弃。

## glStencilOp

`glStencilOp` 函数用来设置当模版测试通过后，缓冲该如何被更新：

```cpp
glStencilOp(GLenum sfail, GLenum dpfail, GLenum dppass)
```

- `sfail`：模版测试失败时采取的行为
- `dpfail` ：模版测试通过，但深度测试失败时采取的行为
- `dppass` ： 模版测试和深度测试都通过时采取的行为

三个参数一共可以选择的变量为：

| 行为         | 描述                                         |
| ------------ | -------------------------------------------- |
| GL_KEEP      | 保持当前存储的模版值                         |
| GL_ZERO      | 将模版值设为 0                               |
| GL_REPLACE   | 将模版值设置为 glStencilFunc 中设定的 Ref 值 |
| GL_INCR      | 模版值+1，达到最大值后保持不变               |
| GL_INCR_WRAP | 模版值+1，达到最大值后保持不变               |
| GL_DECR      | 模版值-1，达到最小值后保持不变               |
| GL_DECR_WRAP | 模版值-1，达到最小值后变为最大值             |
| GL_INVERT    | 按位取反当前模版缓冲值                       |

默认情况下 glStencilOp 设置为 GL_KEEP, GL_KEEP, GL_KEEP，所以无论测试结果是怎么用，模版缓冲的值都不会发生变换

# 实现物体轮廓效果

为物体创建轮廓的大致步骤为：

1.  开启深度缓冲，并设置当所有检测通过后缓冲更新方式为 `GL_REPLACE`

    ```cpp
    glEnable(GL_STENCIL_TEST);
    glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
    ```

2.  在绘制需要添加轮廓的物体前，将模版测试设为 Always，保证所有的片段都通过测试，并且在片段通过测试时刷新模版缓冲

    ```cpp
    glStencilMask(0xFF);
    glStencilFunc(GL_ALWAYS, 1, 0xFF);
    ```

3.  渲染目标物体，因为模板测试被设置为必然通过，又因为 `glStencilFunc` 的 `ref` 值为 1，且更新模式设为了 `GL_REPLACE` ，所以所有通过了深度测试的片元的 Stencil 值会被设为 1。

4.  在渲染轮廓物体前，关闭深度检测，保证轮廓物体必定不会被遮挡。 将模板测试的方式设为 `glStencilFunc` 的方式设为 `GL_NOTEQUAL` 且 `ref` 值为 1。之前渲染目标物体时，所有写入的片元的模版缓冲值为 1。因此在目标物体渲染过的片元上，模板测试都会失败。 禁止模板写入，保证模板缓冲的数据不会被覆盖。

    ```cpp
    glStencilMask(0x00);
    glStencilFunc(GL_NOTEQUAL, 1, 0xFF);
    glDisable(GL_DEPTH_TEST);
    ```

5.  将轮廓物体放大一点点（造成轮廓效果），进行渲染

6.  开启步骤四中关闭的模板数据写入和深度测试。如果在绘制完后不重新开启模板数据的写入，那么下一帧的 `glClear(GL_STENCIL_BUFFER_BIT)` 将会失效。

    ```cpp
    glStencilMask(0xff);
    glEnable(GL_DEPTH_TEST);
    ```

完整流程：

```cpp
GO_Cube *redCube = new GO_Cube();
redCube->GetTransform()->SetPosition(position[i]);
redCube->GetMeshRender()->GetMaterial()->SetColor(vec3(1, 0, 0));
redCube->GetTransform()->SetScale(vec3(1, 1, 1));
redCube->GetMeshRender()->SetPreRenderHandle([]() {
    glStencilMask(0xFF);
    glStencilFunc(GL_ALWAYS, 1, 0xFF);
});

scene.AddGameObject(redCube);
GO_Cube *redCube_2 = new GO_Cube();
redCube_2->GetTransform()->SetPosition(position[i]);
redCube_2->GetMeshRender()->GetMaterial()->SetColor(vec3(1, 1, 0));
redCube_2->GetTransform()->SetScale(vec3(1.05, 1.05, 1.05));
redCube_2->GetMeshRender()->SetPreRenderHandle([]() {
    glStencilMask(0x00);
    glStencilFunc(GL_NOTEQUAL, 1, 0xFF);
    glDisable(GL_DEPTH_TEST);
});
// Must turn on in post render or the clear process will not take effect
redCube_2->GetMeshRender()->SetPostRenderHandle([]() {
    glEnable(GL_DEPTH_TEST);
    glStencilMask(0xFF);
});scene.AddGameObject(redCube_2);
```

# 结果与源码
![|500](assets/Learn%20OpenGL%20-%20Ch%2016%20%20Stencil%20Testing/Stencil.gif)