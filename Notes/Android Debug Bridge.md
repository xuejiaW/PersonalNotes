---
Alias: adb
---

# 查看设备 IP 地址

可通过 `ipconfig` 命令查看，如下所示：
```
adb shell netcfg
```

输出结果中需要关心的是 `wlan0` 部分，该部分的示例如下所示：
```
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

# Wifi 连接 ADB

对于想要通过 Wifi 连接 adb 的设备，首先需要使用 USB 将该设备连接至电脑，并通过 `adb tcp ip ` 设置之后网络连接的端口号，如下将端口号设置为 `5555`：
```
adb tcpip 5555

```

并参考 [查看设备 IP 地址](#查看设备%20IP%20地址) 记录下设备的 IP 地址。

此时可以将 USB 连接断开，在保电脑与手机处于同一个 Wifi 网络下后通过 `adb connect <ip>` 连接设备，如下所示：
```
adb connect 192.168.2.11
```

断开时可使用 `adb disconnect <ip>` 与设备断开连接。
