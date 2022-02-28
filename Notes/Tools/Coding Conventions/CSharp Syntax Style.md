---
tags: Coding-Conventions
created: 2022-03-01
updated: 2022-03-01
---

# Code body

`Code body`  是针对函数体的设置

## Property, indexers

更倾向于使用 `Expression body` 形式。

### Do

```csharp
    private int PropertyA
    {
        get => field;
        set => field = value;
    }

    private int PropertyB => field;

    private int this[int i]
    {
        get => array[i];
        set => array[i] = value;
    }
```


可以选择更倾向于使用 `Block body` 的风格，还是 `Expression body` 的风格。

