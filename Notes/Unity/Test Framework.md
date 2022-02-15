---
tags:
    - Unity
    - QA
created: 2022-02-09
updated: 2022-02-15
Alias: UTF
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


```ad-note
因为所有的测试代码都有自己的 Assembly，所以如果要访问具体的工程代码，需要设置 Assembly 的 Reference。
```

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

# Setup and cleanup

对于一个 Test Class 而言，可以通过继承实现 `IPrebuildSetup` 和 `IPostBuildCleanup` 接口设定该 Test Class 下的所有测试函数执行前以及执行后需要进行的操作。

对于 Test Class 中的每个测试函数，可以通过 [Setup](#Setup) 和 [TearDown](#TearDown) 设定每个函数执行前后需要进行的操作。

示例如下，在一个测试类中定义了两个测试方法，并为测试类及测试函数都设定了对应的 Setup 和 Cleanup：
```csharp
[TestFixture]
public class EditTest2 : IPrebuildSetup, IPostBuildCleanup
{
    public void Setup() { Debug.Log("Setup for class"); }
    public void Cleanup() { Debug.Log("Cleanup for class"); }

    [SetUp]
    public void SetUpForMethod() { Debug.Log("Setup for method"); }

    [TearDown]
    public void CleanupForMethod() { Debug.Log("Cleanup for method"); }

    [Test]
    public void Pass1()
    {
    }

    [Test]
    public void Pass2()
    {
    }
}
```

运行后的输出结果如下所示，可以看到为类设定的 Setup 和 Cleanup 各执行了一次，而因为有两个测试函数，所以 SetUpForMethod 和 CleanupForMethod 各执行了两次：
![|300](assets/Test%20Framework/image-20220211094529947.png)

# Attribute

## Description 

该 Attribute 用来给测试函数添加描述信息，如下：
```csharp
[Test, Description("My really really cool test")]
public void Add()
{ /* ... */}
```

在 Test Runner 界面中显示为：
![|300](assets/Test%20Framework/image-20220211074131596.png)

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

用来标识一个方法是测试方法，同时指定作为测试用例的外部数据。

外部数据可以是 `field`，`property` 或 `method`，但自身或返回的数据类型必须是 `IEnumerable`。

示例如下：
```csharp
[TestCaseSource(nameof(DivideCases))]
public void DivideTest(int n, int d, int q)
{
    Assert.AreEqual(q, n / d);
}

static object[] DivideCases =
{
        new object[] { 12, 3, 4 },
        new object[] { 12, 2, 6 },
        new object[] { 12, 4, 3 }
};
```

当数据函数与测试放在所在类不同时，需要为 TestCaseSource 传递数据函数所在类的信息，如下所示：
```csharp
public class MyTestClass
{
    [TestCaseSource(typeof(AnotherClass), nameof(AnotherClass.DivideCases))]
    public void DivideTest(int n, int d, int q)
    {
        Assert.AreEqual(q, n / d);
    }
}

class AnotherClass
{
    static object[] DivideCases =
    {
        new object[] { 12, 3, 4 },
        new object[] { 12, 2, 6 },
        new object[] { 12, 4, 3 }
    };
}
```

如果一个类继承自 `IEnumerable`，且存在默认构造函数，则可以直接使用该类作为测试数据源，不需要再额外指明数据函数，如下所示：
```csharp
public class MyTestClass
{
    [TestCaseSource(typeof(DivideCases))]
    public void DivideTest(int n, int d, int q)
    {
        Assert.AreEqual(q, n / d);
    }
}

class DivideCases : IEnumerable
{
    public IEnumerator GetEnumerator()
    {
        yield return new object[] { 12, 3, 4 };
        yield return new object[] { 12, 2, 6 };
        yield return new object[] { 12, 4, 3 };
    }
}
```

当数据来源是函数，且函数存在形参时，TestCaseSource 中可以通过 `new object[]` 作为函数形参，如下所示：
```cssharp
[TestCaseSource(typeof(NewTestScript), nameof(TestStrings), new object[] { true })]
public void LongNameWithEvenNumberOfCharacters(string name)
{
    Assert.That(name.Length, Is.GreaterThan(5));
    bool hasEvenNumOfCharacters = (name.Length / 2) == 0;
}

static IEnumerable<string> TestStrings(bool generateLongTestCase)
{
    if (generateLongTestCase)
        yield return "ThisIsAVeryLongNameThisIsAVeryLongName";
    yield return "SomeName";
    yield return "YetAnotherName";
}
```

```ad-note
在 NUnit 中为数据函数传递形参时，如果数据函数与测试方法在同一个类下，则 TestCaseSource 的构造仅需要传递数据函数名即可。但在 UTF 测试中，即使数据函数与测试方法在同一类下，也必须为 TestCasuSource 传递 Type 信息，即如上例所示。
```

### UnityTest

UnityTest Attribute 是 UTF 对 NUnit 的拓展，其功能类似于 [Test](#Test) Attribute。

被 UnityTest 标识的测试函数可以以 Coroutine 的方式运行，在 [Edit Mode](#Edit%20Mode) 下只能 yields null，而在 [Play Mode](#Play%20Mode) 下可以额外使用 `WaitForFixedUpdate` 和 `WaitForSeconds`。

## Setup and Cleanup

### Setup

在每个测试函数前执行的准备函数。

通常而言，一个类中应当仅定义一个 Setup 函数。如果基类和派生类中都定义了 Setup，则基类中的会率先执行，再执行派生类中的。但如果派生类中的 Setup 是对基类中的重写，则基类中的不会被调用。

### TearDown

```ad-note
如果被标识 [Setup](#Setup) 函数执行错误，那么对应的标识 [TearDown](#TearDown) 的函数也不会被执行。
```

# Assertions

断言（Assertion）是单元测试的核心部分，NUnit 为 Assertion 生成了一系列的静态方法和相关函数。

在一个测试函数中，如果一个断言失败，该测试函数就会被认为测试失败，且后续的代码也不再会被执行。

NUnit 中实现了两种模式的断言，`经典模型（Classic Model）`和 `约束模型(COnstraint Model)`。在 NUnit 3.0 及后续的版本，都推荐使用约束模型的断言，后续的新增断言方式也都会以约束模型实现，而经典模型的实现不再会进行拓展。

## Classic Model

经典模式下，所有断言都使用单独的函数标识，如 `Assert.True`，`Assert.Null` 等，常用的支持列表见： [Common Assertions](https://docs.nunit.org/articles/nunit/writing-tests/assertions/assertion-models/classic.html))

## Constraint Model

约束模式下，所有的断言都使用 `Assert.That` 函数，对不同的使用场景需要传递不同的 [Constraints Object](https://docs.nunit.org/articles/nunit/writing-tests/constraints/Constraints.html) 作为函数的第二形参。如下所示：
```csharp
Assert.That(myString, Is.EqualTo("Hello"));
```

# Structure

Arrange（准备工作） && Act（具体逻辑） && Assert（判断 ）

NSubstitute

# Reference

[About Unity Test Framework | Test Framework | 1.1.30 (unity3d.com)](https://docs.unity3d.com/Packages/com.unity.test-framework@1.1/manual/index.html)

[NUnit Documentation | NUnit Docs](https://docs.nunit.org/articles/nunit/intro.html)

[Everything you need to know about Testing In Unity3D (even if you've never written a unit test) - YouTube](https://www.youtube.com/watch?v=qCghhGLUa-Y&ab_channel=JasonWeimann)   

// TODO
[Working with Unity Test Framework: Part 1: Preparing Test Runner – Digital Ephemera (videlais.com)](https://videlais.com/2021/03/02/working-with-unity-test-framework-part-1-preparing-test-runner/)


[Integration testing in Unity using the command pattern | by Colin Bellino | Medium](https://medium.com/@colinbellino/integration-testing-in-unity-using-the-command-pattern-641bb68cd77e)

[Continuous Integration & Unit Tests | The Open Augmented Reality Teaching Book - Create and Code Augmented Reality! (codereality.net)](https://codereality.net/ar-for-eu-book/chapter/development/tools/unity/advanced/ci_unity/)

// Mocking

[Thundernerd/Unity3D-NSubstitute: NSubstitute is designed as a friendly substitute for .NET mocking libraries. (github.com)](https://github.com/Thundernerd/Unity3D-NSubstitute)

Substitute.For
xxx.received

[Installed Unity Test runner but can't access NSubstitute - Unity Answers](https://answers.unity.com/questions/1424108/installed-unity-test-runner-but-cant-access-nsubst.html)

[NSubstitute: A friendly substitute for .NET mocking libraries](https://nsubstitute.github.io/)

[Mocking Web Requests in Unity — Fake it until you make it! | by goedle.io | Medium](https://medium.com/@goedle_io/mocking-web-requests-in-unity-fake-it-until-you-make-it-98496e859c94)

[Practical Unit Testing in Unity3D | by Kuldeep Singh | XRPractices | Medium](https://medium.com/xrpractices/practical-unit-testing-in-unity3d-f8d5f777c5db)


Discussion

[Help Wanted - How to use automated testing in Unity in a productive way? Tips or best practices? - Unity Forum](https://forum.unity.com/threads/how-to-use-automated-testing-in-unity-in-a-productive-way-tips-or-best-practices.814227/)