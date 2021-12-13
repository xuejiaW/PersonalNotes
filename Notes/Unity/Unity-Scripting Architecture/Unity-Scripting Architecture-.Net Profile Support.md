---
tags:
    - C#
created: 2021-12-12
updated: 2021-12-13
---

在 `Edit->Project Settings->Api Compatiability Level` 设置中可以切换 `.Net Standard 2.0` 和 `.Net 4x` 两种配置。
![|400](assets/Unity-Scripting%20Architecture-.Net%20Profile%20Support/image-20211212232835295.png)

这两种配置分别对应了对不同 [.Net 实现库](../../Misc/Misc-.Net%20Standard%20and%20Implementation.md) 的支持，对应关系如下所示：

| Compilation Target | API Compatibility Level |               |
| ------------------ | ----------------------- | ------------- |
|                    | .Net Standard 2.0       | .Net 4x       |
| .Net Standard      | Supported               | Supported     |
| .Net Framework     | Litmited support        | Supported     |
| .Net Core          | Not supported           | Not supported |

