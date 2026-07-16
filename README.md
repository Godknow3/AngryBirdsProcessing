# Angry Birds（Processing）

这是一个使用 Processing 和 Box2D 制作的《愤怒的小鸟》练习项目。

## 游戏说明

- 游戏目前包含 6 个关卡。
- 前三关全部获得三星后，可以在第 4 关解锁威力更强的 Lava Bird。
- 使用鼠标拖拽并释放小鸟。

## 运行环境

建议使用 Processing 3，并安装以下库：

- [Minim](http://code.compartmental.net/minim/)：播放背景音乐。
- [Box2D for Processing](https://github.com/shiffman/Box2D-for-Processing)：物理模拟。

在 Processing 中可通过“工具 → 管理工具 → Libraries”搜索并安装这些库。安装完成后，打开 `AngryBirds.pde` 并点击“运行”。

## 背景音乐

游戏启动时会自动循环播放背景音乐，切换关卡不会重新开始播放。音乐文件位于：

```text
data/angry_birds_theme.mp3
```

背景音乐使用 Minim 加载，并通过以下代码循环播放：

```java
backgroundMusic = minim.loadFile("angry_birds_theme.mp3");
backgroundMusic.setGain(-8.0);
backgroundMusic.loop();
```

可以在 `AngryBirds.pde` 中修改 `setGain()` 调整音量：

- `0.0`：使用原始音量。
- `-8.0`：当前默认音量。
- `-15.0`：更安静。

如果运行时出现 `ddf.minim` 找不到的错误，请先在 Processing 的库管理器中安装 Minim，然后重新运行游戏。

## 攻略

- 第二关：击中滚木是推荐解法。
- 第三关：击中上层木板，让石头垂直落下。
