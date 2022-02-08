---
tags:
    - C#
created: 2022-02-08
updated: 2022-02-08
---

# Code Snippets

## Repeat

创建具有相同元素的容器，如下例子中创建了大小为 $100$，所有元素值为 $1.0$ 的数组：
```csharp
float[] itemSizeArray = Enumerable.Repeat(1.0f,100).ToArray();
```

## Take

从容器开端取 x 个元素，如下：
```csharp
var firstThreeItems = itemSizeArray.Take(3);
```

## Skip

从容器开端跳过 x 个元素，如下：

```csharp
var forthFifthItems= itemSizeArray.Skip(3).Take(2);
```

## Sum

元素求和：
```csharp
float sum = itemSizeArray.Sum();
```