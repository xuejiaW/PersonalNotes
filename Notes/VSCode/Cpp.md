---
tags:
    - VSCode
created: 2021-11-21
updated: 2022-01-26
cssclass: [table-border]
---

> 本部分说明在 [VSCode](../VSCode.md) 中编写 C++ 项目相关的配置

# Overview

在 `.vscode` 文件夹下有三个文件与 C++ 项目的设置相关：

1.  `tasks.json` ：编译出可执行文件的相关设置
2.  `launcher.json` ：调试相关的设置
3.  `c_cpp_properties.json` ：C++ 或 C 语言的智能提示相关

# Intelligence Configuration

关于 C++ 智能提示相关的配置在工作区的 `.vscode/c_cpp_properties.json` 文件中。该文件的示例如下：
```json
{
    "configurations": [
        {
            "name": "Android",
            "includePath": [
                "${workspaceFolder}/**",
                "${ANDROID_NDK_HOME}\\sysroot\\usr\\include"
            ]
        }
    ],
    "version": 4
}
```

其中 C++ 文件中 `#include <path>`  搜索的路径即通过 `includePath` 指定。

# 编译设置

关于编译的设置在工作区的 `.vscode/tasks.json` 文件中。

选择 `Terminal -> Configure Default Build Task` 后，再选择编译时需要用的编译器，如 `g++` ，则可创建 `tasks.json` 文件。

|                                                                         |                                                                        |
| ----------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| ![配置 Build 任务](assets/VSCode%20-%20Cpp/image-20220125094517353.png) | ![选择目标编译器](assets/VSCode%20-%20Cpp/image-20220125094532505.png) |

```ad-note
该文件配置完成后，就可以使用 `Tasks. Run Build Task` 生成可执行文件。 但此时，仍然无法使用 F5 直接调试应用
```


# 调试设置

关于调试的设置在工作区的 `.vscode/launcher.json` 文件中。

选择 `Run->Add Configuration` ，再选择需要用的调试器，如 `GDB` ，再选择 `GDB` 的路径，则可以创建 `launcher.json` 文件。

|                                                          |                                                          |                                                          |
| -------------------------------------------------------- | -------------------------------------------------------- | -------------------------------------------------------- |
| ![增加调试的配置文件](assets/VSCode%20-%20Cpp/image-20220125094808870.png) | ![选择 GDB 调试器](assets/VSCode%20-%20Cpp/image-20220125094839848.png) | ![选择 GDB 文件路径](assets/VSCode%20-%20Cpp/image-20220125094849964.png) |

# Rerference

[Get Started with C++ and Mingw-w64 in Visual Studio Code](https://code.visualstudio.com/docs/cpp/config-mingw)

[Visual Studio Code Variables Reference](https://code.visualstudio.com/docs/editor/variables-reference)

[Tasks in Visual Studio Code](https://code.visualstudio.com/docs/editor/tasks#_run-behavior)