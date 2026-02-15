import processing.sound.*;
import java.util.ArrayList;

// --- 全局配置 ---
String folderName = "C:/Users/Admin/Documents/Processing/project/project-pony/output";
String musicFile = "C:/Users/Admin/Documents/Processing/project/project-pony/data/马年可爱风.mp3";

// --- 动画参数 ---
String runPrefix = "/run-v4/run-v4_"; 
int runTotalFrames = 6;        
float beatsPerRunCycle = 1.0;   

String jumpPrefix = "/jump-mid-v4/jump-mid-v4_";    
int jumpTotalFrames = 23;       
float beatsForRemainingJump = 3.0;

float bpm = 129.0;              

// --- 变量 ---
PImage[] runFrames;
PImage[] jumpFrames;
SoundFile song;

// 状态
int state = 0; // 0=RUN, 1=JUMP
boolean jumpRequested = false; 
int lastRunIndex = -1;

// --- 时间系统 ---
boolean isPaused = false;      
float animTime = 0;            
float timeSpeed = 1.0;         
int prevMillis = 0;            

float jumpStartTime = 0;   
float runCycleOffset = 0;  

// --- 测试模式配置 ---
boolean testMode = true;
float[] jumpTimeline = { 2.0, 4.5, 7.0, 9.5, 12.0 };
int nextTestIndex = 0;

// 【新增】用于记录当前应该显示的帧
PImage currentDisplayFrame = null;

void setup() {
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
  
  song = new SoundFile(this, musicFile);
  song.loop();
  
  prevMillis = millis();
  println(">>> 测试模式: " + testMode);
  if(testMode) println(">>> 预设跳跃时间点: 2.0s, 4.5s, 7.0s...");
}

void draw() {
  background(240);
  
  // 1. 时间步进
  int currMillis = millis();
  float dt = (currMillis - prevMillis) / 1000.0;
  prevMillis = currMillis; 
  
  if (!isPaused) animTime += dt * timeSpeed;
  if (animTime < 0) animTime = 0;
  
  // --- 自动化测试逻辑 ---
  if (testMode && nextTestIndex < jumpTimeline.length) {
    if (animTime >= jumpTimeline[nextTestIndex]) {
      jumpRequested = true;
      println("[AUTO] Requesting Jump at " + nf(animTime, 0, 2) + "s");
      nextTestIndex++;
    }
  }
  
  // 2. 状态机
  int currentFrameIndex = 0; 
  float currentProgress = 0;
  
  if (state == 0) {
    // ================= RUNNING =================
    
    float relativeRunTime = animTime - runCycleOffset;
    float durationPerCycle = (60.0 / bpm) * beatsPerRunCycle;
    float currentCycleProgress = (relativeRunTime % durationPerCycle) / durationPerCycle;
    
    if (currentCycleProgress < 0) currentCycleProgress += 1.0;
    
    int index = int(currentCycleProgress * runTotalFrames);
    if (index >= runTotalFrames) index = runTotalFrames - 1; 
    
    currentProgress = currentCycleProgress;
    
    // 衔接逻辑
    boolean transitionPoint = (index == 4);
    
    if (transitionPoint && lastRunIndex != 4 && jumpRequested) {
        // 【修复2】先绘制当前帧，再切换状态
        currentDisplayFrame = runFrames[index];
        lastRunIndex = index;
        currentFrameIndex = index;
        
        // 启动跳跃（但不 return，让这一帧正常绘制）
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
    // ================= JUMPING =================
    
    float timeSinceJump = animTime - jumpStartTime;
    
    int jumpStartFrame = 3; 
    int framesToPlay = jumpTotalFrames - jumpStartFrame; 
    
    float durationPerFrame = ((60.0 / bpm) * beatsForRemainingJump) / framesToPlay;
    float totalJumpDurationSec = durationPerFrame * jumpTotalFrames;
    
    float effectiveTime = timeSinceJump + (jumpStartFrame * durationPerFrame);
    currentProgress = effectiveTime / totalJumpDurationSec;
    
    // 倒带保护
    if (timeSinceJump < 0) {
       state = 0; 
       jumpRequested = true; 
       lastRunIndex = -1; 
       currentDisplayFrame = runFrames[0]; // 【修复】确保有帧显示
    }
    
    // --- 【修复1】落地逻辑 ---
    else if (currentProgress >= 1.0) {
      // 不管是否暂停，都允许切换状态
      state = 0; 
      lastRunIndex = -1;
      runCycleOffset = animTime; 
      println("<<< 落地：重置跑步相位 (RUN Phase Reset)");
      
      // 【关键】立即计算并显示 RUN 的第一帧，避免闪烁
      currentDisplayFrame = runFrames[0];
      currentFrameIndex = 0;
      currentProgress = 0;
      
    } else {
      // 正常播放跳跃动画
      int index = int(currentProgress * jumpTotalFrames);
      if (index < 0) index = 0;
      if (index >= jumpTotalFrames) index = jumpTotalFrames - 1;
      currentFrameIndex = index;
      currentDisplayFrame = jumpFrames[index];
    }
  }
  
  // 3. 【统一绘制】确保每帧都有内容显示
  if (currentDisplayFrame != null) {
    drawFrame(currentDisplayFrame);
  }
  
  // 4. UI
  drawDebugUI(currentFrameIndex, currentProgress);
  drawTimeline();
}

void drawFrame(PImage img) {
  if (img != null) {
    pushMatrix();
    translate(width/2, height/2);
    imageMode(CENTER);
    image(img, 0, 0);
    popMatrix();
  }
}

void drawWaitingIcon() {
  fill(255, 100, 100); noStroke(); circle(width/2, height/2 - 180, 20);
}

void drawTimeline() {
  if (!testMode) return;
  stroke(180); line(50, height-50, width-50, height-50);
  float timelineScale = (width-100) / 15.0;
  
  for (int i=0; i<jumpTimeline.length; i++) {
    float x = 50 + jumpTimeline[i] * timelineScale;
    fill(0); noStroke(); circle(x, height-50, 8);
    if (i == nextTestIndex - 1) { fill(0, 255, 0); circle(x, height-50, 6); }
  }
  
  float cx = 50 + animTime * timelineScale;
  if (cx < width-50) {
    stroke(255, 0, 0); line(cx, height-60, cx, height-40);
  }
}

void drawDebugUI(int frameIdx, float prog) {
  fill(0, 150); noStroke(); rect(0, 0, 260, 280); 
  fill(255); textAlign(LEFT, TOP); textSize(14);
  int y = 10; int dy = 20;
  
  text(testMode ? "[AUTO TEST MODE]" : "[MANUAL MODE]", 10, y); y+=dy*1.5;
  text("Time: " + nf(animTime, 0, 2) + "s", 10, y); y+=dy;
  text("Status: " + (state == 0 ? "RUN" : "JUMP"), 10, y); y+=dy;
  text("Paused: " + isPaused, 10, y); y+=dy;
  
  text("Frame Index: " + frameIdx, 10, y); y+=dy;
  text("Progress: " + nf(prog * 100, 0, 1) + "%", 10, y); y+=dy;
  
  if (state == 0) {
    text("Run Offset: " + nf(runCycleOffset, 0, 2) + "s", 10, y); y+=dy;
  }
  
  fill(255, 255, 0);
  text("按 T 切换 测试/手动 模式", 10, y+=dy);
  text("按 P 暂停", 10, y+=dy);
  text("按 空格 手动跳跃", 10, y+=dy);
  text("暂停时按 ←/→ 逐帧", 10, y+=dy);
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
    if (isPaused) song.pause(); else song.loop();
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
