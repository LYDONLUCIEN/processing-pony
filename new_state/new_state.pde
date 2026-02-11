import processing.sound.*;
import java.util.ArrayList;

// ==================== 全局配置 ====================
String folderName = "C:/Users/Admin/Documents/Processing/project/project-pony/output";
String musicFile = "C:/Users/Admin/Documents/Processing/project/project-pony/data/马年可爱风.mp3";

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

int state = 0;
boolean jumpRequested = false;
int lastRunIndex = -1;

PImage currentDisplayFrame = null;
float ponyY;

// ==================== 时间系统 ====================
boolean isPaused = false;
float animTime = 0;
float timeSpeed = 1.0;
int prevMillis = 0;

float jumpStartTime = 0;
float runCycleOffset = 0;

// ==================== 测试模式配置 ====================
boolean testMode = true;
float[] jumpTimeline = { 2.0, 4.5, 7.0, 9.5, 12.0 };
int nextTestIndex = 0;

// ==================== 动画层系统 ====================
PImage backgroundImage;
CloudLayer cloudLayer;
MountainLayer mountainLayer;
DenglongManager denglongManager;
StoneManager stoneManager;
MoneyEffect moneyEffect;
GroundManager groundManager;

// ==================== 小马碰撞检测 ====================
boolean isMouseOverPony(int mx, int my) {
  float ponyLeft = PONY_X - 100;
  float ponyRight = PONY_X + 100;
  float ponyTop = ponyY - 150;
  float ponyBottom = ponyY + 50;

  return mx >= ponyLeft && mx <= ponyRight && my >= ponyTop && my <= ponyBottom;
}

// ==================== 跳跃高度计算 ====================
float getJumpHeight(float progress) {
  float jumpProgress = progress;
  if (jumpProgress > 1.0) jumpProgress = 1.0;
  if (jumpProgress < 0) jumpProgress = 0;

  return sin(jumpProgress * PI) * PONY_JUMP_HEIGHT;
}

void setup() {
  size(800, 600, P2D);  // 使用 P2D 渲染器以支持 texture()
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

  ponyY = PONY_Y;

  cloudLayer = new CloudLayer();
  mountainLayer = new MountainLayer();
  denglongManager = new DenglongManager();
  stoneManager = new StoneManager();
  moneyEffect = new MoneyEffect();
  groundManager = new GroundManager();

  song = new SoundFile(this, musicFile);
  song.loop();

  prevMillis = millis();
  println(">>> 测试模式: " + testMode);
  if (testMode) println(">>> 预设跳跃时间点: 2.0s, 4.5s, 7.0s...");
  println(">>> 点击小马可以触发金币红包特效");
}

