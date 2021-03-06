---
created: 2022-01-09
updated: 2022-01-14
tags:
    - Virtual-Reality
    - Audio
---
音频的空间化（Spatialization）是听者可以从音频中定位出音源的位置。

# Direct Sounds, Reflections, and Reverb

为了之后的叙述准确，首先需要明确三个概念， `直接声音（Direct Sound）` ，`反射声音（Reflections）` 和 `混响（Reverb）` 。

当声音从音源中产生，并直接传输到人耳中的声音被称为 `直接声音`。直接声音在人的感知中占比最大，也是人定位声音的主要信号。

当声音从音源中产生，并打到墙壁上时，一部分的声音会被墙壁吸收，另一部分的声音会被反射进人的耳朵，如下图所示，这部分的声音被称为 `反射声音` 。只经历过一次反射的声音被称为 `一阶反射（First-order Reflections）`，经历过两次反射的声音被称为 `二阶反射（Second-order Reflections）` ，通常二阶反射声音要比一阶反射声音轻的多。

一阶反射声音和二阶反射声音的表现与原始声音类似，即基本还是能听出原始声音中的信息，通常表现为回声现象。反射的声音可以帮助人定位声音，且对于所处空间能有个基本的感知。

![](assets/Audio%20Localization/Untitled.png)

当声音经过了进一步的反射（大于二阶反射），声音就会表现得与原始声音差距较大，听起来如同噪声。这种高阶反射的声音被称为 `混响`。

# Human Auditory System

为了实现空间音频，首先需要知道人是怎么理解音频的。在真实世界中，人的大脑定位（Localization）音源具体位置的能力主要依赖于音源的时间，音量，相位，频域的改动等信息。

位置的定位可以进一步细分为两步，音源方向的定位和距离的定位。

## Directional Localization

### Lateral

当音源在人的侧面时，定位音源的方向的方式主要有两种：

1.  `双耳时间差（Interaural time difference，ITD）` ：如果音源在人的左侧，则左耳会先听到声音，反之右耳先听到声音。
2.  `双耳音量差（Interaural level difference，ILD）` ：如果音源在人的左侧，则左耳听到的音量会更大，反之右耳的音量更大。

不同频率的声音不同程度的依赖于这两种方法：

1.  对于低频的信号而言，如果它波长的一半大于人头部大小，那么头对于声音的遮挡效果较差，因此左右耳听到的音量差距不大。所以对于低频的声音信号，更适合用 `双耳时间差` 。左右耳在不同的时间点听到声音即代表听到了音频信号不同相位的信息，因为低频信号的波长较长，因此左右耳所采样的点通常是在同一个波上，即两者的相位会存在差距。
2.  对于高频的信号而言，根据音频的相位去判断声音就不够准确。因为高频信号波长较短，左右耳采样的点并不一定是在一个波上，即两者的相位可能会相同。因此对于高频声音而言，更适合用 `双耳音量差` 。
    ![|500](assets/Audio%20Localization/Untitled%201.png)

### Front/Back and Above/Below

判断音源处在人的前侧还是后侧相对而言更为麻烦，因为此时左右耳听到的声音是相同的，如下图所示：
![|500](assets/Audio%20Localization/Untitled%202.png)

当声音经过人身体上不同区域时（如脖子，肩膀，躯干，耳廓等）会产生不同的频域变化，人的大脑会根据这些不同的频域变化来判断音源的方向。

如当音源在身体前侧，那声音会直接进入耳朵，而当音源在身体后侧时，声音则会被耳廓遮挡

同理当音源在身体上方时，声音经过耳廓后就可以进入耳朵，而当音源在身体下方时，则要经过躯干，肩膀，耳廓才能进入耳朵。

### Head Motion

`HRTFs` 仅考虑了头静置不动时的情况，但在真实世界中，头部的转动也可以帮助定位音源的方向。

如下图展示了，头的旋转如何帮助定位音源时来自于前侧还是右侧，在一开始音源到左右耳的声音是相同的，但是当头部进行旋转后，声音到达右侧的时间就会长于声音到达左侧时间：
![|500](assets/Audio%20Localization/Untitled%203.png)

同理，当头侧向转动时可以帮助定位音源处在上方还是下方，如下图所示，当音源处在人的右上方时，头向左转动，声音到人左耳的时间会变的变长，而声音到人右耳的时间则会变短。

## Distance Localization

上述的 `ITD` ， `ILD` 都是用于对于分辨音源的方向，在方便音源的距离时就需要用到其他的信息

### Loundness

音量大小是当音源距离发生变化时最明显的相应变化。但当缺少参考框架时，就无法判断音量的衰减程度来判断音源距离。

在现实生活中，人之所以能利用音量判断距离是因为人对于物体通常的音量大小是有一个预判的。当出现一个完全不熟悉的物体时，就很难通过它发出的声音来判断出它的距离。

### Initial Time Delay

`初始时间延迟`描述了声音经过第一次反射到人耳和声音直接到人耳的时间差，如下图所示：
![|500](assets/Audio%20Localization/Untitled%204.png)

当声源靠近人的时候，声音直接到人耳的时间会很短，因此初始时间延迟会较大，反之初始时间延迟会很小。

`初始时间延迟`方法不适用于无回声的环境，或一个较为空旷的环境。

### Ratio of Direct Sound to Reverberation

