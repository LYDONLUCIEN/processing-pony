## 项目整体架构概览

本项目是基于 Processing 的节奏向小马跑酷 / 动画演示工程，整体可以分为三大部分：

- **素材工具层**
  - `slicer/slicer.pde`：离线的精灵图切片工具，用于把整张动作序列大图按行列切成独立帧 PNG（支持边缘裁剪），供运行时动画使用。
- **运行时核心场景**
  - `new_state/new_state.pde`：主入口草图，负责窗口/渲染模式初始化、音乐播放、时间系统、场景与事件分发，以及所有视觉层与小马控制器的统一调度。
  - `new_state/AnimationConfig.pde`：集中存放所有素材路径和数值参数（速度、缩放、生成间隔、位置等），是全局配置中心。
- **动画层/特效模块 & 控制器**
  - `new_state/CloudLayer.pde`：云层系统。
  - `new_state/MountainLayer.pde`：山峰与山云系统。
  - `new_state/DenglongManager.pde`：灯笼装饰系统。
  - `new_state/StoneManager.pde`：石头障碍与自动起跳触发。
  - `new_state/GroundManager.pde`：透视滚动地面（mode7 风格）。
  - `new_state/MoneyEffect.pde`（在同目录）：金币/红包粒子特效。
  - `new_state/PonyController.pde`：小马跑步/跳跃控制器，实现基于音乐时间的 FSM 与测试时间线。

参考动画示例（不直接参与主场景）：

- `reference/ground.pde`：一种双缓冲、倾斜透视地面实现。
- `reference/word.pde`、`reference/word-v2.pde`：文字弹性、海绵挤压等局部动效示例。

---

## 当前运行时架构（new_state）

### 1. 全局时间与音乐

- **音乐与节奏**
  - 使用 `SoundFile song` 加载 MP3（`musicFile`），在 `setup()` 中 `song.loop()` 持续播放。
  - 全局设定 `bpm = 125.0`，以及：
    - 每个跑步循环对应的拍数 `beatsPerRunCycle`。
    - 跳跃过程剩余帧需要多少拍 `beatsForRemainingJump`。
- **全局时间驱动**
  - `prevMillis` / `millis()` 计算每帧 `dt`（秒）。
  - `animTime` 作为统一的“动画时间轴”，在 `draw()` 中按 `dt * timeSpeed` 线性推进，支持全局暂停 `isPaused`。
  - 跳跃时间、测试时间线（`jumpTimeline`）等都基于 `animTime` 进行比较和触发。

> 当前设计里，“音乐时间”和“动画时间”实际上是分离的：动画时间靠 `millis()` 推进，音乐只是单独 loop，没有直接用 `song.position()` 作为时间基准。这意味着长时间运行后可能存在轻微的音画漂移，但短时间内足够稳定。

### 2. 小马跑/跳状态机

- **素材管理**
  - 通过 `runPrefix` / `jumpPrefix` 与 `runTotalFrames` / `jumpTotalFrames`，从 `folderName` 指向的 output 目录加载跑步和跳跃帧数组：
    - `PImage[] runFrames;`
    - `PImage[] jumpFrames;`
- **状态与控制变量**
  - `int state`：0 = RUN，1 = JUMP。
  - `boolean jumpRequested`：请求起跳标志（来自自动检测、测试时间线或手动按键）。
  - `float jumpStartTime`：起跳时记录的 `animTime`。
  - `float runCycleOffset`：落地后重置跑步循环相位，使节奏对齐。
  - `PImage currentDisplayFrame` + `float ponyY`：当前绘制的主角帧与竖直位置（由 `getJumpHeight()` 决定）。
- **RUN 状态（state == 0）**
  - 根据 `animTime`、`bpm`、`beatsPerRunCycle` 计算当前跑步循环的归一化进度 `currentCycleProgress`。
  - 通过 `currentCycleProgress * runTotalFrames` 得到帧索引 `index`；在特定“过渡帧”（如 index == 4）检查是否存在 `jumpRequested`：
    - 若满足则在该帧锁定一次，切换到 JUMP 状态。
    - 否则继续播放跑步循环。
- **JUMP 状态（state == 1）**
  - 根据 `animTime - jumpStartTime` 推进跳跃进度，使用 `beatsForRemainingJump` 映射到跳跃动画的帧序列。
  - 通过 `getJumpHeight(progress)`（正弦曲线）计算竖直位移，形成自然的起跳和落地抛物线。
  - 跳跃结束时重置为 RUN 状态，并更新 `runCycleOffset`，保证起跑节奏重新对齐。
