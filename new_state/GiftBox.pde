// ==================== 礼物盒（盖子 + 盒身，不画绳） ====================
// 未击中：吊在空中，上下微动（磁悬浮感）；击中后盖子和盒身旋转着抛物线飞出

class GiftBox {
  PImage lidImg;
  PImage bodyImg;
  float anchorX, anchorY;
  float stringLength;
  float speed;
  float scale;
  String type;

  float boxX;
  float lidX, lidY;
  float bodyX, bodyY;
  float boxCenterY;
  float hangTime;       // 未击中时累计时间，用于悬浮微动

  boolean hit = false;
  float hitTime = 0;
  float lidVx, lidVy;
  float bodyVx, bodyVy;
  float lidAngle, bodyAngle;   // 当前旋转角（rad）
  float lidOmega, bodyOmega;   // 角速度（rad/s）
  float hitSpawnX, hitSpawnY;

  GiftBox(PImage lidImg, PImage bodyImg, float startX, float anchorY, float stringLen, float speed, float scale, String type) {
    this.lidImg = lidImg;
    this.bodyImg = bodyImg;
    this.anchorX = startX;
    this.anchorY = anchorY;
    this.stringLength = stringLen;
    this.speed = speed;
    this.scale = scale;
    this.type = type;
    boxX = startX;
    hangTime = 0;
    boxCenterY = anchorY + stringLen;
    lidX = boxX + GIFT_BOX_LID_OFFSET_X;
    lidY = boxCenterY + GIFT_BOX_LID_Y_OFFSET;
    bodyX = boxX;
    bodyY = boxCenterY;
    lidAngle = bodyAngle = 0;
    lidOmega = bodyOmega = 0;
  }

  void update(float dt) {
    if (hit) {
      hitTime += dt;
      lidVy += GIFT_BOX_GRAVITY * dt;
      bodyVy += GIFT_BOX_GRAVITY * dt;
      lidX += lidVx * dt;
      lidY += lidVy * dt;
      bodyX += bodyVx * dt;
      bodyY += bodyVy * dt;
      lidAngle += lidOmega * dt;
      bodyAngle += bodyOmega * dt;
      return;
    }
    hangTime += dt;
    float bob = GIFT_BOX_BOB_AMPLITUDE * sin(TWO_PI * GIFT_BOX_BOB_SPEED * hangTime);
    boxCenterY = anchorY + stringLength + bob;
    boxX -= speed * dt;
    lidX = boxX + GIFT_BOX_LID_OFFSET_X;
    lidY = boxCenterY + GIFT_BOX_LID_Y_OFFSET;
    bodyX = boxX;
    bodyY = boxCenterY;
  }

  void onHit(float ponyHeadX, float ponyHeadY) {
    if (hit) return;
    hit = true;
    hitTime = 0;
    hitSpawnX = boxX;
    hitSpawnY = boxCenterY;
    // 盖子与盒身分别向左右斜上方飞，角度随机，都向上（Vy 负）
    boolean lidGoesLeft = random(1) > 0.5f;
    float lidVxMag = random(GIFT_BOX_LID_VX_MIN, GIFT_BOX_LID_VX_MAX);
    float bodyVxMag = random(GIFT_BOX_BODY_VX_MIN, GIFT_BOX_BODY_VX_MAX);
    lidVx = lidGoesLeft ? -lidVxMag : lidVxMag;
    bodyVx = lidGoesLeft ? bodyVxMag : -bodyVxMag;
    lidVy = GIFT_BOX_LID_VY * random(0.85f, 1.15f);
    bodyVy = GIFT_BOX_BODY_VY * random(0.85f, 1.15f);
    lidOmega = (random(1) > 0.5f ? 1 : -1) * GIFT_BOX_LID_OMEGA * random(0.8f, 1.2f);
    bodyOmega = (random(1) > 0.5f ? 1 : -1) * GIFT_BOX_BODY_OMEGA * random(0.8f, 1.2f);
  }

  boolean isDone() {
    if (!hit) return false;
    return hitTime > GIFT_BOX_FLY_DURATION_MAX || (lidY > height + GIFT_BOX_OFFSCREEN_MARGIN && bodyY > height + GIFT_BOX_OFFSCREEN_MARGIN);
  }

  boolean collidesWith(float headX, float headY) {
    if (hit) return false;
    float dx = headX - boxX;
    float dy = headY - boxCenterY;
    return dx * dx + dy * dy <= GIFT_BOX_HIT_RADIUS * GIFT_BOX_HIT_RADIUS;
  }

  void display() {
    if (hit) {
      if (hitTime < GIFT_BOX_GLOW_DURATION) {
        float glowAlpha = 255 * (1 - hitTime / GIFT_BOX_GLOW_DURATION);
        noStroke();
        fill(255, 220, 100, glowAlpha * 0.6f);
        ellipse(hitSpawnX, hitSpawnY, GIFT_BOX_GLOW_RADIUS * 2, GIFT_BOX_GLOW_RADIUS * 2);
      }
      float flyAlpha = 255;
      if (GIFT_BOX_FADE_DURATION > 0 && hitTime > GIFT_BOX_FLY_DURATION_MAX - GIFT_BOX_FADE_DURATION) {
        float fadeProgress = (hitTime - (GIFT_BOX_FLY_DURATION_MAX - GIFT_BOX_FADE_DURATION)) / GIFT_BOX_FADE_DURATION;
        if (fadeProgress > 1) fadeProgress = 1;
        flyAlpha = 255 * (1 - fadeProgress);
      }
      drawBody(bodyX, bodyY, bodyAngle, flyAlpha);
      drawLid(lidX, lidY, lidAngle, flyAlpha);
      return;
    }
    drawBody(boxX, boxCenterY, 0, 255);
    drawLid(lidX, lidY, 0, 255);
  }

  void drawBody(float px, float py, float angle, float alpha) {
    if (bodyImg != null && bodyImg.width > 0) {
      pushMatrix();
      translate(px, py);
      rotate(angle);
      scale(scale);
      imageMode(CENTER);
      if (alpha < 255) tint(255, 255, 255, (int)alpha);
      image(bodyImg, 0, 0);
      if (alpha < 255) noTint();
      popMatrix();
    } else {
      pushMatrix();
      translate(px, py);
      rotate(angle);
      if (alpha < 255) fill(139, 90, 43, (int)alpha);
      else fill(139, 90, 43);
      noStroke();
      rectMode(CENTER);
      rect(0, 0, 40 * scale, 35 * scale);
      popMatrix();
    }
  }

  void drawLid(float px, float py, float angle, float alpha) {
    if (lidImg != null && lidImg.width > 0) {
      pushMatrix();
      translate(px, py);
      rotate(angle);
      scale(scale);
      imageMode(CENTER);
      if (alpha < 255) tint(255, 255, 255, (int)alpha);
      image(lidImg, 0, 0);
      if (alpha < 255) noTint();
      popMatrix();
    } else {
      pushMatrix();
      translate(px, py);
      rotate(angle);
      if (alpha < 255) fill(160, 82, 45, (int)alpha);
      else fill(160, 82, 45);
      noStroke();
      rectMode(CENTER);
      rect(0, 0, 42 * scale, 15 * scale);
      popMatrix();
    }
  }

  float getBagX() { return hit ? hitSpawnX : boxX; }
  float getBagY() { return hit ? hitSpawnY : boxCenterY; }
  String getType() { return type; }
  boolean isHit() { return hit; }
}
