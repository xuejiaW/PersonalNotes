---
tags:
    - GPU
created: 2021-12-14
updated: 2021-12-14
---


## CPU/GPU 工作模型

在每一帧中，当调用了GPU相关的命令，CPU并不会把这些命令立即传递给GPU，而是会先保存到一个缓存中，当缓存满了或遇到 `Present` 命令（在例如VSync等情况触发）时才会将相应的命令发送给GPU进行绘制（发送的过程称为 `Marshalling` ）。且CPU和GPU是并行工作的。理想状态下CPU与GPU工作情况如下：

![|300](assets/GPU%20%20Performance/Untitled.png)

可以看到在第一帧时，GPU并没有进行工作。这是因为此时GPU并没有收到来自于CPU的任何数据，当第一帧的末尾CPU将绘制命令发送给GPU后，GPU才开始绘制，因此CPU处理第二帧数据时，GPU才真正的并行绘制第一帧内容。

但在现实情况下，CPU和GPU很难做到两个的负载几乎是相同的。即像上述理想状况的图中那样，当GPU完成了一帧的绘制后，立刻收到CPU发送来的下一帧需要执行的绘制命令，且每当CPU需要传递绘制指令给CPU时，GPU都能立即接受绘制指令。

当GPU完成绘制后，CPU还没有准备好下一帧需要的绘制命令时，两者的工作情况如下所示，这种情况被称为 `CPU Bound` 。在这种情况下，帧率的下降是由CPU造成，所以去优化GPU的工作并不会改善帧率，且在一定程度上增加GPU的工作（保证在空闲事件内能完成），也并不会造成帧率的进一步下降。

![|300](assets/GPU%20%20Performance/Untitled%201.png)

当CPU需要传递当前帧需要的绘制命令时，GPU却还没有完成上一帧的绘制，因此CPU必须等待GPU完成绘制后，才能把命令给GPU，此时两者的工作情况如下，这种情况被称为 `GPU Bound` 。在这种情况下，帧率的下降是由GPU造成，因此优化CPU的工作并不会改善帧率，且一定程度上增加CPU的工作（保证在空闲事件内能完成），也并不会造成帧率的进一步下降。

![|300](assets/GPU%20%20Performance/Untitled%202.png)

### Draw

如果通过 Profiler 去查看CPU不同函数的运行时间，通常会发现  `Draw` 函数只消耗了非常短的时间，但这并不是因为绘制一帧需要的时间很短，而是因为真正的绘制工作并不在 `Draw` 函数中发生。

但在某些时刻，会发现某个 `Draw` 函数耗费了特别长的时间，如前1000个 `Draw` 命令几乎没有花费时间，而第 1001个 `Draw` 命令花费了特别长时间。很可能是因为当要把这个绘制命令放到命令缓存时，发现缓存已满，因此CPU需要将整个列表的命令发送给GPU，而命令发送的时间都会被Profiler归到该绘制命令下。

### Translate Instructions

通常当CPU收到 `Present`命令时，会将存储在缓存中的命令翻译成显卡能理解的格式，然后传递给显卡的驱动，显卡驱动再进一步将命令翻译成GPU能理解的格式。这整个过程都运行再CPU上，且在很多Profiler中会被计算在一个 `Present` 的命令下。

这也就是DrawCall数会影响CPU的原因，每一个DrawCall指令都需要经过一系列的翻译才能给到GPU进行绘制。如果将多个绘制较少内容的DrawCall进行合并，合并一个绘制更多内容的DrawCall，将就可以省下翻译的时间。

<aside>
⚠️ 在某些情况下，整个 `Present` 的时间并不等同于翻译绘制指令的时间。等待下一个 Vsync 或因为GPU Bound等待GPU绘制完成的时间，都会被Profiler统计在 `Present` 时间中。

</aside>

