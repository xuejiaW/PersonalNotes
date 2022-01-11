---
tags: 
    - Obsidian
created: 2022-01-09
updated: 2022-01-12
---

# Tag

tag 标识的示例如下：
```
#Documentation 
```

所有的 Tag 会在 [Tag Pane](Obsidian%20-%20Plugins.md#Tag%20Pane) 中展示。

Tag 中并不支持输入空格，因此当需要输入空格，可以使用如下的三种方式替代：
- 驼峰命名: `#TwoWords`
- 下划线: `#two_words`
- 破折号: `#two-words`


同时 Obsidian 也支持 Yaml  形式的 Tag：
```
---
tags:
    - Documentation
---
```

```ad-warning
使用 YAML 形式的 Tag 时，不能再输入 `#`，否则无法被正确的识别为 Tag。
使用 YAML 形式的 Tag 时，Obsidian 也不能在输入时自动补全 Tag
```