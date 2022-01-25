---
created: 2021-12-09
updated: 2022-01-26
---

```ad-note
这一章不会阐述 Vim 支持的所有移动方式。更多的移动相关信息，可见 `:h motion.txt`
```

```ad-note
可以通过插件 `vim-hardtime` 强迫自己使用正确的方式在 Vim 中移动。
```

# Character Navigation

最常用的移动名词如下：

```jsx
h   Left
j   Down
k   Up
l   Right
```

在这些名词前可以加上数字表示要跳转的行数或字符数，如 `10j` 表示向下移动 10 行。

可以通过如下在 `init.vim` 中的设置，让普通的上下左右按键失效，强迫使用 `hjkl`：

```jsx
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
```

# Relative Numbering

为了更方便的使用如 `10j` 这样多行跳转的方法，可以在编辑器中对每一行显示相对于当前行的行数。

在 Vim 中通过设置 `set relativenumber number` 进行设置，其中 `relativenumber` 还可以替换为 `norelativenumber` ， `number` 还可以替换为 `nonumber` 。

其中 `relativenumber` 中设置 `number` 和 `nonumber` 分别表示是否要在显示相对行之外，额外显示当前行的行数。

`norelativenumber` 中设置 `number` 和 `nonumber` 分别表示显示行号或不显示。

## relativenumber Settings

搭配和效果如下：

```powershell
set relativenumber number
```

![|300](assets/Ch%2005%20Moving%20in%20a%20File/image-20211129224338436.png)

```powershell
set norelativenumber number
```

![|300](assets/Ch%2005%20Moving%20in%20a%20File/image-20211129224353686.png)

```powershell
set norelativenumber nonumber
```

![|300](assets/Ch%2005%20Moving%20in%20a%20File/image-20211129224429641.png)

```powershell
set relativenumber nonumber
```

![|300](assets/Ch%2005%20Moving%20in%20a%20File/image-20211129224446276.png)

