import processing.sound.*;
import java.util.ArrayList;

// ==================== 全局配置 ====================
// 设为 true 时运行测试草图（按键 1-0 触发效果），不加载音乐与场景
boolean TEST_MODE = false;
// 设为 true 时运行柱子与栏杆对齐调试（test_zhuzi），不加载音乐与场景
boolean TEST_ZHUZI = false;
// 设为 true 时运行烟花测试（test_firework），调试爆炸音效与粒子动画
boolean TEST_FIREWORK = false;
// 设为 false 时隐藏左侧调试文字与底部自动跳跃时间条；需要调试时改回 true
boolean SHOW_DEBUG_UI = false;
// 调试：从歌曲最后 N 秒开始播放（仅测试结尾段时用）；0 = 从头播放。例如设为 15 则直接播最后 15 秒（绶带/烟花/马到成功/起扬）
float DEBUG_JUMP_TO_LAST_SEC = 0;

String folderName = "C:/Users/Admin/Documents/Processing/project/project-pony/output";
String musicFile = "C:/Users/Admin/Documents/Processing/project/project-pony/assets/song/马年大吉.wav";

// ==================== 小马动画参数 ====================
String runPrefix = "/run-v4/run-v4_";
int runTotalFrames = 6;
float beatsPerRunCycle = 1.0;

String jumpPrefix = "/jump-mid-v4/jump-mid-v4_";
int jumpTotalFrames = 23;
float beatsForRemainingJump = 3.0;

String qiyangPrefix = "/qiyang/qiyang_";
// 起扬参数统一在 AnimationConfig.pde：QIYANG_TOTAL_FRAMES / START / END / LOOP_START / FPS / LOOP_FPS
float beatsForQiyang = 20;

float bpm = 129.0;

// ==================== 小马状态 ====================
PImage[] runFrames;
PImage[] jumpFrames;
PImage[] qiyangFrames;
SoundFile song;
PonyController pony;

// 音乐驱动的时间与场景系统
MusicClock musicClock;
Scene mainScene;
BeatDispatcher beatDispatcher;
// 是否强制用音乐时间做主时间轴（建议在实时演示时开启）
boolean syncToMusic = true;

// ==================== 时间系统 ====================
boolean isPaused = false;
float animTime = 0;
float timeSpeed = 1.0;
int prevMillis = 0;

// ==================== 动画层系统 ====================
PImage backgroundImage;
PImage skyFilterImage;
CloudLayer cloudLayer;
  MountainLayer mountainLayer;
  ZhuziLayer zhuziLayer;
DenglongManager denglongManager;
PillarManager pillarManager;
FirecrackerManager firecrackerManager;
FireworkManager fireworkManager;
StoneManager stoneManager;
MoneyEffect moneyEffect;
GroundManager groundManager;
RoadsideLayer roadsideLayer;
LuckyBagManager luckyBagManager;
BlessingSpriteManager blessingSpriteManager;
int nextOtherAnimationIndex = 0;
int nextJumpTriggerIndex = 0;
boolean qiyangTriggered = false;
float successTriggeredTime = -1;  // 马到成功触发时刻（仅记录）；起扬由 qiyangTime 时间点触发
boolean backgroundFrozen = false;  // 起扬到 qiyang_64 时置 true，所有背景速度归 0
int currentBeatIndex = 0;         // 当前拍号，供灯笼/柱子/鞭炮按 beat 间隔生成
boolean fireworkActive = false;   // 马到成功前 N 秒起持续放烟花
float fireworkSpawnAccum = 0;     // 连续烟花间隔计时
ShoudaiRibbon shoudaiRibbon;      // 绶带：从右向左 FORGE_SPEED 运动，碰胸口触发马到成功
boolean shoudaiRibbonSpawned = false;

// 娱乐模式：开口福袋光标，按住/划动爆金币
boolean entertainmentMode = false;
PImage entertainmentCursorImg = null;
PImage cursorFingerImg = null;  // 手指素材，替换默认鼠标图标
float lastEntertainSpawnX = -9999;
float lastEntertainSpawnY = -9999;
// Hold 模式：按住鼠标时从鼠标位置持续倾泻元宝/钱币/红包（任意位置均可）；默认未按住
boolean mouseHeld = false;
float holdSpawnAccumulator = 0;

