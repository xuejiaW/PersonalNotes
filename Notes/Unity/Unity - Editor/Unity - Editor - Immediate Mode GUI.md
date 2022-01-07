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

![Horonzontal Scroller with Height 50](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/GIF_1-11-2021_1-40-54_PM.gif)

### ScrollView

`ScrollerView` 表示一个滚动区域，以 `GUI.BeginScrollView` 开始，以 `GUI.EndScrollView` 结束，这两句语句中间的控件都会被包含在滚动区域内。

`BeginScrollView` 中表示位置的 `Rect` 代表区域显示范围，后续的内容部分需要提供两个参数，第一个参数是一个 `Vector2` ，分别表示在水平方向和垂直方向的滚动位置，第二个参数是另一个 `Rect` ，表示滚动区域整个容纳的范围。

```csharp
public Texture2D icon;
private Vector2 scrollViewVector = Vector2.zero;
private string innerText = "I am inside the scrollView";

// ...

scrollViewVector = GUI.BeginScrollView(new Rect(25, 505, 200, 200), scrollViewVector, new Rect(0, 0, 400, 400));
innerText = GUI.TextArea(new Rect(0, 0, 400, 300), innerText);
GUI.Label(new Rect(0, 300, 400, 100), icon);
GUI.EndScrollView();
```

![|300](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/GIF_1-11-2021_2-14-11_PM.gif)

### Window

`Window` 是一个比较特殊的控件，

第一个参数是 `int`，而是 `Window` 的ID。

第二个参数是 `Rect` ，表示 `Window` 的位置。

第三个参数是一个函数，函数原型为 `void WindowFunction(int id)`

第四个参数为 `string` ，表示窗口的标题。

传递给 `Window` 的函数会被每帧调用，在该函数中应当定义需要绘制的控件，其中的控件绘制会以 `Window` 的左上角作为 $[ 0,0]$ 。

```csharp
private Rect windowRect = new Rect(250, 20, 200, 200);
// ...
windowRect = GUI.Window(0, windowRect, WindowFunction, "A Window");

// ...

private void WindowFunction(int windowID)
{
    Debug.Log("window ID" + windowID);
    GUI.Label(new Rect(25, 25, 100, 30), "Label");

    if (GUI.Button(new Rect(25, 60, 100, 30), "Button")) { Debug.Log("Click button"); }
    if (GUI.RepeatButton(new Rect(25, 95, 100, 30), "RepeatButton")) { Debug.Log("Click repeatButton"); }
}
```

![|200](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%2012.png)

## GUI.changed

当某一帧对控件做出了任意操作后（如点击了 `Button`，或拖动了 `Slider`等）， `GUI.changed` 会在这一帧被置为 `true` 。

```csharp
private int toolbarInt = 1;

// ..

toolbarInt = GUI.Toolbar(new Rect(20, 20, 250, 50), toolbarInt, toolbarStrings);
if (GUI.changed)
{
    Debug.Log(toolbarInt);
}
```

![|500](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/GIF_1-11-2021_2-54-14_PM.gif)

# 自定义控件样式

Unity的 IMGUI支持自定义控件样式，每个控件都由 `GUIStyles` 控制它的样式。

所有的 `GUI` 控件函数都有一个重载函数，该重载最后有一个额外参数表示它的 `GUIStyles` 。当没有指定 `GUIStyles` 时就会Unity会使用默认的样式：

```csharp
public static void Label(Rect position, string text);
public static void Label(Rect position, string text, GUIStyle style);
```

## string 到 GUIStyle 的切换

在 `GUIStyle` 类中定义了一个隐式的转换， `string` 可转换为 `GUIStyle` 。

```csharp
public static implicit operator GUIStyle(string str);
```

当指定了一个 `string` 时，Unity 会从当前使用的 `GUISkins` 中找寻该 `string` 与哪个 `GUIStyle` 的 `name` 相匹配，找到后便将该 `string` 转换为 `GUIStyle` 。

如下例子中，最后的参数传递的是一个 `string` ，但会自动的转换为对应控件的类型。该例子中用 `box` 的样式渲染 `Label` ，用 `toggle` 的样式渲染 `Button`：

```csharp
GUI.Label(new Rect(0, 0, 200, 100), "Hi - I'm a label looking like a box", "box");
GUI.Button(new Rect(10, 140, 180, 20), "This is a button", "toggle");
```

![|300](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%208%202.png)

## GUISkin

一系列的 `GUIStyles` 可以被封装进一个 `GUISkin` 中。 `GUISkin` 是 Unity管理的一个资源文件，可通过 `Assets / 右键` → `Create` → `GUI Skin` 进行创建。

`GUISkin` 资源文件中包含各控件的 `GUIStyles` ，也可以自定义其他的 `GUIStyles` 。

![|400](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%209%201.png)

在 `OnGUI` 中可以使用 `GUI.skin` 切换当前要使用的 `GUISkins` ，当 `GUI.Skin` 赋值为 `null` 时则使用的是Unity默认的 `GUISkin`：

```csharp
GUI.skin = customSkin;
GUI.Button(new Rect(10, 10, 150, 20), "Custom skinned button");
GUI.skin = null;
GUI.Button(new Rect(10, 40, 150, 20), "Default skinned button");
```

