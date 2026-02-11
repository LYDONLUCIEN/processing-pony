// ============================================
// 双缓冲无缝地面 - 修复语法错误
// ============================================

PImage groundImg;           
boolean loaded = false;

GroundBlock ground1;
GroundBlock ground2;

float speed = 8;            
final float GROUND_HEIGHT_RATIO = 0.35;  
float groundHeight;           
float groundWidth;            
float scaleRatio;             

// 平行四边形变形参数
float slantFactor = 0.15;     // 倾斜程度
float groundY;                

void setup() {
  size(800, 600, P2D);  // 必须用P2D模式才能用纹理变形！
  
  textureMode(NORMAL);  // 关键：使用0-1的纹理坐标
  
  // 加载素材
  groundImg = loadImage("ground.png");
  if (groundImg == null) {
    groundImg = createBrickTexture(800, 200);
    println("使用测试纹理");
  }
  
  // 计算缩放
  scaleRatio = (height * GROUND_HEIGHT_RATIO) / groundImg.height;
  groundHeight = groundImg.height * scaleRatio;
  groundWidth = groundImg.width * scaleRatio;
  groundY = height;  
  
  println("缩放后: " + groundWidth + "x" + groundHeight);
  
  // 初始化
  ground1 = new GroundBlock(0);
  ground2 = new GroundBlock(groundWidth - (groundWidth * slantFactor));
  
  loaded = true;
}

void draw() {
  background(135, 206, 235);
  
  drawBackground();
  
  ground1.update(speed);
  ground2.update(speed);
  
  ground1.display();
  ground2.display();
  
  checkAndSwap(ground1, ground2);
  checkAndSwap(ground2, ground1);
  
  drawPlayer();
  drawDebug();
}

class GroundBlock {
  float x;  
  
  GroundBlock(float startX) {
    x = startX;
  }
  
  void update(float spd) {
    x -= spd;
  }
  
  void display() {
    // 只在可见时绘制
    if (x + groundWidth > 0 && x < width) {
      
      float topOffset = groundWidth * slantFactor;
      
      pushMatrix();
      
      // 绘制带纹理的四边形
      beginShape();
      texture(groundImg);
      
      // 顶点顺序：左下 -> 右下 -> 右上 -> 左上
      vertex(x, groundY,                    0, 1);  // 左下
      vertex(x + groundWidth, groundY,      1, 1);  // 右下
      vertex(x + groundWidth - topOffset,   // 右上（向左倾斜）
             groundY - groundHeight,        1, 0);
      vertex(x - topOffset,                 // 左上（向左倾斜）
             groundY - groundHeight,        0, 0);
      
      endShape(CLOSE);
      
      popMatrix();
      
      // 调试边框
      if (keyPressed && key == 'b') {
        noFill();
        stroke(255, 0, 0);
        strokeWeight(2);
        beginShape();
        vertex(x, groundY);
        vertex(x + groundWidth, groundY);
        vertex(x + groundWidth - topOffset, groundY - groundHeight);
        vertex(x - topOffset, groundY - groundHeight);
        endShape(CLOSE);
        noStroke();
      }
    }
  }
  
  boolean isFullyOffScreen() {
    float topOffset = groundWidth * slantFactor;
    return x + groundWidth - topOffset < 0;
  }
  
  void resetToRightOf(GroundBlock other) {
    float topOffset = groundWidth * slantFactor;
    x = other.x + groundWidth - topOffset;
  }
}

void checkAndSwap(GroundBlock current, GroundBlock other) {
  if (current.isFullyOffScreen()) {
    current.resetToRightOf(other);
  }
}

void drawBackground() {
  // 简单的地面线
  stroke(100, 150, 100);
  strokeWeight(2);
  line(0, groundY - groundHeight, width, groundY - groundHeight);
  noStroke();
}

void drawPlayer() {
  float px = 150;
  float py = groundY - groundHeight;  // 站在地面上
  
  pushMatrix();
  translate(px, py);
  
  float cycle = frameCount * 0.3;
  float bob = abs(sin(cycle)) * 10;
  translate(0, -bob);
  
  // 身体
  fill(220, 80, 60);
  noStroke();
  rect(-20, -40, 40, 40, 5);
  
  // 头
  fill(255, 220, 180);
  ellipse(0, -55, 25, 25);
  
  // 腿
  stroke(50);
  strokeWeight(4);
  float leg = sin(cycle) * 15;
  line(-8, 0, -10 + leg, 25);
  line(8, 0, 10 - leg, 25);
  noStroke();
  
  popMatrix();
}

PImage createBrickTexture(int w, int h) {
  PImage img = createImage(w, h, RGB);
  img.loadPixels();
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      // 明显的砖块图案，方便观察滚动
      int bx = x / 60;
      int by = y / 30;
      boolean edge = (x % 60 < 3) || (y % 30 < 3);
      boolean alt = (bx + by) % 2 == 0;
      
      color c;
      if (edge) {
        c = color(60, 40, 30);
      } else if (alt) {
        c = color(180, 120, 80);
      } else {
        c = color(160, 100, 70);
      }
      
      // 顶部草地
      if (y < 10) {
        c = color(100, 160, 70);
      }
      
      img.pixels[y * w + x] = c;
    }
  }
  img.updatePixels();
  return img;
}

void drawDebug() {
  fill(0, 220);
  rect(10, 10, 300, 140, 5);
  
  fill(255);
  textAlign(LEFT);
  text("=== 修复版 ===", 20, 30);
  text("倾斜度 Q/A: " + nf(slantFactor, 1, 2), 20, 50);
  text("速度 ↑↓: " + speed, 20, 70);
  text("地面尺寸: " + nf(groundWidth, 1, 0) + "x" + nf(groundHeight, 1, 0), 20, 90);
  text("Ground1.x: " + nf(ground1.x, 1, 0), 20, 110);
  text("Ground2.x: " + nf(ground2.x, 1, 0), 20, 130);
  
  // 显示倾斜示意图 - 修复变量名
  stroke(255);
  noFill();
  rect(320, 20, 100, 60);
  float offset = 100 * slantFactor;  // 改为 offset 而不是 to
  beginShape();
  vertex(320, 80);
  vertex(420, 80);
  vertex(420 - offset, 20);  // 使用 offset
  vertex(320 - offset, 20);  // 使用 offset
  endShape(CLOSE);
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) speed += 1;
    if (keyCode == DOWN) speed = max(0, speed - 1);
  }
  
  if (key == 'q' || key == 'Q') {
    slantFactor = min(0.5, slantFactor + 0.05);
    // 重新调整位置避免缝隙
    ground2.x = ground1.x + groundWidth - (groundWidth * slantFactor);
  }
  if (key == 'a' || key == 'A') {
    slantFactor = max(0, slantFactor - 0.05);
    ground2.x = ground1.x + groundWidth - (groundWidth * slantFactor);
  }
  
  if (key == ' ') {
    speed = (speed == 0) ? 8 : 0;
  }
}