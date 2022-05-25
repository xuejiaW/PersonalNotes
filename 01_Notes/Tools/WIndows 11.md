---
tags: Tools
created: 2022-05-25
updated: 2022-05-25
---

# 关闭登录画面

在 CMD 中运行：
```shell
reg ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device" /v DevicePasswordLessBuildVersion /t REG_DWORD /d 0 /f
```

搜索
