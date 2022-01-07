---
tags: 
    - VSCode
created: 2021-11-21
updated: 2021-12-09
---


> 本部分说明在 [VSCode](VSCode.md) 中编写 C++ 项目相关的配置

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