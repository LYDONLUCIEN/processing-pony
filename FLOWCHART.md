## 逻辑架构流程图（可渲染）

下面的流程图使用 Mermaid 语法书写，可在支持 Mermaid 的编辑器 / 平台中直接渲染。

---

### 1. 模块关系总览

```mermaid
flowchart TD
  %% 顶层
  A["Processing Runtime\nnew_state/new_state.pde"] --> B["初始化\nsize()/frameRate()/加载资源"]
  B --> C["MusicClock\nMusicClock.pde"]
  B --> D["Scene & SceneObject\nSceneCore.pde"]
  B --> E["BeatDispatcher\nSceneCore.pde"]
  B --> F["Config 常量\nAnimationConfig.pde"]

  %% 场景内对象
  D --> G["CloudLayerObject\n包装 CloudLayer"]
  D --> H["MountainLayerObject\n包装 MountainLayer"]
  D --> I["DenglongManagerObject\n包装 DenglongManager"]
  D --> J["GroundManagerObject\n包装 GroundManager"]
  D --> K["StoneManagerObject\n包装 StoneManager"]
  D --> L["PonyController\n小马跑/跳控制器"]
  D --> M["MoneyEffectObject\n包装 MoneyEffect"]
  D --> N["未来: BouncyTextEffect\nSceneObject"]

  %% 底层动效实现
  G --- G1["CloudLayer.pde"]
  H --- H1["MountainLayer.pde"]
  I --- I1["DenglongManager.pde"]
  J --- J1["GroundManager.pde"]
  K --- K1["StoneManager.pde"]
  M --- M1["MoneyEffect.pde"]

  %% 工具与参考
  O["slicer.pde\n素材切片工具"] --> P["输出帧 PNG\n存到 /output"]
  P --> B

  Q["reference/*.pde\n参考动效示例"] --> M
```

---

### 2. 每帧渲染主流程

```mermaid
flowchart TD
  subgraph R["draw() 主循环 - new_state.pde"]
    R1["计算 dt\ncurrMillis - prevMillis"]
    R2["更新 MusicClock\nmusicClock.update()"]
    R3["根据 syncToMusic\n更新 animTime"]
    R4["BeatDispatcher.update(musicClock)"]
    R5["Scene.updateAll(dt,musicTime,beat)"]
    R6["绘制背景 drawBackground()"]
    R7["Scene.drawAll() // 包含云/山/灯笼/地面/石头/小马/金币"]
    R8["绘制调试 UI & 时间轴"]
  end

  R1 --> R2 --> R3 --> R4 --> R5 --> R6 --> R7 --> R8
```

---

### 3. Scene / SceneObject 内部更新流程

```mermaid
flowchart TD
  S["Scene.updateAll(dt,musicTime,beat)"] --> S1{"遍历 objects 列表"}
  S1 -->|active == false| S2["调用 onDestroy() 然后从列表移除"]
  S1 -->|active == true| S3["调用对象 update(dt,musicTime,beat)"]
  S3 --> S4["继续下一个对象"]
```

---

### 4. BeatDispatcher 节拍分发流程

```mermaid
flowchart TD
  T["BeatDispatcher.update(clock)"] --> T1["clock.beatIndex 是否变化?"]
  T1 -->|否| T2[什么也不做]
  T1 -->|是| T3[更新 lastBeatIndex]
  T3 --> T4["遍历 listeners"]
  T4 --> T5["对每个监听者 调用 onBeat(beatIndex,musicTime)"]
```

---

### 5. 典型“新动效模块”接入关系

```mermaid
flowchart TD
  U["新动效文件\nMyEffect.pde"] --> U1["定义 class MyEffect\nextends SceneObject\n可选实现 BeatListener"]
  U1 --> U2["构造函数中加载资源\n使用 AnimationConfig 常量"]

  V["主场景 setup()"] --> V1["创建 MyEffect 实例"]
  V1 --> V2["mainScene.add(myEffect)"]
  V1 --> V3{是否需要对拍?}
  V3 -->|是| V4["beatDispatcher.addListener(myEffect)"]
  V3 -->|否| V5["只被 Scene 管理 update/draw"]
```

---

### 6. 素材生成与运行时的关系

```mermaid
flowchart TD
  W["slicer/slicer.pde"] --> W1["读取大精灵图\n按行列切帧"]
  W1 --> W2["应用 cropPercentage 裁剪边缘"]
  W2 --> W3["保存 PNG 到 /output\n使用统一前缀 run/jump 等"]

  W3 --> X["运行时 new_state.pde"]
  X --> X1["根据 runPrefix/jumpPrefix\n加载帧数组"]
  X1 --> X2["在 PonyController\n或当前状态机中驱动播放"]
```

