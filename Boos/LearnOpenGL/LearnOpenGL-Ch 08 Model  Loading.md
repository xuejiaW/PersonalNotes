# Assimp 编译

[Assimp](http://assimp.org/index.php)是一个用于导入模型资源的开源库，与在 [Creating a Window](LearnOpenGL-Ch%2000%20Creating%20a%20Window.md) 中生成 GLFW 库一样，这里需要通过源码和 `CMake` 编译出需要用到的 dll 和 lib。

```ad-error
从 [Assimp官网](http://assimp.org/index.php) 下载的源码（4.0.3版本），会存在编译问题 ，因此建议从 Github 上直接下载最新代码
```

首先从 Assimp Github 页面上下载最新代码，然后在工程文件夹中通过 CMake 编译出需要的 MinGW 源文件：