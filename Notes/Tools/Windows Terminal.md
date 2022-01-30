---
created: 2022-01-30
updated: 2022-01-30
tags:
    - Tool
---


## 以管理员权限运行Shell

安装第三方软件 [gsudo](https://github.com/gerardog/gsudo) ，可通过 [Chocolatey](Chocolatey.md) 安装：

```powershell
choco install --y gsudo
```

之后在需要管理员权限的 shell 中直接运行 `gsudo` 即可：
![](assets/Windows%20Terminal/Untitled.png)

# 配置 Windows Terminal

通过以下步骤可打开 Windows Terminal 的配置文件 `settings.json`：
![](assets/Windows%20Terminal/GIF_6-13-2021_10-00-04_PM.gif)

`settings.json` 文件通常在以下地址：

```text
C:\Users\<username>\AppData\Local\Packages\Microsoft.WindowsTerminal_<Random>\\LocalState\\
```