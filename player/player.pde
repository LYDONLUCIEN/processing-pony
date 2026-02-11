// --- 脚本 2: PonyPlayer (播放器) ---
import processing.sound.*;

// --- 配置区域 ---
int totalFrames = 24;        // 你的序列总帧数
String imageFolder = "C:/Users/Admin/Documents/Processing/project/project-pony/output"; // 图片所在的文件夹名 (在data目录下)
String imagePrefix = "jump_";   // 图片前缀
String musicFilename = "C:/Users/Admin/Documents/Processing/project/project-pony/data/马年可爱风.mp3"; 

// --- 节奏控制 ---
float bpm = 170.0;       // 音乐BPM (每分钟节拍数)
float beatsPerCycle = 1.0; // 整个动画循环一次(15帧)对应几拍? 
                           // 如果15帧是跑一步，通常是1拍。如果是跑一圈(左脚+右脚)，通常是2拍。

// --- 变量 ---
PImage[] frames;
SoundFile song;

void setup() {
  size(800, 600);
  frameRate(60); // 尽量让程序跑在60帧以保证流畅
  
  // 1. 加载序列帧
  frames = new PImage[totalFrames];
  for (int i = 0; i < totalFrames; i++) {
    // 拼接路径: data/output/run_00.png
    String path = imageFolder + "/" + imagePrefix + nf(i, 2) + ".png";
    frames[i] = loadImage(path);
    
    // 简单的错误检查
    if (frames[i] == null) {
      println("错误: 无法加载 " + path);
      exit();
    }
  }
  println("图片加载完毕。");

  // 2. 加载音乐
  song = new SoundFile(this, musicFilename);
  
  // 3. 播放
  // 这里做一个简单的对齐：先让程序跑起来，稍微延时一点点再播音乐，或者直接播
  song.loop();
}

void draw() {
  background(240); // 浅灰背景

  // --- 核心同步逻辑 (Time-based Animation) ---
  
  // 1. 获取基准时间
  // 使用 millis() 获取程序运行时间(秒)
  // 减去一个偏移量可以微调同步(如果觉得声音比画面慢)
  float time = millis() / 1000.0; 
  
  // 2. 计算当前拍数
  // 公式：当前秒数 * (BPM / 60)
  float currentBeat = time * (bpm / 60.0);
  
  // 3. 计算循环进度 (0.0 ~ 0.999...)
  // 使用模运算 (%) 获取当前处于循环的哪个阶段
  float progress = (currentBeat % beatsPerCycle) / beatsPerCycle;
  
  // 4. 映射到帧索引
  // 使用 int() 向下取整
  int frameIndex = int(progress * totalFrames);
  
  // 保险措施，防止浮点数精度问题导致 index = 15
  if (frameIndex >= totalFrames) frameIndex = 0;
  
  
  // --- 绘制 ---
  pushMatrix();
  translate(width/2, height/2); // 居中
  imageMode(CENTER);
  
  // 显示图片
  if (frames[frameIndex] != null) {
    image(frames[frameIndex], 0, 0);
  }
  
  popMatrix();
  
  // --- UI 信息 ---
  fill(0);
  text("FPS: " + int(frameRate), 10, 20);
  text("Index: " + frameIndex + " / " + (totalFrames-1), 10, 40);
  text("BPM: " + bpm, 10, 60);
}
