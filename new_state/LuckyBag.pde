// ==================== 福袋（线 + 袋）碰撞与顶飞动画 ====================
// 线头固定，线连福袋顶部；被顶后金光、袋顶飞、线弯曲收掉

class LuckyBag {
  PImage bagImg;
  float anchorX, anchorY;
  float bagX, bagY;
  float stringLength;
  float speed;
  float scale;
  String type;
  boolean hit = false;
  float hitTime = 0;
  float flyVx, flyVy;
  float retractProgress = 0;

  LuckyBag(PImage img, float startX, float anchorY, float stringLen, float speed, float scale, String type) {
    this.bagImg = img;
    this.anchorX = startX;
    this.anchorY = anchorY;
    this.stringLength = stringLen;
    this.bagX = startX;
    this.bagY = anchorY + stringLen;
    this.speed = speed;
    this.scale = scale;
    this.type = type;
  }

  void update(float dt) {
    if (hit) {
      hitTime += dt;
      bagX += flyVx * dt;
      bagY += flyVy * dt;
      retractProgress = min(1.0f, retractProgress + dt * LUCKY_BAG_STRING_RETRACT_SPEED / stringLength);
      return;
    }
    bagX -= speed * dt;
  }

  void onHit(float ponyHeadX, float ponyHeadY) {
    if (hit) return;
    hit = true;
    hitTime = 0;
    flyVy = LUCKY_BAG_FLY_UP_VY;
    flyVx = random(-LUCKY_BAG_FLY_UP_VX_RANDOM, LUCKY_BAG_FLY_UP_VX_RANDOM);
    retractProgress = 0;
  }

  boolean isDone() {
    return hit && (hitTime > LUCKY_BAG_GLOW_DURATION + 0.5 && retractProgress >= 1.0);
  }

  boolean collidesWith(float headX, float headY) {
    if (hit) return false;
    float dx = headX - bagX;
    float dy = headY - bagY;
    return dx * dx + dy * dy <= LUCKY_BAG_HIT_RADIUS * LUCKY_BAG_HIT_RADIUS;
  }

  void display() {
    if (bagImg == null) return;

    if (hit) {
      if (hitTime < LUCKY_BAG_GLOW_DURATION) {
        float glowAlpha = 255 * (1 - hitTime / LUCKY_BAG_GLOW_DURATION);
        noStroke();
        for (int i = 5; i > 0; i--) {
          float r = LUCKY_BAG_GLOW_RADIUS * (1.0 - (i - 1) / 5.0) + 20;
          fill(255, 220, 100, glowAlpha * (1.0 - r / LUCKY_BAG_GLOW_RADIUS) / 5);
          circle(bagX, bagY, r * 2);
        }
      }
      drawStringRetract();
      if (retractProgress < 1.0) {
        pushMatrix();
        translate(bagX, bagY);
        scale(scale);
        imageMode(CENTER);
        image(bagImg, 0, 0);
        popMatrix();
      }
      return;
    }

    drawString();
    pushMatrix();
    translate(bagX, bagY);
    scale(scale);
    imageMode(CENTER);
    image(bagImg, 0, 0);
    popMatrix();
  }

  void drawString() {
    stroke(80, 60, 40);
    strokeWeight(2);
    line(anchorX, anchorY, bagX, bagY);
    noStroke();
  }

  void drawStringRetract() {
    float t = 1 - retractProgress;
    float cx = lerp(bagX, anchorX, retractProgress);
    float cy = lerp(bagY, anchorY, retractProgress);
    stroke(80, 60, 40, 255 * (1 - retractProgress));
    strokeWeight(2);
    line(anchorX, anchorY, cx, cy);
    noStroke();
  }

  float getBagX() { return bagX; }
  float getBagY() { return bagY; }
  String getType() { return type; }
  boolean isHit() { return hit; }
}