// ==================== 跳跃高度计算 ====================
float getJumpHeight(float progress) {
  float jumpProgress = progress;
  if (jumpProgress > 1.0) jumpProgress = 1.0;
  if (jumpProgress < 0) jumpProgress = 0;

  return sin(jumpProgress * PI) * PONY_JUMP_HEIGHT;
}

// 小马头顶在跳跃最高点时的 Y（用于礼盒垂直对齐）；与 getJumpHeight(JUMP_APEX_FRACTION) + PONY_HEAD_OFFSET_Y 一致
float getPonyHeadApexY() {
  float apexHeight = sin(JUMP_APEX_FRACTION * PI) * PONY_JUMP_HEIGHT;
  return PONY_Y - apexHeight + PONY_HEAD_OFFSET_Y;
}

// 起跳请求提前量（秒）：JSON 里读到 T 后，要在 T - 此值 时 requestJump。
// = 最长等待 run 到过渡帧（1 beat）+ 起跳到最高点时间（JUMP_APEX_FRACTION * 跳跃总时长）
float getJumpRequestLeadTimeSec() {
  float runCycleSec = (60.0f / bpm) * beatsPerRunCycle;
  float jumpApexSec = (60.0f / bpm) * beatsForRemainingJump * JUMP_APEX_FRACTION;
  return runCycleSec + jumpApexSec;
}

// 福袋顶到后触发的精灵动画（小象/金钱/福等），由 LuckyBagManager 调用
void spawnBlessingSprite(String type, float x, float y) {
  if (blessingSpriteManager != null) blessingSpriteManager.spawn(type, x, y);
}

// 礼盒击中：从礼盒位置由小放大飞到小马背上（目标位置由 BlessingConfig 偏移决定）
void spawnBlessingSpriteFromBox(String type, float boxX, float boxY) {
  // 马背上精灵落点按 BlessingConfig：相对 (PONY_X, PONY_Y)，用 PONY_X/PONY_Y 计算
  if (blessingSpriteManager != null) blessingSpriteManager.spawnFromBox(type, boxX, boxY, PONY_X, PONY_Y);
}

// 马上起飞：在马背两侧生成双火箭（由 LuckyBagManager 碰撞 fly 礼盒时调用）
void spawnFlyRocketsAtPony() {
  if (blessingSpriteManager == null) return;
  blessingSpriteManager.spawn("fly_back", PONY_X + ROCKET_OFFSET_BEHIND_X, PONY_Y + ROCKET_BEHIND_Y, BLESSING_SPRITE_DURATION);
  blessingSpriteManager.spawn("fly_front", PONY_X + ROCKET_OFFSET_FRONT_X, PONY_Y + ROCKET_FRONT_Y, BLESSING_SPRITE_DURATION);
}

