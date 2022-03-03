---
tags:
    - Unity
    - Android
created: 2022-03-03
updated: 2022-03-03
---

如果 Unity 的应用发生了 Crash 或开发者主动的去获取当前 SysTrace，往往会看到 Unity 应用中的调用堆栈是以内存地址的方式显示，如下：

```text
#00 pc 0000000001063c34  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libil2cpp.so (BuildId: c1dcae557afcd11ac1163f9daaada8845e665e0a)

#01 pc 0000000001d922ec  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libil2cpp.so (BuildId: c1dcae557afcd11ac1163f9daaada8845e665e0a)

#02 pc 0000000000fd6314  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libil2cpp.so (BuildId: c1dcae557afcd11ac1163f9daaada8845e665e0a)

#03 pc 0000000000fd59b0  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libil2cpp.so (BuildId: c1dcae557afcd11ac1163f9daaada8845e665e0a)

#04 pc 0000000000b72d1c  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libil2cpp.so (BuildId: c1dcae557afcd11ac1163f9daaada8845e665e0a)

```

其中如 `0000000001063c34`的字符即为内存地址，如`/data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libil2cpp.so`的字符表示内存地址对应的 `.so`库。

本文章旨在说明将这些近乎不可读的内存地址转换到具体函数符号表的方式，同时也会阐述 Log 中相关 .so 文件的含义。


# 异常环境创建

为方便说明，首先需要使用如下的 C# 代码创建出一个会 Crash 的 Unity 应用，如下所示。

```csharp

[Il2CppSetOption(Option.NullChecks, false)]

protected override void OnInit()

{

 YVRManager yvrManager = null;

 Debug.Log(yvrManager.batteryLevel);

}

// YVRManager.cs

public float batteryLevel => hmdManager.batteryLevel;

```
其中 `Il2CppSetOption`Attribute 关闭了 Unity 对 NullReference 的异常捕捉，因此当代码中访问了空对象应用会直接 Crash。

