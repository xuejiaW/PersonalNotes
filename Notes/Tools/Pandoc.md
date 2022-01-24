---
tags:
    - Documentation
---

# 安装 Pandoc

```bash
choco install pandoc --yes
choco install rsvg-convert python miktex --yes # Pandoc 转换常用的依赖库
```

# Markdown 生成 PDF

```bash
pandoc --pdf-engine=xelatex --toc -N -o <pdfPath> <mdPathes>
```

其中 `--pdf-engine=xelatex` 用来指定 PDF 渲染的引擎， `xelatex` 支持 Unicode 类型文本。 `--toc` 让生成的 PDF 自动生成目录 ， `-N` 为 PDF 中的标题增加序号。

`mdPathes` 支持多个 Markdown 文件，实例如下：

```bash
pandoc --pdf-engine=xelatex --toc -N -o result.pdf .\README.md .\chapter1-software-stack.md .\chapter2-gpu-architecture.md .\chapter3-pipeline-overview.md .\chapter4-texture-samplers.md .\chapter5-primitive-assembly.md .\chapter6-triangle-rasterization.md .\chapter7-zstencil-processing.md .\chapter8-pixel-processing-fork.md .\chapter9-pixel-processing-join.md .\chapter10-geometry-shaders.md .\chapter11-stream-out.md .\chapter12-tessellation.md .\chapter13-compute-shaders.md
```

```ad-error
Windows 下 pandoc 不支持如 `*.md` 的参数，原因与解决方法未知。
```
