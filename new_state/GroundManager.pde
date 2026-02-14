// ==================== 地面滚动系统 ====================
// GroundManager.pde - floor2.png 平行四边形双块滚动
//
// 几何与旧版 P2D texture+QUADS 完全一致：
//   底边：(x, groundY) — (x+widthPx, groundY)
//   顶边：(x+slantPx, groundY-heightPx) — (x+widthPx+slantPx, groundY-heightPx)
//   slantPx = 顶边相对底边向右偏移（由 GROUND_TILT_DEG 或 GROUND_SLANT_PIXELS 决定）
// JAVA2D 下用 shearX 实现上述平行四边形，再贴图。

class GroundManager {
  PImage groundImg;

  float groundY;      // 屏幕上的底边 y
  float heightPx;     // 屏幕上的高度（例如 270）
  float widthPx;      // 逻辑宽度（使用原图宽度，如 5060）
  float slantPx;      // 顶边相对底边水平偏移像素（剪切量）
  float speed;        // 滚动速度（像素/秒，向左）

  GroundBlock block1;
  GroundBlock block2;

 GroundManager() {
    loadGroundImage();

    if (groundImg == null) {
      println("ERROR: Failed to load ground image from: " + GROUND_PATH);
      groundImg = createImage(100, 100, RGB);
    }

    groundY  = GROUND_Y;
    heightPx = GROUND_PARALLELOGRAM_HEIGHT;
    widthPx  = groundImg.width;
    speed    = GROUND_SPEED;

    // 与旧版一致：优先用像素值，否则用角度 slantPx = heightPx * tan(GROUND_TILT_DEG)
    if (GROUND_SLANT_PIXELS > 0) {
      slantPx = GROUND_SLANT_PIXELS;
    } else {
      float tiltRad = radians(GROUND_TILT_DEG);
      slantPx = heightPx * tan(tiltRad);
    }

    block1 = new GroundBlock(0);
    block2 = new GroundBlock(widthPx);

    println("Ground initialized: tex=" + groundImg.width + "x" + groundImg.height +
            " screen=" + widthPx + "x" + heightPx +
            " y=" + groundY + " slantPx=" + slantPx +
            " (tune: GROUND_TILT_DEG or GROUND_SLANT_PIXELS) speed=" + speed);
  }

  void loadGroundImage() {
    groundImg = loadImage(GROUND_PATH);
    if (groundImg != null) {
      int w = groundImg.width;
      int h = groundImg.height;
      if (w > GROUND_MAX_TEXTURE_WIDTH) {
        int newH = (int)((float)h * GROUND_MAX_TEXTURE_WIDTH / w);
        groundImg.resize(GROUND_MAX_TEXTURE_WIDTH, newH);
        println("Ground image loaded and resized to: " + groundImg.width + "x" + groundImg.height + " (from " + w + "x" + h + ")");
      } else {
        println("Ground image loaded: " + w + "x" + h);
      }
    }
  }

  void update(float dt) {
    if (groundImg == null) return;

    block1.update(dt);
    block2.update(dt);

    // 只要某一块完全离开左侧，就把它移到另一块右边
    checkAndSwap(block1, block2);
    checkAndSwap(block2, block1);
  }

  void display() {
    if (groundImg == null) {
      fill(255, 0, 0);
      noStroke();
      rect(0, groundY - heightPx, width, heightPx);
      fill(255);
      text("Ground image not loaded!", 10, groundY - 20);
      return;
    }

    // JAVA2D 下用 shearX 做平行四边形变形（原 texture+QUADS 仅在 P2D 有效）
    noStroke();
    block1.display();
    block2.display();
  }

  void checkAndSwap(GroundBlock current, GroundBlock other) {
    if (current.isFullyOffScreen()) {
      current.resetToRightOf(other);
    }
  }

  // ==================== GroundBlock：一块地面 ====================

  class GroundBlock {
    float x;  // 底边左下角的 x

    GroundBlock(float startX) {
      x = startX;
    }

    void update(float dt) {
      x -= speed * dt;
    }

    void display() {
      // 与旧版一致：可见范围左缘 x，右缘 x+widthPx+slantPx
      if (x > width || x + widthPx + slantPx < 0) return;

      pushMatrix();
      translate(x, groundY);  // 原点 = 底边左下角，y 向下为正（Processing 默认）
      // shearX(angle): x' = x + y*tan(angle)。令 (0,-heightPx) → (slantPx,-heightPx) 得 tan(angle)=-slantPx/heightPx
      shearX(atan(-slantPx / heightPx));
      imageMode(CORNER);
      image(groundImg, 0, -heightPx, widthPx, heightPx);  // 矩形贴图，剪切后即平行四边形
      popMatrix();
    }

    // 完全离开左侧：平行四边形右缘移出屏幕
    boolean isFullyOffScreen() {
      return x + widthPx + slantPx < 0;
    }

    // 把当前块重置到 other 的右边，保证无缝衔接
    void resetToRightOf(GroundBlock other) {
      x = other.x + widthPx;
    }
  }
}