此时运行应用后会产生如下的 Crash Log：
```text

 *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***

 Version '2020.3.25f1c1 (fd09ccef852e)', Build type 'Release', Scripting Backend 'il2cpp', CPU 'arm64-v8a'

 Build fingerprint: 'YVR/kona/kona:10/QKQ1.210910.001/479:userdebug/release-keys'

 Revision: '0'

 ABI: 'arm64'

 Timestamp: 2022-03-03 15:42:20+0800

 pid: 3716, tid: 3745, name: UnityMain  >>> com.yvr.home <<<

 uid: 1000

 signal 11 (SIGSEGV), code 1 (SEGV_MAPERR), fault addr 0x58

 Cause: null pointer dereference

 x0  0000000000000000  x1  0000000000000000  x2  0000007836fbb850  x3  0000000000000000

 x4  00000078556c89f4  x5  000000771fc162e8  x6  0000007857604e80  x7  0000007857604e80

 x8  0000000000000001  x9  0000000000000000  x10 0000000000000000  x11 00000078351d1fc8

 x12 000000000121a3a8  x13 0000000000000001  x14 b000000000000000  x15 00000000000000ff

 x16 00000079489828f0  x17 0000007948974080  x18 0000007857785000  x19 000000771baf8e40

 x20 0000007857783000  x21 0000000000000000  x22 000000785772fa30  x23 000000785773b998

 x24 0000007857730010  x25 00000000000000ff  x26 0000000000000000  x27 0000000000000000

 x28 0000000000000001  x29 0000007854efa360

 sp  0000007854efa340  lr  0000007856c922f0  pc  0000007855f63c34

 backtrace:

 #00 pc 0000000001063c34  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libil2cpp.so (BuildId: c1dcae557afcd11ac1163f9daaada8845e665e0a)

 #01 pc 0000000001d922ec  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libil2cpp.so (BuildId: c1dcae557afcd11ac1163f9daaada8845e665e0a)

 #02 pc 0000000000fd6314  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libil2cpp.so (BuildId: c1dcae557afcd11ac1163f9daaada8845e665e0a)

 #03 pc 0000000000fd59b0  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libil2cpp.so (BuildId: c1dcae557afcd11ac1163f9daaada8845e665e0a)

 #04 pc 0000000000b72d1c  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libil2cpp.so (BuildId: c1dcae557afcd11ac1163f9daaada8845e665e0a)

 #05 pc 0000000001d80b44  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libil2cpp.so (BuildId: c1dcae557afcd11ac1163f9daaada8845e665e0a)

 #06 pc 0000000000683ab4  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libil2cpp.so (BuildId: c1dcae557afcd11ac1163f9daaada8845e665e0a)

 #07 pc 00000000007cb64c  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libil2cpp.so (BuildId: c1dcae557afcd11ac1163f9daaada8845e665e0a)

 #08 pc 000000000062061c  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libunity.so (BuildId: 2788d0c9032eb7c8359060c8452e9d1a063b25b3)

 #09 pc 000000000062deec  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libunity.so (BuildId: 2788d0c9032eb7c8359060c8452e9d1a063b25b3)

 #10 pc 00000000006305d8  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libunity.so (BuildId: 2788d0c9032eb7c8359060c8452e9d1a063b25b3)

 #11 pc 000000000066974c  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libunity.so (BuildId: 2788d0c9032eb7c8359060c8452e9d1a063b25b3)

 #12 pc 000000000063a9a4  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libunity.so (BuildId: 2788d0c9032eb7c8359060c8452e9d1a063b25b3)

 #13 pc 000000000063adc0  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libunity.so (BuildId: 2788d0c9032eb7c8359060c8452e9d1a063b25b3)

 #14 pc 000000000063a90c  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libunity.so (BuildId: 2788d0c9032eb7c8359060c8452e9d1a063b25b3)

 #15 pc 0000000000679938  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libunity.so (BuildId: 2788d0c9032eb7c8359060c8452e9d1a063b25b3)

 #16 pc 00000000006797f4  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libunity.so (BuildId: 2788d0c9032eb7c8359060c8452e9d1a063b25b3)

 #17 pc 0000000000679750  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libunity.so (BuildId: 2788d0c9032eb7c8359060c8452e9d1a063b25b3)

 #18 pc 0000000000551bb8  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libunity.so (BuildId: 2788d0c9032eb7c8359060c8452e9d1a063b25b3)

 #19 pc 0000000000551e6c  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libunity.so (BuildId: 2788d0c9032eb7c8359060c8452e9d1a063b25b3)

 #20 pc 00000000005518a0  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libunity.so (BuildId: 2788d0c9032eb7c8359060c8452e9d1a063b25b3)

 #21 pc 0000000000551960  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libunity.so (BuildId: 2788d0c9032eb7c8359060c8452e9d1a063b25b3)

 #22 pc 0000000000551634  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libunity.so (BuildId: 2788d0c9032eb7c8359060c8452e9d1a063b25b3)

 #23 pc 000000000055259c  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libunity.so (BuildId: 2788d0c9032eb7c8359060c8452e9d1a063b25b3)

 #24 pc 0000000000552f6c  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libunity.so (BuildId: 2788d0c9032eb7c8359060c8452e9d1a063b25b3)

 #25 pc 0000000000544088  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libunity.so (BuildId: 2788d0c9032eb7c8359060c8452e9d1a063b25b3)

 #26 pc 00000000005440bc  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libunity.so (BuildId: 2788d0c9032eb7c8359060c8452e9d1a063b25b3)

 #27 pc 0000000000544300  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libunity.so (BuildId: 2788d0c9032eb7c8359060c8452e9d1a063b25b3)

 #28 pc 000000000069b600  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libunity.so (BuildId: 2788d0c9032eb7c8359060c8452e9d1a063b25b3)

 #29 pc 00000000006b3ac8  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/lib/arm64/libunity.so (BuildId: 2788d0c9032eb7c8359060c8452e9d1a063b25b3)

 #30 pc 00000000000109ec  /data/app/com.yvr.home--uTefOl7d6zOeo_9fsRfrg==/oat/arm64/base.odex

  

```


可以看到相关的调用堆栈中主要涉及了 `libunity.so`和 `libil2cpp.so`两个文件。

# .so
## libil2cpp.so

当应用的 Scripting Backend 设为 IL2CPP 后，Unity 工程中的 C# 代码在编译时都会转换为 C++ 代码并被编译为 `libil2cpp.so`文件。

