
# The Ten Register Types

Vim 有 10 个 Register 的类型：

1.  The unnamed register (`""`).
2.  The numbered registers (`"0-9`).
3.  The small delete register (`"-`).
4.  The named registers (`"a-z`).
5.  The read-only registers (`":`, `".`,and `"%`).
6.  The alternate file register (`"#`).
7.  The expression register (`"=`).
8.  The selection registers (`"*` and `"+`).
9.  The black hole register (`"_`).
10.  The last search pattern register (`"/`).

# Register Operators

下列三个动作会将内容存储进 Register 中：

```
y    Yank (copy)
c    Delete text and start insert mode
d    Delete text
s    Delete character and start insert mode
x    Delete character
```

```ad-note
如果一个操作删除了内容，那被删除的内容就会进 Register
```

从 Register 中拷贝出内容，可以使用以下动作：

```
p    Paste the text after the cursor
P    Paste the text before the cursor
```

如果要拷贝 10 次，可以使用 `10p` ；如果想要从 `a` Register 中拷贝，可以使用 `"ap` ；如果想要从 `a` Register 中拷贝 10 次，可以使用 `10"ap` 。

```ad-note
`p` 的含义实际上并不是 Paste 的缩写，而是 Put
```

# Calling Registers From Insert Mode

再 Insert 模式下，可以使用 `Ctrl-r <register>` 的方式拷贝，如 `Ctrl-r "` 从默认的 Unnamed Register 中拷贝， `Ctrl-r a` 从 `a` Register 中拷贝。

# The Unnamed Register

默认的内容都会放进 Unnamed Register 中，即使用 `p` 相当于使用了 `""p`

# The Numbered Registers

数字 的 Registers 主要分为两类， `0` 和 `1~9` 。

## The Yanked Register

如复制了一整行文本 （ `yy`），那么 Vim 实际上会将内容拷贝到两个 Registers 中：

1.  Unnamed Register
2.  0 Register （Yanked Register）

```ad-note
`0` Register 中只会存储拷贝的内容，删除/修改的内容不会进入 0 Register 中。
```

```ad-note
`0` Register 对拷贝的文本长度并无限制，即使复制一个单词，也会进入 `0` Register。
```

## The Non-zero Numbered Registers

更改或删除最少一行长度的文本，原文被的内容会被存储在 `1-9` Register 中，且其中的内容由新到旧排序，即 Register 1 中的内容是最新更改的内容。

如有文本：

```
line three
line two
line one
```

将光标移动到 `line three` 上，然后依次通过 `dd` 删除每一行，则 Register 1 中会是内容 `line one` ， Register 2 中的内容是 `line two` ，Register 3 中的内容是 `line three` 。

当使用 `.` 操作符时，如果执行的操作是关于 Numbered Register 的，那么每次 `.` 操作都会递增所使用的 Register。如有操作 `"2p` ，则下次使用 `.` 时，执行的操作是 `"3p` ，下一次 `.` 时执行的是 `"4p` 。

# The Small Delete Register

删除和调整小于一行长度的文本，不会被存储到 Numbered Registers 中，而会到 Small Delete Register（ `-`） 中，如命令 `diw` 就会将删除的信息放到 `-` Register 中，而 `dd` 就不会。

# The Named Register

之前的 `Unnamed Register` ， `Numbered Register` 和 `Small Delete Register` 都是 Vim 自动控制的，而 `Named Register` 受使用者的控制。

`Nmaed Register` 包括 `a-z` Register ，如 `"ayiw` 会将复制的内容放到 `a` Register 中。再次使用 `"ayiw` 会将之前 `a` Register 中的内容覆盖。

使用大写的 `A-Z` 则会在对应的 Register 中添加新的内容，如使用 `"Ayiw` 会在之前的 `a` 中添加新拷贝的内容。

如有字符串 `Hello World` ，将光标移动到 `H` 上，使用 `"ayiw` ，则 `a` Register 中的内容为 `Hello` 。此时将光标移动到 `W` 上，如果使用的是 `"ayiw` ，则 `a` Register 会被覆盖为 `World` ；如果使用 `"Ayiw` ， `a` Register 中的内容会被添加为 `Hello World` 。

