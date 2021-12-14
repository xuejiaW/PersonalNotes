---
created: 2021-12-14
updated: 2021-12-14
---

在使用 OpenGL前，首先需要创建OpenGL的上下文和用于绘制的窗口等，这些内容是与操作系统相关的。OpenGL则是希望成为一个夸平台的工具，因此OpenGL本身并不复杂这些内容的处理，需要用户自己来进行相关的环境配置。好在一些现有的库以及帮助完成了工作，这里首先需要进行的就是相关库的配置。

## GLFW

GLFW是一个开源的OpenGL库，主要为创建窗口，OpenGL上下文，处理用户输入等功能提供了简单的API。

从[官网](https://www.glfw.org/download.html)中下载GLFW源文件，然后再下载并安装[CMake](https://cmake.org/download/)软件，如使用 [Chocolatey](../../Notes/Chocolatey.md)，可直接通过 `choco install --yes cmake` 进行安装。

安装Cmake后，按下图进行配置，从上到下三个红框分别表示，GLFW的源代码地址，编译后结果的输出地址以及编译对象，这里因为想搭建的是VSCode环境下的地址，所以选择了`MinGW Makefiles`。其中第三个红框的窗口时通过按左下角的`Configure`按钮呼出的。

![](assets/LearnOpenGL-Ch%2000%20Creating%20a%20Window/image-20211214094401003.png)