对于GPU芯片的设计师而言，如果将GPU的架构设计的如 3D API 所需要的类似，那么指令的翻译时间会很短，但可能会因为架构并不符合渲染的流程，而让GPU运行时间增长。相反，如果让架构极大程度的符合渲染的流程，则GPU运行时间会短，但可能会导致CPU翻译指令的时间更长。因此某些显卡可能更容易触发CPU Bound，而另一些更容易触发 GPU Bound。

## CPU Bound Or GPU Bound

<aside>
⚠️ 这里将CPU的工作简化为三个部分， `Update` ， `Draw` ， `Translate Instruction`

</aside>

如果Profiler中显示一帧大量的时间耗费在在 `Update` 中，那么说明是 `CPU Bound`。

但如果时间大量耗费在 `Draw` 和 `Translate Instruction` 中，则无法说明问题，可能是 `CPU Bound` （CPU翻译指令的时间消耗过久），也可能是 `GPU Bound`  （GPU上一帧的绘制没有及时完成，CPU必须等待GPU）。

<aside>
🚫 通过注释掉一部分的绘制命令来查看是否是GPU Bound的思路是行不通的，即使因为这个操作让帧率上升了，也无法得知究竟是因为减少了GPU操作（绘制的东西变少），还是因为减少了CPU操作（需要翻译的指令变少）。

</aside>

<aside>
💡  可通过增加 `CPU Sleep` 的方式来确定是否是 `GPU Bound` 。如果是 `GPU Bound` 的情况下，CPU处于空载的状态，那么即使让CPU 挂起几毫秒（在空载的时间内），也不会造成帧率的下降。

</aside>

可通过以下的代码来检测究竟是 `CPU Bound` 还是 `GPU Bound` ：

```cpp
protected override void Update(GameTime gameTime)
{
#if PROFILE
    if (currentKeyboardState.IsKeyDown(Keys.PageUp))
        Thread.Sleep(1);

    if (currentKeyboardState.IsKeyDown(Keys.PageDown))
        return;
#endif
}
```

当按下 `Up` 时，CPU 挂起1毫秒, 如果帧率没有下降，那么说明是 `GPU Bound` ，否则是 `CPU Bound` （CPU并未空载）。

当按下 `Down` 时，直接返回 `Update` （不进行任何的游戏逻辑处理），如果帧率上升，说明是 `CPU Bound` ，否则是 `GPU Bound` （仅是指令的翻译通常不会消耗完CPU一帧的全部时间，如果仍然耗费大量时间，则说明是在等GPU绘制完成）。

如果 CPU挂起让帧率下降，且跳过游戏处理逻辑并没用让帧率上升，那么就是同时 `CPU Bound` 和 `GPU Bound` 。

## 渲染管线中的瓶颈

整个GPU的绘制流程也可以拆分成多个部分，每一部分及会影响这部分性能的参数如下所示：

1. 顶点获取（Vertex Fetch）：从内存中读取顶点数据
    - 顶点数量
    - 每个顶点的数据量（是否包含位置信息，UV，颜色等）
    - 顶点数据的排布是否Cache Coherency友好（❓ //TODO）
2. 顶点着色器 （Vertex Shader）：处理顶点数据的着色器
    - 顶点数量
    - 着色器的复杂程度
    - 三角形顶点的 Index 排布是否Cache Coherency 友好
3. 光栅化 （Rasterizer）：确认哪些像素会被需要绘制的三角形覆盖
    - 需要渲染的像素的数量，当开启了MSAA后，该数量需要乘以MSAA的等级
    - 从顶点着色器传递到像素着色器的插值的数据量（如法线，颜色）
4. 像素着色器（Pixel Shader）：即片段着色器，计算每个像素输出的颜色
    - 需要渲染的像素的数量，不受MSAA影响
    - 着色器的复杂程度
5. 纹理获取（Texture Fetch）：
    - 需要渲染的像素数量（要从纹理上采样）
    - 计算每个像素的颜色时，需要用到多少张纹理
    - 纹理需要从内存中读取的数据量，受Mipmap和纹理压缩影响
    - 纹理过滤的方式：
        
        anisotropic最耗费性能，Trilinear耗费略比Bilinear大，Bilinear与Point几乎无差别
        
