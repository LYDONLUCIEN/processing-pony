// ==================== 地面滚动系统 ====================
// 使用平行四边形地面块 + 无缝滚动
//
// 思路：
// - 使用一张长方形纹理（GROUND_PATH），按 GROUND_HEIGHT_RATIO 缩放到合适高度。
// - 将矩形变形为平行四边形（通过 GROUND_SLANT_FACTOR 倾斜顶部边缘）。
// - 使用两个 GroundBlock 首尾拼接，向左滚动；当一块完全离屏时，重置到另一块右侧，实现无限循环。
//

class GroundManager {
  PImage groundImg;

  // 几何与滚动参数（从 AnimationConfig.pde 派生）
  float groundY;          // 地面底边 y 坐标
  float groundHeight;     // 地面高度（像素）
  float groundWidth;      // 地面宽度（像素，纹理缩放后）
  float scaleRatio;       // 纹理缩放系数
  float slantFactor;      // 平行四边形顶部相对底部的水平偏移比例
  float speed;            // 滚动速度（像素/秒，向左）

  GroundBlock block1;
  GroundBlock block2;

  GroundManager() {
    loadGroundImage();

    if (groundImg == null) {
      println("ERROR: Failed to load ground image from: " + GROUND_PATH);
      return;
    }

    // 计算缩放：根据屏幕高度与 GROUND_HEIGHT_RATIO 得到目标高度
    groundY = GROUND_Y;
    slantFactor = GROUND_SLANT_FACTOR;
    speed = GROUND_SPEED;

    scaleRatio = (height * GROUND_HEIGHT_RATIO) / groundImg.height;
    groundHeight = groundImg.height * scaleRatio;
    groundWidth = groundImg.width * scaleRatio;

    // 初始化两个地面块：第二块接在第一块右侧，考虑顶部倾斜
    float topOffset = groundWidth * slantFactor;
    block1 = new GroundBlock(0);
    block2 = new GroundBlock(groundWidth - topOffset);

    println("Ground initialized: w=" + groundWidth + " h=" + groundHeight
      + " slant=" + slantFactor + " speed=" + speed + " y=" + groundY);
  }

  void loadGroundImage() {
    groundImg = loadImage(GROUND_PATH);
    if (groundImg != null) {
      println("Ground image loaded: " + groundImg.width + "x" + groundImg.height
        + " from " + GROUND_PATH);
    }
  }

  void update(float dt) {
    if (groundImg == null) return;

    block1.update(dt);
    block2.update(dt);

    // 无缝重置逻辑：任何一块完全离屏后，移动到另一块右侧
    checkAndSwap(block1, block2);
    checkAndSwap(block2, block1);
  }

  void display() {
    if (groundImg == null) {
      // 如果图片加载失败，显示调试矩形
      fill(255, 0, 0);
      noStroke();
      rect(0, groundY - 40, width, 40);
      fill(255);
      text("Ground image not loaded!", 10, groundY - 20);
      return;
    }

    textureMode(NORMAL);
    noStroke();

    block1.display();
    block2.display();
  }

  // ===== 内部 GroundBlock 类 =====

  class GroundBlock {
    float x;  // 底边左下角顶点的 x 坐标

    GroundBlock(float startX) {
      x = startX;
    }

    void update(float dt) {
      x -= speed * dt;
    }

    void display() {
      // 只在地面块可能可见时绘制
      if (x + groundWidth > 0 && x < width) {
        float topOffset = groundWidth * slantFactor;

        beginShape();
        texture(groundImg);

        // 顶点顺序：左下 -> 右下 -> 右上 -> 左上
        // 纹理坐标使用 0~1 的 NORMAL 模式

        // 左下
        vertex(x, groundY, 0, 1);
        // 右下
        vertex(x + groundWidth, groundY, 1, 1);
        // 右上（向左倾斜）
        vertex(x + groundWidth - topOffset, groundY - groundHeight, 1, 0);
        // 左上（向左倾斜）
        vertex(x - topOffset, groundY - groundHeight, 0, 0);

        endShape(CLOSE);
      }
    }

    // 判断当前块是否完全离开屏幕左侧（包含顶部倾斜影响）
    boolean isFullyOffScreen() {
      float topOffset = groundWidth * slantFactor;
      return x + groundWidth - topOffset < 0;
    }

