## 开发规范总览

这份文档约定了本项目后续所有动效 / 场景 / 工具代码的**统一开发规范**，以保证：

- **接口一致性**：所有模块都遵循统一的时间、场景、事件接口。
- **解耦**：新动效、新场景在独立 `.pde` 文件里开发，不需要修改已有模块内部。
- **音画同步**：所有与音乐节奏相关的逻辑，都通过统一的时间/节拍系统接入。
- **可扩展性**：方便未来改成离线逐帧渲染、导出视频而不掉帧。

---

## 1. 时间与音乐规范

- **统一时间源**
  - 实时演示时：**强烈建议**使用 `MusicClock` 的 `musicTime / beat / beatIndex` 作为主时间轴。
  - 变量约定：
    - `dt`：本帧与上一帧的时间差（秒），用来做平滑过渡、积分速度等。
    - `musicTime`：从音乐开始播放到现在的时间（秒）。
    - `beat`：已经经过的拍子数（float，可有小数）。
    - `beatIndex`：当前是第几拍（int，从 0 或 1 开始，自行约定）。

- **不要在模块内部自行调用 `millis()` 作为主时间轴**，除非是：
  - 局部的调试用途；
  - 明确与音乐无关的随机装饰效果。

- **与音乐对齐的逻辑**：
  - 请统一使用 `musicTime` 或 `beat` 做判断，例如：
    - `if (beat > 32 && beat < 40) {...}`
    - `float localT = musicTime - sectionStartTime;`。

---

## 2. 场景与对象规范

### 2.1 必须使用的基类：`SceneObject`

在运行时场景（`new_state`）中，所有会被统一更新和绘制的元素，都应该实现：

```java
class MyEffect extends SceneObject {
  // 构造：传入需要的配置 / 资源
  MyEffect(/* params */) {
    // 初始化
  }

  void update(float dt, float musicTime, float beat) {
    // 在这里进行所有与时间相关的更新逻辑
  }

  void draw() {
    // 在这里进行所有的绘制
  }
}
```

规范：

- **不要**在外部直接调用 `myEffect.update()` / `myEffect.display()`。
- 统一由 `Scene.updateAll()` / `Scene.drawAll()` 调用。
- 当对象不再需要时，把 `active` 设为 `false`，Scene 会在下一帧自动回收：
  - 例如：粒子全部消失后，`MoneyEffect` 可以选择 `active = false`。

### 2.2 场景注册

- 在主场景入口（目前是 `new_state/new_state.pde` 的 `setup()`）中，将对象注册到全局 `Scene`：

```java
mainScene.add(new MyEffect(/* params */));
```

- 文件位置建议：
  - 每个动效模块一个 `.pde` 文件，命名统一为：`<Name>.pde`。
  - 对应的 `SceneObject` 子类就写在同名文件里。

---

## 3. 节拍事件与音画同步

### 3.1 `BeatListener` 规范

如果某个对象需要对“具体的拍子事件”做出反应（例如：第 32 拍触发一次爆炸），需要实现：

```java
class MyBeatEffect extends SceneObject implements BeatListener {
  void update(float dt, float musicTime, float beat) {
    // 平常的逻辑
  }

  void draw() {
    // 绘制逻辑
  }

  void onBeat(int beatIndex, float musicTime) {
    // 在这里处理“到了一拍”的瞬时事件
  }
}
```

- 在主场景初始化时，把该对象注册到 `BeatDispatcher`：

```java
MyBeatEffect e = new MyBeatEffect();
mainScene.add(e);
beatDispatcher.addListener(e);
```

- 在主循环中（通常在 `draw()` 顶部）：

```java
musicClock.update();
beatDispatcher.update(musicClock);
mainScene.updateAll(dt, musicClock.musicTime, musicClock.beat);
mainScene.drawAll();
```

这样可以保证：

- `onBeat()` 只会在**整拍交界**时被调用一次；
- 任何需要“严格对齐拍子”的逻辑，都集中在 `onBeat()` 中处理（例如：触发一次跳跃、重置相位、切换阶段等）。

### 3.2 不要在多个地方重复处理同一节拍

- 同一类事件（例如“小马起跳”）只应该有一个明确的来源：
  - 要么在 `PonyController` 的 `onBeat()` 中处理；
  - 要么由某个“谱面控制器”集中处理，然后给 Pony 发消息。

---

## 4. 配置与资源规范

### 4.1 动画与素材路径

- 所有素材路径、尺寸、速度等配置，统一放在 `AnimationConfig.pde` 中：
  - 例如：`BACKGROUND_PATH`、`CLOUD_PATH_PREFIX`、`GROUND_SPEED` 等。
