// ==================== 山层系统 ====================
// 与 floor 相同逻辑：单张 final-all.png，双块无缝滚动，固定慢速向左
// mountain 目录下只使用 final-all.png

class MountainLayer {
  PImage mountainImg;
  float mountainWidthPx;  // 屏幕上每块山的宽度 = 原图宽 * scale
  float speed;
  MountainBlock block1;
  MountainBlock block2;

  MountainLayer() {
    loadMountainImage();
    if (mountainImg != null && mountainImg.width > 0) {
      mountainWidthPx = mountainImg.width * MOUNTAIN_SCALE;
    } else {
      mountainWidthPx = 1000;
    }
    speed = MOUNTAIN_SPEED;
    block1 = new MountainBlock(0);
    block2 = new MountainBlock(mountainWidthPx);
  }

  void loadMountainImage() {
    mountainImg = loadImage(MOUNTAIN_PATH);
    if (mountainImg != null) {
      int w = mountainImg.width;
      int h = mountainImg.height;
      if (w > MOUNTAIN_MAX_TEXTURE_WIDTH) {
        int newH = (int)((float)h * MOUNTAIN_MAX_TEXTURE_WIDTH / w);
        mountainImg.resize(MOUNTAIN_MAX_TEXTURE_WIDTH, newH);
        println("Mountain image loaded and resized to: " + mountainImg.width + "x" + mountainImg.height + " (from " + w + "x" + h + ")");
      } else {
        println("Mountain image loaded: " + w + "x" + h);
      }
    } else {
      println("ERROR: Failed to load mountain from: " + MOUNTAIN_PATH);
    }
  }

  void update(float dt) {
    if (backgroundFrozen) return;
    if (mountainImg != null) {
      block1.update(dt);
      block2.update(dt);
      checkAndSwap(block1, block2);
      checkAndSwap(block2, block1);
    }
  }

  void checkAndSwap(MountainBlock current, MountainBlock other) {
    if (current.isFullyOffScreen()) {
      current.resetToRightOf(other);
    }
  }

  void display() {
    if (mountainImg != null) {
      block1.display();
      block2.display();
    }
  }

  // ==================== MountainBlock：一块山（与 GroundBlock 同逻辑） ====================
  class MountainBlock {
    float x;  // 左边缘的 x

    MountainBlock(float startX) {
      x = startX;
    }

    void update(float dt) {
      x -= speed * dt;
    }

    void display() {
      if (mountainImg == null) return;
      float halfW = mountainWidthPx * 0.5;
      float centerX = x + halfW;
      if (centerX + halfW < 0 || centerX - halfW > width) return;
      pushMatrix();
      translate(centerX, MOUNTAIN_BASE_Y);
      scale(MOUNTAIN_SCALE);
      imageMode(CENTER);
      image(mountainImg, 0, 0);
      popMatrix();
    }

    boolean isFullyOffScreen() {
      return x + mountainWidthPx < 0;
    }

    void resetToRightOf(MountainBlock other) {
      x = other.x + mountainWidthPx;
    }
  }
}