- **跳跃触发来源**
  - **石头障碍自动触发**：`StoneManager.checkAutoJump(PONY_X)` 内部检测主角与石头距离，小于阈值时返回 true。
  - **测试模式时间表**：`jumpTimeline` 中预设秒数，当 `animTime` 超过指定时间点时自动置 `jumpRequested = true`。
  - **玩家输入**：空格键、或未来可能来自音乐节奏事件。

### 3. 动画层与特效模块

所有视觉层都遵循类似模式：在 `new_state.pde` 中持有一个实例，在 `draw()` 中按统一顺序调用：

```java
// new_state.pde 中（伪结构）
cloudLayer.update(dt);
mountainLayer.update(dt);
denglongManager.update(dt);
stoneManager.update(dt);
moneyEffect.update(dt);
groundManager.update(dt);

drawBackground();
cloudLayer.display();
mountainLayer.display();
denglongManager.display();
groundManager.display();
stoneManager.display();
drawPony(currentDisplayFrame);
moneyEffect.display();
```

主要模块职责（简化）：

- **CloudLayer**
  - 管理 `ArrayList<Cloud>`，云朵缓慢从右向左移动，超出屏幕后移除。
  - 使用 `spawnTimer` / `nextSpawnTime` 随机间隔生成新云朵。
  - 构造时预加载、预缩放云朵贴图，减少运行时开销。
- **MountainLayer**
  - 山峰与山云分别使用 `ArrayList<Mountain>` 和 `ArrayList<MountainCloud>` 管理。
  - 始终保持画面中有 1 个左右的山峰，和一定数量的山云，形成中景层。
  - 同样对贴图进行预缩放，更新时只平移坐标。
- **DenglongManager**
  - 周期性生成灯笼装饰，缓慢移动并在超出屏幕后删除。
  - 也使用预缩放的图片以提升性能。
- **StoneManager**
  - 管理石头障碍及其位置，负责自动起跳判定（`shouldTriggerJump(ponyX)`）。
  - 可以配置自动起跳开关（`autoJumpEnabled`），并对外暴露 `getStones()`、`getCount()` 进行调试或高级玩法扩展。
- **GroundManager**
  - 使用 `beginShape(QUAD_STRIP)` + `texture(groundImage)` + 多段纵向切片模拟透视地面。
  - 通过 `scrollOffset` 驱动 X 方向纹理坐标滚动，实现无缝地面移动。
  - `stripCount` 越大画面越平滑，但 GPU 顶点提交量增加。

### 4. 输入与调试

- **输入控制**
  - 空格：手动请求跳跃。
  - T：切换自动测试模式 / 手动模式。
  - P：暂停 / 恢复，并同步暂停/恢复音乐。
  - S：开启/关闭石头自动跳跃。
  - 左右方向键：在暂停时按单帧步进预览。
- **调试可视化**
  - `drawDebugUI()` 显示当前时间、状态、帧号、进度、各层对象数量等。
  - `drawTimeline()` 在画面底部显示测试模式的时间轴和预设跳跃点，可视化“节奏脚本”。

---

## 工具与参考草图

### 1. slicer：精灵图切片工具

- 输入一张包含多行多列动作的整图（sprite sheet），指定：
  - 列数 `cols` / 行数 `rows`。
  - 总帧数 `totalFrames`。
  - 边缘裁剪百分比 `cropPercentage`（例如 10% 表示每边裁 5%）。
- 自动计算单帧区域，并通过 `get(x, y, w, h)` 裁剪后保存为一系列 PNG。
- 输出文件以 `outputFolder + outputPrefix + nf(index, 2) + ".png"` 命名（与 `new_state` 中加载的命名规则相匹配）。

### 2. reference/ground & word 动效

- `reference/ground.pde`
  - 演示双缓冲、倾斜平行四边形地面块的无缝滚动。
  - 使用两个 `GroundBlock`，当一个完全离屏后重置到另一个右侧，形成无限循环。
  - 通过 `slantFactor` 控制梯形倾斜程度，支持实时调整和调试显示。
- `reference/word.pde` / `reference/word-v2.pde`
  - 实现“海绵弹出”“挤压”“外发光”“呼吸”效果的文字。
  - `BouncyChar` 使用弹簧物理模型（`springK`、`damping`）分离 X/Y 缩放与旋转，链式形成波浪式弹出效果。
  - 这些可以作为未来“歌词动效”“节拍文字特效”的参考模块。

---

