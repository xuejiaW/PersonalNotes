混合是在OpenGL中实现物体透明度的一种技术。

透明物体指的是一个非纯色的物体，在他后面的物体的颜色将会叠加到他上面，比如窗子就是一种透明物体，窗子会将他后面的物体的颜色叠加在他上面。所以将其称为混合（混合多个物体的颜色）。

透明物体分为全透明和半透明，全透明物体所有的颜色都来自其背后的物体，半透明物体的颜色则是背后物体的颜色和自身的颜色叠加。

颜色的第四个参数Alpha设为1，这表示为不透明物体，为0则是全透明，0-1之间为半透明，alpha值为0.5意味这个物体最终显示的颜色，一半来自于自身，一般来自于它背后的物体。

# 丢弃片段

对于不透明物体，首先要确保其 Alpha值被正确的加载，即对于不带有透明通道的物体，使用 `GL_RGB` ，对于带有透明通道的物体，使用 `GL_RGBA` 。

```cpp
int nrChannels = 0;
unsigned char *data = stbi_load(texturePath.c_str(), &width, &height, &nrChannels, 0);
...
glTexImage2D(GL_TEXTURE_2D, 0, nrChannels == 3 ? GL_RGB : GL_RGBA, width, height, 0, nrChannels == 3 ? GL_RGB : GL_RGBA, GL_UNSIGNED_BYTE, data);
```

因为OpenGL默认不知道如何处理alpha值的，因此直接渲染带有Alpha通道的物体，其透明部分会显示为白色。
![|300](assets/LearnOpenGL-Ch%2017%20Blending/Untitled.png)