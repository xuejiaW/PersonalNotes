---
tags:
    - C#
created: 2022-02-08
updated: 2022-03-02
---

# Code Snippets

## Enumerable.Range

`Enumerable.Range(int start, int count)` 返回 `IEnumerable<int>` 类型的容器，其中元素为$[start, start+count)$。

如下创造的容器内的数值为 $4,5,6$：
```csharp
var list = Enumerable.Range(4, 3);
```

## Enumerable.Repeat

创建具有相同元素的容器，如下例子中创建了大小为 $100$，所有元素值为 $1.0$ 的数组：
```csharp
float[] itemSizeArray = Enumerable.Repeat(1.0f,100).ToArray();
```

当使用 `Repeat` 创建引用类型的数据时，容器中所有的元素都指向相同的引用地址。

如下操作，虽然只修改了容器的第一个元素，但因为所有元素都指向相同的引用地址，所以容器内的所有元素的值都发生了改变：
```csharp
public class Data
{
    public float size = 0;
}

List<Data> dataList = Enumerable.Repeat(new Data(),10).ToList();
dataList[0].size = 1;
```

如果要创造深度拷贝的具有相同数值的引用类型的元素容器，可使用 [Enumerable Range](#Enumerable%20Range) 实现，如下所示：
```csharp
List<Data> dataList = Enumerable.Range(1,10).Select(i => new Data()).ToList();
```

## Take

从容器开端取 x 个元素，如下：
```csharp
var firstThreeItems = itemSizeArray.Take(3);
```

## Skip

从容器开端跳过 x 个元素，如下：

```csharp
var forthFifthItems = itemSizeArray.Skip(3).Take(2);
```

## Sum

元素求和：
```csharp
float sum = itemSizeArray.Sum();
```

## Any



