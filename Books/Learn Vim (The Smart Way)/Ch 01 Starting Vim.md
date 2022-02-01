---
created: 2022-01-20
updated: 2022-01-20
---
可以在命令行中通过 `nvim` 打开 Neovim

# Saving a File

通过 `:quit` 或 `:q` 推出打开的 Neovim。

通过 `:write` 或 `:w` 保存修改的内容。如果是一个新的内容，需要为其增加保存的文件名，如：

```powershell
 :w ~\\Desktop\\Target.txt
```

如果需要在保存的同时关闭文件，使用命令 `:wq` 。如果需要关闭文件但不保存文件，使用命令 `:q!`

# Help

在打开的 Neovim 中可以通过 `:help` 或 `:h` 打开帮助文档。在命令后可以加上需要查找的部分，如 `:h write-quit` ，此时的效果如下：

![](assets/Ch%201%20Starting%20Vim/image-20211129093429994.png)

```ad-fail
在 VSCode 的 Neovim 插件中，通过 `:help` 命令只能打开帮助文件，但并不会跳转到对应的部分。
```

# Opening a File

可以通过如 `nvim <filePath>` 打开文件，也可以通过 `nvim <filePath> <filePath2>` 打开多个文件。

在 `nvim` 后跟着 `+` 再进一步跟着指令，格式为： `nvim +<Cmd> <filePath>` 。如以下命令可以将 `vim.txt` 中所有的 `abc` 文本替换为 `def` 。其中的 `%s` 表示命令 `substitute`：

```powershell
nvim +%s/abc/def/g vim.txt
```

```ad-note
`+` 可以替换为 `-c` 。如上述命令等效为： `nvim -c %s/abc/def/g vim.txt`
```


多条命令也可以级联，如以下命令是将 `abc` 替换为 `def` ，再将结果中的 `def` 替换为 `ghi` ：

```powershell
nvim +%s/abc/def/g +%s/def/ghi/g vim.txt
```

在打开了文件后，可以在 Vim 中通过 `:edit <filePath>` 进一步打开其他的文件。

# Opening Multiple Windows

在 `nvim` 命令后，可以加上 `o` 或 `O` 分别表示水平和垂直方向的切割：

如通过命令 `nvim -o5` 打开五个水平切割的窗口，效果如下：
![](assets/Ch%201%20Starting%20Vim/image-20211129093632484.png)


此时运行 `:q!` 会自上而下的关闭窗口，如果要一次性关闭所有的窗口，可通过 `:qall!` 。

同样可以在后续加上需要打开的文件，如 `nvim -o5 .\\vim.txt .\\TestText.txt` ，此时会在最上两个窗口分别打开 `vim.txt` 和 `TestText.txt` 。

# Suspending

可以通过 `:stop` 或 `:suspend` 暂时关闭 Vim，在后续通过 `fg` 回到暂停的 Vim。

```ad-fail
在 Windows Terminal 和 Neovim 的环境下， suspending 指令无用。 不确定是执行方式问题，还是 Windows Terminal 和 Neovim 存在 Bug
```

# Starting Vim the Smart Way

可以在命令行中通过 `|` 将其他命令执行的结果通过 Vim 编辑或保存，如：

```powershell
ls | nvim
```

此时的效果如下：
![](assets/Ch%201%20Starting%20Vim/image-20211129093712000.png)
