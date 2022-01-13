---
tags:
    - Documentation
created: 2022-01-09
updated: 2022-01-13
---

# Overview

`MKDocs` 是一个支持用 `markdown` 文件生成静态网页文档的工具。

相较于 `Sphinx` 的好处在于：

1.  原生支持 `markdown`
2.  动态修改预览，在对配置文件， `md` 文件改动后，无需重新编译，可直接看到更新结果。


# Getting Start

## 安装MKDocs

通过 `pip` 安装 `MKDocs`
```bash
pip install mkdocs
```

安装完成后，运行 `mkdocs --version` 应当可以看到 `mkdocs` 的版本：
```bash
$ mkdocs --version
mkdocs, version 1.1.2 from c:\\users\\106270\\appdata\\local\\programs\\python\\python39\\lib\\site-packages\\mkdocs (Python 3.9)
```

## 基本功能

### 初始化文档目录

使用命令 `mkdocs new <FolderName>` 创建一个包含文档工程的文件夹，如
```bash
mkdocs new my-project
cd my-project
```

创建后的目录如下：
![|300](assets/Tools%20-%20MKDocs/image-20220109164730715.png)

其中 `mkdocs.yml` 是配置文件， `docs` 中是所有文档的源文件。

目前 `docs` 中只有一个名为 `index.md` 的文件，用于显示首页的信息。

网站的名称可以在 `mkdocs.yml` 中通过 `site_name` 设置：
```yaml
site_name: Unity
```

### 运行网页

运行命令 `mkdocs server` 后将网页部署在 [`http://127.0.0.1:8000/`](http://127.0.0.1:8000/) 中，在浏览器中打开该页面即能显示结果：
```bash
PS G:\\yvr_sdk\\yvr_sdk_Unity\\Document> mkdocs serve
INFO    -  Building documentation...
INFO    -  Cleaning site directory
INFO    -  Documentation built in 0.05 seconds
[I 210122 16:04:59 server:335] Serving on <http://127.0.0.1:8000>
INFO    -  Serving on <http://127.0.0.1:8000>
```

![](assets/Tools%20-%20MKDocs/image-20220109164800373.png)

```ad-note
当配置文件或源文件被改动后，页面会自动被刷新，不需要重新启动serve
```

### 增加自定义页面

可以通过 `mkdocs.yml` 中新增 `nav` 字段来添加导航页：
```yaml
site_name: Unity
nav:
    - Home: index.md
    - About: about.md
```

当 `nav` 中的界面大于一个时，会自动出现 `Previous` 和 `Next` 按钮
![](assets/Tools%20-%20MKDocs/image-20220109164854446.png)

### 修改样式

可以通过 `mkdocs.yml` 中的 `theme` 字段设置文档样式：
```yaml
theme: readthedocs
```

![|500](assets/Tools%20-%20MKDocs/image-20220109164936100.png)

# 插件

## Arithmatex

若需要让 `MKDocs` 支持 `MathJax` ，则需要 `Arithmatex` 插件的支持。

该插件是 `PyMdown` 插件中的一部分，且 `PyMdown` 在安装 `MKDocs` 时已自动被安装了，因此仅需要开启 `Arthmatex` 插件即可。

在 `mkdocs.yml` 的 `markdown_extensions` 中开启插件：
```yaml
markdown_extensions:
  - pymdownx.arithmatex:
      generic: true
```

该插件还依赖于额外的组件，在 `mkdocs.yml` 的 `extra_javascript` 中进行配置：
```yaml
extra_javascript:
  - js/config.js
  - <https://polyfill.io/v3/polyfill.min.js?features=es6>
  - <https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js>
```

其中 `js/config.js` 为本地文件，需要添加到 `docs_dir` 目录下，该文件中的内容如下：
```yaml
window.MathJax = {
  tex: {
    inlineMath: [["\\\\(", "\\\\)"]],
    displayMath: [["\\\\[", "\\\\]"]],
    processEscapes: true,
    processEnvironments: true
  },
  options: {
    ignoreHtmlClass: ".*|",
    processHtmlClass: "arithmatex"
  }
};
```

```ad-fail
在 `extra_javascript` 中增加的本地文件，必须在 `docs_dir` 中。即无法通过类似于 `../../` 的方法访问外部的文件
```

# Reference

[MkDocs](https://www.mkdocs.org/)