void setup() {
  size(800, 600);
  frameRate(60);
  if (TEST_ZHUZI) {
    testZhuziSetup();
    prevMillis = millis();
    return;
  }
  if (TEST_FIREWORK) {
    testFireworkSetup();
    prevMillis = millis();
    return;
  }
  if (TEST_MODE) {
    testSetup();
    blessingSpriteManager = new BlessingSpriteManager();
    blessingSpriteManager.loadSprites();
    return;
  }

  // 使用默认 JAVA2D 渲染器，避免 P2D/OpenGL 在大图纹理上传时的 5 秒超时
  runFrames = new PImage[runTotalFrames];
  for (int i = 0; i < runTotalFrames; i++) {
    runFrames[i] = loadImage(folderName + runPrefix + nf(i, 2) + ".png");
  }

  jumpFrames = new PImage[jumpTotalFrames];
  for (int i = 0; i < jumpTotalFrames; i++) {
    jumpFrames[i] = loadImage(folderName + jumpPrefix + nf(i, 2) + ".png");
  }

  qiyangFrames = new PImage[QIYANG_TOTAL_FRAMES];
  for (int i = 0; i < QIYANG_TOTAL_FRAMES; i++) {
    qiyangFrames[i] = loadImage(folderName + qiyangPrefix + nf(i, 2) + ".png");
  }

  backgroundImage = loadImage(BACKGROUND_PATH);
  skyFilterImage = loadImage(SKY_FILTER_PATH);
  cloudLayer = new CloudLayer();
  mountainLayer = new MountainLayer();
  zhuziLayer = new ZhuziLayer();
  denglongManager = new DenglongManager();
  pillarManager = new PillarManager();
  firecrackerManager = new FirecrackerManager();
  fireworkManager = new FireworkManager();
  stoneManager = new StoneManager();
  moneyEffect = new MoneyEffect();
  groundManager = new GroundManager();
  roadsideLayer = new RoadsideLayer();
  loadBlessingsTimeline();
  initBlessingFont();
  luckyBagManager = new LuckyBagManager();
  blessingSpriteManager = new BlessingSpriteManager();
  PImage[] shoudaiFrames = new PImage[OUTPUT_SHOUDAI_COUNT];
  for (int i = 0; i < OUTPUT_SHOUDAI_COUNT; i++) {
    shoudaiFrames[i] = loadImage(folderName + "/" + OUTPUT_SHOUDAI_PREFIX + nf(i, 2) + OUTPUT_FRAME_SUFFIX);
  }
  shoudaiRibbon = new ShoudaiRibbon(shoudaiFrames, SHOUDAI_RIBBON_FPS, FORGE_SPEED, SHOUDAI_RIBBON_SCALE);

  // 娱乐模式光标图（开口福袋），优先用专用图，否则用福袋图
  entertainmentCursorImg = loadImage(ENTERTAINMENT_CURSOR_PATH);
  if (entertainmentCursorImg == null || entertainmentCursorImg.width <= 0) {
    entertainmentCursorImg = loadImage(LUCKY_BAG_IMAGE_PATH);
  }
  if (entertainmentCursorImg != null && entertainmentCursorImg.width > 0) {
    int w = (int)ENTERTAINMENT_CURSOR_SIZE;
    int h = (int)((float)entertainmentCursorImg.height * w / entertainmentCursorImg.width);
    if (h > (int)(ENTERTAINMENT_CURSOR_SIZE * 1.5f)) h = (int)(ENTERTAINMENT_CURSOR_SIZE * 1.5f);
    entertainmentCursorImg.resize(w, h);
  }

  // 手指光标图（替换默认鼠标图标）
  cursorFingerImg = loadImage(CURSOR_FINGER_PATH);
  if (cursorFingerImg != null && cursorFingerImg.width > 0) {
    int w = (int)CURSOR_FINGER_SIZE;
    int h = (int)((float)cursorFingerImg.height * w / cursorFingerImg.width);
    cursorFingerImg.resize(w, h);
  }

  song = new SoundFile(this, musicFile);
  song.play();  // 不循环，音乐播完就结束

  // 调试：从最后 N 秒开始，便于只测结尾（绶带/烟花/马到成功/起扬）
  if (DEBUG_JUMP_TO_LAST_SEC > 0 && song.duration() > 0) {
    float startTime = max(0, song.duration() - DEBUG_JUMP_TO_LAST_SEC);
    song.jump(startTime);
    // 时间轴索引对齐到 startTime，避免一帧内触发前面所有事件
    float jumpLead = getJumpRequestLeadTimeSec();
    while (nextJumpTriggerIndex < getTimelineHitTimeCount() && getTimelineHitTime(nextJumpTriggerIndex) - jumpLead <= startTime) {
      nextJumpTriggerIndex++;
    }
    JSONArray otherArr = getTimelineOtherAnimations();
    while (nextOtherAnimationIndex < otherArr.size() && otherArr.getJSONObject(nextOtherAnimationIndex).getFloat("time") <= startTime) {
      nextOtherAnimationIndex++;
    }
    println("[DEBUG] Jumped to last " + DEBUG_JUMP_TO_LAST_SEC + "s, startTime=" + nf(startTime, 0, 2) + "s, duration=" + nf(song.duration(), 0, 2) + "s");
  }

  // 初始化音乐时钟与场景系统
  musicClock = new MusicClock(song, bpm);
  mainScene = new Scene();
  beatDispatcher = new BeatDispatcher();

  // 小马控制器（基于音乐时间驱动的跑/跳/起扬 FSM）
  pony = new PonyController(runFrames, jumpFrames, qiyangFrames, bpm, beatsPerRunCycle, beatsForRemainingJump, beatsForQiyang, QIYANG_START_FRAME, QIYANG_END_FRAME, QIYANG_LOOP_START_FRAME, QIYANG_LOOP_FPS);

  // 图层顺序（从远到近）：云(山后) → 山 → 云(山前) → 地面 → 路边近景 → …
  mainScene.add(new CloudLayerBackObject(cloudLayer));
  mainScene.add(new MountainLayerObject(mountainLayer));
  mainScene.add(new CloudLayerFrontObject(cloudLayer));
  mainScene.add(new FireworkManagerObject(fireworkManager));  // 烟花在柱子前，被 zhuzi 遮挡
  mainScene.add(new ZhuziLayerObject(zhuziLayer));
  mainScene.add(new GroundManagerObject(groundManager));
  mainScene.add(new RoadsideBackObject(roadsideLayer));   // 花 + 栏杆（中景）
  mainScene.add(new ShoudaiRibbonObject(shoudaiRibbon));   // 绶带：在花/栏杆之上，在护栏/草之下
  mainScene.add(new RoadsideFrontObject(roadsideLayer));  // 护栏 + 草（前景）
  mainScene.add(new DenglongManagerObject(denglongManager));
  mainScene.add(new PillarManagerObject(pillarManager));
  mainScene.add(new FirecrackerManagerObject(firecrackerManager));
  mainScene.add(new BlessingSpritesBackObject(blessingSpriteManager)); // 火箭 fly_back 等：画在小马后
  mainScene.add(pony);
  mainScene.add(new StoneManagerObject(stoneManager));
  mainScene.add(new MoneyEffectObject(moneyEffect));

  // 注册需要响应整拍事件的对象
  beatDispatcher.addListener(pony);

  prevMillis = millis();
  println(">>> 点击小马可触发金币红包；任意位置按住鼠标可从该处持续倾泻元宝/钱币/红包");
}

