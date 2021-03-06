---
tags:
    - C#
    - Unity
created: 2021-12-12
updated: 2022-01-26
---

# Overview

在 `Edit->Project Settings->Api Compatiability Level` 设置中可以切换 `.Net Standard 2.0` 和 `.Net 4x` 两种配置。
![|400](assets/Dot%20Net%20Profile%20Support/image-20211212232835295.png)

这两种配置分别对应了对不同 [.Net 实现库](../../CSharp/Dot%20.Net%20Standard%20and%20Implementation.md) 的支持，对应关系如下所示：

| Compilation Target | API Compatibility Level |               |
| ------------------ | ----------------------- | ------------- |
|                    | .Net Standard 2.0       | .Net 4x       |
| .Net Standard      | Supported               | Supported     |
| .Net Framework     | Litmited support        | Supported     |
| .Net Core          | Not supported           | Not supported |

