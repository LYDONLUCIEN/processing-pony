// ==================== 地面滚动系统 ====================
// GroundManager.pde
// 
// 功能：
// 1. 加载地面纹理并根据屏幕比例缩放
// 2. 将矩形纹理变形为平行四边形以产生速度感（Slant）
// 3. 使用“双块交替”（Two-Block Check & Swap）算法实现无限无缝滚动
//

class GroundManager {
  PImage groundImg;

  // 几何与滚动参数（从 Config 读取）
  float groundY;          // 地面底边 y 坐标
  float groundHeight;     // 地面高度（像素）
  float groundWidth;      // 地面宽度（像素，纹理缩放后）
  float scaleRatio;       // 纹理缩放系数
  float slantFactor;      // 平行四边形顶部相对底部的水平偏移比例
  float speed;            // 滚动速度（像素/秒，向左）

  // 两个地面块用于循环拼接
  GroundBlock block1;
  GroundBlock block2;

  GroundManager() {
    loadGroundImage();

    // 如果图片加载失败，打印错误防止崩溃
    if (groundImg == null) {
      println("ERROR: Failed to load ground image from: " + GROUND_PATH);
      // 给定默认值防止空指针，虽然显示会出错
      groundImg = new PImage(100, 100); 
    }

    // 1. 初始化基础参数
    groundY = GROUND_Y;
    slantFactor = GROUND_SLANT_FACTOR;
    speed = GROUND_SPEED;

    // 2. 计算缩放比例：根据屏幕高度与配置比例得到目标高度
    // 防止除以0错误
    if (groundImg.height > 0) {
      scaleRatio = (height * GROUND_HEIGHT_RATIO) / groundImg.height;
    } else {
      scaleRatio = 1.0;
    }
    
    groundHeight = groundImg.height * scaleRatio;
    groundWidth = groundImg.width * scaleRatio;

    // 3. 初始化两个地面块
    // 计算顶部倾斜带来的偏移量，用于无缝拼接
    float topOffset = groundWidth * slantFactor;
    
    // block1 从屏幕左侧开始
    block1 = new GroundBlock(0);
    // block2 紧接在 block1 后面（减去偏移量以消除缝隙）
    block2 = new GroundBlock(groundWidth - topOffset);

    println("Ground initialized: w=" + groundWidth + " h=" + groundHeight
      + " slant=" + slantFactor + " speed=" + speed + " y=" + groundY);
  }

  void loadGroundImage() {
    groundImg = loadImage(GROUND_PATH);
    if (groundImg != null) {
      println("Ground image loaded: " + groundImg.width + "x" + groundImg.height);
    }
  }

  void update(float dt) {
    if (groundImg == null) return;

    // 更新位置
    block1.update(dt);
    block2.update(dt);

    // 无缝重置逻辑：任何一块完全离屏后，移动到另一块右侧
    checkAndSwap(block1, block2);
    checkAndSwap(block2, block1);
  }

  void display() {
    if (groundImg == null) {
      // 调试模式：如果图片没加载，画个红框提示
      fill(255, 0, 0);
      noStroke();
      rect(0, groundY - 40, width, 40);
      fill(255);
      text("Ground Img Missing!", 10, groundY - 20);
      return;
    }

    // 设置纹理模式为 NORMAL (0~1 坐标系)
    textureMode(NORMAL);
    noStroke();
    // 使用白色填充以保持纹理原色
    fill(255); 

    block1.display();
    block2.display();
  }

  // 工具函数：检查并在需要时把 current 移到 other 右侧
  void checkAndSwap(GroundBlock current, GroundBlock other) {
    if (current.isFullyOffScreen()) {
      current.resetToRightOf(other);
    }
  }

  // ==========================================
  // 内部类：单独的地面块
  // ==========================================
  class GroundBlock {
    float x;  // 底边左下角顶点的 x 坐标

    GroundBlock(float startX) {
      x = startX;
    }

    void update(float dt) {
      // 向左移动
      x -= speed * dt;
    }

    void display() {
      // 性能优化：只在地面块可能可见时绘制
      // x < width : 块的左边在屏幕右边界左侧
      // x + groundWidth > 0 : 块的右边在屏幕左边界右侧
      if (x + groundWidth > 0 && x < width) {
        float topOffset = groundWidth * slantFactor;

        beginShape();
        texture(groundImg);

        // 顶点顺序：左下 -> 右下 -> 右上 -> 左上
        // 纹理坐标使用 0~1 的 NORMAL 模式

        // 1. 左下角
        vertex(x, groundY, 0, 1);
        
        // 2. 右下角
        vertex(x + groundWidth, groundY, 1, 1);
        
        // 3. 右上角（向左倾斜 - topOffset）
        vertex(x + groundWidth - topOffset, groundY - groundHeight, 1, 0);
        
        // 4. 左上角（向左倾斜 - topOffset）
        vertex(x - topOffset, groundY - groundHeight, 0, 0);

        endShape(CLOSE);
      }
    }

    // 判断当前块是否完全离开屏幕左侧（包含顶部倾斜影响）
    boolean isFullyOffScreen() {
      float topOffset = groundWidth * slantFactor;
      // 当最右侧的顶点（如果是正梯形）都小于0时
      return (x + groundWidth - topOffset) < 0;
    }

    // 把当前块重置到另一块的右侧，保证无缝衔接
    void resetToRightOf(GroundBlock other) {
      float topOffset = groundWidth * slantFactor;
      // 新位置 = 前一块的位置 + 宽度 - 倾斜造成的重叠修正
      x = other.x + groundWidth - topOffset;
    }
  }
}