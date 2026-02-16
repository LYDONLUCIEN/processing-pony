// ==================== ShoudaiRibbon.pde 绶带（终点线） ====================
// success 的 time（如 79.2）表示该时刻绶带中心与 PONY_CHEST 相碰并触发动画。
// 绶带根据 leadTime 提前从画面右侧开始移动；触发前只显示首帧不播，触发后播一遍不循环，播完停最后一帧。

class ShoudaiRibbon {
  float x, y;
  float speed;
  float scale;   // 只用一个缩放，绘制时按图片比例不压缩
  float ribbonW, ribbonH;  // 由首帧与 scale 算出，用于 isOffScreenLeft 等
  PImage[] frames;
  float fps;
  float animationElapsed; // 触发后才递增，用于取帧；播完停最后一帧不循环
  boolean active = false;
  boolean hasTriggeredSuccess = false;

  ShoudaiRibbon(PImage[] frameArray, float frameFps, float moveSpeed, float displayScale) {
    frames = frameArray != null ? frameArray : new PImage[0];
    fps = frameFps > 0 ? frameFps : 24;
    speed = moveSpeed;
    scale = displayScale > 0 ? displayScale : 1;
    if (frames.length > 0 && frames[0] != null && frames[0].width > 0) {
      ribbonW = frames[0].width * scale;
      ribbonH = frames[0].height * scale;
    } else {
      ribbonW = ribbonH = 0;
    }
  }

  void spawn(float startX, float centerY) {
    x = startX;
    y = centerY;
    animationElapsed = 0;
    active = true;
    hasTriggeredSuccess = false;
  }

  void update(float dt) {
    if (!active) return;
    x -= speed * dt;
    if (hasTriggeredSuccess && fps > 0 && frames.length > 1) {
      float maxElapsed = (frames.length - 1) / fps;
      if (animationElapsed < maxElapsed) animationElapsed += dt;
    }
  }

  void display() {
    if (!active || frames == null || frames.length == 0) return;
    PImage img = frames[0];
    if (hasTriggeredSuccess && fps > 0 && frames.length > 1) {
      int idx = (int)(animationElapsed * fps);
      if (idx < 0) idx = 0;
      if (idx >= frames.length) idx = frames.length - 1;
      img = frames[idx];
    }
    if (img == null || img.width == 0) return;
    imageMode(CENTER);
    pushMatrix();
    translate(x, y);
    if (SHOUDAI_RIBBON_ANGLE_DEG != 0) rotate(-radians(SHOUDAI_RIBBON_ANGLE_DEG));
    float drawW = img.width * scale;
    float drawH = img.height * scale;
    image(img, 0, 0, drawW, drawH);
    popMatrix();
  }

  /** 绶带中心是否已到达胸口 X（中心点 = PONY_CHEST 时才开始播马到成功） */
  boolean hitChest(float chestX) {
    if (!active) return false;
    return x <= chestX;
  }

  boolean hasAlreadyTriggeredSuccess() {
    return hasTriggeredSuccess;
  }

  void setTriggeredSuccess() {
    hasTriggeredSuccess = true;
  }

  /** 绶带是否已完全移出画面左侧（可安全移除） */
  boolean isOffScreenLeft() {
    if (!active) return true;
    return (x + ribbonW/2) < 0;
  }

  void deactivate() {
    active = false;
  }

  boolean isActive() {
    return active;
  }
}
