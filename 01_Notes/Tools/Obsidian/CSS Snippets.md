---
tags: 
    - Obsidian
created: 2021-12-20
updated: 2022-02-01
---


# 设置

通过路径 `Settings/Appearance/CSS snippets` 设置自定义的 CSS Snippet，所有自定义的文件需要放在目录 `/.obsidian/snippets` 下

# Custom Snippets

## Table Border

实现不显示表格边框的效果：

```css
.table-border {
    --background-modifier-border: none;
}
```

对于要删除表格线条的文件，需要在文件的最上方通过 `yaml` 加入 `CSS Class` 的表示：
```yaml
---
cssclass: [table-border]
---
```

## Heading

为标题增加颜色及调整标题的大小：
```css
.theme-dark
{
    --text-title-h1:              var(--red);
    --text-title-h2:              var(--orange);
    --text-title-h3:              var(--yellow);
    --text-title-h4:              var(--green);
    --text-title-h5:              var(--purple);
    --text-title-h6:              var(--orange);
}

.cm-header-1,
.markdown-preview-section h1
{
    font-weight: 500 !important;
    font-size: 2.2em !important;
    color: var(--text-title-h1) !important;
}

.cm-header-2,
.markdown-preview-section h2
{
    font-weight: 500 !important;
    font-size: 2.0em !important;
    color: var(--text-title-h2) !important;
}

.cm-header-3,
.markdown-preview-section h3
{
    font-weight: 500 !important;
    font-size: 1.8em !important;
    color: var(--text-title-h3) !important;
}

.cm-header-4,
.markdown-preview-section h4
{
    font-weight: 500 !important;
    font-size: 1.6em !important;
    color: var(--text-title-h4) !important;
}

.cm-header-5,
.markdown-preview-section h5
{
    font-weight: 500 !important;
    font-size: 1.4em !important;
    color: var(--text-title-h5) !important;
}

.cm-header-6,
.markdown-preview-section h6
{
    font-weight: 500 !important;
    font-size: 1.2em !important;
    color: var(--text-title-h6) !important;
}

```


## Folding Glutter

实现始终在预览模式和编辑模式下显示折叠块标识的效果，并调整标识的透明度：

```css
/* Always display folding glutter in preview mode */
.markdown-preview-view .heading-collapse-indicator.collapse-indicator svg,
.markdown-preview-view ol > li .collapse-indicator svg,
.markdown-preview-view ul > li .collapse-indicator svg {
    opacity: 0.5;
}

.markdown-preview-view .is-collapsed .collapse-indicator svg,
.markdown-preview-view .collapse-indicator:hover svg {
    opacity: 1;
}

/* Always display folding glutter in edit mode*/
.CodeMirror-foldgutter-folded:after,
.CodeMirror-foldgutter-open:after {
    opacity: 1;
}
```

## Image Caption

实现在图片下方显示说明的功能：
```css
.image-embed[alt]:after {
    content: attr(alt);
    display: block;
    margin: 0.2rem 1rem 1rem 1rem;
    font-size: 90%;
    line-height: 1.4;
    color: var(--text-faint);
}
```

如下所示：
![Obsidian Logo | 200](assets/Obsidian%20-%20CSS%20Snippets/image-20211207085006908.png)

## Image Centered

实现图片自动居中的功能：
```css
img {
    display: block;
    margin-left: auto;
    margin-right: auto;
}
```

## Table View Table

为 Dataview 的列表增加分割线：

```css
.table-view-table tr{

 border-bottom: 1px solid;

}
```