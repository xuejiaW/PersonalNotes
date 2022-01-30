---
tags:
    - Tool
created: 2022-01-30
updated: 2022-01-30
---

Chocolatey[^1] 为 Windows 平台下的包管理软件

# 安装方法

以管理员模式打开 `Powshell` 并执行如下语句：

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

```ad-note
推荐后续所有 Chocolatey 的安装都基于管理员模式
```

# 常用语句

## 安装

```powershell
choco install --y <软件名>
choco install --y <软件名A> <软件名B> // 一次性安装多个应用
```

install 时的 `—-yes` 表示在安装过程中，一切的询问都允许。

### 异常处理

#### Checksum not meet

安装时可能会出现 CheckSums 不匹配的错误

```powershell
ERROR: Checksum for 'C:\Users\wxj\AppData\Local\Temp\chocolatey\wechat\3.0.0\WeChatSetup.exe' did not meet '95ab26c3048b6705954549d30bb4f3ee12c8a61c3a961477fa7d736d2792ffc01f6e550472b8c0148d7df66a04c9877b5a4857dc56684b96ea0baa56b184d74b' for checksum type 'sha512'
```

说明当前 `chocolatey` 下载的安装包与该软件在 `chocolatey` 验证的包 `checksum` 码不一致，因此 `chocolatey` 拒绝安装。[^2]

修复方法为，在安装时加上 `--ignore-checksums` 的标记位，如：

```powershell
choco install wechat --yes --ignore-checksums
```

#### Already Installed

```powershell
A newer version of xxx is already installed.
Use --allow-downgrade or --force to attempt to install older versions, or use side by side to allow multiple versions.
```

修复方法为，加上 `--allow-downgrade` 或 `--force` 允许降级安装或强制安装：

```powershell
choco install --y mingw --version=8.1.0 --force
```

## 搜索软件名

```powershell
choco search <模糊软件名>
```

如搜索 `choco search notepad`，可得到：

```
❯ choco search wechat
Chocolatey v0.10.15
wechat 3.4.0.38 [Approved] Downloads cached for licensed users
wechatdevtools 1.0.5 [Approved] Downloads cached for licensed users
wecom 3.0.36.2004 [Approved] Downloads cached for licensed users
franz 5.7.0 [Approved] Downloads cached for licensed users
rambox-os-nightly 0.5.19 [Approved] - Possibly broken
rambox 0.7.9 [Approved]
airdroid 3.6.9.100 [Approved] Downloads cached for licensed users
siyuan-note 1.1.83 [Approved]
wiznote 4.13.15 [Approved]
9 packages found.
```

## 查看已安装应用

```powershell
choco list -li
```

# 常见应用 Package Name

```
choco install --y 7zip
choco install --y clash-for-windows
choco install --y notion
choco install --y notepadplusplus
choco install --y git
choco install --y vscode
choco install --y unity-hub
choco install --y adb
choco install --y powershell-core
choco install --y wechat --ignore-checksums
choco install --y dingtalk
choco install --y spotify
choco install --y android-sdk // 会默认安装jdk8
choco install --y android-ndk // 不推荐使用,见@android-ndk部分说明
choco install --y jdk8
choco install --y scrcpy // 一个控制安卓设备的软件
choco install --y gradle
choco install --y netfx-4.7.1-devpack 
choco install --y dotnet-sdk
choco install --y powertoys
choco install --y mingw --version=8.1.0
choco install --y nodejs
```


# Reference

[^1]: [Chocolatey - The package manager for Windows](https://chocolatey.org/)
[^2]: [Gary Ewan Park - Chocolatey Package Error - Checksums do not match](https://www.notion.so/Gary-Ewan-Park-Chocolatey-Package-Error-Checksums-do-not-match-df7a9fb4821d47be95f37b3326e6a157)
