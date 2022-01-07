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

|                                                                                                  |                                                                                                |
| ------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------- |
| ![鼠标未移动到Button上](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%206.png) | ![鼠标移动到Button上](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%207.png) |

```ad-warning
当鼠标移动到定义了 `Tooltip` 的控件上时， `GUI.tooltip` 会自动改为定义的 `Tooltip` 字符串。 因此在鼠标未移动到Button上时，Label其实也被绘制了，只不过绘制的字符串为空。

如果将 `GUI.Tooltip` 作为 `GUI.Button` 的形参，可以发现 `GUI.Button` 的背景无论鼠标有没有移动到上面，都会绘制了出来，但仅当鼠标移动到 `GUI.Button` 上时，上面的文字才会被显示
```

# 控件

## 控件类型

### Label

`Label` 是不可交互的，仅用来展示的。

`Label` 只会展示定义的内容，如定义的内容是 `string` ，则该 `string` 后不会有任何的背景。而其他大部分的控件都有默认的背景。

```csharp
GUI.Label(new Rect(25, 25, 100, 30), "Label");
```

![|100](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%208.png)

### Button

`Button` 在被完成了一整个点击操作后（点击下，释放），会返回 `true` （一帧）。

```csharp
if (GUI.Button(new Rect(25, 60, 100, 30), "Button"))
{
    Debug.Log("Click button");
}
```

![|100](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%201%201.png)

### RepeatButton

`Button` 在鼠标按下后就一直会返回 `true` （多帧）。

```csharp
if (GUI.RepeatButton(new Rect(25, 95, 100, 30), "RepeatButton"))
{
    Debug.Log("Click repeatButton");
}
```

![|100](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%202%201.png)

### TextField

`TextField` 是用来展示 `string` ，因此必须给 `TextField` 提供一个 `string` 作为控件的内容。

每当在 `TextField` 中输入字符（不需要按回车），该控件就会返回当前 `TextField` 中的字符。

在 `TextField` 如果输入了超过控件宽度的字符串，字符串会自动向后延申而不会换行，即使控件的高度大于多行字符的高度，即使按下回车。

```csharp
private string textFieldString = "text field";
// ...
textFieldString = GUI.TextField(new Rect(25, 130, 100, 50), textFieldString);
```

![|100](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%203%201.png)

### TextArea

`TextArea` 是用来展示 `string` ，因此必须给 `TextArea` 提供一个 `string` 作为控件的内容。

每当在 `TextArea` 中输入字符（不需要按回车），该控件就会返回当前 `TextArea` 中的字符。

在 `TextField` 如果输入了超过控件宽度的字符串，字符串会自动换行。

```csharp
private string textAreaString = "text area";
// ...
textAreaString = GUI.TextArea(new Rect(25, 185, 100, 50), textAreaString);
```

![|100](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%204%201.png)

### Toggle

`Toggle` 需要提供一个 `bool` 类型作为当前的状态，还需要提供一个 `string` 作为展示的内容。

```csharp
toggleBool = GUI.Toggle(new Rect(25, 240, 100, 50), toggleBool, "Toggle");
```

![|100](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%205%201.png)

### ToolBar

`ToolBar` 是一系列按钮的集合。该控件的内容部分需要提供两个参数，第一个是 `int` 类型，表示第几个按钮（从0开始）被选中，第二个是 `string[]` ，表示一系列按钮上需要显示的字符串，且该参数表示了一共有多少个按钮。

点击其中的一个按钮后，会返回被点击的按钮的 `Index` ，且该按钮被选中。在同一时间只会有一个按钮被选中。

```csharp
private int toolbarInt = 1;
private string[] toolbarStrings = { "ToolBar1", "Toolbar2", "Toolbar3" };

// ...

toolbarInt = GUI.Toolbar(new Rect(25, 295, 250, 50), toolbarInt, toolbarStrings);
```

![|100](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%206%201.png)

### SelectionGrid

`SelectionGrid` 是一系列按钮的集合且以多行展示。

该控件的内容部分需要提供三个参数，第一个是 `int` 类型，表示第几个按钮被选中（从0开始），第二个是 `string[]` ，表示一系列按钮上需要显示的字符串，且该参数表示了一共有多少个按钮。第三个是 `int` 表示一行中要显示多少个按钮。

