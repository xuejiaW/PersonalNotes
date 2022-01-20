`宏(Macro)` 是用来记录一系列的操作，然后 Vim 可以回放这些操作，以此来减少重复操作的执行。

# Basic Macros

通过 `q` 可以开始记录和停止记录 Register， `Macro` 可以被存储在 `a-z` Register 中：

```
qa                     Start recording a macro in register a
q (while recording)    Stop recording macro
```

后续可以通过 `@a` 执行 a Register 中的 Macro，也可以通过 `@@` 执行上一次执行过的 Macro：

```
@a    Execute macro from register a
@@    Execute the last executed macros
```

如有以下的字符串：

```
hello
vim
macros
are
awesome
```

将光标移动到 `hello` 所在行，然后执行 `qa0gU$jq` ，该宏会将一行的内容全部替换为大写，拆分开来看：

1.  `qa` 表示开始录制宏，并将宏内容放在 Register a 中
2.  `0` 将光标移动到行的开始
3.  `gU$` 将字符调整为大写，直到行的末尾
4.  `j` 移动到下一行
5.  `q` 结束宏的录制

要重复该宏的操作，执行 `@a` 即可。

# Safety Guard

Macro 的执行会在发生一个错误后自动停止。

如有以下的字符串：

```
a. chocolate donut
b. mochi donut
c. powdered sugar donut
d. plain donut
```

使用宏 `qa0W~jq` 会每一行的第一个单词大写，拆分开来看：

1.  `qa` 表示开始录制宏，并将宏内容放在 Register a 中
2.  `0` 将光标移动到行的开始
3.  `W` 移动到下一个单词
4.  `~` 切换光标下的字符的大小写
5.  `j` 移动到下一行
6.  `q` 结束宏的录制

如果在录制完 Macro 后，执行 `99@a` ，Vim 并不会真正的将宏执行 99 次，当 Vim 运行到最后一行后再执行 `j` 就会产生错误，此时宏的执行就结束了。

# Command Line Macro

可以在 Vim 的命令行中，通过 `:normal @a` 执行 a Register 中的 Macro，该命令就相当于从 Normal 模式下执行 `@a` 。

也可以在 `:normal` 中加入执行的范围，如 `:2,3 normal @a` 表示在行 2，3 中执行 `@a` 。

# Series vs Parallel Macro

如有以下文本：

```
import { FUNC1 } from "library1";
import { FUNC2 } from "library2";
import { FUNC3 } from "library3";
import { FUNC4 } from "library4";
import { FUNC5 } from "library5";
```

通过命令录制可以将 `{}` 内文本变换为小写的 Macro： `qa0f{gui{jq` ，命令可拆分为：

1.  `qa` 表示开始录制宏，并将宏内容放在 Register a 中
2.  `f{` 将光标跳转到 `{` 上
3.  `gui}` 将 `{}` 中的内容改为小写
4.  `j` 移动到下一行
5.  `q` 结束宏的录制

此时可以通过 `99@a` 反复执行 Macros，将所有行的 `{}` 中的内容都变为小写。

而如果文本为如下所示，则 `99@a` 会在第四行因为错误而停止：

```
import { FUNC1 } from "library1";
import { FUNC2 } from "library2";
import { FUNC3 } from "library3";
import foo from "bar";
import { FUNC4 } from "library4";
import { FUNC5 } from "library5";
```

为了解决这个问题，可以通过命令行执行 Macro，如 `:1,$ normal @a` 表示对从第一行到最后一行的所有行执行 `@a` 。此时除了第四行，其他行都正常的将 `{}` 中的内容变为了小写。

之所以 `99@a` 无法完成理想的效果，而 `1,$ normal @a` 可以完成，是因为前者为 顺序执行（Serials） Macros，即逐行的执行 Macro，当遇到错误即停止运行。而 `1,$ normal @a` 是并行执行，即对每一行同时执行 Macro，因此即使第四行发生了错误，其他行也正常的运行 Macros。:

# Executing a Macro Across Multiple Files

可以通过 `:args**.txt`* 从当前的目录下查找所有的 `.txt` 文件，并通过 `:argdo g/donut/normal @a` 在之前查找到的文件中查找内容 `donut` ，并在查找到的行，执行 `normal @a` 。

