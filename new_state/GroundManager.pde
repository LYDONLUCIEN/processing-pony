// ==================== 地面滚动系统 ====================
// GroundManager.pde - floor2.png 平行四边形双块滚动
//
// 行为：
// - 把 floor2.png 当作 5060x556 的矩形，在屏幕上画成一个高度固定（270 像素）的平行四边形。
// - 上下两条边都是水平的，图片里的水平线仍然是水平的，只是轮廓被剪成平行四边形。
// - 使用两块 GroundBlock 首尾拼接，简单水平滑动实现无限地面。

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

    // 用角度控制剪切量：slantPx = heightPx * tan(θ)
    float tiltRad = radians(GROUND_TILT_DEG);
    slantPx = heightPx * tan(tiltRad);

    block1 = new GroundBlock(0);
    block2 = new GroundBlock(widthPx);

    println("Ground initialized: tex=" + groundImg.width + "x" + groundImg.height +
            " screen=" + widthPx + "x" + heightPx +
            " y=" + groundY + " slantPx=" + slantPx +
            " tiltDeg=" + GROUND_TILT_DEG +
            " speed=" + speed);
  }

  void loadGroundImage() {
    groundImg = loadImage(GROUND_PATH);
    if (groundImg != null) {
      println("Ground image loaded: " + groundImg.width + "x" + groundImg.height);
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

    textureMode(NORMAL);
    noStroke();
    fill(255);

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
      // 粗略裁剪：如果整块都在屏幕右边或左边很远，就不画
      if (x > width || x + widthPx + slantPx < 0) return;

      beginShape();
      texture(groundImg);

      // 屏幕坐标：
      // 底边： (x, groundY) -> (x + widthPx,       groundY)
      // 顶边： (x + slantPx, groundY - heightPx) -> (x + widthPx + slantPx, groundY - heightPx)

      float bx = x;
      float by = groundY;

      // 左下：u=0, v=1
      vertex(bx,               by,              0, 1);
      // 右下：u=1, v=1
      vertex(bx + widthPx,     by,              1, 1);
      // 右上：u=1, v=0
      vertex(bx + widthPx + slantPx, by - heightPx, 1, 0);
      // 左上：u=0, v=0
      vertex(bx + slantPx,     by - heightPx,   0, 0);

      endShape(CLOSE);
    }

    // 完全离开左侧：右上角的 x 也小于 0 时
    boolean isFullyOffScreen() {
      float rightMostX = x + widthPx + slantPx;
      return rightMostX < 0;
    }

    // 把当前块重置到 other 的右边，保证无缝衔接
    void resetToRightOf(GroundBlock other) {
      x = other.x + widthPx;
    }
  }
}