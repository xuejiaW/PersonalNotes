# 模板缓冲

当片段着色器处理完一个片段后，模版测试会开始执行，没有通过测试的片段将被丢弃，剩下的进入深度测试。模版测试也是根据缓冲来进行的，称为 `模板缓冲` 。

一个模版缓冲中，一般每个 `模版值(Stencil Value)`都是8位的，所以每个片段有256种不同的模版值,可以根据这个值来决定是否要丢弃这个片段

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

在 [Depth Testing](LearnOpenGL-Ch%2015%20Depth%20Testing.md) 中我们可以通过 `glDepthMask`来控制ZWrite，在模版中则可以使用 `glStencilMas`来设置。 这个函数需要我们提供一个掩码（BitMask），它会与将要写入模版缓冲的值进行位运算。掩码默认设置为 `1`，这样就不会造成任何改变。如果我们想要关闭Stencil写入，则可以将其设置为0x00，这样所有写入的Stencil都为0，此时就等同于 `glDepthMask(GL_False)` 。

# 模板函数

## glStencilFunc

在深度测试中，可以通过 `glDepthFunc`来指定当前片段的Z与缓冲中的Z将通过何种方式比较。在模版测试中，对应使用 `glStencilFunc`：

```cpp
glStencilFunc(GLenum func, GLint ref, GLuint mask)
```

-   `func` 设置模版测试函数，这个测试函数将会用在模版数据参考值 `ref`和保存在缓存中的模版数据上。可选选项有 `GL_NEVER`、 `GL_LESS`、 `GL_LEQUAL`、 `GL_GREATER`、 `GL_GEQUAL`、 `GL_EQUAL`、 `GL_NOTEQUAL`和 `GL_ALWAYS` 这些值的含义与深度测试中的相同。
-   `ref` 为模板数据的参考值，模板缓存中的值将它进行比较
-   `mask` 为掩码，在 `ref`和缓存中的数据比较前， `mask`会分别与它们先进行与运算。 `mask`默认为0xff

如调用 `glStencilFunc(GL_EQUAL,1,0xff)` 表示只有当片段对应的模版缓存中的值为1，才会被绘制，否则被抛弃。