// ==================== 柱子层（主场景） ====================
// 与 flower/railing 同逻辑：FORGE_SPEED 无缝双块向左滚动，在花丛/栏杆后、山前；细节由 AnimationConfig 控制

class ZhuziLayer {
  PImage img;
  float widthPx;
  ZhuziBlock block1;
  ZhuziBlock block2;

  ZhuziLayer() {
    loadZhuziImage();
    if (img != null && img.width > 0) {
      widthPx = img.width * ZHUZI_SCALE;
      block1 = new ZhuziBlock(0, img, widthPx, ZHUZI_BASE_Y, ZHUZI_SCALE, ZHUZI_SPEED);
      block2 = new ZhuziBlock(widthPx, img, widthPx, ZHUZI_BASE_Y, ZHUZI_SCALE, ZHUZI_SPEED);
    } else {
      widthPx = 800;
      block1 = null;
      block2 = null;
    }
  }

  void loadZhuziImage() {
    img = loadImage(ZHUZI_IMAGE_PATH);
    if (img != null && img.width > 0) {
      int w = img.width;
      int h = img.height;
      if (ZHUZI_MAX_TEXTURE_WIDTH > 0 && w > ZHUZI_MAX_TEXTURE_WIDTH) {
        int newH = (int)((float)h * ZHUZI_MAX_TEXTURE_WIDTH / w);
        img.resize(ZHUZI_MAX_TEXTURE_WIDTH, newH);
        println("[zhuzi] loaded and resized to " + img.width + "x" + img.height + " (from " + w + "x" + h + ")");
      } else {
        println("[zhuzi] loaded " + ZHUZI_IMAGE_PATH + " " + w + "x" + h);
      }
    } else {
      println("[zhuzi] " + ZHUZI_IMAGE_PATH + " not found, skip draw");
    }
  }

  void update(float dt) {
    if (backgroundFrozen) return;
    if (block1 != null && block2 != null) {
      block1.update(dt);
      block2.update(dt);
      checkAndSwap(block1, block2);
      checkAndSwap(block2, block1);
    }
  }

  void checkAndSwap(ZhuziBlock current, ZhuziBlock other) {
    if (current.isFullyOffScreen()) {
      current.resetToRightOf(other);
    }
  }

  void display() {
    if (block1 != null) block1.display();
    if (block2 != null) block2.display();
  }

  // 单块：按左边缘 x + 图片逻辑宽度做无缝拼接（与 RoadsideBlock 逻辑一致）
  class ZhuziBlock {
    float x;
    PImage img;
    float widthPx;
    float baseY;
    float scale;
    float speed;

    ZhuziBlock(float startX, PImage img, float widthPx, float baseY, float scale, float speed) {
      this.x = startX;
      this.img = img;
      this.widthPx = widthPx;
      this.baseY = baseY;
      this.scale = scale;
      this.speed = speed;
    }

    void update(float dt) {
      x -= speed * dt;
    }

    void display() {
      if (img == null) return;
      float halfW = widthPx * 0.5;
      float centerX = x + halfW;
      if (centerX + halfW < 0 || centerX - halfW > width) return;
      pushMatrix();
      translate(centerX, baseY);
      scale(scale);
      imageMode(CENTER);
      image(img, 0, 0);
      popMatrix();
    }

    boolean isFullyOffScreen() {
      return x + widthPx < 0;
    }

    void resetToRightOf(ZhuziBlock other) {
      x = other.x + widthPx;
    }
  }
}