    // 把当前块重置到另一块的右侧，保证无缝衔接
    void resetToRightOf(GroundBlock other) {
      float topOffset = groundWidth * slantFactor;
      x = other.x + groundWidth - topOffset;
    }
  }

  // 工具函数：检查并在需要时把 current 移到 other 右侧
  void checkAndSwap(GroundBlock current, GroundBlock other) {
    if (current.isFullyOffScreen()) {
      current.resetToRightOf(other);
    }
  }
}

// ==================== 地面滚动系统 ====================
// 使用平行四边形地面块 + 无缝滚动
//
// 思路：
// - 使用一张长方形纹理（GROUND_PATH），按 GROUND_HEIGHT_RATIO 缩放到合适高度。
// - 将矩形变形为平行四边形（通过 GROUND_SLANT_FACTOR 倾斜顶部边缘）。
// - 使用两个 GroundBlock 首尾拼接，向左滚动；当一块完全离屏时，重置到另一块右侧，实现无限循环。
//

class GroundManager {
  PImage groundImg;

  // 几何与滚动参数（从配置派生）
  float groundY;          // 地面底边 y 坐标
  float groundHeight;     // 地面高度（像素）
  float groundWidth;      // 地面宽度（像素，纹理缩放后）
  float scaleRatio;       // 纹理缩放系数
  float slantFactor;      // 平行四边形顶部相对底部的水平偏移比例
  float speed;            // 滚动速度（像素/秒，向左）

  GroundBlock block1;
  GroundBlock block2;

  GroundManager() {
    loadGroundImage();

    if (groundImg == null) {
      println("ERROR: Failed to load ground image from: " + GROUND_PATH);
      return;
    }

    // 计算缩放：根据屏幕高度与 GROUND_HEIGHT_RATIO 得到目标高度
    groundY = GROUND_Y;
    slantFactor = GROUND_SLANT_FACTOR;
    speed = GROUND_SPEED;

    scaleRatio = (height * GROUND_HEIGHT_RATIO) / groundImg.height;
    groundHeight = groundImg.height * scaleRatio;
    groundWidth = groundImg.width * scaleRatio;

    // 初始化两个地面块：第二块接在第一块右侧，考虑顶部倾斜
    float topOffset = groundWidth * slantFactor;
    block1 = new GroundBlock(0);
    block2 = new GroundBlock(groundWidth - topOffset);

    println("Ground initialized: w=" + groundWidth + " h=" + groundHeight
      + " slant=" + slantFactor + " speed=" + speed + " y=" + groundY);
  }

  void loadGroundImage() {
    groundImg = loadImage(GROUND_PATH);
    if (groundImg != null) {
      println("Ground image loaded: " + groundImg.width + "x" + groundImg.height
        + " from " + GROUND_PATH);
    }
  }

  void update(float dt) {
    if (groundImg == null) return;

    block1.update(dt);
    block2.update(dt);

    // 无缝重置逻辑：任何一块完全离屏后，移动到另一块右侧
    checkAndSwap(block1, block2);
    checkAndSwap(block2, block1);
  }

  void display() {
    if (groundImg == null) {
      // 如果图片加载失败，显示调试矩形
      fill(255, 0, 0);
      noStroke();
      rect(0, groundY - 40, width, 40);
      fill(255);
      text("Ground image not loaded!", 10, groundY - 20);
      return;
    }

    textureMode(NORMAL);
    noStroke();

    block1.display();
    block2.display();
  }

  // ===== 内部 GroundBlock 类 =====

  class GroundBlock {
    float x;  // 底边左下角顶点的 x 坐标

    GroundBlock(float startX) {
      x = startX;
    }

    void update(float dt) {
      x -= speed * dt;
    }

    void display() {
      // 只在地面块可能可见时绘制
      if (x + groundWidth > 0 && x < width) {
        float topOffset = groundWidth * slantFactor;

        beginShape();
        texture(groundImg);

        // 顶点顺序：左下 -> 右下 -> 右上 -> 左上
        // 纹理坐标使用 0~1 的 NORMAL 模式

        // 左下
        vertex(x, groundY, 0, 1);
        // 右下
        vertex(x + groundWidth, groundY, 1, 1);
        // 右上（向左倾斜）
        vertex(x + groundWidth - topOffset, groundY - groundHeight, 1, 0);
        // 左上（向左倾斜）
        vertex(x - topOffset, groundY - groundHeight, 0, 0);

        endShape(CLOSE);
      }
    }