6. 深度/模板缓冲（Depth/Stencil）
    - 需要渲染的像素数，当开启了MSAA后，该数量需要乘以MSAA的等级
    - 缓冲是只读的还是可读写的
7. 帧缓冲（FrameBuffer）：
    - 需要渲染的像素数，当开启了MSAA后，该数量需要乘以MSAA的等级
    - 每个像素的尺寸（包括MRT，Multi Rendering Target）（❓ //TODO）
    - 缓冲是只读（不透明物体）的还是可读写的（开启的Alpha Blending）

在GPU内部存在非常多的核，GPU内部各核的工作模式与CPU和GPU之间的工作模式类似，当一个核处理完它的任务后，会将输出放到缓冲中，另一个核会从缓冲中读取数据，然后再处理自己的工作。这些操作都是并行的，即并不是所有核都同时处理同一个像素的数据，很可能A核在处理当前像素，而B核在处理前一个像素。

但当处理流程中某个部分的核工作量太大的话，它就无法及时将自己的输出放到缓冲中，其他核就不得不去等待它的输出，这就造成了其他核的空闲。因此如果瓶颈出现在其中的某个流程，而优化其他流程的话，同样不会造成性能的提升。

### 确认是否是顶点数量造成：

降低渲染的分辨率，如将分辨率改为 $100 \times 50$，如果帧率没有提升，那么瓶颈一点在顶点获取或顶点着色器中，因为只有这两者不受分辨率的影响。

可以通过减少顶点的数量来提升性能

### 确认是否是带宽造成：

将纹理都开启Mipmap，或将使用的纹理都改为更低的分辨率，如果帧率有提升，那么说明瓶颈在纹理获取部分。

可通过开启Mipmap，降低纹理分辨率或开启纹理压缩提升性能

### 确认是否是像素着色器造成：

如果在确认不是带宽造成的情况下，在像素着色器中直接返回一个固定色，可以让性能上升，则说明瓶颈出现在像素着色器阶段。

可以通过简化像素着色器来提升性能 。

### 确认是否是光栅化导致：

如果打开或了关闭MSAA，但却没有造成变化，则是由光栅化导致，但这种情况一般较少出现。

可以通过减少要插值的数据来提升性能

### 确认是否是帧缓冲导致：

将帧缓冲用一个更小的纹理格式来表示，如 `BGR565` ，即用5个bit来表示R和B通道，用6个bit表示G通道。如果这样改动后，性能上升了，则说明性能瓶颈在帧缓冲写入。

### 确认是否是深度/模板导致：

当上述的测试都做过，且不属于上述任意类型，则必然是深度/模板导致。

## 管线堵塞 （Pipeline stall）

正常来说，CPU和GPU是并行运算的，即 $FrameTime=max(CPU_{time} + GPU_{time})$。

但在某些情况下会产生管线堵塞的情况，即CPU或GPU必须等一方的工作完成后（不包括提交渲染指令），才能继续运行，即 $FrameTime=CPU_{time} + GPU_{time}$

如下的伪代码就会导致这种情况的出现：

```csharp
devide.SetRenderTarget(rt);
device.SetVertexBuffer(vb);
device.Draw(...);
rt.GetData();
```

当调用了 `Draw` 命令后，实际上只是CPU将绘制命令放到了缓冲中，并未将这些命令传递给GPU。因此在调用 `GetData` 时，GPU还没有进行绘制，而CPU却需要绘制后的结果，所以CPU不得不将目前缓冲中的绘制消息发送给GPU，并且挂起直到GPU缓冲完成后，才能去拿绘制得到的数据。

如下的伪代码看上去并没有问题，但同样可能触发管线堵塞：

