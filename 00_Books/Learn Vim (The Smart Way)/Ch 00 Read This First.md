# Why This Guide Was Written

通常而言， `vimtutor` 是一个开始学习 Vim 地方，而 `:help` 包含了 Vim 需要的一切。

但对于大部分学习 Vim 的人而言， `vimtutor` 太过于简单，而 `:help` 太过于复杂。而这本书就是处于两者中间的状态。

```ad-note
这本书并不会 100% 的讲解 Vim 的所有特性，大约只会覆盖 20% 。但这 20% 是作者认为最有用的部分，且作者认为这 20% 足够让人成为一个强大的 Vimmer。
```

# Init.vim

Neovim 依赖的配置文件在 Windows 平台下路径为：

```powershell
 C:\\Users\\<user>\\AppData\\Local\\nvim\\init.vim 
```

在每次 Neovim 重开的情况下，会重新读取配置文件。如果想要在不重开 Neovim 的情况下让配置文件，可通过 `source` 命令刷新，如：

```powershell
:source C:\\Users\\<user>\\AppData\\Local\\nvim\\init.vim
```

可以将该路径配置为系统变量，如 `VimConfig` 后续通过系统环境进行访问：

```powershell
:source $VimConfig$
```