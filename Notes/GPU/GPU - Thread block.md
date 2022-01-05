在 GPU 中，会将 Computer Shader 的函数拆分成多进多个 Groups 中，这些组都会并行的运算。每个 Group 中都有固定数量的线程，这些线程都会运行相同的计算，但这些线程有着不同的输入。

对于每个 Group 中的线程数是由 `numthreads` 进行控制， `numthreads` 是一个三维的 Attribute，即所有的线程以三维的方式进行管理。如设置 `numthreads(10,8,3)` 则表示这个 Group 一共有 240 个线程，且是以 $10*8*3$ 的三维模式展现。

对于 Groups 而言，同样是以三维方式进行管理，如调用 DX 中的 [Dispatch](https://docs.microsoft.com/en-us/windows/win32/api/d3d11/nf-d3d11-id3d11devicecontext-dispatch) 函数，且调用格式为 `Dispatch(5,3,2)` 则表示一共有 30 个 Groups，且是以 $5*3*2$ 的三维模式展现。

示例图如下所示，图中展现了 $5*3*2$ 个 Groups，图的上半部分中每个小方格即表示一个 Group。图的下半部分中每个小方格即表示一个 Thread，每个 Group 中有 $10*8*3$ 个 Threads。

![](assets/GPU%20-%20Thread%20block/image-20220105083052542.png)

对于每个 Computer Shader 的函数而言，能接受一系列的 Syntax 表示在 Thread Blocks 中的状态。

1.  `SV_GroupID` ：所在 Group 的三维 Index 表示，如上图上半部分中灰显的小方块，即表示第 $(2,1,0)$ 个 Group，所以 `SV_GroupID` 的值为 $(2,1,0)$ 。
2.  `SV_GroupThreadID` ：所在 Thread 在当前 Group 中的三维 Index 表示，如上图下半部分中的灰显小方块，即表示第 $(7,5,0)$ 个 Thread，所以 `SV_GroupThreadID` 的值为 $(7,5,0)$。
3.  `SV_GroupIndex` ：所在 Thread 在当前 Group 中的一维 Index 表示。在上例中，即为 $5*10+7 = 57$。
4.  `SV_DispatchThreadID` ：所在 Thread 在所有 Groups 中的三维表示。在上例中，即将每个 Group 都展开成 $(10*8*3)$ 个 Threads 后，当前 Threads 所在位置。因为上例中 Thread 在第 $(2,1,0)$ 个 Group 中，且在所在 Group 的第 $(7,5,0)$ 个线程。因此在所有 Group 中的位置为 $(2,1,0)*(10,8,3) + (7,5,0) = (27,13,0)$ 。

# Reference

 [numthreads - Win32 apps | Microsoft Docs](https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/sm5-attributes-numthreads)
