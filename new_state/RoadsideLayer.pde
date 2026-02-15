// ==================== 路边近景层 ====================
// 花朵、栏杆、护栏、草丛（从远到近）；最下方为护栏+草丛
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

  // 画面最下方：护栏、草丛
  PImage guardrailImg;
  float guardrailWidthPx;
  RoadsideBlock guardrailBlock1;
  RoadsideBlock guardrailBlock2;
  PImage grassImg;
  float grassWidthPx;
  RoadsideBlock grassBlock1;
  RoadsideBlock grassBlock2;

  RoadsideLayer() {
    loadFlowerImage();
    loadRailingImage();
    loadGuardrailImage();
    loadGrassImage();

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

    if (guardrailImg != null && guardrailImg.width > 0) {
      guardrailWidthPx = guardrailImg.width * ROADSIDE_GUARDRAIL_SCALE;
      guardrailBlock1 = new RoadsideBlock(0, guardrailImg, guardrailWidthPx, ROADSIDE_GUARDRAIL_BASE_Y, ROADSIDE_GUARDRAIL_SCALE, ROADSIDE_GUARDRAIL_SPEED);
      guardrailBlock2 = new RoadsideBlock(guardrailWidthPx, guardrailImg, guardrailWidthPx, ROADSIDE_GUARDRAIL_BASE_Y, ROADSIDE_GUARDRAIL_SCALE, ROADSIDE_GUARDRAIL_SPEED);
    } else {
      guardrailWidthPx = 800;
      guardrailBlock1 = null;
      guardrailBlock2 = null;
    }

    if (grassImg != null && grassImg.width > 0) {
      grassWidthPx = grassImg.width * ROADSIDE_GRASS_SCALE;
      grassBlock1 = new RoadsideBlock(0, grassImg, grassWidthPx, ROADSIDE_GRASS_BASE_Y, ROADSIDE_GRASS_SCALE, ROADSIDE_GRASS_SPEED);
      grassBlock2 = new RoadsideBlock(grassWidthPx, grassImg, grassWidthPx, ROADSIDE_GRASS_BASE_Y, ROADSIDE_GRASS_SCALE, ROADSIDE_GRASS_SPEED);
    } else {
      grassWidthPx = 800;
      grassBlock1 = null;
      grassBlock2 = null;
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

  void loadGuardrailImage() {
    guardrailImg = loadImage(ROADSIDE_GUARDRAIL_PATH);
    if (guardrailImg != null) {
      int w = guardrailImg.width;
      int h = guardrailImg.height;
      if (w > ROADSIDE_MAX_TEXTURE_WIDTH) {
        int newH = (int)((float)h * ROADSIDE_MAX_TEXTURE_WIDTH / w);
        guardrailImg.resize(ROADSIDE_MAX_TEXTURE_WIDTH, newH);
        println("Roadside guardrail loaded and resized to: " + guardrailImg.width + "x" + guardrailImg.height);
      } else {
        println("Roadside guardrail loaded: " + w + "x" + h);
      }
    } else {
      println("ERROR: Failed to load guardrail from: " + ROADSIDE_GUARDRAIL_PATH);
    }
  }

  void loadGrassImage() {
    grassImg = loadImage(ROADSIDE_GRASS_PATH);
    if (grassImg != null) {
      int w = grassImg.width;
      int h = grassImg.height;
      if (w > ROADSIDE_MAX_TEXTURE_WIDTH) {
        int newH = (int)((float)h * ROADSIDE_MAX_TEXTURE_WIDTH / w);
        grassImg.resize(ROADSIDE_MAX_TEXTURE_WIDTH, newH);
        println("Roadside grass loaded and resized to: " + grassImg.width + "x" + grassImg.height);
      } else {
        println("Roadside grass loaded: " + w + "x" + h);
      }
    } else {
      println("ERROR: Failed to load grass from: " + ROADSIDE_GRASS_PATH);
    }
  }

  void update(float dt) {
    if (backgroundFrozen) return;
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
    if (guardrailBlock1 != null && guardrailBlock2 != null) {
      guardrailBlock1.update(dt);
      guardrailBlock2.update(dt);
      checkAndSwap(guardrailBlock1, guardrailBlock2);
      checkAndSwap(guardrailBlock2, guardrailBlock1);
    }
    if (grassBlock1 != null && grassBlock2 != null) {
      grassBlock1.update(dt);
      grassBlock2.update(dt);
      checkAndSwap(grassBlock1, grassBlock2);
      checkAndSwap(grassBlock2, grassBlock1);
    }
  }

  void checkAndSwap(RoadsideBlock current, RoadsideBlock other) {
    if (current.isFullyOffScreen()) {
      current.resetToRightOf(other);
    }
  }

  void display() {
    // 从远到近：花朵 → 栏杆 → 护栏（最下方）→ 草丛（最前）
    if (flowerBlock1 != null) flowerBlock1.display();
    if (flowerBlock2 != null) flowerBlock2.display();
    if (railingBlock1 != null) railingBlock1.display();
    if (railingBlock2 != null) railingBlock2.display();
    if (guardrailBlock1 != null) guardrailBlock1.display();
    if (guardrailBlock2 != null) guardrailBlock2.display();
    if (grassBlock1 != null) grassBlock1.display();
    if (grassBlock2 != null) grassBlock2.display();
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
