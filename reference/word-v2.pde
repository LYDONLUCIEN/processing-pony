// ========== 超级Q弹版本 ==========
class BouncyChar {
  char c;
  float x, y;
  float scaleX = 0, scaleY = 0;
  float velocityX = 0, velocityY = 0;
  float rotation = 0, rotationVel = 0;
  float delay, timer = 0;
  boolean active = false;
  color col;
  
  // 海绵压缩参数
  float compressionPhase = 0;  // 压缩阶段
  
  BouncyChar(char c, float x, float y, float delay) {
    this.c = c;
    this.x = x;
    this.y = y;
    this.delay = delay;
    this.col = color(random(200, 255), random(60, 120), random(100, 180));
  }
  
  void update() {
    timer++;
    if (timer < delay) return;
    active = true;
    
    float t = (timer - delay) * 0.1;  // 时间参数
    
    // === 方案1: 使用缓动函数（最真实的海绵感）===
    float progress = constrain(t, 0, 1);
    float eased = elasticEaseOut(progress);
    
    scaleX = eased;
    scaleY = eased;
    
    // 挤压变形（海绵被压扁后弹起）
    if (progress < 1) {
      float squashX = 1.0 + sin(t * 10) * 0.15 * (1 - progress);
      float squashY = 1.0 - sin(t * 10) * 0.15 * (1 - progress);
      scaleX *= squashX;
      scaleY *= squashY;
    }
    
    // 旋转（海绵弹出时的扭转）
    rotation = sin(t * 8) * 0.3 * (1 - progress);
    
    // 稳定后的微动
    if (progress >= 1) {
      float breathe = sin(timer * 0.03) * 0.02;
      scaleX = 1.0 + breathe;
      scaleY = 1.0 - breathe * 0.5;
    }
  }
  
  // ===== 弹性缓动函数（核心！）=====
  float elasticEaseOut(float t) {
    if (t == 0 || t >= 1) return t;
    
    float p = 0.4;  // 周期（越大振荡越慢）
    float s = p / 4.0;
    
    // 经典弹性公式
    return pow(2, -10 * t) * sin((t - s) * TWO_PI / p) + 1;
  }
  
  // ===== 回弹缓动（另一种海绵感）=====
  float bounceEaseOut(float t) {
    if (t < 1/2.75) {
      return 7.5625 * t * t;
    } else if (t < 2/2.75) {
      t -= 1.5/2.75;
      return 7.5625 * t * t + 0.75;
    } else if (t < 2.5/2.75) {
      t -= 2.25/2.75;
      return 7.5625 * t * t + 0.9375;
    } else {
      t -= 2.625/2.75;
      return 7.5625 * t * t + 0.984375;
    }
  }
  
  void display() {
    if (!active) return;
    
    pushMatrix();
    translate(x, y);
    rotate(rotation);
    scale(scaleX, scaleY);
    
    // 彩色外发光
    for (int i = 5; i > 0; i--) {
      fill(col, 20 * i);
      textAlign(CENTER, CENTER);
      text(c, 0, 0);
      scale(0.96, 0.96);
    }
    
    // 主文字（渐变色效果）
    fill(col);
    text(c, 0, 0);
    
    // 高光
    fill(255, 255, 255, 100);
    textSize(90);
    text(c, -2, -3);
    textSize(100);
    
    popMatrix();
  }
}