void draw() {
  if (TEST_ZHUZI) {
    int currMillis = millis();
    float dt = (currMillis - prevMillis) / 1000.0f;
    prevMillis = currMillis;
    testZhuziUpdate(dt);
    testZhuziDraw();
    return;
  }
  if (TEST_FIREWORK) {
    testFireworkDraw();
    return;
  }
  if (TEST_MODE) {
    testDraw();
    return;
  }

  int currMillis = millis();
  float dt = (currMillis - prevMillis) / 1000.0;
  prevMillis = currMillis;

  if (musicClock != null) musicClock.update(dt);

  // Hold 模式：按住鼠标时从鼠标位置持续倾泻元宝/钱币/红包（与点击同逻辑，从鼠标处倒出）
  if (mouseHeld && moneyEffect != null) {
    holdSpawnAccumulator += dt;
    while (holdSpawnAccumulator >= HOLD_SPAWN_INTERVAL) {
      moneyEffect.spawn(mouseX, mouseY);
      holdSpawnAccumulator -= HOLD_SPAWN_INTERVAL;
    }
  }

  // 主时间轴：优先跟随音乐，保证长时间播放也不会音画漂移
  if (!isPaused) {
    if (syncToMusic && musicClock != null) {
      animTime = musicClock.musicTime;
    } else {
      animTime += dt * timeSpeed;
    }
  }

  if (animTime < 0) animTime = 0;

  if (!isPaused) {
    if (musicClock != null) currentBeatIndex = musicClock.beatIndex;
    if (beatDispatcher != null && musicClock != null) {
      beatDispatcher.update(musicClock);
    }

    // 使用场景统一更新各层和所有对象（内部仍然是按 dt 更新，兼容旧逻辑）
    if (mainScene != null) {
      float musicTime = (musicClock != null) ? musicClock.musicTime : animTime;
      float beat = (musicClock != null) ? musicClock.beat : 0;
      mainScene.updateAll(dt, musicTime, beat);
    }

    // 起扬到 QIYANG_END_FRAME 时冻结所有背景（速度归 0，到终点）
    if (pony != null && pony.getStateLabel().equals("QIYANG") && pony.getCurrentFrameIndex() >= QIYANG_END_FRAME) {
      backgroundFrozen = true;
    }

    float musicTime = (musicClock != null) ? musicClock.musicTime : animTime;
    // 起跳触发：JSON 的 time = T（小马应在最高点撞到的时刻）。requestJump 后要等 run 到过渡帧才真正起跳，再经 jumpApexTime 到最高点。
    // 所以提前量 = 最长等待 run 一周期 + 起跳到最高点时间
    float jumpRequestLeadSec = getJumpRequestLeadTimeSec();
    while (nextJumpTriggerIndex < getTimelineHitTimeCount() && musicTime >= getTimelineHitTime(nextJumpTriggerIndex) - jumpRequestLeadSec && pony != null) {
      pony.requestJump();
      println("[AUTO] Jump trigger for hit at " + nf(getTimelineHitTime(nextJumpTriggerIndex), 0, 2) + "s (musicTime " + nf(musicTime, 0, 2) + "s)");
      nextJumpTriggerIndex++;
    }
    float ponyHeadX = PONY_X + PONY_HEAD_OFFSET_X;
    float ponyHeadY = PONY_Y - getJumpHeight(pony != null ? pony.getCurrentProgress() : 0) + PONY_HEAD_OFFSET_Y;
    boolean ponyIsJumping = (pony != null && pony.getStateLabel().equals("JUMP"));
    if (luckyBagManager != null) {
      luckyBagManager.update(dt, musicTime, ponyHeadX, ponyHeadY, ponyIsJumping);
    }

    for (Stone s : stoneManager.getStones()) {
      if (!s.isCleared() && s.getRightEdge() < PONY_X - 80 && pony != null && pony.getStateLabel().equals("RUN")) {
        s.setCleared();
        spawnBouncyWord(getStonePhrase(s.getTextIndex()), PONY_X + PONY_CHEST_OFFSET_X, PONY_Y + PONY_CHEST_OFFSET_Y, null);
      }
    }

    // 绶带：blessings_timeline.json 里 success 的 time（如 79.2）表示该时刻绶带中心与 PONY_CHEST 相碰并触发
    // leadTime = 从画面右侧到胸口所需时间，提前在 successTime - leadTime 开始画并左移，到 79.2 时正好相碰
    float successTime = getTimelineSuccessTime();
    float ribbonLeadTime = getShoudaiRibbonLeadTime();
    if (successTime < 99998 && musicTime >= successTime - ribbonLeadTime && !shoudaiRibbonSpawned && shoudaiRibbon != null) {
      float spawnX = width + SHOUDAI_RIBBON_SPAWN_MARGIN + SHOUDAI_RIBBON_OFFSET_X;
      float spawnY = SHOUDAI_RIBBON_BASE_Y + SHOUDAI_RIBBON_OFFSET_Y;
      shoudaiRibbon.spawn(spawnX, spawnY);
      shoudaiRibbonSpawned = true;
    }
    if (shoudaiRibbon != null && shoudaiRibbon.isActive()) {
      float hitX = PONY_X + PONY_CHEST_OFFSET_X + SHOUDAI_HIT_OFFSET_X;
      if (shoudaiRibbon.hitChest(hitX) && !shoudaiRibbon.hasAlreadyTriggeredSuccess()) {
        shoudaiRibbon.setTriggeredSuccess();
        spawnBouncyWord(getBlessingPhrase("success"), PONY_X + PONY_CHEST_OFFSET_X, PONY_Y + PONY_CHEST_OFFSET_Y, null);
        if (firecrackerManager != null) firecrackerManager.spawnBurst(BLESSING_SUCCESS_FIRECRACKER_BURST_COUNT);
        successTriggeredTime = musicTime;
        // success 只保留绶带 + 字 + 鞭炮，不再 spawn 任何 shoudai 精灵，避免出现第二次 shoudai
      }
      if (shoudaiRibbon.isOffScreenLeft()) {
        shoudaiRibbon.deactivate();
      }
    }

    JSONArray otherArr = getTimelineOtherAnimations();
    while (nextOtherAnimationIndex < otherArr.size()) {
      JSONObject ev = otherArr.getJSONObject(nextOtherAnimationIndex);
      if (musicTime < ev.getFloat("time")) break;
      String type = ev.getString("type");
      if (type.equals("success")) {
        // 马到成功由绶带碰胸口触发，此处只推进索引
        nextOtherAnimationIndex++;
        continue;
      }
      // 仅 success 时配 shoudai 素材（绶带触发展示）；daji 只显示「马年大吉」文字 + 烟花，不再出现 shoudai 动画
      PImage asset = type.equals("daji") ? null : loadBlessingAsset(type);
      spawnBouncyWord(getBlessingPhrase(type), PONY_X + PONY_CHEST_OFFSET_X, PONY_Y + PONY_CHEST_OFFSET_Y, asset);
      if (type.equals("daji")) {
        if (fireworkManager != null) fireworkManager.spawnBurst(BLESSING_DAJI_FIREWORK_COUNT);
      }
      nextOtherAnimationIndex++;
    }

    // 烟花：仅在 success 前 3 秒开始放，之后持续到关闭（successTime 已在上面用过）
    if (successTime < 99998 && musicTime >= successTime - FIREWORK_SUCCESS_LEAD_SEC) {
      fireworkActive = true;
    }
    if (fireworkActive && fireworkManager != null) {
      fireworkSpawnAccum += dt;
      while (fireworkSpawnAccum >= FIREWORK_SUCCESS_SPAWN_INTERVAL) {
        fireworkSpawnAccum -= FIREWORK_SUCCESS_SPAWN_INTERVAL;
        fireworkManager.spawnFirework();
      }
    }

    // 起扬触发：仅由时间轴 qiyangTime 触发，与 success/daji 无关
    float qiyangTriggerTime = getTimelineQiyangTime();
    if (song != null && song.duration() > 0 && QIYANG_TRIGGER_SECONDS_BEFORE_END > 0) {
      float triggerByEnd = song.duration() - QIYANG_TRIGGER_SECONDS_BEFORE_END;
      if (triggerByEnd < qiyangTriggerTime) qiyangTriggerTime = triggerByEnd;
    }
    if (!qiyangTriggered && musicTime >= qiyangTriggerTime && pony != null) {
      pony.requestQiyang();
      qiyangTriggered = true;
      println("[Qiyang] triggered at " + nf(musicTime, 0, 2) + "s (trigger time " + nf(qiyangTriggerTime, 0, 2) + "s)");
    }

    updateBouncyWord(dt);
    if (blessingSpriteManager != null) blessingSpriteManager.update(dt);
  }

  float musicTimeForDraw = (musicClock != null ? musicClock.musicTime : animTime);
  drawBackground(musicTimeForDraw);
  drawSkyFilter(musicTimeForDraw);
  // 场景负责绘制所有背景/中景/前景层（包括小马和金币特效）
  if (mainScene != null) {
    mainScene.drawAll();
  } else {
    // 容错：如果场景未初始化，按图层顺序绘制（云后→山→云前）
    cloudLayer.displayBack();
    mountainLayer.display();
    cloudLayer.displayFront();
    groundManager.display();
    if (roadsideLayer != null) roadsideLayer.display();
    denglongManager.display();
    if (pony != null) pony.draw();
    stoneManager.display();
    moneyEffect.display();
  }

  if (luckyBagManager != null) luckyBagManager.display();
  drawBouncyWord();
  if (blessingSpriteManager != null) blessingSpriteManager.display();

  int frameIdx = pony != null ? pony.getCurrentFrameIndex() : 0;
  float prog = pony != null ? pony.getCurrentProgress() : 0;
  if (SHOW_DEBUG_UI) {
    drawDebugUI(frameIdx, prog);
    drawTimeline();
  }

  // 自定义光标：隐藏系统鼠标，用手指或娱乐模式福袋图
  noCursor();
  if (entertainmentMode) {
    if (entertainmentCursorImg != null && entertainmentCursorImg.width > 0) {
      imageMode(CENTER);
      image(entertainmentCursorImg, mouseX, mouseY);
    } else {
      fill(255, 200, 0);
      noStroke();
      circle(mouseX, mouseY, ENTERTAINMENT_CURSOR_SIZE);
    }
  } else if (cursorFingerImg != null && cursorFingerImg.width > 0) {
    imageMode(CENTER);
    image(cursorFingerImg, mouseX, mouseY);
  } else {
    cursor();
  }
}