    // 判断当前块是否完全离开屏幕左侧（包含顶部倾斜影响）
    boolean isFullyOffScreen() {
      float topOffset = groundWidth * slantFactor;
      return x + groundWidth - topOffset < 0;
    }

    // 把当前块重置到另一块的右侧，保证无缝衔接
    void resetToRightOf(GroundBlock other) {
      float topOffset = groundWidth * slantFactor;
      x = other.x + groundWidth - topOffset;
    }
  }

  // 工具函数：检查并在需要时把 current 移到 other 右侧
  void checkAndSwap(GroundBlock current, GroundBlock other) {
    if (current.isFullyOffScreen()) {
      current.resetToRightOf(other);
    }
  }
}

// ==================== 地面滚动系统 ====================
// 使用平行四边形地面块 + 无缝滚动
//
// 思路：
// - 使用一张长方形纹理（GROUND_PATH），按 GROUND_HEIGHT_RATIO 缩放到合适高度。
// - 将矩形变形为平行四边形（通过 GROUND_SLANT_FACTOR 倾斜顶部边缘）。
// - 使用两个 GroundBlock 首尾拼接，向左滚动；当一块完全离屏时，重置到另一块右侧，实现无限循环。
//

class GroundManager {
  PImage groundImg;

  // 几何与滚动参数（从配置派生）
  float groundY;          // 地面底边 y 坐标
  float groundHeight;     // 地面高度（像素）
  float groundWidth;      // 地面宽度（像素，纹理缩放后）
  float scaleRatio;       // 纹理缩放系数
  float slantFactor;      // 平行四边形顶部相对底部的水平偏移比例
  float speed;            // 滚动速度（像素/秒，向左）

  GroundBlock block1;
  GroundBlock block2;

  GroundManager() {
    loadGroundImage();

    if (groundImg == null) {
      println("ERROR: Failed to load ground image from: " + GROUND_PATH);
      return;
    }

    // 计算缩放：根据屏幕高度与 GROUND_HEIGHT_RATIO 得到目标高度
    groundY = GROUND_Y;
    slantFactor = GROUND_SLANT_FACTOR;
    speed = GROUND_SPEED;

    scaleRatio = (height * GROUND_HEIGHT_RATIO) / groundImg.height;
    groundHeight = groundImg.height * scaleRatio;
    groundWidth = groundImg.width * scaleRatio;

    // 初始化两个地面块：第二块接在第一块右侧，考虑顶部倾斜
    float topOffset = groundWidth * slantFactor;
    block1 = new GroundBlock(0);
    block2 = new GroundBlock(groundWidth - topOffset);

    println("Ground initialized: w=" + groundWidth + " h=" + groundHeight
      + " slant=" + slantFactor + " speed=" + speed + " y=" + groundY);
  }

  void loadGroundImage() {
    groundImg = loadImage(GROUND_PATH);
    if (groundImg != null) {
      println("Ground image loaded: " + groundImg.width + "x" + groundImg.height
        + " from " + GROUND_PATH);
    }
  }

  void update(float dt) {
    if (groundImg == null) return;

    block1.update(dt);
    block2.update(dt);

    // 无缝重置逻辑：任何一块完全离屏后，移动到另一块右侧
    checkAndSwap(block1, block2);
    checkAndSwap(block2, block1);
  }

  void display() {
    if (groundImg == null) {
      // 如果图片加载失败，显示调试矩形
      fill(255, 0, 0);
      noStroke();
      rect(0, groundY - 40, width, 40);
      fill(255);
      text("Ground image not loaded!", 10, groundY - 20);
      return;
    }

    textureMode(NORMAL);
    noStroke();

    block1.display();
    block2.display();
  }

  // ===== 内部 GroundBlock 类 =====

  class GroundBlock {
    float x;  // 底边左下角顶点的 x 坐标

    GroundBlock(float startX) {
      x = startX;
    }

    void update(float dt) {
      x -= speed * dt;
    }

