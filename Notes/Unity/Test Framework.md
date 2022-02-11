---
tags:
    - Unity
    - QA
created: 2022-02-09
updated: 2022-02-11
---

# Prepare

## Install Test Framework

Unity Test Framework 可以选择 Package Manager 中的 `Test Framework` 进行安装。

## Create Test Assembly

所有的测试代码都单独以 Assembly 管理，可以通过 `Window -> General -> TestRunner` 窗口中创建 [Edit Mode](#Edit%20Mode) 或 [Play Mode](#Play%20Mode) 的 Assembly：
![|300](assets/Test%20Framework/image-20220209075951444.png)

Unity 会默认的为 Test Assembly 创建新的文件夹。

## Create Test

在存有 Test Assembly 的文件夹内，右键选择 `Create -> Testing -> C# Test Script` 可以创建出测试脚本。

## Run Test

当 Test Assembly 及 Test Script 创建后，即可在 `Test Runner` 窗口中看到所有定义的测试函数，如下：
![|300](assets/Test%20Framework/image-20220209075630528.png)

双击其中的 Assembly / Script/ Function 名即可执行其下的所有测试，可以选择窗口上方的 `Run All` 执行所有测试。

在 [Play Mode](#Play%20Mode) 下，可以在 `Test Runner` 窗口中选择 `Run All Test (<Platform>)` 进行打包后的验证，其中 `Platform` 与当前项目选择的平台相关，如下所示：
![|300](assets/Test%20Framework/image-20220209094859570.png)

真机测试时会以一个空场景运行，当所有测试结束后应用将会被关闭，且结果会显示在 `Test Runner` 窗口中。

# Edit Mode vs. Play Mode

## Edit Mode

Edit Mode 仅能在 Unity 编辑器中运行，除了游戏代码外， Edit Mode 还可以测试自定义 Edit  Extension代码。

```ad-note
Edit Mode 使用的 Assembly 的 Platforms 必须 **仅 **支持 `Editor`。
```

```ad-tip
Edit Mode 的测试代码运行在 [EditorApplication.update](https://docs.unity3d.com/ScriptReference/EditorApplication-update.html) 回调中。
```


## Play Mode

Play Mode 可以以游戏运行的模式运行测试用例。

```ad-note
[UnityTest](#UnityTest) Attribute 仅能在 Play Mode 中运行
```

# Attribute

## Description

该 Attribute 用来给测试函数添加描述信息，如下：
```csharp
[Test, Description("My really really cool test")]
public void Add()
{ /* ... */}
```

在 Test Runner 界面中显示为：


## Test 标识

### TestFixture

该 Attribute 用来标识一个类中包含有测试方法。

此 Attribute 在 NUnit 2.5 以上的版本中对于无泛型的测试类而言是一个可选参数[^1]。只要类中包含有被 [Test](#Test)，[TestCase](#TestCase)，[TestCaseSource](#TestCaseSource) 修饰的函数。该类就会被自动标识为测试类。

### Test

用来标识一个方法是测试方法，如下：
```csharp
[Test]
public void NewTestScriptSimplePasses()
{
    // Use the Assert class to test conditions
}
```

可以直接在 `TestAttribute` 中指明预取结果：
```csharp

```

### TestCase

用来标识一个方法是测试方法，并且提供调用时的测试用例，如下：
```csharp
[TestCase(12, 3, 4)]
[TestCase(12, 2, 6)]
[TestCase(12, 4, 3)]
public void TestCase(int n, int d, int q)
{
    Debug.Log($"{n},{d},{q}");
    Assert.AreEqual(q, n / d);
}
```

### TestCaseSource

### UnityTest


# Reference

[About Unity Test Framework | Test Framework | 1.1.30 (unity3d.com)](https://docs.unity3d.com/Packages/com.unity.test-framework@1.1/manual/index.html)


[NUnit Documentation | NUnit Docs](https://docs.nunit.org/articles/nunit/intro.html)

[^1]: [TestFixture | NUnit Docs](https://docs.nunit.org/articles/nunit/writing-tests/attributes/testfixture.html)