# 创建 Asset Bundle 脚本准备

Unity本身的界面中并没有创建Asset Bundle的按键，因此需要通过Editor脚步自定义按键。代码如下：

```csharp
using UnityEditor;
using UnityEngine;
using System.IO;

public class CreateAssetBundles
{
    [MenuItem("Assets/Build AssetBundles")]
    static void BuildAssetBundles()
    {
        string assetBundleDirectory = "Assets/StreamingAssets";
        if (!Directory.Exists(Application.streamingAssetsPath))
        {
            Directory.CreateDirectory(assetBundleDirectory);
        }
        BuildPipeline.BuildAssetBundles(assetBundleDirectory, BuildAssetBundleOptions.None, EditorUserBuildSettings.activeBuildTarget);
    }
}
```

其中最重要的函数为 `BuildPipeline.BuildAssetBundles` ，该函数会将Editor中所有标记为Asset Bundle的文件打包，输出路径为 `assetBundleDirectory` ，打包的选项通过 `BuildAssetBundleOptions` 设置，输出的目标平台通过 `EditorUserBuildSettings` 设置。

```ad-note
针对不同平台打包的Asset Bundles并不通用。
```

创建完该脚本并放置到 `Editor` 文件夹后，在界面的 `Assets` 菜单中会出现 `Build AssetBundles` 按钮。

![|200](assets/Introduction%20to%20Asset%20Bundles/image-20220124090857058.png)

# 标记 Asset Bundle

所有在Assets中的资源文件最下一栏就是关于Asset Bundle的设置，左边一栏为Asset Bundle包的名称，右边一栏为在该包中的分类。名称与分类都可以自由定义。

![|200](assets/Introduction%20to%20Asset%20Bundles/image-20220124090912291.png)

可以看到该文件名为 `BundledSpriteObject` ，AssetBundle 名为 `testbundle` ，在AB包中的类型为 `test`

若使用上面创建 Asset Bundles的脚本，输出路径为 `Assets/StreamingAssets` 。则在点击 `Assets/Build AssetBundles` 按钮后该目录下会存在以下文件。

![|200](assets/Introduction%20to%20Asset%20Bundles/image-20220124090958880.png)

其中 `testbundle.test` 就是生成出的AB包。

# 同步加载 Asset Bundle

同步加载的代码如下：

```csharp
public string assetName = "BundledSpriteObject";
public string bundleName = "testbundle.test";

private void Start()
{
    AssetBundle localAssetBundle = AssetBundle.LoadFromFile(Path.Combine(Application.streamingAssetsPath, bundleName));
    GameObject asset = localAssetBundle.LoadAsset<GameObject>(assetName);
    Instantiate(asset);
    localAssetBundle.Unload(false);
}
```

主要通过函数 `AssetBundle.LoadFromFile` 将文件解析为AB包，再通过 `AssetBundle.LoadAsset` 函数将具体的物体从AB包中解析出来。

最后通过 `loadAssetBundle.unload` 函数释放掉AB包的资源。当参数为 `false` 时仅释放 AB包本身的资源，当为 `true` 时，通过AB包实例化的物体同样会被释放，在这个例子中，即通过 `Instantiate` 创建出的物体同样会被释放。

# 异步加载 Asset Bundle

异步加载的代码如下：

```csharp
public string assetName = "BundledSpriteObject";
public string bundleName = "testbundle.test";

IEnumerator Start()
{
    AssetBundleCreateRequest asyncBundleRequest = AssetBundle.LoadFromFileAsync(Path.Combine(Application.streamingAssetsPath, bundleName));
    yield return asyncBundleRequest;

    AssetBundle loadAssetBundle = asyncBundleRequest.assetBundle;

    AssetBundleRequest assetRequest = loadAssetBundle.LoadAssetAsync<GameObject>(assetName);
    yield return assetRequest;

    GameObject prefab = assetRequest.asset as GameObject;
    Instantiate(prefab);

    loadAssetBundle.Unload(false);
}
```

通过 `AssetBundle.LoadFromFileAsync` 得到加载 AB 包的请求，在请求完成后，通过 `AssetBundleCreateRequest.assetBundle` 得到 AB包。

得到 AB 包后，通过 `AssetBundle.LoadAssetAsync` 创建加载资源的请求，加载完成后，通过 `AssetBundleRequest.asset` 得到资源。

# Reference

