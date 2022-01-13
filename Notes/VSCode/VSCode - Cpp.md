---
tags: 
    - VSCode
created: 2021-11-21
updated: 2022-01-14
---


> 本部分说明在 [VSCode](VSCode.md) 中编写 C++ 项目相关的配置

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

关于编译的设置在工作区的 `.vscode/tasks.json` 文件中，