// ==================== 路边近景层 ====================
// 花朵（floor 与 mountain 接缝处）+ 栏杆（在花朵前）
// 逻辑：一开始就在画面中，匀速缓慢向左，双块按图片尺寸无缝拼接；大图按性能压缩

class RoadsideLayer {
  // 花朵
  PImage flowerImg;
  float flowerWidthPx;
  RoadsideBlock flowerBlock1;
  RoadsideBlock flowerBlock2;

  // 栏杆（在花朵前）
  PImage railingImg;
  float railingWidthPx;
  RoadsideBlock railingBlock1;
  RoadsideBlock railingBlock2;

  RoadsideLayer() {
    loadFlowerImage();
    loadRailingImage();

    if (flowerImg != null && flowerImg.width > 0) {
      flowerWidthPx = flowerImg.width * ROADSIDE_FLOWER_SCALE;
      flowerBlock1 = new RoadsideBlock(0, flowerImg, flowerWidthPx, ROADSIDE_FLOWER_BASE_Y, ROADSIDE_FLOWER_SCALE, ROADSIDE_FLOWER_SPEED);
      flowerBlock2 = new RoadsideBlock(flowerWidthPx, flowerImg, flowerWidthPx, ROADSIDE_FLOWER_BASE_Y, ROADSIDE_FLOWER_SCALE, ROADSIDE_FLOWER_SPEED);
    } else {
      flowerWidthPx = 800;
      flowerBlock1 = null;
      flowerBlock2 = null;
    }

    if (railingImg != null && railingImg.width > 0) {
      railingWidthPx = railingImg.width * ROADSIDE_RAILING_SCALE;
      railingBlock1 = new RoadsideBlock(0, railingImg, railingWidthPx, ROADSIDE_RAILING_BASE_Y, ROADSIDE_RAILING_SCALE, ROADSIDE_RAILING_SPEED);
      railingBlock2 = new RoadsideBlock(railingWidthPx, railingImg, railingWidthPx, ROADSIDE_RAILING_BASE_Y, ROADSIDE_RAILING_SCALE, ROADSIDE_RAILING_SPEED);
    } else {
      railingWidthPx = 800;
      railingBlock1 = null;
      railingBlock2 = null;
    }
  }

  void loadFlowerImage() {
    flowerImg = loadImage(ROADSIDE_FLOWER_PATH);
    if (flowerImg != null) {
      int w = flowerImg.width;
      int h = flowerImg.height;
      if (w > ROADSIDE_MAX_TEXTURE_WIDTH) {
        int newH = (int)((float)h * ROADSIDE_MAX_TEXTURE_WIDTH / w);
        flowerImg.resize(ROADSIDE_MAX_TEXTURE_WIDTH, newH);
        println("Roadside flower loaded and resized to: " + flowerImg.width + "x" + flowerImg.height + " (from " + w + "x" + h + ")");
      } else {
        println("Roadside flower loaded: " + w + "x" + h);
      }
    } else {
      println("ERROR: Failed to load roadside flower from: " + ROADSIDE_FLOWER_PATH);
    }
  }

  void loadRailingImage() {
    railingImg = loadImage(ROADSIDE_RAILING_PATH);
    if (railingImg != null) {
      int w = railingImg.width;
      int h = railingImg.height;
      if (w > ROADSIDE_MAX_TEXTURE_WIDTH) {
        int newH = (int)((float)h * ROADSIDE_MAX_TEXTURE_WIDTH / w);
        railingImg.resize(ROADSIDE_MAX_TEXTURE_WIDTH, newH);
        println("Roadside railing loaded and resized to: " + railingImg.width + "x" + railingImg.height + " (from " + w + "x" + h + ")");
      } else {
        println("Roadside railing loaded: " + w + "x" + h);
      }
    } else {
      println("ERROR: Failed to load roadside railing from: " + ROADSIDE_RAILING_PATH);
    }
  }

  void update(float dt) {
    if (flowerBlock1 != null && flowerBlock2 != null) {
      flowerBlock1.update(dt);
      flowerBlock2.update(dt);
      checkAndSwap(flowerBlock1, flowerBlock2);
      checkAndSwap(flowerBlock2, flowerBlock1);
    }
    if (railingBlock1 != null && railingBlock2 != null) {
      railingBlock1.update(dt);
      railingBlock2.update(dt);
      checkAndSwap(railingBlock1, railingBlock2);
      checkAndSwap(railingBlock2, railingBlock1);
    }
  }

  void checkAndSwap(RoadsideBlock current, RoadsideBlock other) {
    if (current.isFullyOffScreen()) {
      current.resetToRightOf(other);
    }
  }

  void display() {
    // 先画花朵（靠后），再画栏杆（靠前）
    if (flowerBlock1 != null) flowerBlock1.display();
    if (flowerBlock2 != null) flowerBlock2.display();
    if (railingBlock1 != null) railingBlock1.display();
    if (railingBlock2 != null) railingBlock2.display();
  }

  // ==================== 单块：按左边缘 x + 图片逻辑宽度做无缝拼接 ====================
  class RoadsideBlock {
    float x;
    PImage img;
    float widthPx;
    float baseY;
    float scale;
    float speed;

    RoadsideBlock(float startX, PImage img, float widthPx, float baseY, float scale, float speed) {
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

    void resetToRightOf(RoadsideBlock other) {
      x = other.x + widthPx;
    }
  }
}