    void display() {
      // 只在地面块可能可见时绘制
      if (x + groundWidth > 0 && x < width) {
        float topOffset = groundWidth * slantFactor;

        beginShape();
        texture(groundImg);

        // 顶点顺序：左下 -> 右下 -> 右上 -> 左上
        // 纹理坐标使用 0~1 的 NORMAL 模式

        // 左下
        vertex(x, groundY, 0, 1);
        // 右下
        vertex(x + groundWidth, groundY, 1, 1);
        // 右上（向左倾斜）
        vertex(x + groundWidth - topOffset, groundY - groundHeight, 1, 0);
        // 左上（向左倾斜）
        vertex(x - topOffset, groundY - groundHeight, 0, 0);

        endShape(CLOSE);
      }
    }

    // 判断当前块是否完全离开屏幕左侧（包含顶部倾斜影响）
    boolean isFullyOffScreen() {
      float topOffset = groundWidth * slantFactor;
      return x + groundWidth - topOffset < 0;
    }

    // 把当前块重置到另一块的右侧，保证无缝衔接
    void resetToRightOf(GroundBlock other) {
      float topOffset = groundWidth * slantFactor;
      x = other.x + groundWidth - topOffset;
    }
  }

  // 工具函数：检查并在需要时把 current 移到 other 右侧
  void checkAndSwap(GroundBlock current, GroundBlock other) {
    if (current.isFullyOffScreen()) {
      current.resetToRightOf(other);
    }
  }
}

// ==================== 地面滚动系统 ====================
// 真正的透视地面效果

class GroundManager {
  PImage groundImage;
  float horizonY;      // 地平线高度
  float bottomScale;   // 底部拉伸倍数
  float scrollOffset = 0;  // 纹理滚动偏移量
  int stripCount = 120;    // 越大越平滑，但更耗性能
  float perspectivePower = 2.2;  // 透视压缩强度

  GroundManager() {
    loadGroundImage();

    // 从配置读取参数
    horizonY = GROUND_Y - 120;  // 地面顶部位置
    bottomScale = 1.5;  // 底部比顶部宽1.5倍，制造透视感

    // 开启纹理重复模式
    textureWrap(REPEAT);

    println("Ground initialized: horizonY=" + horizonY + " bottomScale=" + bottomScale);
  }

  void loadGroundImage() {
    groundImage = loadImage(GROUND_PATH);
    if (groundImage == null) {
      println("ERROR: Failed to load ground image from: " + GROUND_PATH);
    } else {
      println("Ground image loaded: " + groundImage.width + "x" + groundImage.height);
    }
  }

  void update(float dt) {
    if (groundImage == null) return;

    // 计算纹理偏移量 (像素速度转为纹理坐标速度)
    float textureSpeed = GROUND_SPEED / float(groundImage.width);
    // 地面从右向左滚动，所以 u 方向取负
    scrollOffset -= textureSpeed * dt;
    // 防止数值无限增长
    if (scrollOffset > 10000) scrollOffset -= 10000;
    if (scrollOffset < -10000) scrollOffset += 10000;
  }

  void display() {
    if (groundImage == null) {
      // 如果图片加载失败，显示调试矩形
      fill(255, 0, 0);
      noStroke();
      rect(0, horizonY, width, height - horizonY);
      fill(255);
      text("Ground image not loaded!", 10, horizonY + 20);
      return;
    }

    noStroke();

    // 使用水平切片模拟透视（Mode 7 风格）
    float topY = horizonY;
    float bottomY = height;

    float topW = width * GROUND_TOP_SCALE;
    float bottomW = width * bottomScale;

    float tilesX = GROUND_TILE_COUNT;  // 横向重复次数
    float tilesY = GROUND_TILE_COUNT;  // 纵向重复次数

    textureMode(NORMAL);
    beginShape(QUAD_STRIP);
    texture(groundImage);

    for (int i = 0; i <= stripCount; i++) {
      float t = i / float(stripCount);
      float tp = pow(t, perspectivePower);

      float y = lerp(topY, bottomY, tp);
      float w = lerp(topW, bottomW, tp);
      float x = (width - w) * 0.5;

      // 纵向不滚动，仅用于透视压缩
      float v = t * tilesY;

      vertex(x, y, scrollOffset, v);
      vertex(x + w, y, scrollOffset + tilesX, v);
    }

    endShape();
  }
}
