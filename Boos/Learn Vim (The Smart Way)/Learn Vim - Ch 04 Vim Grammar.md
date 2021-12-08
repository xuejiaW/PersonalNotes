```ad-warning
这一章中提到的 Vim Language 指的是 Vim 中使用快捷键，而不是指 Vimscript Language。
```

# Grammar Rule

Vim 语言的形式为简单的 动词 + 名词：

$$vert+noun$$

# Nouns (Motions)

Vim 中的名词很多，其中关于移动的典型名词有：

```text
h    Left
j    Down
k    Up
l    Right
w    Move forward to the beginning of the next word
}    Jump to the next paragraph
$    Go to the end of the line
```

# Verbs(Operators)

Vim 一共有 16 个操作符，但在使用中 80% 的情况，使用如下四个操作符即可：

```text
y    Yank text (copy)
p    Paste text
d    Delete text and save to register
c    Delete text, save to register, and start insert mode
```

```ad-tip
更多内容见： :h operator
```

还有一些可能有用的动词：

```text
gU    Uppercase text
gu    Lowercase text
~     Switch case of the character and move to the right
```

```ad-note
在 Visual Mode 下，gU 和 gu 可以让文本变为大写或小写。在 Normal Mode 下，后跟着 <Motion> 将字符切换为大写或小写
```

# Verb and Noun

如前所述，快捷键的格式为 动词+名词，如：

-   要删除当前位置到行末的所有字符： `y$`
-   要删除从当前位置要下一个单词的开始： `dw`

另外名词前也能加入数字，如：

-   向上三行： `3k`
-   复制左两个字符： `y2h`
-   删除后两个单词： `d2w`
-   要修改下两行： `c2j`

在绝大部分的文本操作中，都是对整个一行进行修改。可以通过两个连续的动词，对一行进行操作，如：

```text
yy    Yank one line
dd    Delete one line
cc    Change one line
```

# More Nouns (Text Objects)

Text Objects 是用来对一些封闭符号进行操作的名词，典型的封闭符如 `()` ， `{}` 等。将封闭符号称为 `object` ，Text Objects 的格式为：

```text
i + object    Inner text object
a + object    Outer text object
```

其中 `i` 表示操作的对象不包括封闭符号， `a` 表示包括封闭符号。

在使用 Text Objects 前同样需要加入动词，如有以下的字符：

```jsx
const hello = function() {
  console.log("Hello Vim");
  return true;
}
```

首先将光标的移动到 `Hello` 的 `H` 上 ，并使用的 Text Objects 例子如下：

-   删除 `Hello Vim`，使用 `di(`
-   删除 `"Hello Vim"` ，使用 `da(`
-   删除 `Hellow` ，使用 `diw`
-   删除整个 `{}` 中的内容，使用 `di{`

常用的 `objects` 如下所示：

```text
w         A word
p         A paragraph
s         A sentence
( or )    A pair of ( )
{ or }    A pair of { }
[ or ]    A pair of [ ]
< or >    A pair of < >
t         XML tags
"         A pair of " "
'         A Pair of ' '
`         A pair of ` `
```

```ad-tip
更多的内容，见 :h text-objects
```

```ad-note
插件 vim-textobj-user 可以自定义 text-objects
```

# Composability and Grammar

Vim 的语法有可组合性，如可以将一系列常用的 Command 组合成更复杂的 Commands。

Vim 可以通过 `!` 关键字调用命令行的其他程序。如有以下字符，通过命令 `!}column -t-s "|"`：
```text
Id|Name|Cuteness
01|Puppy|Very
02|Kitten|Ok
03|Bunny|Ok
```

可变为如下的字符：
```text
Id  Name    Cuteness
01  Puppy   Very
02  Kitten  Ok
03  Bunny   Ok
```

其中 `!` 为 filter operator， `}` 表示跳转到下一个段落， `column -t-s` 为外部命令行指令。

```ad-fail
在 Windows 下 Powershell 不包含 column 命令，因此这一部分未做测试。
```