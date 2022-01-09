---
created: 2021-12-13
updated: 2022-01-09
---
# Overview

`.Net Standard ` 是一系列由 `.Net` 组织定义的不同 `.Net` 实现库都必须实现的 APIs。

```ad-tip
`.Net Standard` 的存在保证了 `.Net` 生态的统一性。
```

下图展出了 `.Net Framework`，`.Net Core` 和 `XAMARIN` 与 `.Net Standard` 之间的关系[^2]：
![|500](assets/CSharp%20-%20.Net%20Standard%20Overview/image-20211213082828912.png)

# .Net implementation support

对于 `.Net` 实现库而言，它必须支持从最低的 `.Net Standard` 版本到该库所支持最高的 `.Net Standard` 版本间所有的 APIs 实现。如一个库支持 `.Net Standard 2.1`，则该库需要支持从 `.Net Standard 1.0`  到 `.Net Standard 2.1` 间所有定义的 APIs。

如下为各 `.Net` 实现库与 `.Net Standard` 之间的关系列表[^1]：
![](assets/CSharp%20-%20.Net%20Standard%20Overview/image-20211213082543001.png)

```ad-note
`.Net Core` 实现库有时会被简称为 `.Net`
```

# .Net APIs

`.Net Standard` 定义了各 `.Net` 实现库最小的 APIs 子集，各 `.Net` 库还会实现各自拓展的 APIs。

以 `ThreadPool` 类为例，在其 [文档](https://docs.microsoft.com/en-us/dotnet/api/system.threading.threadpool?view=netframework-4.5) 中的 `Applies to` 标题下阐述了支持该 API 的 `.Net` 实现库与 `.Net Standard` 版本：

![|400](assets/CSharp%20-%20.Net%20Standard%20Overview/image-20211213083515807.png)

# Reference

 [^1]: [.NET Standard | Microsoft Docs](https://docs.microsoft.com/en-us/dotnet/standard/net-standard)
 [^2]: [Introducing .NET Standard - .NET Blog (microsoft.com)](https://devblogs.microsoft.com/dotnet/introducing-net-standard/)
