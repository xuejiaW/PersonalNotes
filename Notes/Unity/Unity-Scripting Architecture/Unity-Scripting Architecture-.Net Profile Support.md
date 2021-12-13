---
tags:
    - C#
created: 2021-12-12
updated: 2021-12-13
---

在 `Edit->Project Settings->Api Compatiability Level` 设置中可以切换 `.Net Standard 2.0` 和 `.Net 4x` 两种配置。
![|400](assets/Unity-Scripting%20Architecture-.Net%20Profile%20Support/image-20211212232835295.png)

这两种配置分别对应了对不同 `.Net` 框架的支持，对应关系如下所示：

| Compilation Target | API Compatibility Level |               |
| ------------------ | ----------------------- | ------------- |
|                    | .Net Standard 2.0       | .Net 3x       |
| .Net Standard      | Supported               | Supported     |
| .Net Framework     | Litmited support        | Supported     |
| .Net Core          | Not supported           | Not supported |

其中 `.Net Standard`，`.Net Framework`和 `.Net Core` 分别为三种不同的 .Net 配置。其中 `.Net Standard` 由 `.Net` 组织定义，其中定义了一系列各 `.Net` 实现库都必须实现的 APIs。