如果对编译出的 `.apk`文件进行解压缩，可以在 `lib\<architecture>\`目录下找到该文件。如目标设备架构为 ARM64，则文件地址为 `lib\arm64-v8a\libil2cpp.so`。

```ad-warning
每一次修改 Unity 工程后都会编译产生不同的 `libil2cpp.so`
```

## libunity.so

`libunity.so`中包含了 Unity 引擎工程的 Cpp 实现，通常可以在 Unity 安装路径下找到。但 Unity 针对 Release / Debug 模式，Scripting Backend （IL2Cpp / Mono）以及目标设备架构的不同组合，提供了不同的 `libunity.so`文件，即同一个 Unity 版本下会存在多个 `libUnity.so`文件，如下所示：
![](assets/Android%20Symbols/image-20220303193842523.png)

例如产生了 Crash 的应用使用的是 Unity 2020.3.25f1c1 版本，使用了 Release 模式，Scripting Backend 设定为 IL2CPP，目标设备架构为移动设备的 64 位，则打包在 apk 中 `libunity.so`对应在 Unity 安装路径下的文件地址位：
`C:\Program Files\Unity\Hub\Editor\2020.3.25f1c1\Editor\Data\PlaybackEngines\AndroidPlayer\Variations\il2cpp\Release\Libs\arm64-v8a\libunity.so`

# .sym.so

`.so` 文件可以用以反编译，但无法直接通过 `.so`文件将内存地址转换为函数符号。

具体转换时需要用到 `.so`文件对应的 `.sym.so`文件。

## libil2cpp.sym.so

`libil2cpp.sym.so`默认不会生成，需要在打包时勾选 `Create symbols.zip`，如下所示：
![](assets/Android%20Symbols/image-20220303193907152.png)


如果是脚本打包，则需要添加如下命令：

```csharp

EditorUserBuildSettings.androidCreateSymbolsZip = true;

```


此时编译 apk 后，会在生成 apk 的同目录下产生 `<apkName>.symbols.zip`文件，解压该文件后可在 `<apkName>.symbols/<Architecture>/`目录下找到对应文件，如 `crashDemo.symbols\arm64-v8a\libil2cpp.sym.so`。

```ad-warning
与 `libil2cpp.so`类似，每一次项目修改后编译生成的 `libil2cpp.sym.so`也都不同。
```

## libunity.sym.so

`libunity.sym.so`与 `libunity.so`类似，都是在 Unity 安装目录下，同时也都会根据项目设置的不同进行区分。

例如产生了 Crash 的应用使用的是 Unity 2020.3.25f1c1 版本，使用了 Release 模式，Scripting Backend 设定为 IL2CPP，目标设备架构为移动设备的 64 位，则需要使用的 `libunity.sym.so`路径为：
`‪C:\Program Files\Unity\Hub\Editor\2020.3.25f1c1\Editor\Data\PlaybackEngines\AndroidPlayer\Variations\il2cpp\Release\Symbols\arm64-v8a\libunity.sym.so`

如果在工程的 `Project Settings -> Player -> Android -> Other Settings -> Otiomization -> Strip Engine Code`选项被勾选上，那么解析符号表时需要的 `libunity.sym.so`就不再是 Unity 安装目录下的源文件。此时同样需要在打包时生成 `symbols.zip`文件，在解压缩后可找到目标文件 `<apkName>.symbols/<Architecture>/libunity.sym.so`。


# 使用 .sym.so 找寻函数路径

当有了正确的 `.sym.so`时，可以使用如下的命令将内存地址转换为函数路径：

```bash
<add2line> -f -C -e <.sym.so Path> <memory address>
```

其中 `addr2line`为 Android NDK 中提供的将内存地址转换为函数路径的工具，其使用的版本必须和 Unity 编译时使用的 NDK 版本匹配。如 Unity 工程使用的 NDK 版本为 `19.0.5232133`则需要使用的 `addr2line`工具地址应为 `<ndkPath>\19.0.5232133\toolchains\aarch64-linux-android-4.9\prebuilt\windows-x86_64\bin\aarch64-linux-android-addr2line.exe`。

```ad-warning
注意需要使用 aarch64-linux-android-addr2line.exe  而不是 arm-linux-androideabi-addr2line.exe
```

`-f`，`-C`，`-e`分别为 `add2line`工具需要的 Flag，其含义分别为：
- `-f`：需要显示函数名

- `-C`：标准化函数名（去除一些无意义字符）

- `-e`：需要设置输入的 `.sym.so`文件

`.sym.so Path`即为上述找寻到的 `.sym.so`文件地址

`memory address`即为需要找寻的内存地址。

一个完整的将内存地址转换为函数路径的调用如下：
```text
C:\Android\android-sdk\ndk\19.0.5232133\toolchains\aarch64-linux-android-4.9\prebuilt\windows-x86_64\bin\aarch64-linux-android-addr2line.exe -f -e D:\YUI_Home\Build\2022_02_27-1.6-v1.symbols\arm64-v8a\libil2cpp.sym.so 0000000001063c34

```

其输出结果如下：
```text
YVRManager_t4874062D82B0C0D2D40B50895B6E4D80AB9165B9::get_hmdManager_14() const

D:\YUI_Home\Library\Il2cppBuildCache\Android\arm64-v8a\il2cppOutput/Unity.com.yvr.core.cpp:11417

```

可以看到该地址对应的函数有 `get_hmdManager` 字符，其与 C# 代码 `hmdManager.batteryLevel`可匹配上。