|                                                                                   |     |                                                                                          |
| --------------------------------------------------------------------------------- | --- | ---------------------------------------------------------------------------------------- |
| ![](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%2010%201.png) |     | ![](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/GIF_1-11-2021_4-25-34_PM.gif) |

## GUIStyle

当在脚本中定义了一个 public 的 `GUIStyle` ，则在 `Inspector` 中会展现出一个 `GUIStyle` 的可设置项：

```ad-error
Unity中没有对应的 `GUIStyle` 的资源文件
```

```csharp
public GUIStyle customButtonStyle;
// ...

GUI.Button(new Rect(20, 20, 200, 100), "Custom Button",customButtonStyle);
```

|                                                                                   |                                                                                          |
| --------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| ![](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%2011%201.png) | ![](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/GIF_1-11-2021_3-55-51_PM.gif) | 

## 动态修改 GUIStyle

`GUIStyle` 中的参数可以在运行时被动态修改，如下代码在运行时动态的修改 `label` 的 `GUIStyle` 中 `fontSize` 属性：

```csharp
GUI.skin = customSkin;
GUIStyle style = GUI.skin.GetStyle("label");
style.fontSize = (int)(20.0f + 10.0f * Mathf.Sin(Time.time));
GUI.Label(new Rect(10, 10, 200, 80), "Hello World!");
```

![|300](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/GIF_1-11-2021_4-33-23_PM.gif)

# GUI VS GUILayout

`IMGUI` 中有两种排列方式， `固定排列（Fixed Layout）` 和 `自动排列（Automatic Layout）` 。在 `固定排列`中，每个控件都需要指定它的位置和大小，在 `自动排列` 中控件的位置和大小则会自动调节。

`GUI` 类对应的就是 `固定排列` ，因此 `GUI` 类中的每个控件都需要传递 `Rect` 表示它的位置和大小。

`GUILayout` 类对应的就是 `自动排列` ，因此 `GUILayout` 类中的每个控件都不要求传递 `Rect` 表示位置和大小。

## GUILayout
```csharp
GUILayout.Box("Loader Menu");

if (GUILayout.Button("Level 1"))
{
    Debug.Log("Level 1");
}

if (GUILayout.Button("Level 2"))
{
    Debug.Log("Level 2");
}
```

![|100](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%2012%201.png)

## GUI

```csharp
GUI.Box(new Rect(0, 0, 100, 20), "Loader Menu");

if (GUI.Button(new Rect(0, 25, 100, 20), "Level 1"))
{
    Debug.Log("Level 1");
}

if (GUI.Button(new Rect(0, 50, 100, 20), "Level 2"))
{
    Debug.Log("Level 2");
}
```

![|100](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/Untitled%2013.png)

## 排列控件

排列控件可以控制其他的控件的显示范围或多个控件之间该如何分组。

不同的排列方式需要用不同的排列控件：

对于 `固定排列` 需要用 `Groups`

对于 `自动排列` 需要用 `Areas` 或 `Horizontal Groups` 或 `Vertical Groups`

### Fixed Layout - Groups

`Groups` 可以定义一系列控件要显示的范围，定义在 `BeginGroup` 和 `EndGroup` 中的组件都属于该 `Group` 。

定义在 `Group` 中的各组件位置都是依赖于 `Group` 的左上角计算的，而非屏幕的左上角。因此当移动 `Group` 时，里面的各控件相对位置并不会发生变化。

```csharp
GUI.BeginGroup(new Rect(Screen.width / 2 + 50 * Mathf.Sin(Time.time), Screen.height / 2 - 50, 100, 100));
GUI.Box(new Rect(0, 0, 100, 100), "Group is here");
GUI.Button(new Rect(10, 40, 80, 30), "Click me");
GUI.EndGroup();
```

![|500](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/GIF_1-11-2021_6-02-03_PM.gif)

对于超过了 `Group` 范围的控件，会被裁剪掉。如果直接调整一个控件的大小，实现的是缩放效果，因此如果要实现裁剪效果必须需要用到 `Group`。

```csharp
GUI.BeginGroup(new Rect(20, 20, (Mathf.Sin(Time.time) + 1) / 2.0f * 256, 32));
GUI.Box(new Rect(0, 0, 256, 32), icon);
GUI.EndGroup();
```

![|300](assets/Unity%20-%20Editor%20-%20Immediate%20Mode%20GUI/GIF_1-11-2021_6-10-54_PM.gif)

### Automatic Layout - Areas

`自动排列` 中的 `Area` 功能与 `固定排列` 中的 `Groups` 类似。

当未定义在 `Area` 中的 `GUILayout` 控件，会在屏幕控件的左上角排列并绘制。而定义了在 `Area` 中的 `GUILayout` 控件，则会从 `Area` 的左上角排列并绘制。

```csharp
GUILayout.Button("I am not inside an Area");
GUILayout.BeginArea(new Rect(Screen.width / 2, Screen.height / 2, 300, 300));
GUILayout.Button("I am completely inside an Area");
GUILayout.EndArea();
GUILayout.Button("I am not inside an Area too");
```