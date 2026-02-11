import processing.sound.*;

// --- 全局配置 ---
String folderName = "C:/Users/Admin/Documents/Processing/project/project-pony/output";
String musicFile = "C:/Users/Admin/Documents/Processing/project/project-pony/data/马年可爱风.mp3";

// --- 跑步参数 ---
String runPrefix = "/run-v4/run-v4_"; 
int runTotalFrames = 6;        
float beatsPerRunCycle = 1.0;   

// --- 跳跃参数 ---
String jumpPrefix = "/jump-mid-v4/jump-mid-v4_";    
int jumpTotalFrames = 23;       
float beatsPerJump = 2.0;       

// --- 节奏控制 ---
float bpm = 125.0;              

// --- 内部变量 ---
PImage[] runFrames;
PImage[] jumpFrames;
SoundFile song;

// 状态变量
int state = 0; // 0 = RUN, 1 = JUMP
boolean jumpRequested = false; 
int lastRunIndex = -1;

// --- 【DEBUG 核心变量】 ---
boolean isPaused = false;      
float animTime = 0;            
float timeSpeed = 1.0;         
int prevMillis = 0;            
float jumpStartTime = 0;       

void setup() {
  size(800, 600);
  frameRate(60); 
  
  // 加载素材
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
}

void draw() {
  background(240);
  
  // 1. 时间管理
  int currMillis = millis();
  float dt = (currMillis - prevMillis) / 1000.0;
  prevMillis = currMillis; 
  
  if (!isPaused) {
    animTime += dt * timeSpeed;
  }
  
  // 防止时间倒退成负数
  if (animTime < 0) animTime = 0;
  
  // 2. 状态机逻辑
  int currentFrameIndex = 0; 
  float currentProgress = 0;
  
  if (state == 0) {
    // --- 跑步状态 ---
    float currentBeat = animTime * (bpm / 60.0);
    currentProgress = (currentBeat % beatsPerRunCycle) / beatsPerRunCycle;
    
    int index = int(currentProgress * runTotalFrames);
    if (index >= runTotalFrames) index = 0;
    currentFrameIndex = index;
    
    // 检测循环结束 (Last: 11 -> Curr: 0)
    boolean isCycleEnd = (index == 0 && lastRunIndex != 0 && lastRunIndex != -1);
    
    // 这里增加一个保护：只有时间是在前进方向，才触发跳跃
    // 否则倒退时可能会意外触发
    if (isCycleEnd && jumpRequested) {
        startJump();
        lastRunIndex = index;
        return; 
    }
    
    lastRunIndex = index;
    drawFrame(runFrames[index]);
    
    if (jumpRequested) drawWaitingIcon();

  } else if (state == 1) {
    // --- 跳跃状态 ---
    
    float timeSinceJump = animTime - jumpStartTime;
    float jumpDuration = (60.0 / bpm) * beatsPerJump;
    
    currentProgress = timeSinceJump / jumpDuration;
    
    // 【新增】倒退逻辑检测：如果时间倒退到了起跳点之前
    if (currentProgress < 0) {
      // 1. 强制切回跑步状态
      state = 0; 
      // 2. 重要！把"请求"恢复为true。
      // 这样你按向右键前进时，到那个点又会自动触发跳跃，方便反复观察。
      jumpRequested = true; 
      println("<<< 倒带：退回跑步状态 (JUMP -> RUN)");
      return;
    }

    // 正常结束逻辑
    if (currentProgress >= 1.0) {
      state = 0; 
      lastRunIndex = -1;
      return; 
    }
    
    int index = int(currentProgress * jumpTotalFrames);
    // 防止倒退产生微小负数导致数组越界
    if (index < 0) index = 0;
    if (index >= jumpTotalFrames) index = jumpTotalFrames - 1;
    currentFrameIndex = index;
    
    drawFrame(jumpFrames[index]);
  }
  
  // 3. UI
  drawDebugUI(currentFrameIndex, currentProgress);
}

void startJump() {
  state = 1;
  jumpStartTime = animTime; 
  jumpRequested = false;
  println(">>> 切换动作: RUN -> JUMP at time: " + nf(animTime, 0, 2));
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
  fill(255, 50, 50);
  textAlign(CENTER);
  textSize(24);
  text("Pending...", width/2, height/2 - 150);
}

void drawDebugUI(int frameIdx, float prog) {
  fill(0, 150); 
  noStroke();
  rect(0, 0, 250, 240); // 加高一点
  
  fill(255);
  textAlign(LEFT, TOP);
  textSize(14);
  int y = 10;
  int dy = 20;
  
  text("[DEBUG MODE]", 10, y); y+=dy*1.5;
  text("Status: " + (isPaused ? "PAUSED" : "PLAYING"), 10, y); y+=dy;
  text("Time: " + nf(animTime, 0, 3) + "s", 10, y); y+=dy;
  text("----------------", 10, y); y+=dy;
  
  text("State: " + (state == 0 ? "RUN" : "JUMP"), 10, y); 
  if(state == 0) text(jumpRequested ? " (Wait)" : "", 80, y);
  y+=dy;
  
  text("Frame Index: " + frameIdx, 10, y); y+=dy;
  text("Progress: " + nf(prog * 100, 0, 1) + "%", 10, y); y+=dy;
  
  fill(255, 255, 0);
  text("按 P 暂停/继续", 10, y); y+=dy;
  text("按 → 前进一帧", 10, y); y+=dy;
  text("按 ← 后退一帧", 10, y); y+=dy; // 新增提示
  text("按 空格 请求跳跃", 10, y);
}

// ---------------- 交互控制 ----------------

void keyPressed() {
  if (key == ' ') {
    if (state == 0) jumpRequested = true;
  }
  
  if (key == 'p' || key == 'P') {
    isPaused = !isPaused;
    if (isPaused) song.pause(); else song.loop();
  }
  
  if (key == CODED) {
    if (keyCode == RIGHT) {
      if (isPaused) animTime += 1.0/60.0; // 前进 1 帧
    }
    else if (keyCode == LEFT) {
      if (isPaused) animTime -= 1.0/60.0; // 【新增】后退 1 帧
    }
    else if (keyCode == UP) {
      timeSpeed += 0.1;
    }
    else if (keyCode == DOWN) {
      timeSpeed -= 0.1;
      if(timeSpeed < 0.1) timeSpeed = 0.1;
    }
  }
}
