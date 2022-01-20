---
tags: 
    - Obsidian
created: 2022-01-05
updated: 2022-01-06
---

在 `.md` 文件的最上方，可以通过 `---` 记录 metedata 数据，格式如下：
```
---
key: value
key2: value2
key3: [one, two, three]
key4:
- four
- five
- six
---
```

[Plugins](Plugins.md)

# Alias

Alias 用来标明一个页面的别名，如下：
```
// File : Visual Studio Code

---
Alias: VSCode
---
```

此时 `Visual Studio Code` 被设置了别名 `VSCode`，在其他页面中输入的 `VSCode` 也同样会被认为是与 `Visual Studio Code` 产生了关联，如下所示：
![](assets/Obsidian%20-%20MetaData/image-20211122094352377.png)
