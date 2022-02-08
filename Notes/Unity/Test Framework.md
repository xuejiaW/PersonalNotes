---
tags:
    - Unity
    - QA
created: 2022-02-09
updated: 2022-02-09
---

# Prepare

## Install Test Framework

Unity Test Framework 可以选择 Package Manager 中的 `Test Framework` 进行安装。

## Create Test Assembly

所有的测试代码都单独以 Assembly 管理，可以通过 `Window -> General -> TestRunner` 窗口中创建 [Edit Mode](#Edit%20Mode) 或 [Play Mode](#Play%20Mode) 的 Assembly：
![](assets/Test%20Framework/image-20220209074938654.png)

Unity 会默认的为 Test Assembly 创建新的文件夹。

## Create Test

在存有 Test Assembly 的文件夹内，右键选择 `Create -> Testing -> C# Test Script` 可以创建出测试脚本。

## Run Test

当 Test A

# Edit Mode vs. Play Mode

## Edit Mode

Edit Mode 使用的 Assembly 的 Platforms 仅支持 `Editor`。
![|500](assets/Test%20Framework/image-20220209075114741.png)


## Play Mode


