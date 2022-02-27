---
tags:
    - IDE
    - Tool
Alias: VS
created: 2022-02-26
updated: 2022-02-27
---

```ad-tip
基于 Visual Studio 2022
```

# Commands

可以在 [Keymap](#Keymap) 窗口看到所有支持的 Command ID：
![](assets/Visual%20Studio/image-20220226145909296.png)

 ```ad-note
 并未找到完整的 Commands list，但 VS 2017 的所有命令可以从 [VS Command List](https://github.com/Why8n/dotfiles/blob/dc3a3530a17a6c6826a1798275680ea2e60a9a5a/vs2017/vscommands.txt) 中查询。
 ```

## Keymap

可以在 `Tools/Options/Environment/Keyboard` 打开 Keymap 窗口，其中可以设置所有按键的快捷键。

## 常用命令

### 下一个/上一个切换 Tab：

`Window.NextTab`，`Window.PreviousTab`

### 纵向分割窗口：

`Window.NewVerticalTabGroup`

- 与在 [VSCode](Visual%20Studio%20Code.md) 中的命令 `workbench.action.splitEditorRight` 不同的是，在 VS 中该命令是将当前的文件**移动**到垂直分割的新窗口中，且每个窗口中都必须至少有一个文件存在，所以在 VS 中使用该命令时至少应当有两个打开的文件。

### 切换 Tabs Group

依赖 [NavigateTabGroups](#NavigateTabGroups) 插件

### 向左/向右按单词拓展：

`Edit.WordPreviousExtend`，`Edit.WordNextExtend`

### 前进/后退

`View.NevigationBackward`, `View.NevigationForward`

### 下一个/上一个提示

`Edit.LineDown`，`Edit.LineUp`

```ad-note
该命令只用于代码的只能提示，但如跳转到目标文件这样的窗口就无法使用该命令选择，因此可以使用 [Keyboard Manager](Power%20Toys.md#Keyboard%20Manager) 全局替换上下按键。
```

### 注释

`Edit.CommentSelection`

```ad-error
Visual 自带的 `Edit.CommentSelection` 当遇到空白行时无法正常的处理，可以选择利用 [ReSharper](#ReSharper) 的命令 `ReSharper.ReSharper_LineComment` 替代
```

# Settings

# Extensions

## AutoSave

AutoSave[^1] 保证文件在丢失焦点时自动保存。

## NavigateTabGroups

Visual Studio 默认不支持在 Tab Groups 间切换，因此需要 NavigateTabGroups[^2] 的支持，该插件提供了如下的 Commands：

| Command                            | Description                                              |
| ---------------------------------- | -------------------------------------------------------- |
| `Tools.NavigateTabGroups.Right`    | Moves to tab group to the **left** of the current group  |
| `Tools.NavigateTabGroups.Left`     | Moves to tab group to the **right** of the current group |
| `Tools.NavigateTabGroups.Up`       | Moves to tab group **above** the current group           |
| `Tools.NavigateTabGroups.Down`     | Moves to tab group **below** the current group           |
| `Tools.NavigateTabGroups.Next`     | Moves to **next** tab group in the list.                 |
| `Tools.NavigateTabGroups.Previous` | Moves to **previous** tab group in the list              | 

## ReSharper

## VsVim

[keithn/vsvimguide: Guide to VsVim and Resharper (github.com)](https://github.com/keithn/vsvimguide)

### Settings

### Fixing

1.  `<C-k>` 无效
    因为 Visual Studio 有大量的快捷键依赖 `Ctrl-k`，而这个会造成与 Vim 按键的冲突。
    为了解决这个问题，可以先在 [Keymap](#Keymap) 中先将任意按键的快捷键设定为 `Ctrl-k`，然后再进行Remove。

# Referencce

[^1]: [Auto Save File - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=HRai.AutoSaveFile)
[^2]: [Release VS2022 Build · jagt/vs-NavigateTabGroups (github.com)](https://github.com/jagt/vs-NavigateTabGroups/releases/tag/vs2022)
