---
created: 2021-12-21
updated: 2021-12-21
---
默认在 Framebuffer 中，亮度和颜色都会被 Clamp 到 $0.0 \sim 1.0$ 的范围中，这就会导致当多个光源的亮度叠加，且总亮度大于 $1.0$ 时，都会被 Clamp 到 $1.0$ ，即都显示为白色，这样就丢失了大量的信息。

`High Dynamic Range(HDR)` 的思路就是临时让亮度和颜色的范围大于 $1.0$，保留各种光亮信息，然后再通过后处理将其转换到 `Low Dynamic Range(LDR)` ，即 $0.0 \sim 1.0$ 的范围。将图像数值从 `HDR` 转换到 `LDR` 的过程称为 `Tone Mapping`，有各种不同的 `Tone Mapping` 算法，它们的目的都是在转换过程中尽量的保有更多的信息。

```ad-tip
无论是 OpenGL 默认的 Clamp 还是自定义的 `Tone Mapping` 算法，都是将图像数值从 `HDR` 转换到 `LDR` 。只不过 `Tone Mapping` 算法目的是在转换过程中尽可能多的保留有信息。
```

```ad-note
在实时渲染中， `HDR` 的存在让光源可以以其真实的强度被设置，如太阳的亮度可以被设置为 $100$，而普通灯泡的亮度设置为 $0.1$。在没有 `HDR` 的情况下，为了避免过量的光源造成场景一片白，只能降低光源的亮度，但这也就破坏了光照模型的物理真实性。
```

# Floating Point Framebuffers

使用 `HDR` 的思路为先将整个场景渲染到自定义的 Framebuffer 上，再通过 [后处理](Learn%20OpenGL%20-%20Ch%2019%20Framebuffers.md#后处理) 将自定义 Framebuffer 上的颜色附件绘制到默认的 [Default Framebuffer](https://www.notion.so/Default-Framebuffer-67987f4758d74b9ab4548a819800f2c9) 上，在这个绘制过程中使用 `Tone Mapping` 算法将画面从 `HDR` 转换到 `LDR` 。