```csharp
device.SetVertexBuffer(vb);
device.Draw(...);
device.SetVertexBuffer(null);

vb.SetData(...);
```

因为 `graphicsDevice.VertexBuffer` 是浅拷贝，当 `SetData` 执行时，它修改的是绘制命令中需要用到的顶点数据。因此对于执行数据的修改的流程，显卡的驱动可能做出如下四种选择：

1. 阻塞渲染管线：将目前的绘制命令传送给GPU。这是因为要保证之前设置的绘制命令被正常执行，因此必须等GPU使用之前设置的顶点数据完成了渲染后，再对顶点数据进行修改
2. 直接修改顶点数据：这样不会导致任何的性能问题，但很可能最终GPU绘制出来的效果与开发者想要的效果不同，因为在存放了绘制命令后，绘制命令需要用的数据却被后续修改了。
3. 直接报错：最简单粗暴的解决方式
4. 数据拷贝：先分配一块新内存，内存的大小与目前顶点数据的大小一致。将目前顶点数据拷贝到新内存中，执行内存修改，但是对于新分配内存中数据进行修改。将 `vb` 指向新内存的地址，这样之后对于顶点数据的修改都是基于新分配的内存。GPU仍然使用旧的内存进行渲染，当GPU渲染完成后，将旧内存释放。

对于类似于OpenGL或DX这样的API，可能存在接口可以指定GPU采取上面的某个策略，如在DX中调用 `SetDataOptions.NoOverWrite`，可指定驱动采用方法2。当调用 `SetDataOptions.Discard` ，可指定驱动采用方法4，但会少了方法四种将原数据拷贝到新内存的步骤。

但当不调用相关API时，GPU采取的策略是不确定的。因此最好的方法是规避这种情况的出现，规避的方法如下：

1. 在 `SetVertexBuffer` 和  `Draw` 中进行顶点数据的修改，即在绘制命令绑定要用的顶点数据前，把顶点数据修改好。
2. 保证绘制命令中使用的顶点数据是深拷贝进绘制命令缓冲中的，在 DX 的API中可以通过使用 `DrawUserPrimitives` 达到类似的效果
3. 双缓冲，同时定义两块顶点数据的内存。当绘制命令需要A内存后，之后关于顶点数据的修改就去处理B内存，然后让之后帧去使用B内存。

如下的代码是上一个例子的修改，也可能会触发管线堵塞，且这里的触发机制更难察觉：

```csharp
vertexBuffer.SetData(particlePositions);
graphicsDevice.VertexBuffer = vertexBuffer;
graphicsDevice.DrawPrimitives(...);
```

同样因为 `graphicsDevice.VertexBuffer` 是浅拷贝，当 `SetData` 执行时，它实际修改的是上一帧绘制命令的顶点数据，而上一帧的绘制可能尚未完成（调用 `SetData` 是在Update中，此时GPU在并行的画上一帧图像），所以GPU还需要用到上一帧时设置的顶点数据。

因此当调用 `SetData` 时，CPU必须确认GPU是否已经完成了上一帧的绘制，这样才能覆盖顶点数组的数据。如果未完成的话CPU必须等待GPU完成上一帧绘制才能继续执行，这就会导致CPU的阻塞（Update中必须等待GPU将上一帧画完，而不是正常的两者并行），且即使GPU在CPU访问时已经完成了上一帧的绘制，CPU向GPU查询操作也是个耗时较大的操作。即 `SetData` 会耗费CPU较长的时间甚至阻塞CPU。

<aside>
💡 在 `OpenGL` 中， `glBufferData` 是深拷贝。因此在这种情况下不会触发管线堵塞。但之前的几种情况，仍然会触发管线堵塞。

</aside>

## Reference

[](http://www.shawnhargreaves.com/blogindex.html#gpuperformance)

[How are Direct3D and OpenGL instructions handled in a graphics card?](https://stackoverflow.com/questions/6352159/how-are-direct3d-and-opengl-instructions-handled-in-a-graphics-card)