在 VSCode 中通过 [editor lineNumbers](../../Notes/VSCode/Settings.md#editor%20lineNumbers) 设置行号的显示方式。
但如果要同时显示行号和相对行号，需要使用插件 [Relative Line Numbers 5](../../Notes/VSCode/Extensions.md#Relative%20Line%20Numbers%205)

# Word Navigation

有以下单词见跳转的方式：

```powershell
w     Move forward to the beginning of the next word
W     Move forward to the beginning of the next WORD
e     Move forward one word to the end of the next word
E     Move forward one word to the end of the next WORD

b     Move backward to beginning of the previous word
B     Move backward to beginning of the previous WORD
ge    Move backward to end of the previous word
gE    Move backward to end of the previous WORD
```

其中 `word` 和 `WORD` 的区别在于， `word` 仅包含 "大小写字母，数字和下划线"，而 `WORD` 包含除了空格键外的所有字符。

如字符串 `"editor.minimap.enabled": false`，将光标移动到 `e` 上，按下 `w` 会跳转到 `.` 上，而按下 `W` 会跳转到 `false` 的 `f` 上。

# Current Line Navigation

行内的跳转名词有：

```powershell
0     Go to the first character in the current line
^     Go to the first nonblank char in the current line
g_    Go to the last non-blank char in the current line
$     Go to the last char in the current line
n|    Go the column n in the current line
```

还有行内搜索的名词，如下所示：

```powershell
f    Search forward for a match in the same line
F    Search backward for a match in the same line
t    Search forward for a match in the same line, stopping before match
T    Search backward for a match in the same line, stopping before match
;    Repeat the last search in the same line using the same direction
,    Repeat the last search in the same line using the opposite direction
```

`f` 和 `t` 的区别在于， `f` 会将光标停到搜索的字符上， `t` 会将光标停在搜索的字符前一个字符上。如字符串 `"editor.minimap.enabled": false`，将光标移动到 `e` 上，按下 `fm` 光标会停留在 `m` 上，按下 `tm` 光标会停留在 `.` 上。

# Sentence and Paragraph Navigation

可以通过 `(` 和 `)` 在句子间跳转，句子的定义是以 `.!?` 结尾并后跟 `EOL, Space, Tab` ：

```powershell
(    Jump to the previous sentence
)    Jump to the next sentence
```

```ad-warning
代码中很难以句子的方式进行跳转
```

可以通过 `{` 和 `}` 在段落间跳转，段落的定义是有空行的分割：

```powershell
{    Jump to the previous paragraph
}    Jump to the next paragraph
```

# Match Navigation

当光标在 `(`时按下通过名词 `%` 会跳转到 `)` 上，反之亦然。 `[]` 与 `{}` 也同理：

```powershell
%    Navigate to another match, usually works for (), [], {}
```

```ad-warning
当光标不处在上述括号上时，按下 % 的结果是未定义的。
```

# Line Number Navigation

跳转到特定行的名词如下：

```powershell
gg    Go to the first line
G     Go to the last line
nG    Go to line n
n%    Go to n% in file
```

# Window Navigation

窗口内跳转名词如下，：

```powershell
H     Go to top of screen
M     Go to medium screen
L     Go to bottom of screen
nH    Go n line from top
nL    Go n line from bottom
```

```ad-note
这里的窗口跳转并不是指窗口间的跳转，而是将光标移动到窗口内的特定地方。
```

如目前窗口内，最上面一行显示的是第 21 行，则按下 H 后光标会跳转到窗口最上方，即 第 21 行。

# Scrolling

可以分别通过 `Ctrl-F/Ctrl-B` 滚动全屏， `Ctrl-D/Ctrl-U` 滚动半屏 和 `Ctrl-E/Ctrl-Y` 滚动一行：

```powershell
Ctrl-F    Scroll down whole screen
Ctrl-B    Scroll up whole screen

Ctrl-D    Scroll down half screen
Ctrl-U    Scroll up half screen

Ctrl-E    Scroll down a line
Ctrl-Y    Scroll up a line
```

也可以通过 `zt` `zz` `zb` 将当前光标的所在行滚动到窗口的特定位置：

```powershell
zt    Bring the current line near the top of your screen
zz    Bring the current line to the middle of your screen
zb    Bring the current line near the bottom of your screen
```

# Search Navigation

可以在使用搜索进行跳转：

```powershell
/    Search forward for a match
?    Search backward for a match
n    Repeat last search in same direction of previous search
N    Repeat last search in opposite direction of previous search
gn   Like n, but start Visual mode to select the match.
gN   Like N, but start Visual mode to select the match.
```

如要搜索单词 `let` ，运行 `/let` 即可。之后按下 `n` 就会继续向下搜索 `let` ，而 按下 `N` 就会在当前位置向上搜索 `N` 。运行 `?Let` 效果类似，只不过此时按 `n` 会向上搜索，而按 `N` 会向下搜索。

可以通过在配置文件中增加 `set hlsearch` 表示 highlight search 让搜索后文件中所有匹配的字符高亮。还可以写入 `set incsearch` 表示 incremental search 让在输入需要搜索的字符时，匹配的内容自动高亮。

默认的，当开启 hightlight search 后，搜索的字符会保持高亮，直到重新搜索新的字符。为了关闭搜索字符的高亮，可以运行命令 `:nohlsearch` 或缩写的 `: noh` 。因为这个操作的调用频率可能比较频繁，可以将其加入快捷键中，如通过连按两下 `Esc` 触发：

```powershell
nnoremap <esc><esc> :noh<CR><esc> """ Turn off search highlight and press <Esc>
```

如果想要向下搜索当前光标下的单词，可以使用 `*` 。如将光标停留在字符串 `one`上时，按下 `*` 相当于输入 `/ \\<Two\\>` ，其中 `\\< \\>` 意味完全匹配。即如果有字符串 `oneTwoThree` ，则按下 `*` 并不会匹配。如果想要匹配，需要使用 `g*` 。

同理，向上搜索，有对应的 `#` 和 `g#` 。

```powershell
*     Search for whole word under cursor forward
#     Search for whole word under cursor backward
g*    Search for word under cursor forward
g#    Search for word under cursor backward
```

# Marking Position

可以通过 `mx` 记录下当前的位置和行号，其中 `x` 为标记符，可以是任意的 `a-z` 和 `A-Z` 中的字符。其中 `a-z` 表示当前 Buffer 中的标记位，如在不同的 Buffer 中可以各自定义 `a` 的位置，而不会互相覆盖。而 `A-Z` 则表示全局的标记位，不同 Buffer 间的定义会相互覆盖，且支持不同 Buffer 间的跳转。将这些标记位称作为 `Marks`

```ad-tip
Marks 类似于书签一样的作用。
```

想要回到标记的地方，可以通过 \` 或 \' ，其中 \` 表示回到记录的确切位置，包括行号和在所在行的位置。\' 表示回到记录的行号。

除了自定义的 Marks, Vim 中还定义了一些默认的 Marks，部分如下所示：

```powershell
''    Jump back to the last line in current buffer before jump
``    Jump back to the last position in current buffer before jump
`[    Jump to beginning of previously changed / yanked text
`]    Jump to the ending of previously changed / yanked text
```

想要查看所有的 Marks，可以通过命令 `:h marks` 。

```ad-warning
系统 Marks 的位置会被操作反复覆盖，而很难保证记录的位置就是想要的情况。因此，通常而言，这些 Vim 默认的 Marks 使用的并不频繁。
```

# Jump

在 Vim 中，一些移动的操作会被认为是 `Jump` ，如 `j` 不会认为是 Jump，但 `10G` 则会认为是 Jump。文档中描述会被 Vim 视作为 Jump 的操作如下：

```powershell
'       Go to the marked line
`       Go to the marked position
G       Go to the line
/       Search forward
?       Search backward
n       Repeat the last search, same direction
N       Repeat the last search, opposite direction
%       Find match
(       Go to the last sentence
)       Go to the next sentence
{       Go to the last paragraph
}       Go to the next paragraph
L       Go to the the last line of displayed window
M       Go to the middle line of displayed window
H       Go to the top line of displayed window
[[      Go to the previous section
]]      Go to the next section
:s      Substitute
:tag    Jump to tag definition
```

```ad-tip
虽然文档中并无描述，但在 `VSCode + nvim` 中，如 `10j` 这样的操作也会被视作为 Jump
```

Vim 记录了所有的 Jumps 操作，可以通过命令 `:jumps` 查看。

可以通过按键 `Ctrl + o` 返回 Jump List 中上一个地方，通过按键 `Ctrl + i` 返回 Jump List 的下一个地方。

```ad-warning
 当使用 `VSCode + nvim` 时，查看 `:jumps` 发现记录的跳转路径似乎并不准确，但仍然可以通过 `Ctrl + o` 和 `Ctrl + i` 正常的跳转。
```

---

```ad-important
如果发现自己的某个操作需要连续按，就考虑是否有更好的操作替代。如频繁的按 `l` 就可以选择使用 `w` ，如果频繁的按 `w` 就可以考虑选择使用 `f`
```
