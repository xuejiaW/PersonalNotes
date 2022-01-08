---
tags: 
    - VSCode
created: 2021-11-18
updated: 2022-01-08
---

> 本部分说明在 [[VSCode](VSCode.md) 中部分插件的说明。




# Paste Image[^1]

该插件实现在 Markdown 文件中插入图片的功能。

当复制或截取了图片后，在 `.md` 文件中按下 `Ctrl+Alt+V` 即可完成图片以 markdown 格式的黏贴，图片的源文件会被保存在与 `.md` 同名的子文件夹下。

```ad-info
图片文件具体保存的路径可在 Setting 中通过 `pasteImage.path` 设置。

如下设置图片源文件保存在 `./asset/` 目录下的与文件同名的子文件夹下：
~~~json
"pasteImage.path": "assets/${currentFileNameWithoutExt}",
~~~
```

# Windows Terminal Integration[^2]

该实现自动在当前工作区或当前文件夹打开 [Tools - Windows Terminal](../Tools/Tools%20-%20Windows%20Terminal.md) 。

在当前工作区打开 Windows Terminal 的命令为：`Windows Terminal: Open`，对应的 Command ID 为 `windows-terminal.open`。

在当前文件夹打开 Windows Terminal 的命令为：`Windows Terminal: Open Active File's Folder`，对应的 Command ID 为 `windows-terminal.openActiveFilesFolder`

# Clang-Format[^3]

该插件实现调用本机的 [Tools  - Clang-Format](../Tools/Tools%20%20-%20Clang-Format.md) 格式化 VSCode 中的文件。

在使用插件前，首先需要在 `settings.json` 中设置 [Tools  - Clang-Format](../Tools/Tools%20%20-%20Clang-Format.md) 的路径，如下所示：
```json
"clang-format.executable": "C:/Program Files/LLVM/bin/clang-format.exe"
```

# PlantUML[^4]

该插件支持在 Markdown 中预览 [PlantUML](../PlantUML/PlantUML.md) 绘图。在安装插件后，需要在 `settings.json` 中设置渲染 PlantUML 的 renderer 为 Server，并设定渲染的 Server 地址：
```json
"plantuml.render": "PlantUMLServer",
"plantuml.server": "http://www.plantuml.com/plantuml",
```

# Relative Line Numbers[^5]

该插件实现了在 VSCode 中同时显示行号和相对行号，效果如下：
![](assets/VSCode%20-%20Extensions/image-20211129225048235.png)


# Reference

[^1]: [Paste Image - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=mushan.vscode-paste-image)
[^2]:[Windows Terminal Integration - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=Tyriar.windows-terminal)
[^3]: [Clang-Format - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=xaver.clang-format)
[^4]:[PlantUML - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=jebbs.plantuml)
[^5]:[Relative Line Numbers - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=extr0py.vscode-relative-line-numbers)