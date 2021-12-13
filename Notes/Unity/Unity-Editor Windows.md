---
tags:
    - Unity
created: 2021-12-13
updated: 2021-12-13
---

# Overview

Unity 编辑器面板中的 `Scene`，`Game`，`Asset Store` 各区域本质上都是 `Editor Window`。

为了创建一个自定义的 `Editor Window`，需要经过如下最简步骤：

# Derive From EditorWindow

需要定义一个派生自 `EditorWindow` 的类，该类的脚本必须存放在 `Editor` 文件夹下。如下所示：
```csharp
using UnityEngine;
using UnityEditor;
using System.Collections;

public class Example : EditorWindow
{
}
```

```ad-tip
对于 `Editor` 文件夹的父文件夹并无要求
```


# Showing the window

在该类中，定义一个静态函数，并使用 `MenuItem` 修饰该函数，如下所示：
```csharp
class MyWindow : EditorWindow
{
    [MenuItem("Window/My Window")]

    public static void ShowWindow()
    {
        EditorWindow.GetWindow<MyWindow>("MyWindow Name");
    }
}
```

该函数用来唤出自定义的窗口，其中 `Window/My Window` 决定了唤出该窗口的按钮在 Unity Editor 中的路径，本例中即通过路径 `Window -> My Window`。

通过 `EditorWindow.GetWindow` 函数唤起窗口，该函数的泛型类型是定义需要唤起的窗口的类，并形参用来表示窗口的名称：

上例的效果如下所示：
![|400](assets/Unity-Editor%20Windows/GIF%2012-13-2021%2011-28-15%20AM.gif)

# Implement Custom Window's GUI

窗口的样式需要通过自定义窗口类中的 `OnGUI` 函数绘制，如下所示：
```csharp

```