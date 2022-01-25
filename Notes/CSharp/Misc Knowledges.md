# 支持隐式和显式类型转换

```csharp
public class Shape{ ... }
public class ShapeInstance
{
		public ShapeInstance(Shape shape){...}

		public static implicit operator ShapeInstance(Shape shape)
		{
				return new ShapeInstance(shape);
		}
}
```

上述实现了 `Shape` 到 `ShapeInstance` 的显示和隐式转换，如果要仅支持显示转换的话，将上述代码中的 `implicit` 改为 `explicit` 即可。

```ad-note
Unity 中的 `Vector3` 和 `Vector2` 之间的转换就是使用这种方式。
```

# 操作符

## ??=

一个变量如果为空，则等于 `??=` 操作符后的数值：

```csharp
propertyBlock ??= new MaterialPropertyBlock();
```

```ad-tip
c# 8.0 支持
```
