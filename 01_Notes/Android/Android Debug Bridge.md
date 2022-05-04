---
Alias: adb
created: 2021-12-13
updated: 2022-01-09
tags:
    - Android
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

## 发送广播

通过 `am boradcast` 发送广播，如下所示：
```shell
adb shell am broadcast -a <action>
// adb shell am broadcast -a com.ABC
```

后可以跟着 `-e<x> <key> <value>` 的格式传递额外数据，如下所示：
```shell
adb shell am broadcast -a <action> -e<x> <Key> <Value>
// adb shell am broadcast -a com.ABC --es foo "bar"
```

可支持的额外数据类型如下：
```text
--ez  - boolean  
--ei  - integer  
--el  - long  
--ef  - float  
--eu  - uri  
--eia - int array (separated by ',')  
--ela - long array (separated by ',')  
--efa - float array (separated by ',')  
--esa - string array (separated by ',')
```

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

## 查看内存

通过 `dumpsys meminfo` 查看当前所有应用/服务各自占据的内存总数：
```shell
adb shell dumpsys meminfo
```

输出如下所示：
```text
Applications Memory Usage (in Kilobytes):
Uptime: 17118754 Realtime: 17118754

Total PSS by process:
    252,825K: com.yvr.yframework (pid 4821 / activities)
    246,296K: com.yvr.vrruntimeservice (pid 1800)
    227,613K: system (pid 1112)
    212,824K: surfaceflinger (pid 905)
    175,685K: controllerservice (pid 1191)
    144,699K: com.yvr.guardianservice (pid 2415)
     86,310K: com.android.systemui (pid 1683)
     82,887K: android.hardware.camera.provider@2.4
```

如果仅关心特定的应用/服务，可以在 `dumpsys meminfo` 后跟包名，如：
```shell
adb shell dumpsys meminfo com.yvr.yframework
```

此时有针对该包名应用/服务更详细的输出，如下所示：
```text
Applications Memory Usage (in Kilobytes):
Uptime: 17261012 Realtime: 17261012

** MEMINFO in pid 4821 [com.yvr.yframework] **
                   Pss  Private  Private     Swap     Heap     Heap     Heap
                 Total    Dirty    Clean    Dirty     Size    Alloc     Free
                ------   ------   ------   ------   ------   ------   ------
  Native Heap    35291    35184        0        0    48864    43899     4964
  Dalvik Heap     1535     1448        0        0     2724     1188     1536
 Dalvik Other      460      452        0        0
        Stack       36       36        0        0
       Ashmem        7        0        0        0
      Gfx dev     4212     4212        0        0
    Other dev       44        0       44        0
     .so mmap    39677     2256    30840        0
    .jar mmap     1109        0        0        0
    .apk mmap      923        0        0        0
    .dex mmap     1789        4     1728        0
    .oat mmap      899        0        0        0
    .art mmap     1698     1072       32        0
   Other mmap     4770       16     4724        0
   EGL mtrack    60336    60336        0        0
    GL mtrack     7900     7900        0        0
      Unknown    92437    92356        0        0
        TOTAL   253123   205272    37368        0    51588    45087     6500

 App Summary
                       Pss(KB)
                        ------
           Java Heap:     2552
         Native Heap:    35184
                Code:    34828
               Stack:       36
            Graphics:    72448
       Private Other:    97592
              System:    10483

               TOTAL:   253123      TOTAL SWAP (KB):        0

 Objects
               Views:        6         ViewRootImpl:        1
         AppContexts:        5           Activities:        1
              Assets:        6        AssetManagers:        0
       Local Binders:       15        Proxy Binders:       35
       Parcel memory:        6         Parcel count:       24
    Death Recipients:        2      OpenSSL Sockets:        0
            WebViews:        0

 SQL
         MEMORY_USED:        0
  PAGECACHE_OVERFLOW:        0          MALLOC_SIZE:        0
```

## 重复执行操作

可以通过如下格式重复执行特定操作：
```shell
adb shell "while true; do <operation>; sleep <gapTime>; done"
```

如下命令可以实现”间隔1秒，执行查看 `com.yvr.yframework` 应用的内存“ 的操作：
```shell
adb shell "while true; do dumpsys meminfo <com.yvr.vrruntimeservice>; sleep 1; done"
```

# 错误处理

## More then one device and emulator

有的时候，当设备连接时会出现无法安装应用，之后通过 `adb devices` 发现除了设备外，还额外多出了一个模拟器。此时可以通过如下命令重启 `adb`， 消除模拟器：

```bash
adb kill-server
```