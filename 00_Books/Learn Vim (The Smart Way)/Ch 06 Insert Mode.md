---
created: 2022-01-20
updated: 2022-03-11
---
# Ways to GO to Insert Mode

有以下方式从 Normal Mode 变为 Insert Mode：

```powershell
i    Insert text before the cursor
I    Insert text before the first non-blank character of the line
gi   Insert text in same position where the last insert mode was stopped
gI   Insert text at the start of line (column 1)

a    Append text after the cursor
A    Append text at the end of line

o    Starts a new line below the cursor and insert text
O    Starts a new line above the cursor and insert text

s    Delete the character under the cursor and insert text
S    Delete the current line and insert text
```

## Different Ways to Exit Insert Mode

退出 Insert Mode有以下的方式：

```powershell
<Esc>     Exits insert mode and go to normal mode
Ctrl-[    Exits insert mode and go to normal mode
Ctrl-C    Like Ctrl-[ and <Esc>, but does not check for abbreviation
```

还有比较常见的自定义做法是将 `jj` 或 `jk` 映射成 `<Esc>` ：

```powershell
inoremap jj <Esc>
inoremap jk <Esc>
```

```ad-note
在 VSCode + Nvim 中，因为插件并不监听 Insert Mode，所以类 `jj` 的映射依赖于 VSCode 的按键管理，需要使用如下的方式：
~~~json
{
        "command": "vscode-neovim.compositeEscape1",
        "key": "j",
        "when": "neovim.mode == insert && editorTextFocus",
        "args": "j"
},
~~~
```

# Repeating Insert Mode

可以在进入输入模式前按下数字，表示要重复多次输入内容，如按下 `10j` ，并输入 `Hello` 。在退出输入模式时， Vim 会产生 10 个 Hello。 `I` `a` `o` 等也是同理。

# Deleting Chunks in Insert Mode

在输入模式时，如果错误的输入了内容，可以通过以下的方法删除：

```json
Ctrl-H    Delete one character
Ctrl-W    Delete one word
Ctrl-U    Delete the entire line
```

# Insert Fomr Register

在输入模式中可以通过 `Ctrl-r` + `<registerMark>` ，从 `a-z` Register 中粘贴数据。

如果要将信息放进特定的 Register，可以使用 `"` + `<registerMark>` 。

如 `"ayiw` 就是将当前光标下的单词放进 `a` register ， 之后要复制时使用 `Ctrl-r a` 。

```ad-note
具体关于 Register 的内容可见 [Learn Vim - Ch 08 Registers](Learn%20Vim%20-%20Ch%2008%20Registers.md)
```

# Scrolling

可以在输入模式中按下 `Ctrl-x` ，Vim 会进入 Sub-Mode。之后使用 Normal 模式下的 [Scrolling](Ch%2005%20Moving%20in%20a%20File.md#Scrolling) 进行滚动。如：

```json
Ctrl-X Ctrl-Y    Scroll up
Ctrl-X Ctrl-E    Scroll down
```

```ad-fail
VSCode + Nvim 不支持该功能
```

# Autocompletion

在 Insert Mode 中按下 `Ctrl+x` 进入 Sub-Mode 后，Vim 会进行自动补全的提示，可以通过如下的方式选择补全内容：

```json
Ctrl-X Ctrl-L	   Insert a whole line
Ctrl-X Ctrl-N	   Insert a text from current file
Ctrl-X Ctrl-I	   Insert a text from included files
Ctrl-X Ctrl-F	   Insert a file name
```

```ad-error
首先 VSCode + Nvim 不支持 Sub-Mode，其次 Vim 自身的自动补全功能比较孱弱，最后自动补全 VSCode 本身就提供，因此这一部分无需特别关注。
```

对于自动补全有各种选择的情况，可以使用 `Ctrl-n` 和 `Ctrl-p` 进行切换。

```ad-tip
VSCode + Nvim 实现了有选择列表时，可通过 `Ctrl-n` 和 `Ctrl-p` 进行切换的功能。选择列表包括自动补全的提示，查看应用列表，打开文件时等等。
```

# Executing a Normal Mode Command

可以按下 `Ctrl-o` 进入 `--(insert)--` 模式，该模式下可以执行 **一个** Normal Mode 的指令，执行完后会自动回到 Insert Mode。

如 `Ctrl-o 'a` 跳到 mark a 的地方，或 `Ctrl-o !!<command>` 执行命令行操作。