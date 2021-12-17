简单来说，立方体贴图就是一个包含了6个2D纹理的纹理，每个2D纹理都组成立方体的一个面。

# 创建立方体贴图

创建立方体贴图的方法与其他纹理一样，只不过绑定的纹理类型为 `GL_TEXTURE_CUBE_MAP`。

```glsl
glGenTextures(1, &id);
glBindTexture(GL_TEXTURE_CUBE_MAP, id);
```

因为立方体有6个面，所以需要调用 `glTexImage2D` 6次，每次对应立方体的一个面。对于用于装填立方体贴图的 `glTexImage2D` 的调用，其参数与装填普通纹理时类似，但需要将纹理目标设为立方体贴图特定的面。OpenGL提供了6个特殊的纹理目标，对应立方体贴图的每一个面：

| Texture Target                 | Orientation |
| ------------------------------ | ----------- |
| GL_TEXTURE_CUBE_MAP_POSITIVE_X | Right            |
| GL_TEXTURE_CUBE_MAP_NEGATIVE_X | Left            |
| GL_TEXTURE_CUBE_MAP_POSITIVE_Y | Top            |
| GL_TEXTURE_CUBE_MAP_NEGATIVE_Y | Right            |
| GL_TEXTURE_CUBE_MAP_POSITIVE_Z | Right            |
| GL_TEXTURE_CUBE_MAP_NEGATIVE_Z | Right            |