- 新增动效时，如果需要图片资源：
  - 在 `AnimationConfig.pde` 里添加对应的 `PATH_PREFIX` / `SUFFIX` / 数量常量。
  - 在模块内部使用这些常量加载图片，并尽量在构造函数中一次性 `loadImage()` + `resize()`。

### 4.2 命名约定

- 常量：全部大写，下划线风格，例如：`MOUNTAIN_SPEED`、`PONY_JUMP_HEIGHT`。
- 类名：大写驼峰，例如：`CloudLayer`、`MountainLayer`、`MoneyEffect`、`BouncyTextEffect`。
- 成员变量：小写驼峰，例如：`spawnTimer`、`scrollOffset`。
- 帧数组：`PImage[] xxxFrames`，如 `runFrames`、`jumpFrames`。

---

## 5. 新动效模块开发步骤（推荐流程）

以“节拍文字弹出效果”（类似 `reference/word.pde` 的效果）为例：

1. **在 `new_state` 目录创建文件**：`BouncyTextEffect.pde`。
2. **实现类并继承 `SceneObject`（可选实现 `BeatListener`）**：

```java
class BouncyTextEffect extends SceneObject implements BeatListener {
  // 内部使用 BouncyChar / 字符数组等

  BouncyTextEffect(String text, float centerY, int startBeat, int endBeat) {
    // 初始化，记录要显示的文字、位置、起止拍子
  }

  void update(float dt, float musicTime, float beat) {
    // 根据 beat / musicTime 决定当前是否处于激活区间
    // 更新内部的弹簧物理
  }

  void draw() {
    // 绘制当前的文字
  }

  void onBeat(int beatIndex, float musicTime) {
    // 当 beat 进入起始区间时，触发一次新的弹出动画
  }
}
```

3. **在主场景 `setup()` 里注册**：

```java
BouncyTextEffect title = new BouncyTextEffect("HAPPY NEW YEAR", 200, 0, 16);
mainScene.add(title);
beatDispatcher.addListener(title);
```

4. **不要**在其他地方直接操作内部细节，例如：
  - 不要直接调用 `title.createText()`；
  - 如需改变行为，应通过构造参数、公共方法或节拍事件实现。

---

## 6. 小马控制器（未来改造约定）

为了保持一致性，后续如果把小马逻辑抽成独立类，请遵循：

- 文件：`PonyController.pde`。
- 类定义：

```java
class PonyController extends SceneObject implements BeatListener {
  // 内部持有 runFrames / jumpFrames / 状态机变量等

  void update(float dt, float musicTime, float beat) {
    // 统一使用 musicTime/beat 作为输入
  }

  void draw() {
    // 通过 drawPony 或自己的绘制逻辑画出当前帧
  }

  void onBeat(int beatIndex, float musicTime) {
    // 可选：基于谱面、拍子触发跳跃 / 切换状态
  }
}
```

- 主场景中：

```java
PonyController pony;

void setup() {
  // ...
  pony = new PonyController();
  mainScene.add(pony);
  beatDispatcher.addListener(pony);
}
```

---

## 7. 离线逐帧渲染规范（预留）

为了将来支持“逐帧生成、拼成视频”的不掉帧模式，约定以下点：

- 在主场景中保留一个开关，例如：`boolean offlineRenderMode = false;`
- 当离线模式开启时：
  - 不依赖 `frameRate` 实时渲染，而是在 `draw()` 中按固定步长推进 `animTime` 或 `musicTime`：

```java
if (offlineRenderMode) {
  float step = 1.0 / 60.0; // 等效 60fps
  animTime += step;
  // 或：musicTime += step; 同时不播放真实声音，只走逻辑
}
```

  - 每一帧调用 `saveFrame("frames/####.png");` 导出图片。
  - 所有模块必须**只依赖传入的 `dt` / `musicTime` / `beat`，而不直接读取系统时间**，这样离线回放时动画表现才能与实时保持一致。

---

## 8. 提交前自检清单

在编写任何新模块或修改旧模块前，请确认：

- **是否继承了 `SceneObject` 并通过 `Scene` 管理？**
- **是否使用了 `musicTime` / `beat` 而不是自己用 `millis()`？**
- **资源路径是否都在 `AnimationConfig.pde` 中集中配置？**
- **是否需要对拍子敏感？如果需要，是否实现了 `BeatListener` 并注册到 `BeatDispatcher`？**
- **是否避免在多个地方重复处理同一个逻辑事件（例如，小马起跳只在一个模块中处理）？**

只要遵守以上规范，你后续增加的任意动效（背景、道具、歌词、粒子等）都可以自然融入现在的架构，并保证音画同步和整体流畅性。

