---
tags: Unity
created: 2022-02-18
updated: 2022-02-19
---

# Texture2D

## GetPiexles

`Texture2D.GetPixels` 返回纹理的所有像素数据，以 [Color](Color%20vs%20Color32.md#Color) 数组的形式返回。

### 数据失效

如果通过 GPU 修改了 Texture2D 的内容，如使用了 `Graphics.CopyTexture` 或将 Texture 作为 Native 的 Color Handle 进行了绘制，此时调用 GetPixels 得到的将是 GPU 更新前的像素数据。

如果需要获取 GPU 更新后的纹理像素，只能通过 [RenderTexture](#RenderTexture) 作为中间层，如下：
```csharp
Texture2D sourceTexture = Resources.Load<Texture2D>("cube_texture");
RenderTexture targetTexture = new RenderTexture(sourceTexture.width, sourceTexture.height, 0);
targetTexture.Create();

Graphics.CopyTexture(sourceTexture, targetTexture);

RenderTexture currentActive = RenderTexture.active;
RenderTexture.active = targetTexture;
Texture2D temp = new Texture2D(sourceTexture.width, sourceTexture.height);
temp.ReadPixels(new Rect(0, 0, sourceTexture.width, sourceTexture.height), 0, 0);
temp.Apply();
```

此时 `temp` 中包含有更新后的像素数据。

# RenderTexture