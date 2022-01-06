---
created: 2022-01-06
updated: 2022-01-06
tags:
    - Unity
---

# 概述

`Immediate Model GUI (IMGUI)` 是一套完全以代码驱动的GUI系统，主要目的是帮助开发者开发工具，通常有以下用法：

1.  创建游戏内调试用的GUI界面
2.  为脚本创建自定义的 `Inspector` 面板
3.  创建自定义的 `Editor Windows`

```ad-warning
IMGUI 并不是设计用来实现游戏中的UI
```

IMGUI 之所以称为 `Immediate Mode` 是因为它仅依赖于Unity管控的一个特殊函数 `OnGUI` ，只要定义该函数的脚本是 Enabled，该函数每帧都会被执行（如同Update函数一样），IMGUI在其中处理的逻辑都会被直接绘制到屏幕上。

因此 IMGUI 并非采取Unity中常用的 `GameObject-Component` 模式，它仅仅需要一个定义了 `OnGUI` 的脚本，完全不依赖于其他的任何游戏物体或组件。

示例1：

```csharp
public class TestIMGUI : MonoBehaviour
{
    private void OnGUI()
    {
        if (GUILayout.Button("Press Me"))
            Debug.Log("Hello!");
    }
}
```

![](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled.png)

示例2：

```csharp
// (0,0) is at the left-upper corner of screen

private void OnGUI()
{
    GUI.Box(new Rect(10, 10, 100, 90), "Loader Menu");

    if (GUI.Button(new Rect(20, 40, 80, 20), "Level 1"))
    {
        Application.LoadLevel(1);
    }

    if (GUI.Button(new Rect(20, 70, 80, 20), "Level 2"))
    {
        Application.LoadLevel(2);
    }
}
```

![](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%201.png)

# 控件解析

IMGUI中的控件由三部分组成： `类型（Type）` ， `位置（Position）` ， `内容（Content）`

```csharp
// Type (Position, Content)
// GUI.Button -> Type
// Rect(20, 40, 80, 20) -> Position
// "Level 1" -> COntent
GUI.Button(new Rect(20, 40, 80, 20), "Level 1"
```

## 类型（Type）

空间的类型定义在Unity的 `GUI` 类或 `GUILayout` 类中。

[GUILayout 与 GUI 区别](https://www.notion.so/Immediate-Mode-GUI-IMGUI-0fe7b8a74d634738b5e134204e2666f5) 在之后的部分有解释。

如 `GUI.Button` 和 `GUI.Box` 都表示控件的类型。