通过直接直接声音与混响声音的比例，也可以判断出声源的距离。

当音源较近时，直接声音的比例更大，反之混响的比例更大。

### Motion Parallax

运动声差指的是当音源在场景内移动时，人感知到的声源移动的距离。

当声源离人较近的时候，感知到的运动声差会很明显，想象一个虫子从左耳飞到右耳时，虽然虫子只移动了几厘米，但感知非常明显。

当声源离人较远的时候，感知到的运动声差则会很小，想象几百米米外一个老虎移动了几米，人的感知就很小。

### High-Frequency Attenuation

通常来说，高频声音相较于低频声音会更快的衰减，因此理论上可以通过高频声音的衰减来判断音源的距离。如当只能听到火车的隆隆声时，说明火车距离较远。

但是这种方法在实际中很难应用，一是因为音源的距离通常要在几百，几千英尺外，人才能明显的感受到高频信号的衰减。二是高频声音的衰减也受温度，湿度等因素的影响。

# 3D Audio Spatialization

3D空间音频就是希望听者可以从输出到耳机的音频中分辨出音频中的虚拟音源的位置。这就要求音频模块输出到耳机的音频应当是与人在真实世界中听到的声音是类似的，比如音频模块会根据虚拟音源的位置调整左右耳的时间差等。

### Head-Related Transfer Functions（HRTFs）

音源从不同方向出发，到人双耳听到时的变化（相位，音量，频域）可抽象为一个 `头部相关转移函数（HRTFs）`。但需要注意 `HRTFs` 仅仅关注音源的方向，且假设耳朵的位置和角度是不动的。

为了计算得到 `HRTFs`，需要一个人带入一个无回音（HRTFs不考虑回音）的房间内，将一对麦克风非常贴近的放到这个人的耳廓外。然后从房间中的各个方向发出声音，记录下麦克风对于来自于不同方向的声音的接收程度。从房间各方向发出的原始声音信号转换到麦克风接收到的声音信号，中间的这个转换模型就是 `HRTFs`。

```ad-warning
对于不同的人而言有不同的 `HRTFs` ，因此上述的方法只能计算出实验者的 `HRTFs`。理想上对于每个用户都要为其计算他自己的 `HRTFs` ，但通常会通过实验得到大量的人的 `HRTFs` ，然后将平均值作为需要使用的 `HRTFs` 。
```

当应用 `HRTFs` 模型时，需要将原始音频经过 `HRTFs` 的转换再传输到耳机中。

```ad-warning
对于应用了 `HRTFs` 的音频而言，必须使用耳机听，外放的话相当于经过了两遍 `HRTFs` 。一遍来自于音频的 `HRTFs` 处理，一遍来自于外放时声音到人耳的传输过程。
```

## Head Tracking

`HRTFs` 仅提供了头部静止状态下的音频转移模型。但在真实世界中，头的移动和旋转也会造成听到的声音的变化。为了让输出的音频也能针对听者的位置和角度对音频进行调整，音频处理模块必须首先知道听者的位置和角度。

在VR中，可以直接将SDK获取的头盔位姿信息传递给音频模块，音频模块则需要通过这些信息调整输出的音频。

## Environmental Modeling

环境模型是为了模拟出声音在真实世界中的反射效果。

在许多的空间音频的模拟中，都是采用了一个类似于鞋盒的立方体（Shoebox Model）作为虚拟环境，如下图所示：
![|500](assets/Audio%20Localization/Untitled%205.png)

在使用鞋盒模型模拟虚拟场景的情况下，没有考虑场景内物体对音频的遮挡，没有考虑场景内不同物体对于音频吸收的能力不同，且场景的墙壁只是六个完全垂直的面。

因此鞋盒模型与开发者自定义的场景会存在较大的差距，但因为要根据不同的虚拟场景去动态的调整音频太过于复杂，所以在很多情况下都仍是使用鞋盒模型。

## Distance Modeling

3D空间音频模块需要分别对人区分音源距离的几个标准进行适配：

-   Loudness：定义一个音源距离增长时的音量衰减曲线
-   Initial Time Delay：需要根据虚拟音源所处的虚拟环境，计算出直接声音和一阶反射声音到耳朵的时间差。通常这个标准很难去模拟，因为它依赖于对于虚拟环境的反射计算，且比较耗费性能。
-   Ratio of Direct Sound to Reverberation：如果要达到理论上的准确，为了得到直接声音和混响的比例，需要模拟虚拟音源在虚拟环境下的反射路径，无疑这也是个极度耗费性能且困难的工作。因此大多数的音频软件都提供了 `Dry/Wet Mix` 功能，其中 `Dry Audio` 表示直接声音， `Wet Audio` 表示混音，创作者可以直接调节直接声音和混响的比例。
-   Motion Parallax：根据头的位姿和虚拟音源的位置，并采用 `HRTFs` 就能直接得出移动音差的效果
-   Air Absorption：模拟空气吸收的模型，来实现高频信号长距离的衰减


## Volumetric Sounds

游戏引擎中，默认声音都是从一个点传出来的，这种设置会在一些情况下显得很突兀。如有一个巨大的喇叭，声音应该是从该喇叭的四面八方传出的。

# Reference

https://developer.oculus.com/blog/volumetric-sounds/?locale=en_US
https://developer.oculus.com/learn/audio-intro-localization/
https://developer.oculus.com/learn/audio-intro-env-modeling/