void drawBackground(float musicTime) {
  background(240);
  if (backgroundImage == null || backgroundImage.width <= 0) return;
  float progress = 0;
  if (BACKGROUND_FADE_DURATION > 0 && musicTime >= BACKGROUND_FADE_START_SEC) {
    progress = (musicTime - BACKGROUND_FADE_START_SEC) / BACKGROUND_FADE_DURATION;
    if (progress > 1.0f) progress = 1.0f;
  }
  float opacity = BACKGROUND_OPACITY_START + (BACKGROUND_OPACITY_END - BACKGROUND_OPACITY_START) * progress;
  if (opacity <= 0) return;
  int alpha = (int)(255 * opacity);
  if (alpha > 255) alpha = 255;
  tint(255, 255, 255, alpha);
  imageMode(CORNER);
  image(backgroundImage, 0, 0, width, height);
  noTint();
}

void drawSkyFilter(float musicTime) {
  if (skyFilterImage == null || skyFilterImage.width <= 0) return;
  float progress = 0;
  if (musicTime >= SKY_FILTER_START_SEC && SKY_FILTER_FADE_DURATION > 0) {
    progress = (musicTime - SKY_FILTER_START_SEC) / SKY_FILTER_FADE_DURATION;
    if (progress > 1.0f) progress = 1.0f;
  }
  float opacity = SKY_FILTER_OPACITY_START + (SKY_FILTER_OPACITY_END - SKY_FILTER_OPACITY_START) * progress;
  if (opacity <= 0) return;
  int alpha = (int)(255 * opacity);
  if (alpha > 255) alpha = 255;
  tint(255, 255, 255, alpha);
  imageMode(CORNER);
  image(skyFilterImage, 0, 0, width, height);
  noTint();
}