# Recursive Macro

Macro 中也可以包含执行 Macro 本身，依次达到一个递归执行的效果。

如有以下字符串：

```
a. chocolate donut
b. mochi donut
c. powdered sugar donut
d. plain donut
```

录制 Macro `qaqqa0W~j@aq` ，并执行技能将所有行的第一个单词变为大写，拆解来看：

1.  `qaq` 在 a Register 中录制了一个空的 Macro。该操作主要是为了避免 Register 中包含有之前记录的数据或信息，导致递归调用 Macro 时产生意料之外的情况发生。
2.  `qa` 表示开始录制宏，并将宏内容放在 Register a 中
3.  `0` 将光标移动到行的开始
4.  `W` 移动到下一个单词
5.  `~` 切换光标下的字符的大小写
6.  `j` 移动到下一行
7.  `@a` 执行 Register a 中的命令
8.  `q` 结束宏的录制

上述命令的关键在于 第二步和 第七步，即将宏定义在 a Register 中，并自身调用存储在 a Register 中的命令。

该 Macro 会重复的递归调用自己，即宛如一个死循环，直到遇到一个错误位置。如运行到最后一行，此时再执行 `j` 就会产生错误， Macro 就会停止。

# Appending a Macro

在 [Ch 08 Registers](Ch%2008%20Registers.md) 中可以通过 `A-Z` 对 `a-z` Register 中的内容进行增加，而非覆盖。在使用 Macro 时有一样的逻辑。

如先通过以下指令在 a Register 中存储一段宏 `qa0W~q` 。之后想在该 Macro 中加入跳转到行最后，并插入 `.` 的操作，可以使用命令 `qAA.<Esc>q` ，该拆分来看：

1.  `qA` 表示后续的录制会添加到 Register a 中而非覆盖 a 中内容
2.  `A.` 调试跳转到行的末尾，并进入输入模式，并输入 `.`
3.  `<Esc>` 表示退出到 Normal 模式
4.  `q` 表示结束录制。

```ad-note
步骤中的 `<Esc>` 表示按下 `Esc` 键，并非是 输入 `<Esc>`
```

```ad-note
注意区分上述步骤 1 和 2 中的 A， 步骤 1 中的表示添加到 Register A 中，步骤 2 中的表示插入到行末尾
```

# Amending a Macro

因为 Macro 存储在 Register 中，因此如果修改了 Register 中内容，就相当于修改了 Macro。

如通过命令 `qaAabc<Esc>q` 将 Macro 存储在 Register a 中，如果此时运行 `"ap` 即将 a Register 中的内容拷贝出来，就能看到输出为 `Aabc^[` 其中 `^[` 为 Esc 键在 Vim 中的内部表示。

如果在输出的 `Aabc^[` 后加入内容 `0gU$` ，然后将整个文本即 `Aabc^[0gU$` 通过 `0"ay$` 拷贝进 Register a 中，并再次执行 `@a` 就会发现 a 中的 Macro 变成在行尾输入 `abc` 并将其调整为大写。

如果在补充 Macro 时需要加入如 `^[` 这样的内部指令，可以通过在输入模式下按下 `Ctrl-V` 或 `Ctrl-Q` 并按下需要代表的按键，这样 Vim 会自动输入需要的内部指令。 如在输入模式下， `Ctrl-Q <Esc>` 就会插入 `^[`

```ad-error
^[` 在 VSCode + Neovim 中显示为乱码，且输入模式下的 `Ctrl-V` 或 `Ctrl-Q` 也不支持，手动输入 `^[` 也不支持。因此在 VSCode + NeoVim 中无法输入代表按键的内部指令。
```

# Macro Redundancy

如果需要将一个 Macro 从一个 Register 拷贝到另一个 Register 中，如将 a Register 中的 Macro 拷贝到 z Register 中，可以通过如下的命令 `:let @z = @a` 。此时执行 `@z` 的效果就如同执行 `@a` 。

对于一些一直要使用到的 Macro，可以将其拷贝到比较靠后的 Register 中，如 z, y。避免之后的录入 Macro，意外想需要的 Macro 给覆盖掉。