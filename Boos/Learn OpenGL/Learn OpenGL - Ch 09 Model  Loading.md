---
created: 2021-12-15
updated: 2021-12-22
cssclass: [table-border]
---

# Assimp 编译

 [Assimp](http://assimp.org/index.php) 是一个用于导入模型资源的开源库，与在 [Creating a Window](Learn%20OpenGL%20-%20Ch%2000%20Creating%20a%20Window.md) 中生成 GLFW 库一样，这里需要通过源码和 `CMake` 编译出需要用到的 dll 和 lib。

```ad-error
从 [Assimp官网](http://assimp.org/index.php) 下载的源码（4.0.3版本），会存在编译问题 ，因此建议从 Github 上直接下载最新代码
```

首先从 Assimp Github 页面上下载最新代码，然后在工程文件夹中通过 CMake 编译出需要的 MinGW 源文件：

![|500](assets/Learn%20OpenGL%20-%20Ch%2008%20Model%20%20Loading/Untitled.png)

```ad-tip
测试时使用的 Github 仓库最新 Commit ID 为 96d0524fab2173a4198f12cd
```

进入生成的 `Build` 文件夹，并运行 `mingw32-make` 命令编译出需要的 dll 和 lib。当编译完成后，从 `Build/bin` 文件夹中的 `libassimp.dll` 和 `Build/lib` 文件夹中的 `libassimp.dll.a` 即为需要的资源。

将 `libassimp.dll.a` 和 `libassimp.dll` 拷贝到工程的 `lib` 文件夹下，将 `libassimp.dll` 拷贝到 `bin` 文件夹下，此时两个文件夹中的文件如下所示：

|                                                                       |                                                                       |
| --------------------------------------------------------------------- | --------------------------------------------------------------------- |
| ![](assets/Learn%20OpenGL%20-%20Ch%2008%20Model%20%20Loading/Untitled%201.png) | ![](assets/Learn%20OpenGL%20-%20Ch%2008%20Model%20%20Loading/Untitled%202.png) |

在编译的 Makefile 中的 `LIBRARIES` 加上新的 assimp ，即：

```csharp
LIBRARIES    := -lglad -lglfw3dll -lassimp # Add Lib file
```

# Assimp 数据结构

Assimp 将不同的模型数据（如 `fbx` , `obj` ）都加载为 Assimp 定义的数据结构，如下所示：
![](assets/Learn%20OpenGL%20-%20Ch%2008%20Model%20%20Loading/Untitled%203.png)

- `aiScene` 中包含了一个 `RootNode` ，一个 `aiMesh` 数据的数组，一个 `aiMaterial` 数据的数组。
- 每个 `aiNode` 数据中包含了一个子 `aiNode` 的数组，和一个 `aiMesh` 数据的 Index 的数组（即 `int` 数组）。
- `aiMesh` 数据中包含了顶点，法线， `Indices` 等一系列数据，以及 `aiMaterial` 数据的 Index。
- `aiMaterial` 数据中包含一系列纹理源数据的地址，即图片文件的地址。

```ad-note
真正的数据包含在 aiScene 中， 在 aiNode 或 aiMesh 中存储的只是数据的 Index，需要根据该 Index 去 aiScene 中读取真实数据。
```

# 加载 Assimp 数据

加载 Assimp 数据的思路是从 `aiScene` 出发，先解析 `RootNode` 。对于每个 `aiNode` 而言，先解析其中的每个 `aiMesh` ，然后递归解析它的子结点 `Children` 。在解析 `aiMesh` 的过程中，会需要装填一系列顶点数据数据，并解析其中的 `aiMaterial` ，根据 `aiMaterial` 中读取的图片地址，加载纹理等。

为了适配 [Framework](Learn%20OpenGL%20-%20Ch%2008%20Framework.md)，这里将整个 Assimp 数据封装在 `Model` 类中， `Model` 类继承自 `GameObject` ，因此可以直接被添加到场景中。

-   在 `Model` 类中有一个 `MeshRender` 的数组，Assimp 数据中的每个 `aiMesh` 最终都会被解析为一个 `MeshRender` 。其中`aiMesh` 中的顶点相关数据会被装填到 `MeshRender` 的 `Mesh` 中， `aiMaterial` 中的纹理都会被解析到 `MeshRender` 的 `Material` 中。

```ad-note
每个 aiMesh 对应一个 MeshRender ，因此一个模型会有多个 MeshRender 。每个 MeshRender 中都包含自己的 Material ，但这些 Material 可以公用一个 Shader 。
```

整个流程的代码如下：

```cpp
Model::Model()
{
		...
    ProcessModelNode(scene->mRootNode, scene);
}

void Model::ProcessModelNode(aiNode *node, const aiScene *scene)
{
    for (unsigned int i = 0; i != node->mNumMeshes; ++i)
    {
        aiMesh *mesh = scene->mMeshes[node->mMeshes[i]]; // Get actual mesh data from scene
        MeshRender *meshRender = new MeshRender(usingShader);
        ProcessModelMesh(meshRender, mesh, scene);
        meshRenderLists.push_back(meshRender);
    }

    // Recursively process children node
    for (unsigned int i = 0; i != node->mNumChildren; ++i)
    {
        ProcessModelNode(node->mChildren[i], scene);
    }
}

void Model::ProcessModelMesh(MeshRender *meshRender, aiMesh *aiMesh, const aiScene *scene)
{
    LoadVertexData(meshRender, aiMesh, scene);
    LoadTexturesData(meshRender, aiMesh, scene);
}
```

## 加载顶点数据

Assimp 中将顶点数据都存储在 `aiMesh` 的不同数组中，将这些数据一一读出并装填进 `Mesh` 中即可，整个流程代码如下：

```cpp
void Model::LoadVertexData(MeshRender *meshRender, aiMesh *aiMesh, const aiScene *scene)
{
    std::vector<Vertex> vertices;
    std::vector<unsigned int> indices;

    // Load Vertex Data
    for (unsigned int i = 0; i != aiMesh->mNumVertices; ++i)
    {
        Vertex vertex;
        vertex.Position.x = aiMesh->mVertices[i].x;
        vertex.Position.y = aiMesh->mVertices[i].y;
        vertex.Position.z = aiMesh->mVertices[i].z;

        if (aiMesh->mTextureCoords[0])
        {
            // A Vertex may contain multiply texture coordinates, here we only use the first one
            vertex.TexCoord.x = aiMesh->mTextureCoords[0][i].x;
            vertex.TexCoord.y = aiMesh->mTextureCoords[0][i].y;

            vertex.Tangent.x = aiMesh->mTangents[i].x;
            vertex.Tangent.y = aiMesh->mTangents[i].y;
            vertex.Tangent.z = aiMesh->mTangents[i].z;

            vertex.Bitangent.x = aiMesh->mBitangents[i].x;
            vertex.Bitangent.y = aiMesh->mBitangents[i].y;
            vertex.Bitangent.z = aiMesh->mBitangents[i].z;
        }

        if (aiMesh->HasNormals())
        {
            vertex.Normal.x = aiMesh->mNormals[i].x;
            vertex.Normal.y = aiMesh->mNormals[i].y;
            vertex.Normal.z = aiMesh->mNormals[i].z;
        }

        vertices.push_back(vertex);
    }

    // Load indices
    for (unsigned int i = 0; i != aiMesh->mNumFaces; ++i)
    {
        aiFace face = aiMesh->mFaces[i];
        for (unsigned int j = 0; j != face.mNumIndices; ++j)
            indices.push_back(face.mIndices[j]);
    }

    Mesh *mesh = new Mesh(vertices, indices);
    meshRender->SetMesh(mesh);
}
```

## 加载纹理数据

其中关于纹理的读取需要额外的说明。 Assimp 将模型的纹理分为不同的类型并各自管理，因此读取图片信息时，也需要指明不同的类型，如 `aiTextureType_DIFFUSE` 。

另外，读取图片信息时，还需要指定图片的 Index，且读到的信息是图片的相对与模型文件地址的相对地址，因此为了加载图片，首先需要记录下模型文件的目录地址。目的地址与相对地址的结合，才是图片素材真正的地址，即整个纹理的加载过程如下：

```cpp
void Model::LoadTexturesFromAIMaterial(aiMaterial *aMat, Material *material, aiTextureType type, string typeName)
{
    int textureCount = aMat->GetTextureCount(type);

    for (unsigned int i = 0; i != textureCount; ++i)
    {
        aiString textureStr;
        aMat->GetTexture(type, i, &textureStr);
        string texturePath = modelPathDirectory + "/" + string(textureStr.C_Str());

        Texture *texture = new Texture(texturePath);

        material->AddTexture(typeName + to_string(i), texture);
    }
}
```

考虑到整个模型有存在许多的 Mesh 实际上是共用纹理的，因此没必要对每个 Mesh 都重写加载它需要的纹理。可以将已经读取的纹理存储起来，仅当新需要的纹理未被读取过时才进行加载纹理，即：

```cpp
Texture *texture = new Texture(texturePath);

// Convert to: 

Texture *texture = NULL;
if (str2TextureMap.find(texturePath) != str2TextureMap.end())
{
    texture = str2TextureMap[texturePath];
}
else
{
    texture = new Texture(texturePath);
    str2TextureMap[texturePath] = texture;
}
```

# 结果与源码：

![](assets/Learn%20OpenGL%20-%20Ch%2008%20Model%20%20Loading/Untitled%204.png)

[main.cpp](https://www.notion.so/main-cpp-f28de83f9c3b4bb09805de058326acef)
[Model.cpp](https://www.notion.so/Model-cpp-4953a69e304f44f8a6b6d0c0116e58d7)
[ModelDefault.vs](https://www.notion.so/ModelDefault-vs-81e93a6c580d4b95b54e6245cf91b4b9)
[ModelDefault.fs](https://www.notion.so/ModelDefault-fs-5b59214a8d794ef480030ec5414a230a)