void drawPony(PImage img) {
  if (img != null) {
    pushMatrix();
    translate(PONY_X, PONY_Y);
    scale(PONY_SCALE);
    imageMode(CENTER);
    image(img, 0, 0);
    popMatrix();
  }
}

void drawWaitingIcon() {
  fill(255, 100, 100);
  noStroke();
  circle(PONY_X, PONY_Y - 180, 20);
}

void drawTimeline() {
  if (pony == null || !pony.isTestMode()) return;
  stroke(180);
  line(50, height - 50, width - 50, height - 50);
  float timelineScale = (width - 100) / 15.0;

  float[] timeline = pony.getJumpTimeline();
  int nextIndex = pony.getNextTestIndex();

  for (int i = 0; i < timeline.length; i++) {
    float x = 50 + timeline[i] * timelineScale;
    fill(0);
    noStroke();
    circle(x, height - 50, 8);
    if (i == nextIndex - 1) {
      fill(0, 255, 0);
      circle(x, height - 50, 6);
    }
  }

  float cx = 50 + animTime * timelineScale;
  if (cx < width - 50) {
    stroke(255, 0, 0);
    line(cx, height - 60, cx, height - 40);
  }
}

void drawDebugUI(int frameIdx, float prog) {
  fill(0, 150);
  noStroke();
  rect(0, 0, 280, 320);
  fill(255);
  textAlign(LEFT, TOP);
  textSize(14);
  if (blessingFont != null) textFont(blessingFont);
  int y = 10;
  int dy = 20;

  String modeLabel = (pony != null && pony.isTestMode()) ? "[AUTO TEST MODE]" : "[MANUAL MODE]";
  text(modeLabel, 10, y);
  y += dy * 1.5;
  float t = (musicClock != null) ? musicClock.musicTime : animTime;
  text("Time: " + nf(t, 0, 2) + "s", 10, y);
  y += dy;
  String stateLabel = pony != null ? pony.getStateLabel() : "N/A";
  text("Status: " + stateLabel, 10, y);
  y += dy;
  text("Paused: " + isPaused, 10, y);
  y += dy;

  text("Frame Index: " + frameIdx, 10, y);
  y += dy;
  text("Progress: " + nf(prog * 100, 0, 1) + "%", 10, y);
  y += dy;

  if (pony != null) {
    text("Run Offset: " + nf(pony.getRunCycleOffset(), 0, 2) + "s", 10, y);
    y += dy;
  }

  y += dy;
  text("=== 动画层统计 ===", 10, y);
  y += dy;
  text("云朵: " + cloudLayer.getCloudCount(), 10, y);
  y += dy;
  text("灯笼: " + denglongManager.getCount(), 10, y);
  y += dy;
  text("石头: " + stoneManager.getCount(), 10, y);
  y += dy;
  text("粒子: " + moneyEffect.getParticleCount(), 10, y);
  y += dy;

  if (entertainmentMode) {
    fill(255, 220, 0);
    text("娱乐模式: 开（按 E 关闭）", 10, y += dy);
    text("按住/划动鼠标 = 爆金币红包；任意位置按住 = 从该处倾泻元宝/钱币/红包", 10, y += dy);
  } else {
    text("按 E 开启娱乐模式（福袋光标+划动爆金币）", 10, y += dy);
  }
  y += dy;
  fill(255, 255, 0);
  text("按 T 切换 测试/手动 模式", 10, y += dy);
  text("按 P 暂停", 10, y += dy);
  text("按 空格 手动跳跃", 10, y += dy);
  text("按 S 切换自动跳跃", 10, y += dy);
  text("按 Q 触发起扬（测试）", 10, y += dy);
  text("点击小马触发特效", 10, y += dy);
  text("暂停时按 ←/→ 逐帧", 10, y += dy);
}

