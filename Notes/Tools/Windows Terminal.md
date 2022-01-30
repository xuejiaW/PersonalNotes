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

|   Options                      |   Description                                                                |
| ---------------------- | ------------------------------------------------------------- |
| `-help`, `-h`, `-?`, `/?`      | Displays the help message.                                    | | `--maximized`, `-M`    | Launches the terminal maximized.                              |
| `--fullscreen`,`-F`        | --fullscreen, -F                                              |
| `--focus`, `-f`            | Launches the terminal in the focus mode.                      |
| `--window`, `-w window-id`  | Launches the terminal in a specific window (need parameters). | 

### Command

| Command            | Parameters                                                                                                                                                                                     | Description                                                                                    |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| `new-tab`, `nt`    | --profile, -p profile-name, --startingDirectory, -d starting-directory, commandline, --title, --tabColor                                                                                       | Creates a new tab.                                                                             |
| `split-pane`, `sp` | `-H, --horizontal`, `-V, --vertical`, `--profile, -p profile-name`, `--startingDirectory, -d starting-directory`, `--title`, `--tabColor`, `--size, -s size`, `commandline`, `-D, --duplicate` | Splits a new pane.                                                                             |
| `focus-tab`, `ft`  | `--target, -t tab-index`                                                                                                                                                                       | Focuses on a specific tab.                                                                     |
| `move-focus`, `mf` | `direction`                                                                                                                                                                                    | Move focus between panes in the given direction. Accepts one of `up`, `down`, `left`, `right`. | 


### Command Example

```powershell
wt ping docs.microsoft.com #打开新 Terminal instance，运行 ping 命令
wt -p <profiles.name> # 打开新窗口，且指定 Profile，如 Ubuntu / Command Prompt
wt -d <path> # 指定启动的目录，如 wt -d c:\\
wt ; ; # 打开多个 Tab，如 wt -p "Ubuntu" ; -p "Ubuntu"
wt ; new-tab -p "Ubuntu" ; focus-tab -target 1 # Focus the tab with index 1

# Split Panel，此时虽然有 ; 但并非用来作为多 Tab，只是用来分隔 wt 的 commands
wt -p "Command Prompt" ; split-pane -V -p "Windows PowerShell" ; split-pane -H wsl.exe

# Split Panel 和多 Tab 结合
wt -p "Command Prompt" ; split-pane -V wsl.exe ; new-tab -d c:\\ ; split-pane -H -d c:\\ wsl.exe

# Set Title
wt --title tabname1 ; new-tab -p "Ubuntu" --title tabname2
```

### 解决 wt 与 Powershell 间的冲突

因为 Powershell 默认将 `;` 作为分割语句的方法，而上示例中同样需要用 `;` 分隔 wt 的 commands ，因此两者会产生冲突。

以下是几种解决冲突的方法：

1.  使用start 命，令并且使用单引号框住所有的 `options` 和 `commands` ，如下所示：
    
    ```powershell
    start wt 'new-tab "cmd" ; split-pane -p "Windows PowerShell" ; split-pane -H wsl.exe'
    ```
    
2.  使用 start 命令，并且使用双引号框住所有的 `options` 和 `commands` 对于原先需要使用双引号的地方改为 ``"` 如下所示：
    
    ```powershell
    start wt "new-tab cmd ; split-pane -p `"Windows PowerShell`" ; split-pane -H `"wsl.exe`""
    ```

3.  使用 ``;`替代`;` ，如下所示：
    
    ```powershell
    wt new-tab "cmd" `; split-pane -p "Windows PowerShell" `; split-pane -H wsl.exe
    ```
    
4.  使用 `--%` 命令，告知 Powershell 命令的剩余部分都是参数，如下所示：
    
    ```powershell
    wt --% new-tab cmd ; split-pane -p "Windows PowerShell" ; split-pane -H wsl.exe
    ```

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

## 保存多个 Panels

[Specify Panes in a Profile · Issue #3759 · microsoft/terminal](https://github.com/microsoft/terminal/issues/3759)

[BiliBili tutorial](https://www.bilibili.com/video/BV1LE411v7wM)

## 登录 SSh

可通过命令 `ssh <userName>@<server address>` 来登录 SSH，如：

```
ssh wangxuejia@192.168.166.245
```

可进一步将设置某个 `Profile` 设置为一开启就自动登录 ssh：

```json
// setting.json for windows terminal
"profiles": {
"defaults": {
		// ...
},
"list": [
// ...
{
      "commandline": "ssh wangxuejia@192.168.166.245",
      "hidden": false,
      "icon": "ms-appx:///ProfileIcons/pwsh.png",
      "name": "SSH",
      "tabTitle": "SSH"
}
// ...
]
```

此时的效果如下：
![|500](assets/Windows%20Terminal/GIF_8-25-2021_10-42-27_AM.gif)

可以将开启 `SSH` Profile 的操作定义为一个命令：
```json
"actions": 
[
		// ...
		{
		    "name": "SSH WXJ",
		    "command": { "action": "newTab", "index": 1 }
		},
		// ...
]
```

此时的效果如下：
![|500](assets/Windows%20Terminal/GIF_8-25-2021_10-45-17_AM.gif)

## 关闭 PowerShell 提示语

默认打开 Power Shell 时会有如下的提示语：

```shell
PowerShell v6.0.0
Copyright (c) Microsoft Corporation. All rights reserved.

<https://aka.ms/pscore6-docs>
Type 'help' to get help.
```

可以在启用 Power Shell 时加入 `--nologo` 关闭该提示语。在 Windows Terminal 中，可在开启 Power Shell 的 Profile List 中做如下的修改：

```json
{
      "guid": "{574e775e-4f2a-5b96-ac1e-a2962a402336}",
      "hidden": false,
      "name": "PowerShell",
      "commandline": "pwsh.exe -nologo",
      "source": "Windows.Terminal.PowershellCore"
  },
```