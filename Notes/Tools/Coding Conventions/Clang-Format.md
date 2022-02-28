---
created: 2022-01-07
updated: 2022-01-30
tags:
    - Tool
---
# 安装

在 Windows 中可以使用 [Chocolatey](Chocolatey.md) 安装 Clang-Format：
```
choco install --yes llvm
```

# 基本使用

使用 `clang-format <filePath>` 时，会将文件 Format 格式化后的内容打印到终端中。
- 使用 `-i` ，直接将修改目标文件
- 使用 `-style`，设置格式化的风格，如使用 `-style=google` 表示使用谷歌的风格


# 配置文件

`clang-format` 可通过 `.clang-format` 文件控制

