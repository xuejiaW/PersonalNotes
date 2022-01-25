---
tags:
    - C#
created: 2021-12-11
updated: 2021-12-12
---

# Overview

`转义序列（Escape Sequences）` 用来在字符串中表示特殊字符，如 `"` 被用来表示字符串，则当要输入 `"` 时，需要使用 `\"`。

转义序列都使用 `\` 作为前缀，且包含如下选项：

| 转义序列 | 字符名称                                 |
| -------- | ---------------------------------------- |
| `\'`     | 单引号                                   |
| `\"`     | 双引号                                   |
| `\\`     | 反斜杠                                   |
| `\0`     | null                                     |
| `\b`     | Backspace                                |
| `\f`     | 换页                                     |
| `\n`     | 换行                                     |
| `\r`     | 回车                                     |
| `\t`     | 水平制表符                               |
| `\v`     | 垂直制表符                               |
| `\u`     | Unicode 转义序列（UTF-16）               |
| `\U`     | Unicode 转义序列（UTF-32）               |
| `\x`     | 除长度可变外，Unicode 转义序列与`\u`类似 |


# Reference

[Strings - C# Programming Guide | Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/strings/)