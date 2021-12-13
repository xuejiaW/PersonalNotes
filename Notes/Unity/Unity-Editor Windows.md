---
tags:
    - Unity
created: 2021-12-13
updated: 2021-12-13
---

# Overview

Unity 编辑器面板中的 `Scene`，`Game`，`Asset Store` 各区域本质上都是 `Editor Window`。

为了创建一个自定义的 `Editor Window`，需要经过如下最简步骤：

# Derive From EditorWindow

1. 定义一个派生自 `EditorWindow` 的类