## 新的“引擎式”架构设计思路

> 目标：在素材数量大幅增加、动效类型丰富、且需要严格音画同步的前提下，构建一个**对象化、解耦、可扩展**的架构，使每个动效像“游戏对象”一样：
> - 一次触发即可自主更新渲染；
> - 支持被其他指令中断、暂停；
> - 能对音乐节拍、时间线事件作出响应。

### 1. 核心理念概括

- **统一时间基准**：用音乐的时间（`song.position()`）作为全局“真时间”，`animTime`、节拍、事件触发全都从这个时间派生，减小音画漂移。
- **对象化场景管理**：引入 `Scene` 和 `SceneObject` 概念，所有可动元素（小马、云、山、地面、文字特效等）都是 `SceneObject`。
- **事件/信号驱动**：引入简单的事件系统（尤其是**节拍事件**），对象可以订阅音乐节拍、节拍区间、甚至谱面脚本中的 cue。
- **分层解耦**：每个动效模块在自己独立的 `.pde` 文件中，只依赖少量公共接口（时间、事件、资源），尽量不直接引用彼此的内部状态。

---

## 设计细节：类与模块

### 1. 时间与音乐同步模块

**目标**：让全局所有动画只依赖一个“音乐时钟”，从而保证音画同步。

建议新增类似结构（伪代码）：

```java
// MusicClock.pde
class MusicClock {
  SoundFile song;
  float bpm;

  float musicTime;   // 当前音乐播放时间（秒）
  float beat;        // 当前处在哪个小节拍（float，可带小数）
  int beatIndex;     // 第几拍（整数）

  MusicClock(SoundFile song, float bpm) {
    this.song = song;
    this.bpm = bpm;
  }

  void update() {
    musicTime = song.position();            // 从音频获取“真时间”
    beat = musicTime / (60.0 / bpm);       // 拍子数
    beatIndex = floor(beat);
  }
}
```

在 `draw()` 里：

```java
clock.update();
float dt = ...; // 保留 dt 用来做平滑插值
scene.updateAll(dt, clock.musicTime, clock.beat);
scene.drawAll();
```

### 2. 场景与对象基类

**统一管理 update / draw / 生命周期**，每个动效模块只管自身逻辑。

```java
// SceneObject.pde
abstract class SceneObject {
  boolean active = true;

  // dt: 帧间隔（秒），musicTime/beat: 全局音乐时间与拍子位置
  abstract void update(float dt, float musicTime, float beat);
  abstract void draw();

  // 可选：对象自己的回调（创建/销毁/被打断等）
  void onSpawn() {}
  void onDestroy() {}
}

// Scene.pde
class Scene {
  ArrayList<SceneObject> objects = new ArrayList<SceneObject>();

  void add(SceneObject obj) {
    objects.add(obj);
    obj.onSpawn();
  }

  void updateAll(float dt, float musicTime, float beat) {
    for (int i = objects.size() - 1; i >= 0; i--) {
      SceneObject o = objects.get(i);
      if (!o.active) {
        o.onDestroy();
        objects.remove(i);
      } else {
        o.update(dt, musicTime, beat);
      }
    }
  }

  void drawAll() {
    for (SceneObject o : objects) {
      o.draw();
    }
  }
}
```

> 这样一来，`CloudLayer`、`MountainLayer`、`StoneManager`、`MoneyEffect` 等都可以改写为 `SceneObject` 子类，各自维护内部的列表结构，但对外统一是 `update/draw` 两个接口。

### 3. 事件与节拍回调

为了支持“某一拍触发某动效”“在一小节内执行淡入”等，更推荐添加一个简易事件系统：

```java
// BeatEvent.pde
interface BeatListener {
  void onBeat(int beatIndex, float musicTime);
}

class BeatDispatcher {
  ArrayList<BeatListener> listeners = new ArrayList<BeatListener>();
  int lastBeatIndex = -1;

  void addListener(BeatListener l) {
    listeners.add(l);
  }

  void update(MusicClock clock) {
    if (clock.beatIndex != lastBeatIndex) {
      lastBeatIndex = clock.beatIndex;
      for (BeatListener l : listeners) {
        l.onBeat(clock.beatIndex, clock.musicTime);
      }
    }
  }
}
```

使用方式示例：

- **PonyController**：实现 `BeatListener`，在某些 beat 上重置跑步相位、触发跳跃、切换状态等。
- **文字特效**：实现 `BeatListener`，在特定拍子上触发 `BouncyChar` 的弹出。
- **镜头/场景切换**：某些 beat 触发背景颜色变化、场景淡入淡出。

