import processing.sound.*;
import java.util.ArrayList;

// ==================== 全局配置 ====================
String folderName = "C:/Users/Admin/Documents/Processing/project/project-pony/output";
String musicFile = "C:/Users/Admin/Documents/Processing/project/project-pony/assets/song/马年可爱风.mp3";

// ==================== 小马动画参数 ====================
String runPrefix = "/run-v4/run-v4_";
int runTotalFrames = 6;
float beatsPerRunCycle = 1.0;

String jumpPrefix = "/jump-mid-v4/jump-mid-v4_";
int jumpTotalFrames = 23;
float beatsForRemainingJump = 3.0;

float bpm = 125.0;

// ==================== 小马状态 ====================
PImage[] runFrames;
PImage[] jumpFrames;
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
CloudLayer cloudLayer;
MountainLayer mountainLayer;
DenglongManager denglongManager;
StoneManager stoneManager;
MoneyEffect moneyEffect;
GroundManager groundManager;
RoadsideLayer roadsideLayer;

// ==================== 跳跃高度计算 ====================
float getJumpHeight(float progress) {
  float jumpProgress = progress;
  if (jumpProgress > 1.0) jumpProgress = 1.0;
  if (jumpProgress < 0) jumpProgress = 0;

  return sin(jumpProgress * PI) * PONY_JUMP_HEIGHT;
}

void setup() {
  // 使用默认 JAVA2D 渲染器，避免 P2D/OpenGL 在大图纹理上传时的 5 秒超时；JAVA2D 同样支持 texture()
  size(800, 600);
  frameRate(60);

  runFrames = new PImage[runTotalFrames];
  for (int i = 0; i < runTotalFrames; i++) {
    runFrames[i] = loadImage(folderName + runPrefix + nf(i, 2) + ".png");
  }

  jumpFrames = new PImage[jumpTotalFrames];
  for (int i = 0; i < jumpTotalFrames; i++) {
    jumpFrames[i] = loadImage(folderName + jumpPrefix + nf(i, 2) + ".png");
  }

  backgroundImage = loadImage(BACKGROUND_PATH);

  cloudLayer = new CloudLayer();
  mountainLayer = new MountainLayer();
  denglongManager = new DenglongManager();
  stoneManager = new StoneManager();
  moneyEffect = new MoneyEffect();
  groundManager = new GroundManager();
  roadsideLayer = new RoadsideLayer();

  song = new SoundFile(this, musicFile);
  song.loop();

  // 初始化音乐时钟与场景系统
  musicClock = new MusicClock(song, bpm);
  mainScene = new Scene();
  beatDispatcher = new BeatDispatcher();

  // 小马控制器（基于音乐时间驱动的跑/跳 FSM）
  pony = new PonyController(runFrames, jumpFrames, bpm, beatsPerRunCycle, beatsForRemainingJump);

  // 图层顺序（从远到近）：云 → 山 → 地面 → 路边近景 → 灯笼 → 小马 → 石头 → 金币特效
  // 石头在最上层，遮蔽小马跑步的阴影
  mainScene.add(new CloudLayerObject(cloudLayer));          // 最远：云
  mainScene.add(new MountainLayerObject(mountainLayer));    // 中景：山
  mainScene.add(new GroundManagerObject(groundManager));    // 近景：地面
  mainScene.add(new RoadsideLayerObject(roadsideLayer));    // 路边近景（花盆/草丛/树木 预留）
  mainScene.add(new DenglongManagerObject(denglongManager));// 装饰：灯笼
  mainScene.add(pony);                                      // 主角小马
  mainScene.add(new StoneManagerObject(stoneManager));      // 最前：石头（遮蔽小马阴影）
  mainScene.add(new MoneyEffectObject(moneyEffect));        // 前景：金币红包特效

  // 注册需要响应整拍事件的对象
  beatDispatcher.addListener(pony);

  prevMillis = millis();
  println(">>> 点击小马可以触发金币红包特效");
}

void draw() {
  int currMillis = millis();
  float dt = (currMillis - prevMillis) / 1000.0;
  prevMillis = currMillis;

  // 更新音乐时钟（无论是否暂停，都可以拿到当前位置）
  if (musicClock != null) {
    musicClock.update();
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
    // 在每一帧推进前，先分发节拍事件
    if (beatDispatcher != null && musicClock != null) {
      beatDispatcher.update(musicClock);
    }

    // 使用场景统一更新各层和所有对象（内部仍然是按 dt 更新，兼容旧逻辑）
    if (mainScene != null) {
      float musicTime = (musicClock != null) ? musicClock.musicTime : animTime;
      float beat = (musicClock != null) ? musicClock.beat : 0;
      mainScene.updateAll(dt, musicTime, beat);
    }

    // 石头自动跳跃：改为通知 PonyController，由其决定是否真正起跳
    if (stoneManager.checkAutoJump(PONY_X) && pony != null) {
      pony.requestJump();
      println("[AUTO] Stone trigger jump at " + nf(animTime, 0, 2) + "s");
    }
  }

  drawBackground();
  // 场景负责绘制所有背景/中景/前景层（包括小马和金币特效）
  if (mainScene != null) {
    mainScene.drawAll();
  } else {
    // 容错：如果场景未初始化，按图层顺序绘制
    cloudLayer.display();
    mountainLayer.display();
    groundManager.display();
    if (roadsideLayer != null) roadsideLayer.display();
    denglongManager.display();
    if (pony != null) pony.draw();
    stoneManager.display();
    moneyEffect.display();
  }

  // 小马与金币特效已经挂在 Scene 中，这里只负责调试 UI
  int frameIdx = pony != null ? pony.getCurrentFrameIndex() : 0;
  float prog = pony != null ? pony.getCurrentProgress() : 0;
  drawDebugUI(frameIdx, prog);
  drawTimeline();
}

void drawBackground() {
  background(240);
  imageMode(CORNER);
  if (backgroundImage != null) {
    image(backgroundImage, 0, 0, width, height);
  }
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

  fill(255, 255, 0);
  text("按 T 切换 测试/手动 模式", 10, y += dy);
  text("按 P 暂停", 10, y += dy);
  text("按 空格 手动跳跃", 10, y += dy);
  text("按 S 切换自动跳跃", 10, y += dy);
  text("点击小马触发特效", 10, y += dy);
  text("暂停时按 ←/→ 逐帧", 10, y += dy);
}

void keyPressed() {
  if (key == ' ') {
    if (pony != null) pony.requestJump();
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
  if (pony != null && pony.isMouseOver(mouseX, mouseY)) {
    moneyEffect.spawn(PONY_X, PONY_Y);
    println("触发金币红包特效!");
  }
}