void draw() {
  int currMillis = millis();
  float dt = (currMillis - prevMillis) / 1000.0;
  prevMillis = currMillis;

  if (!isPaused) animTime += dt * timeSpeed;
  if (animTime < 0) animTime = 0;

  float groundSpeed = GROUND_SPEED;
  if (!isPaused) {
    cloudLayer.update(dt);
    mountainLayer.update(dt);
    denglongManager.update(dt);
    stoneManager.update(dt);
    moneyEffect.update(dt);
    groundManager.update(dt);

    if (stoneManager.checkAutoJump(PONY_X)) {
      if (state == 0) {
        jumpRequested = true;
        println("[AUTO] Stone trigger jump at " + nf(animTime, 0, 2) + "s");
      }
    }
  }

  if (testMode && nextTestIndex < jumpTimeline.length) {
    if (animTime >= jumpTimeline[nextTestIndex]) {
      jumpRequested = true;
      println("[AUTO] Timeline jump at " + nf(animTime, 0, 2) + "s");
      nextTestIndex++;
    }
  }

  int currentFrameIndex = 0;
  float currentProgress = 0;

  if (state == 0) {
    float relativeRunTime = animTime - runCycleOffset;
    float durationPerCycle = (60.0 / bpm) * beatsPerRunCycle;
    float currentCycleProgress = (relativeRunTime % durationPerCycle) / durationPerCycle;

    if (currentCycleProgress < 0) currentCycleProgress += 1.0;

    int index = int(currentCycleProgress * runTotalFrames);
    if (index >= runTotalFrames) index = runTotalFrames - 1;

    currentProgress = currentCycleProgress;

    boolean transitionPoint = (index == 4);

    if (transitionPoint && lastRunIndex != 4 && jumpRequested) {
      currentDisplayFrame = runFrames[index];
      lastRunIndex = index;
      currentFrameIndex = index;

      state = 1;
      jumpStartTime = animTime;
      jumpRequested = false;
      println(">>> 起跳: RUN[4] -> JUMP[3] at " + nf(animTime, 0, 2));

    } else {
      lastRunIndex = index;
      currentFrameIndex = index;
      currentDisplayFrame = runFrames[index];
    }

    if (jumpRequested) drawWaitingIcon();

  } else if (state == 1) {
    float timeSinceJump = animTime - jumpStartTime;

    int jumpStartFrame = 3;
    int framesToPlay = jumpTotalFrames - jumpStartFrame;

    float durationPerFrame = ((60.0 / bpm) * beatsForRemainingJump) / framesToPlay;
    float totalJumpDurationSec = durationPerFrame * jumpTotalFrames;

    float effectiveTime = timeSinceJump + (jumpStartFrame * durationPerFrame);
    currentProgress = effectiveTime / totalJumpDurationSec;

    if (timeSinceJump < 0) {
      state = 0;
      jumpRequested = true;
      lastRunIndex = -1;
      currentDisplayFrame = runFrames[0];
    }

    else if (currentProgress >= 1.0) {
      state = 0;
      lastRunIndex = -1;
      runCycleOffset = animTime;
      println("<<< 落地：重置跑步相位");

      currentDisplayFrame = runFrames[0];
      currentFrameIndex = 0;
      currentProgress = 0;

    } else {
      int index = int(currentProgress * jumpTotalFrames);
      if (index < 0) index = 0;
      if (index >= jumpTotalFrames) index = jumpTotalFrames - 1;
      currentFrameIndex = index;
      currentDisplayFrame = jumpFrames[index];
    }
  }

  drawBackground();
  cloudLayer.display();
  mountainLayer.display();
  denglongManager.display();
  groundManager.display();  // 地面移到这里
  stoneManager.display();

  if (currentDisplayFrame != null) {
    drawPony(currentDisplayFrame);
  }

  moneyEffect.display();

  drawDebugUI(currentFrameIndex, currentProgress);
  drawTimeline();
}

void drawBackground() {
  background(240);
  imageMode(CORNER);
  image(backgroundImage, 0, 0, width, height);
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
  circle(PONY_X, ponyY - 180, 20);
}

void drawTimeline() {
  if (!testMode) return;
  stroke(180);
  line(50, height - 50, width - 50, height - 50);
  float timelineScale = (width - 100) / 15.0;

  for (int i = 0; i < jumpTimeline.length; i++) {
    float x = 50 + jumpTimeline[i] * timelineScale;
    fill(0);
    noStroke();
    circle(x, height - 50, 8);
    if (i == nextTestIndex - 1) {
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

  text(testMode ? "[AUTO TEST MODE]" : "[MANUAL MODE]", 10, y);
  y += dy * 1.5;
  text("Time: " + nf(animTime, 0, 2) + "s", 10, y);
  y += dy;
  text("Status: " + (state == 0 ? "RUN" : "JUMP"), 10, y);
  y += dy;
  text("Paused: " + isPaused, 10, y);
  y += dy;

  text("Frame Index: " + frameIdx, 10, y);
  y += dy;
  text("Progress: " + nf(prog * 100, 0, 1) + "%", 10, y);
  y += dy;

  if (state == 0) {
    text("Run Offset: " + nf(runCycleOffset, 0, 2) + "s", 10, y);
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
    if (state == 0) jumpRequested = true;
  }
  if (key == 't' || key == 'T') {
    testMode = !testMode;
    nextTestIndex = 0;
    if (!testMode) jumpRequested = false;
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
  if (isMouseOverPony(mouseX, mouseY)) {
    moneyEffect.spawn(PONY_X, ponyY);
    println("触发金币红包特效!");
  }
}