点击其中的一个按钮后，会返回被点击的按钮的 `Index` ，且该按钮被选中。在同一时间只会有一个按钮被选中。

```csharp
private int selectionGridInt = 2;
private string[] selectionStrings = { "Grid 1", "Grid 2", "Grid 3", "Grid 4" };

// ...

selectionGridInt = GUI.SelectionGrid(new Rect(25, 350, 250, 100), selectionGridInt, selectionStrings, 3);
```

![|100](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%207%201.png)

### Horizontal / Vertical Slider

`HorizontalSlider` 是一个水平方向的滑条， `VerticalSlider` 是一个垂直方向的滑条。

该控件在内容部分需要提供3个参数，这三个参数都是 `float` 类型，第一个参数则是在最小值和最大值之间的某个中间值，该参数会决定滑动条的初始位置，第二和第三个参数表示滑动条的最小值和最大值，

在滑动过程中，该控件会根据滑动的位置，返回一个最小值和最大值之间的某个中间值。

如最小值和最大值为 $[1,10]$，则在滑动过程中，返回值会在 $[1,10]$ 中变化。

```csharp
// HorizontalSlider
private float hSliderValue = 3.0f;
// ...
hSliderValue = GUI.HorizontalSlider(new Rect(25, 455, 250, 100), hSliderValue, 0, 10);

// VerticalSLider
private float vSliderValue = 3.0f;
// ...
vSliderValue = GUI.VerticalSlider(new Rect(200, 25, 100, 250), vSliderValue, 0, 10);
```

![|100](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%208%201.png)

![|100](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%209.png)

```ad-warning
 `HorizontalSlider` 中表示位置的 `Rect` 中的`height` 并不会改变 `Slider` 的显示高度，它只表示 `HorizontalSldier` 可交互范围的高度。 在这个占据的高度内，拖动鼠标都会造成滑动条的变化，即使鼠标下并没有被绘制的UI。 如果其他的控件在被 `HorizontalSlider` 占据的空间中，则这些控件并不会有交互反应。
```

|                                                                                                                            |                                                                                                                            |
| -------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| ![Vertical Slider with Height : 100](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/GIF_1-11-2021_11-57-24_AM.gif) | ![Vertical Slider with Height : 100](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/GIF_1-11-2021_11-56-21_AM.gif) |

### Horizontal / Vertical Scrollbar

```ad-note
`Scrollerbar` 与 `Slider` 类似，差别在于 `ScrollerBar` 多了一个参数去调整滑动条的滑块大小。
```

`HorizontalScrollbar` 是一个水平的滚动条。

该控件在内容部分需要提供4个参数，这四个参数都是 `float` 类型。第一个参数则是在最小值和最大值之间的某个中间值，该参数会决定滑动条的初始位置。第二个参数决定滑块的大小，其中第三和第四个参数表示滑动条的最小值和最大值，

```csharp
// Horizontal Scrollbar
private float hScrollBarValue = 3.0f;
// ...
hScrollBarValue = GUI.HorizontalScrollbar(new Rect(25, 475, 250, 25), hScrollBarValue, 1, 0, 10);

// Vertical Scrollbar
private float vScrollBarValue = 3.0f;
// ...
vScrollBarValue = GUI.VerticalScrollbar(new Rect(200, 25, 25, 200), vScrollBarValue, 1, 0, 10);
```

|                                                                                                  |                                                                                                |
| ------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------- |
| ![Horizontal Scroller](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%2010.png) | ![Vertical Scroller](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%2011.png) |

```ad-warning
滑块在滚动条中的位置是由滑块最左侧表现得。即如果 `hScrollBarValue` 的值是在最大值和最小值的中间值，则滑块的最左侧会在整个滚动条的中间。

也因此，滑块的Size也决定了滑块的取值范围。如整个范围是 $0 \sim 10$，且滑块的大小是 1，则最终滑块的取值范围是 $0 \sim 9$。

当滑块的大小设为0，则表现的如同 `Slider`
```

```ad-error
`Scroller` 对于 `Rect` 中宽高的处理与 `Slider` 类似，即不表示显示的范围，只表示可交互的范围。但是 `Scroller` 中对于交互的处理存在抖动，不知道是否是Bug。
```