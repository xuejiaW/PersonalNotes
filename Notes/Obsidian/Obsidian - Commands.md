---
created: 2022-01-04
updated: 2022-01-05
tags:
    - Obsidian
---
# 获取命令列表

Obsidian 中开启 Vim 模式后，通过运行 `:obcommand`，再按下 `Ctrl + Shift + I` 打开 `Developer Console` 可以看到 Obsidian 定义的所有命令，如下所示。

# 命令列表

```text
editor:follow-link
editor:open-link-in-new-leaf
editor:focus-top
editor:focus-bottom
editor:focus-left
editor:focus-right
workspace:toggle-pin
workspace:split-vertical
workspace:split-horizontal
workspace:edit-file-title
workspace:copy-path
workspace:copy-url
workspace:undo-close-pane
workspace:export-pdf
editor:rename-heading
obsidian-admonition:collapse-admonitions
obsidian-admonition:open-admonitions
obsidian-admonition:insert-admonition
obsidian-minimal-settings:increase-body-font-size
obsidian-minimal-settings:decrease-body-font-size
obsidian-minimal-settings:toggle-minimal-dark-cycle
obsidian-minimal-settings:toggle-minimal-light-cycle
obsidian-minimal-settings:toggle-hidden-borders
obsidian-minimal-settings:toggle-minimal-focus-mode
obsidian-minimal-settings:cycle-minimal-table-width
obsidian-minimal-settings:cycle-minimal-image-width
obsidian-minimal-settings:cycle-minimal-iframe-width
obsidian-minimal-settings:toggle-minimal-img-grid
obsidian-minimal-settings:toggle-minimal-switch
obsidian-minimal-settings:toggle-minimal-light-default
obsidian-minimal-settings:toggle-minimal-light-white
obsidian-minimal-settings:toggle-minimal-light-tonal
obsidian-minimal-settings:toggle-minimal-light-contrast
obsidian-minimal-settings:toggle-minimal-dark-default
obsidian-minimal-settings:toggle-minimal-dark-tonal
obsidian-minimal-settings:toggle-minimal-dark-black
open-vscode:open-vscode
quick-explorer:browse-vault
quick-explorer:browse-current
sliding-panes-obsidian:toggle-sliding-panes
sliding-panes-obsidian:toggle-sliding-panes-smooth-animation
sliding-panes-obsidian:toggle-sliding-panes-leaf-auto-width
sliding-panes-obsidian:toggle-sliding-panes-stacking
sliding-panes-obsidian:toggle-sliding-panes-rotated-headers
sliding-panes-obsidian:toggle-sliding-panes-header-alt
table-editor-obsidian:next-row
table-editor-obsidian:next-cell
table-editor-obsidian:previous-cell
table-editor-obsidian:format-table
table-editor-obsidian:format-all-tables
table-editor-obsidian:insert-column
table-editor-obsidian:insert-row
table-editor-obsidian:escape-table
table-editor-obsidian:left-align-column
table-editor-obsidian:center-align-column
table-editor-obsidian:right-align-column
table-editor-obsidian:move-column-left
table-editor-obsidian:move-column-right
table-editor-obsidian:move-row-up
table-editor-obsidian:move-row-down
table-editor-obsidian:delete-column
table-editor-obsidian:delete-row
table-editor-obsidian:sort-rows-ascending
table-editor-obsidian:sort-rows-descending
table-editor-obsidian:evaluate-formulas
table-editor-obsidian:table-control-bar
obsidian-git:open-git-view
obsidian-git:pull
obsidian-git:push
obsidian-git:commit-push-specified-message
obsidian-git:commit
obsidian-git:commit-specified-message
obsidian-git:push2
obsidian-git:edit-remotes
obsidian-git:remove-remote
obsidian-git:init-repo
obsidian-git:clone-repo
obsidian-git:list-changed-files
obsidian-emoji-toolbar:emoji-picker:open-picker
obsidian-pangu:pangu-format
app:go-back
app:go-forward
app:open-vault
theme:use-dark
theme:use-light
app:open-settings
markdown:toggle-preview
workspace:close
workspace:close-others
app:delete-file
app:toggle-left-sidebar
app:toggle-right-sidebar
app:toggle-default-new-pane-mode
app:open-help
app:reload
app:show-debug-info
file-explorer:new-file
file-explorer:new-file-in-new-pane
editor:open-search
editor:open-search-replace
editor:focus
editor:toggle-fold
editor:fold-all
editor:unfold-all
editor:insert-wikilink
editor:insert-embed
editor:insert-link
editor:insert-tag
editor:set-heading
editor:toggle-bold
editor:toggle-italics
editor:toggle-strikethrough
editor:toggle-highlight
editor:toggle-code
editor:toggle-blockquote
editor:toggle-comments
editor:toggle-bullet-list
editor:toggle-numbered-list
editor:toggle-checklist-status
editor:swap-line-up
editor:swap-line-down
editor:attach-file
editor:delete-paragraph
editor:toggle-spellcheck
file-explorer:open
file-explorer:reveal-active-file
file-explorer:move-file
global-search:open
switcher:open
graph:open
graph:open-local
graph:animate
backlink:open
backlink:open-backlinks
backlink:toggle-backlinks-in-document
tag-pane:open
note-composer:merge-file
note-composer:split-file
note-composer:extract-heading
command-palette:open
markdown-importer:open
random-note
outline:open
outline:open-for-current
open-with-default-app:open
open-with-default-app:show
workspaces:load
workspaces:save-and-load
workspaces:open-modal
file-recovery:open
editor:toggle-source
```

# Reference

[^1]: [Obsidian Vim rc support](https://github.com/esm7/obsidian-vimrc-support)