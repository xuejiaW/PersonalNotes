---
Alias: adb
created: 2021-12-13
updated: 2021-12-14
---

# Shell 命令

## 查看设备 IP 地址

可通过 `ipconfig` 命令查看，如下所示：
```shell
adb shell netcfg
```

输出结果中需要关心的是 `wlan0` 部分，该部分的示例如下所示：
```text
wlan0     Link encap:UNSPEC    Driver cnss_pci
          inet addr:192.168.2.11  Bcast:192.168.2.255  Mask:255.255.255.0
          inet6 addr: fe80::58ea:5850:9450:2c7/64 Scope: Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:3809032 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1523225 errors:0 dropped:2 overruns:0 carrier:0
          collisions:0 txqueuelen:3000
          RX bytes:4830754479 TX bytes:220771345
```

其中 `inet addr` 后跟着的即为 IP 地址，示例中为 `192.168.2.11`。

## Wifi 连接 ADB

对于想要通过 Wifi 连接 adb 的设备，首先需要使用 USB 将该设备连接至电脑，并通过 `adb tcp ip ` 设置之后网络连接的端口号，如下将端口号设置为 `5555`：
```shell
adb tcpip 5555

```

并参考 [查看设备 IP 地址](#查看设备%20IP%20地址) 记录下设备的 IP 地址。

此时可以将 USB 连接断开，在保电脑与手机处于同一个 Wifi 网络下后通过 `adb connect <ip>` 连接设备，如下所示：
```
adb connect 192.168.2.11
```

断开时可使用 `adb disconnect <ip>` 与设备断开连接。

## 打开应用

```shell
adb shell am start <packageName>/<mainAcitvityName>
// adb shell am start com.yvr.launcher2d/com.unity3d.player.UnityPlayerActivity
```

可通过 `-n` 标记位在打开应用的同时传递 Intent：

```shell
adb shell am start -n <packageName>/<mainAcitvityName> --e<type> <intentKey> <intentValue>
// adb shell am start -n com.yvr.launcher2d/com.unity3d.player.UnityPlayerActivity --es "packageName" "com.android.settings"
```

## 关闭应用

### force-stop

```shell
adb shell am force-stop <packageName>
```

### kill

首先通过 `ps` 找到需要关闭的应用的进程号，再通过 `kill` 命令关闭：
```shell
adb shell ps -A |grep <searchPattern>
adb shell kill <processID>
```

### killall

如果在已知应用包名的情况下，可以直接通过 `killall` 关闭应用：
```shell
adb shell killall <packageName>
```

```ad-warning
`kill` 和 `killall` 命令依赖设备的 Root 权限
```

## 截图

```shell
adb shell screencap <outputPath> #截图
```

## 录视频

```shell
adb shell screenrecord <outputPath> #录视频
```

## 模拟按键

```shell
adb shell input keyevent <KeyEvent>
```

该命令需要指定模拟的 [KeyEvent](https://developer.android.com/reference/android/view/KeyEvent)，如需要模拟 `Home` 键，则按键如下：
```shell
adb shell input keyevent KEYCODE_HOME
```

# 错误处理

## More then one device and emulator

有的时候，当设备连接时会出现无法安装应用，之后通过 `adb devices` 发现除了设备外，还额外多出了一个模拟器。此时可以通过如下命令重启 `adb`， 消除模拟器：

```bash
adb kill-server
```