void keyPressed() {
  if (TEST_ZHUZI) {
    if (key == ' ') spawnZhuziAtNearestRailing();
    return;
  }
  if (TEST_FIREWORK) {
    testFireworkKeyPressed();
    return;
  }
  if (TEST_MODE) {
    testKeyPressed();
    return;
  }
  if (key == 'e' || key == 'E') {
    entertainmentMode = !entertainmentMode;
  }
  if (key == ' ') {
    if (pony != null) pony.requestJump();
  }
  if (key == 'q' || key == 'Q') {
    if (pony != null) {
      pony.requestQiyang();
      println("[测试] 按 Q 触发起扬");
    }
  }
  if (key == 't' || key == 'T') {
    if (pony != null) pony.toggleTestMode();
  }
  if (key == 'p' || key == 'P') {
    isPaused = !isPaused;
    if (isPaused) song.pause();
    else song.loop();
  }
  if (key == 's' || key == 'S') {
    stoneManager.setAutoJumpEnabled(!stoneManager.isAutoJumpEnabled());
    println("自动跳跃: " + stoneManager.isAutoJumpEnabled());
  }

  if (key == CODED) {
    float step = 1.0 / 60.0;
    if (keyCode == RIGHT) {
      if (isPaused) animTime += step;
    } else if (keyCode == LEFT) {
      if (isPaused) animTime -= step;
    }

    if (animTime < 0) animTime = 0;
  }
}

void mousePressed() {
  if (TEST_FIREWORK) {
    testFireworkMousePressed();
    return;
  }
  mouseHeld = true;
  holdSpawnAccumulator = 0;
  if (entertainmentMode) {
    moneyEffect.spawn(mouseX, mouseY);
    lastEntertainSpawnX = mouseX;
    lastEntertainSpawnY = mouseY;
  } else if (pony != null && pony.isMouseOver(mouseX, mouseY)) {
    moneyEffect.spawn(PONY_X, PONY_Y);
    println("触发金币红包特效!");
  } else {
    // Hold 模式：非娱乐模式且未点中小马时，也从鼠标位置先喷一批
    moneyEffect.spawn(mouseX, mouseY);
  }
}

void mouseReleased() {
  mouseHeld = false;
}

void mouseDragged() {
  if (entertainmentMode && dist(mouseX, mouseY, lastEntertainSpawnX, lastEntertainSpawnY) >= ENTERTAINMENT_SPAWN_STEP) {
    moneyEffect.spawn(mouseX, mouseY);
    lastEntertainSpawnX = mouseX;
    lastEntertainSpawnY = mouseY;
  }
}
