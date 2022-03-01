---
tags:
    - Vulkan
created: 2022-02-24
updated: 2022-03-01
---

# Visual Studio

## Vulkan SDK

从 [Lunary 官网]([LunarXchange (lunarg.com)](https://vulkan.lunarg.com/)) 下载并安装 Vulkan SDK：
![|400](assets/Ch%2002%20Development%20environment/image-20220224092313285.png)

通常而言，安装后的路径为 `C:\VulkanSDK\<version>`，从中找到 `Bin/vkcube.exe` 程序并运行，如果运行成功，则说明该设备显卡的驱动支持 Vulkan，运行结果如下：
![|300](assets/Ch%2002%20Development%20environment/GIF%202-24-2022%209-39-31%20AM.gif)

## GLFW

通过 [GLFW](../../Notes/Libraries/GLFW.md) 创建系统窗口

## GLM

如 DirectX 12 不同，Vulkan 并没有提供线性代数的库，可以选择使用 [GLM](../../Notes/Libraries/GLM.md) 进行相应的运算。

## Settingup Visual Studio

创建 Visual Studio 新工程，并选择 `Windows 桌面向导（Windows Desktop Wizard）` 作为模板，并在创建时选择 `控制台应用程序（Console Application)`，并勾选 `空项目（Empty Project）`。

![](assets/Ch%2002%20Development%20environment/image-20220224231002367.png)

在项目的目录下添加 `Include` 和 `Lib` 文件夹，结构如下：
```text
├───Include
│   ├───GLFW
│   └───glm
│       ├───detail
│       ├───gtc
│       ├───gtx
│       └───simd
└───Lib
        glfw3.lib
```


在 `Project/Vulkan Property Pages` 窗口中添加 Include Directories：
![](assets/Ch%2002%20Development%20environment/image-20220224232224877.png)

![|300](assets/Ch%2002%20Development%20environment/image-20220224233838498.png)

然后再 `Linker/General` 中选择 `Additional Library Directories`：
![|500](assets/Ch%2002%20Development%20environment/image-20220224232653361.png)

![|400](assets/Ch%2002%20Development%20environment/image-20220224234301818.png)

然后在 `Linker/Input` 中选择 `Additional Dependencies`：

![|500](assets/Ch%2002%20Development%20environment/image-20220224233046607.png)

![|400](assets/Ch%2002%20Development%20environment/image-20220224233631948.png)

最后选择支持 `C++ 17` 的编译器：
![](assets/Ch%2002%20Development%20environment/image-20220224233429504.png)

此时在 `main.cpp` 中添加如下内容：
```cpp
#define GLFW_INCLUDE_VULKAN
#include <GLFW/glfw3.h>

#define GLM_FORCE_RADIANS
#define GLM_FORCE_DEPTH_ZERO_TO_ONE
#include <glm/vec4.hpp>
#include <glm/mat4x4.hpp>

#include <iostream>

int main() {
    glfwInit();

    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    GLFWwindow* window = glfwCreateWindow(800, 600, "Vulkan window", nullptr, nullptr);

    uint32_t extensionCount = 0;
    vkEnumerateInstanceExtensionProperties(nullptr, &extensionCount, nullptr);

    std::cout << extensionCount << " extensions supported\n";

    glm::mat4 matrix;
    glm::vec4 vec;
    auto test = matrix * vec;

    while (!glfwWindowShouldClose(window)) {
        glfwPollEvents();
    }

    glfwDestroyWindow(window);

    glfwTerminate();

    return 0;
}

```

并运行程序，命令行中应当显示支持的拓展数目：
![](assets/Ch%2002%20Development%20environment/image-20220225000216293.png)

