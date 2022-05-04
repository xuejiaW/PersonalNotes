`.` 操作符会重复上一次的改动（Change）。对于 Vim 而言，任何对现有 Buffer 的修改，删除，新增都属于改动。但通过命令行（即 `:` ）造成的变换不算在改动内。

# Usage

通过如下的例子说明 `.` 的用法：

## Example 1
有以下的文本：

```json
let one = "1";
let two = "2";
let three = "3";
```

想要将 `let` 全部替换为 `const` ，可以使用以下步骤
1.  使用 `/let` 搜索跳转
2.  使用 `cwconst<Esc>` 将 `let` 替换为 `const`
3.  使用 `n` 跳转到下一个搜索结果
4.  使用 `.` 重复操作（即将 `let` 替换为 `const`）
5.  使用 `n.n.` 替换所有单词。

对于该例子，还有一个更高效的做法是利用 `gn` 操作符：

1.  使用 `/let` 搜索跳转
2.  使用 `cgnconst<Esc>` 将 `let` 替换为 `const`
3.  使用 `.` 重复操作（即将 `let` 替换为 `const`并跳到并选中下一个搜索结果）

```ad-note
`gn` 的含义为跳转加选中下一个匹配对象
```

## Example 2
```json
pancake, potatoes, fruit-juice,
```

想要从当前光标位置删除直到 `,`，可以使用 `df,` 然后运行 `.` 。

## Example 3
```json
pancake, potatoes, fruit-juice,
```

对于同样的字符串，如果想要删除其中所有的 `,` 而不改动单词。需要先 `f,` 跳转到 `,` 上，再 `x` 删除逗号。之后运行 `;.;.` ，其中 `;` 重复 `f,` 的操作， `.` 重复 `x` 的操作。

## Example 4

```json
pancake
potatoes
fruit-juice
```

想要在每一行后添加一个逗号，可以运行 `A,<Esc>j` ，其中只有 `A,` 是 Change 操作。因此之后首先需要通过 `j` 进入下一行，再运行 `.` 。