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
