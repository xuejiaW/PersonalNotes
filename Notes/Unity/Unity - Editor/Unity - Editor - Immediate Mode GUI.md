---
created: 2022-01-06
updated: 2022-01-07
tags:
    - Unity
cssclass: [table-border]
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

![|300](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled.png)

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

![|300](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%201.png)

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

如 `GUI.Button` 和 `GUI.Box` 都表示控件的类型。

## 位置（Position）

对于 `GUI` 类中的所有控件函数，第一个参数都是通过一个 `Rect` 来指定控件的位置。 `Rect` 的原点从左上角开始，构造函数的前两个值表示位置，后两个值表示大小。

```csharp
Rect(x, y, width, height)

// start at (10,20), end at (310,210)
Rect(10, 20, 300, 100) 
```

![|300](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%202.png)

所有 `GUI` 组件的位置都是在屏幕空间，且单位是像素。可以通过 `Screen.width` 和 `Screen.height` 获取屏幕的总宽高，如下代码分别在屏幕的四个角各画一个 `Box` 。

```csharp
GUI.Box(new Rect(0, 0, 100, 50), "Top-left");
GUI.Box(new Rect(Screen.width - 100, 0, 100, 50), "Top-right");
GUI.Box(new Rect(0, Screen.height - 50, 100, 50), "Bottom-left");
GUI.Box(new Rect(Screen.width - 100, Screen.height - 50, 100, 50), "Bottom-right");
```

![|300](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%203.png)

## 内容（Content）

### Simple

空间的内容可以是文字或图片：

```csharp
GUI.Label(new Rect(0, 0, 100, 50), "This is the text string for a Label Control");
GUI.Label(new Rect(0, 50, 100, 50), icon); // icon is Texture2D

if (GUI.Button(new Rect(10, 110, 100, 50), icon)) print("you clicked the icon");
if (GUI.Button(new Rect(10, 170, 100, 20), "This is text")) print("you clicked the text button");
```

![|100](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%204.png)

### GUIContent

可以是通过 `GUIContent` ，将文字和图片打包在一起作为一个控件的内容：

```csharp
GUI.Box (new Rect (10,10,100,50), new GUIContent("This is text", icon));
```

![|100](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%205.png)

### Tooltip

`GUIContent` 中还可以加入 `Tooltip` ，作为鼠标移动到特定控件上后显示的内容。 `Tooltip` 必须是字符串，且还需要另一个控件作为显示内容的载体。

```csharp
GUI.Button(new Rect(10, 10, 100, 20), new GUIContent("Click me", icon, "This is the tooltip"));
GUI.Label(new Rect(10, 40, 100, 20), GUI.tooltip);
```

|                                                                              |                                                                              |
| ---------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| ![鼠标未移动到Button上](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%206.png) | ![鼠标移动到Button上](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%207.png) |