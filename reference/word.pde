// ========== 海绵弹出效果 ==========
PFont font;
ArrayList<BouncyChar> chars = new ArrayList<BouncyChar>();

void setup() {
  size(800, 600);
  font = createFont("Arial", 100);  // 改成 "Microsoft YaHei" 测试中文
  textFont(font);
  
  String text = "HAPPY";
  createText(text);
}

void draw() {
  background(255, 240, 245);
  
  for (BouncyChar bc : chars) {
    bc.update();
    bc.display();
  }
}

void createText(String text) {
  chars.clear();
  float spacing = 110;
  float startX = (width - text.length() * spacing) / 2 + spacing/2;
  
  for (int i = 0; i < text.length(); i++) {
    chars.add(new BouncyChar(
      text.charAt(i), 
      startX + i * spacing, 
      height/2,
      i * 8  // 延迟，制造波浪效果
    ));
  }
}

// ========== 海绵弹出字符类 ==========
class BouncyChar {
  char c;
  float x, y;
  float scale = 0;           // 从0开始
  float targetScale = 1.0;   // 目标是1
  float scaleVelocity = 0;
  
  float scaleX = 0, scaleY = 0;  // X和Y方向分别缩放（挤压效果）
  float velocityX = 0, velocityY = 0;
  
  float rotation = 0;
  float rotationVel = 0;
  
  float delay, timer = 0;
  boolean active = false;
  
  // 弹簧参数
  float springK = 0.08;      // 弹性系数（越小越慢）
  float damping = 0.88;      // 阻尼（越大弹得越久）
  
  BouncyChar(char c, float x, float y, float delay) {
    this.c = c;
    this.x = x;
    this.y = y;
    this.delay = delay;
  }
  
  void update() {
    timer++;
    if (timer < delay) return;
    active = true;
    
    // === 核心弹簧物理 ===
    // 整体缩放弹出
    float force = (targetScale - scale) * springK;
    scaleVelocity += force;
    scaleVelocity *= damping;
    scale += scaleVelocity;
    
    // === 海绵挤压效果 ===
    // 当弹出时，X方向先压缩后拉伸，Y方向相反
    float speed = abs(scaleVelocity);
    
    // X和Y方向的弹簧（制造挤压感）
    float targetScaleX = scale + scaleVelocity * 0.5;  // 运动方向拉伸
    float targetScaleY = scale - scaleVelocity * 0.3;  // 垂直方向压缩
    
    float forceX = (targetScaleX - scaleX) * 0.15;
    float forceY = (targetScaleY - scaleY) * 0.15;
    
    velocityX += forceX;
    velocityY += forceY;
    velocityX *= 0.85;
    velocityY *= 0.85;
    
    scaleX += velocityX;
    scaleY += velocityY;
    
    // === 轻微旋转 ===
    if (speed > 0.01) {
      rotation += scaleVelocity * 0.3;  // 弹出时旋转
    }
    float rotationForce = (0 - rotation) * 0.1;
    rotationVel += rotationForce;
    rotationVel *= 0.9;
    rotation += rotationVel;
    
    // === 稳定后的呼吸动画 ===
    if (abs(scaleVelocity) < 0.01) {
      float breathe = sin(timer * 0.05) * 0.03;
      scaleX = 1.0 + breathe;
      scaleY = 1.0 - breathe * 0.5;
    }
  }
  
  void display() {
    if (!active) return;
    
    pushMatrix();
    translate(x, y);
    rotate(rotation);
    scale(scaleX, scaleY);
    
    // 外发光效果
    for (int i = 3; i > 0; i--) {
      fill(255, 150, 180, 30);
      textAlign(CENTER, CENTER);
      text(c, 0, 0);
      scale(0.98, 0.98);
    }
    
    // 阴影
    fill(0, 60);
    text(c, 4, 4);
    
    // 主文字
    fill(255, 80, 120);
    text(c, 0, 0);
    
    popMatrix();
  }
}

void mousePressed() {
  createText("HAPPY");  // 点击重新播放
}