在 `draw()` 的顺序：

1. `clock.update()`
2. `beatDispatcher.update(clock)` —— 广播当前 beat 变化。
3. `scene.updateAll(dt, clock.musicTime, clock.beat)`
4. `scene.drawAll()`

### 4. 小马控制器对象化

把当前 `new_state.pde` 中的跑/跳 FSM 收拢成一个 `PonyController`：

```java
class PonyController extends SceneObject implements BeatListener {
  // 现有的 runFrames/jumpFrames/state/jumpRequested 等成员

  void update(float dt, float musicTime, float beat) {
    // 这里不再直接使用 millis-based animTime，
    // 而是把 musicTime 映射为 run/jump 状态进度
  }

  void draw() {
    // 统一的 drawPony 逻辑
  }

  void onBeat(int beatIndex, float musicTime) {
    // 可选：在某些 beat 强行把跑步相位对齐到整拍
    // 或者在谱面定义中：第 16 拍触发一次跳跃请求等
  }
}
```

这样，小马的动作始终紧贴音乐拍子，只要 `SoundFile.position()` 准确，音画就不会明显漂移。

### 5. 参考动效模块化

将 `reference` 下的动效抽成可插拔对象：

- **GroundBlockGround**：可以替换或兼容现在的 `GroundManager`，作为另一种地面风格。
- **BouncyTextEffect**（来自 `word.pde`）：
  - 封装出 `class BouncyTextEffect extends SceneObject implements BeatListener`。
  - 支持：
    - 在指定 beat 范围显示某一串字；
    - 在 beat 到达时触发新一轮弹性动画（`createText()`）。
  - 每个歌词段就是一个对象，不同 `.pde` 文件里写不同歌词段/版式，在主场景中统一注册。

---

## 与现有代码的衔接与渐进改造建议

1. **第一步：引入 MusicClock + Scene，不改现有逻辑**
   - 保留 `animTime` 的用途，但新建 `MusicClock` 和 `Scene`。
   - 把 `cloudLayer`、`mountainLayer` 等包装成简单的 `SceneObject`，内部实现先直接调用原来的 `update(dt)` / `display()`。
2. **第二步：把小马控制器抽成独立类**
   - 把所有与小马状态相关的变量和函数移入 `PonyController`。
   - `draw()` 中只剩一个 `scene.drawAll()` 调用，小马自己负责何时跑/跳。
3. **第三步：时间完全切到音乐轨**
   - 在 `PonyController` 和其他对节奏敏感的对象中，用 `musicTime` 和 `beat` 替代 `animTime`。
   - `animTime` 只作为调试/备用，或干脆移除。
4. **第四步：引入 BeatDispatcher 与谱面脚本**
   - 把原来的 `jumpTimeline` 从“秒表”改写为基于 beat 的事件脚本，比如：`int[] jumpBeats = {8, 16, 24, ...}`。
   - 后续可以发展为从外部 JSON/文本文件加载谱面，这样整个动效可以由非程序文件驱动。

---

## 性能与流畅度考虑

- **对象化本身不会奇迹般提速**，但带来几个实际有帮助的优化点：
  - 可以更精细地控制每类对象的数量（如云层上限、粒子池复用等）。
  - 更容易在低端机器上关闭/降低某些层：只需不向 `Scene` 注册或主动 `active=false`。
  - 所有 update/draw 都集中到几个循环中，方便做整体性能分析（统计每类对象数量、估算开销）。
- **当前已经做得不错的地方**：
  - 多数图片都在构造时一次性 `loadImage` 并 `resize`，运行中没有重复缩放。
  - 使用 `P2D` 渲染器和 `texture()`，图像管线相对高效。
- **进一步可行的优化**：
  - 粒子系统使用预分配数组而不是频繁 new（尤其是大量红包、火花之类）。
  - 减少 `stripCount` 或根据机能动态调整地面细分（如 60/90/120 三档）。
  - 控制远景物体数量（云、山云、灯笼），按画面需求设置合理上限。

结合上述新架构，在你后续加入大量素材和动效时，每一个新效果只需要：

1. 在独立的 `.pde` 中定义一个 `SceneObject` 子类（必要时实现 `BeatListener`）。
2. 在主场景 `setup()` 中注册到 `Scene` 和（可选）`BeatDispatcher`。

这样既能保持文件独立运行/调试，又确保所有动画都挂在统一的时间与事件系统上，音画同步问题也更容易整体把控。

