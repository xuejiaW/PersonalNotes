---
created: 2022-01-30
updated: 2022-01-30
tags:
    - Tool
---


# Command line

## 运行 Window Terminal

可以用 `wt` 命令打开 Windows Terminal，该命令可以接受两个可选参数：

```powershell
wt [options] [command ; ]
```

`options` 是一系列 flag 或其他参数，用来控制 `wt` 命令的行为。

### Options

|         |             |
| ------- | ----------- |
| Options | Description |
|         |             |


## 以管理员权限运行Shell

安装第三方软件 [gsudo](https://github.com/gerardog/gsudo) ，可通过 [Chocolatey](Chocolatey.md) 安装：

```powershell
choco install --y gsudo
```

之后在需要管理员权限的 shell 中直接运行 `gsudo` 即可：
![](assets/Windows%20Terminal/Untitled.png)



`options` 是一系列 flag 或其他参数，用来控制 `wt` 命令的行为。
# 配置 Windows Terminal

通过以下步骤可打开 Windows Terminal 的配置文件 `settings.json`：
![](assets/Windows%20Terminal/GIF_6-13-2021_10-00-04_PM.gif)

`settings.json` 文件通常在以下地址：

```text
C:\Users\<username>\AppData\Local\Packages\Microsoft.WindowsTerminal_<Random>\LocalState\
```

## Appearance

`tabWidthMode` 设置标签页的宽度：

-   equal
-   titleLength
-   compact


## 快捷键

### 默认快捷键
1.  打开设置 `ctrl + ,`
2.  打开新 Tab `ctrl+shift+t`
3.  上一个 Tab `ctrl + alt + h`
4.  下一个 Tab `ctrl + alt + l`


### 设置快捷键格式

-   无参数的命令
    
    ```json
    { "command": "commandName", "keys": "modifiers+key" }
    
    // Example:
    // { "command": "closeWindow", "keys": "alt+f4" }
    ```
    
-   带有参数的命令
    
    ```json
    { "command": { "action": "commandName", "argument": "value" }, "keys": "modifiers+key" }
    
    // Example:
    // Open the new tab with the profile in the first position of list
    // { "command": { "action": "newTab", "index": 0 }, "keys": "ctrl+shift+1" }
    ```


    `keys` 并不是必选项，如果未设置，则命令仍然回出现在命令列表（ `ctrl p` 后出现的面板）内 `keys` 可以是 `string` 或 `string` 的数组。


除了上述的字段，每一个命令还可以设置 `name` 和 `icon` ，这两个都是影响在命令面板中的显示，前者表示命令的名字，后者是命令前所加的 icon，如下所示：

```powershell
{ "icon": "⚡", "name": "New tab", "command": "newTab", "keys": "ctrl+shift+t" }
```

```ad-note
 如果希望一个命令，不出现在命令面板中，可将该命令的 `name` 设为 `null`
```

### 嵌套命令

当使嵌套命令时，运行该命令会出现多项子命令，效果及实例代码如下所示：
![](assets/Windows%20Terminal/GIF_6-15-2021_8-18-33_AM.gif)

```json
{
    "name": "Change font size...",
    "commands": [
        { "command": { "action": "adjustFontSize", "delta": 1 } },
        { "command": { "action": "adjustFontSize", "delta": -1 } },
        { "command": "resetFontSize" },
    ]
}
```

```ad-warning
嵌套命令不支持快捷键
```