# The Read-Only Reigsters

以下有三个只读的 Register：

```
.    Stores the last inserted text
:    Stores the last executed command-line
%    Stores the name of current file
```

`".p` 会输出上一次输入的内容

`"%p` 会输出当前文件的完整绝对路径。

`":p` 会输出上一次执行的 Command 命令

# The Alternate File Register

在 Vim 中，将上一个打开的文件称作为 `Alternate File` ， `#` Register 中存储了 Alternate File 的完整绝对路径，如从 A 文件切换到 B 文件，此时使用 `"#p` 会打印出 A 文件的绝对路径。再从 B 文件切换会 A 文件时，使用 `"#p` 会打印出 B 文件的绝对路径。

# The Expression Register

`#` 表示 Expression Register，如运行 `“=1+1<Enter>p` 得到的输出结果为 2。

也可以再 `=` 后加上 `@<Register>` 输出其他 Register 中的内容。如 `"=@a` 输出 `a` Register 中的内容。

```ad-note
Expression Register 是一个很复杂的内容，教材中也只是阐述了这样的基本概念而已。
```

# The Selection Registers

如果 Vim 的 Register 需要与外部的应用交互，如从外部复制黏贴内容，会将 Vim 中复制的内容黏贴到外部，则需要使用 `*` 和 `+` Reigster。如使用 `"*p` 或 `"+p` 将外部应用复制的内容黏贴进 Vim ， 使用`"*yiw` 或 `"+yiw` 将 Vim 中的内容复制进外部应用也可以调用的 Register 中。

```ad-note
*` 和 `+` 的区别 一些系统使用 X11 Window System，这种系统下黏贴系统包含三部分 `Primary` , `Secondary` 和 `Clipboard` 。 `*` 表示 `Primary` ， `+` 表示 `Clipboard`
```

可以通过设置 `set clipboard=unnamed` 和 `set clipboard+=unnamedplus` 将外部应用链接到 `unnamed` Register 中，此时从外部复制的内容，通过 `p` 就可以直接黏贴。同理 Vim 内复制的内容，通过 Ctrl+V 也可以直接在外部黏贴。

# The Black Hole Register

如果在修改或删除内容时，不想将内容放在任何 Register 中，可以使用 Black Hole Register `_` 。如删除一行时使用 `"_dd`

# The Last Search Pattern Register

可以使用 `/` 表示上一次搜索或替换时的文本，如需要黏贴出上一次搜索的文本，使用 `"/p` 。

# Viewing The Registers

可以通过 `:register` 查看所有的 Register 中的内容。如果只想要搜索 `a` ， `1` 和 `-` ，则使用 `:register a 1 -`

```ad-note
在 VSCode + NeoVim 中， `:register` 的信息会在 SideBar 中的 Output 栏中显示。
```

# Executing a Register

在 Register 中的内容，也可以被认为是 `Macro` ，并通过 `@` 执行，具体内容见 [Ch09: Macros](https://www.notion.so/Ch09-Macros-51c91a1c5c56439fb6378a1d0a87f4f3)

```ad-note
Macro` 存储在 Register 中，因此存储 `Macro` 可能会覆盖当前在 `Register` 中的内容。
```

# Clearing a Register

清除特定的一个 Reigster 方法有以下三种：

1.  通过 Macros，如使用 `qaq` ，即表示在 a Register 中存储一个空的 Macro，即清空了 a Register
2.  使用命令 `:call setreg` ，如 `:call setreg('a', '')` 将空信息存储到 a Register
3.  通过 `:let` ，如 `:let @a=''` 让 a Register 中存储空信息

# Putting the Content of a Register

可以通过命令从特定的 Register 中拷贝出数据，如 `:put a` 从 a Register 中拷贝出数据。

```ad-note
因为 _ Register（Black Hole Register）中并不会包含任何的信息，因此可以通过 `:put _` 相当于插入空白行。
```