---
created: 2022-01-20
updated: 2022-05-04
---
在绝大部分的编辑器和 IDE 中都有 `Windows` 和 `Tabs` 概念，而在 Vim 中则通过三个抽象来实现对应的功能： `Buffer` ，`Windows` 和 `Tabs` 。

```ad-note
在 Vim 中当切换 Buffer 时，如果当前 Buffer 有改动且未保存，则 Vim 会进行提示。当频繁切换 Buffers 时，该提示会比较繁琐。为了关闭提示，可以在 `init.vim` 中加入 `set hidden` 。
```

# Buffers

对于 Vim 而言，每打开一个文件， Vim 都会将其捆绑到一个 Buffer 上。如使用如下命令打开三个文件时， Vim 就会创建三个 Buffers。但此时 Vim 上仅会显示 `Text1.txt` ：

```powershell
nvim .\\Text1.txt .\\Text2.txt .\\Text3.txt
```

但可以通过 `:buffers` 显示目前所有打开的 Buffer，如下所示：
![](assets/Ch%2002%20Buffers,%20Window,%20and%20Tabs/image-20211129093852731.png)

可以通过命令 `:bnext` 切换到下一个 Buffer 文件，或通过 `:bprevious` 切换到上一个 Buffer 文件。

![](assets/Ch%2002%20Buffers,%20Window,%20and%20Tabs/image-20211129093902523.png)

也可以通过 `:buffer <file>` 直接切换到特定的文件，或通过 `:buffer <index>` 直接切换到特定 Index 的文件，如下所示：
    
![](assets/Ch%2002%20Buffers,%20Window,%20and%20Tabs/image-20211129093912812.png)

当 Vim 为文件创建一个 Buffer 后，它会保持在你的 Buffer List 中。如果要移除这个 Buffer，需要使用命令 `:bdelete <index>` 或 `:bdelete <file>` 。
    
```ad-note
可以把一个文件视作一个 Buffer
```

```ad-note
可以将 Vim 的单一 Buffer 看作是扑克牌中的一张牌，而切换 Buffer 就像把特定的 Buffer 切换到牌堆顶部一样。
```

```ad-note
在 Vim 中，后续的 Window 和 Tab 都是 Buffer 的表现形式。在 Window 和 Tab 关闭时，Buffer 并没有被相应的释放。
```

# Windows

Vim 的 Window 是展示 Buffer 的窗口。

可以使用命令 `:split` 水平创建新窗口，或通过命令 `:vsplit` 垂直切分新窗口。可以使用类似于 `:split <file>` 的命令在切分窗口的同时打开文件。

对于切分窗口的操作，可以通过如下的快捷键：

```powershell
Ctrl-W V   垂直切分窗口
Ctrl-W S    水平切分窗口
Ctrl-W C    关闭当前的窗口
Ctrl-W O    关闭除了当前窗口外的全部其他窗口
```

在窗口间的移动，可以通过如下的快捷键：

```powershell
Ctrl-W H    移向左边的窗口
Ctrl-W J    移向下边的窗口
Ctrl-W K    移向上边的窗口
Ctrl-W L    移向右边的窗口
```

![](assets/Ch%2002%20Buffers,%20Window,%20and%20Tabs/image-20211129094106805.png)

```ad-tip
更多内容见 `:h window
```

# Tabs

Tabs 是一系列窗口的集合，可以通过命令 `:tabnew` 创建新的 Tab，或通过 `:tabnew <file>` 在创建新 Tab 的同时打开文件， 效果如下所示：
![](assets/Ch%2002%20Buffers,%20Window,%20and%20Tabs/image-20211129094358792.png)

可以看到切分好的窗口属于一个 Tab，当打开新 Tab 时，新 Tab 中是完整未切割的窗口。

在多个 Tabs 中可以通过 `gt` 选择到下一个 Tab，可以通过 `gT` 切换到上一个 Tab。也可以使用类似于 `<index>gt` 切换到特定位置的 Tab。

在打开 Vim 时，可以通过如下命令创建多个 Tab，并为每个 Tab 指定文件：

```powershell
nvim -p Text1.txt Text2.txt Text3.txt
```

# Moving in 3D

1.  通过 `:bnext` / `bprevious` 在 buffer 间切换
2.  通过 `Ctrl-W H/J/K/L` 在窗口间切换
3.  通过 `gt / gT` 切换 Tabs

可以将窗口看到 `X-Y` 空间的切换，将 `buffer` 看作是 Z 空间切换。