---
tags:
    - C#
created: 2021-12-13
updated: 2021-12-23
---

# C# Version

不同的 Unity 版本所支持的 C# 版本不同，如 `2020.3` 版本[^1]支持 `C# 8.0`，`2022.1` 版本[^2]支持 `C# 9.0` 等。

Unity 对于支持的 C# 版本，可能存在部分特性的不支持。其不支持的特性版本在各说明页面中都会有相应说明，如下为 `2022.1` 中不支持的 `C# 9.0` 特性[^2]：
![|350](assets/Unity%20-%20Scripting%20Architecture%20-%20CSharp/image-20211213084706350.png)

# C# Version 与 .Net Profile 关系

早期的 Unity 版本中，其支持的 C# 版本会与选择的 [](Unity%20-%20Scripting%20Architecture%20-%20.Net%20Profile%20Support.md) 版本相互依赖，如 `2018.3` 版本中，根据不同的 `.Net Profile` 选择，会支持 `C# 4` 或 `C# 7.3`[^3]。

# Reference

[^1]: [Unity - C# Compile - 2020](https://docs.unity3d.com/2020.3/Documentation/Manual/CSharpCompiler.html)
[^2]: [Unity - C# Compile - 2021](https://docs.unity3d.com/2022.1/Documentation/Manual/CSharpCompiler.html)
[^3]:[Unity - C# Compile - 2018](https://docs.unity3d.com/2018.3/Documentation/Manual/CSharpCompiler.html)
