---
tags:
    - Vulkan
created: 2022-02-24
updated: 2022-02-24
---

# Visual Studio

## Vulkan SDK

从 [Lunary 官网]([LunarXchange (lunarg.com)](https://vulkan.lunarg.com/)) 下载并安装 Vulkan SDK：
![|400](assets/Ch%2002%20Development%20environment/image-20220224092313285.png)

通常而言，安装后的路径为 `C:\VulkanSDK\<version>`，从中找到 `Bin/vkcube.exe` 程序并运行，如果运行成功，则说明该设备显卡的驱动支持 Vulkan，运行结果如下：
![|300](assets/Ch%2002%20Development%20environment/GIF%202-24-2022%209-39-31%20AM.gif)

## GLFW

通过 [GLFW](../../Notes/Libraries/GLFW.md) 创建系统窗口