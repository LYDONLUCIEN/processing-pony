// ==================== test_zhuzi：柱子与栏杆对齐调试 ====================
// 在 new_state.pde 中设 TEST_ZHUZI = true 后运行，单独调试 zhuzi 与 ROADSIDE_RAILING 的「对齐点 + 就近匹配」。
//
// 用法：
//   1. 栏杆对齐点 railingAnchorNorm：在「一个栏杆纹理周期」内的归一化位置 0..1，可多个。
//      例如 [0.2, 0.5, 0.8] 表示在栏杆宽度的 20%、50%、80% 处各有一个可对齐点（红点）。
//   2. 柱子对齐点 zhuziAnchorNormX/Y：柱子图内的归一化 (0..1)，(0.5, 1.0)=底边中点。
//   3. 柱子入场时，在「入场线」width+80 处找当前所有栏杆对齐点中最近的一个，让柱子对齐点与之重合（绿点）。
//   4. 空格 = 手动放一根柱子（就近匹配）；每 zhuziSpawnInterval 秒自动放一根。
//
// 柱子：一张图 ZHUZI_IMAGE_PATH，6 个对齐点 = 图内「长度」方向的六等分点 (1/6, 2/6, ..., 6/6)。
// TEST_ZHUZI 在 new_state.pde 中定义，此处不再重复。

// 栏杆：两个块无缝滚动
float railingBlock1X, railingBlock2X;
float railingWidthPx;
float railingScrollSpeed = 190;
PImage railingImg;

// 栏杆对齐点：在「一个栏杆周期」内的归一化位置 (0..1)，按你栏杆图上的立柱位置改
float[] railingAnchorNorm = { 0.2f, 0.5f, 0.8f };

// 柱子：一张图；6 个对齐点 = 长度（高度）方向的六等分，归一化 Y = 1/6, 2/6, ..., 6/6，X 均为 0.5（中心）
float[] zhuziAnchorNormY;  // 在 setup 里填 1/6, 2/6, ..., 6/6，个数见 ZHUZI_ANCHOR_COUNT
float zhuziAnchorNormX = 0.5f;
PImage zhuziImg;   // 单张柱子图
ArrayList<ZhuziInstance> zhuziList = new ArrayList<ZhuziInstance>();
float zhuziSpawnTimer = 0;
float zhuziSpawnInterval = 2.0f;
float zhuziScrollSpeed = 190;
float testZhuziDisplayScale = 0.5f;
// 与栏杆对齐时使用第几个点（0=顶部 1/6，5=底部 6/6），一般用 5 让柱子底与栏杆重合
int zhuziAnchorIndexForRailing = 5;

class ZhuziInstance {
  float x, y;   // 世界坐标：当前用于对齐的那个点（如底边中点）的位置
  ZhuziInstance(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

void testZhuziSetup() {
  railingImg = loadImage(ROADSIDE_RAILING_PATH);
  if (railingImg != null && railingImg.width > 0) {
    if (railingImg.width > ROADSIDE_MAX_TEXTURE_WIDTH) {
      int newH = (int)((float)railingImg.height * ROADSIDE_MAX_TEXTURE_WIDTH / railingImg.width);
      railingImg.resize(ROADSIDE_MAX_TEXTURE_WIDTH, newH);
    }
    railingWidthPx = railingImg.width * ROADSIDE_RAILING_SCALE;
    railingBlock1X = 0;
    railingBlock2X = railingWidthPx;
  } else {
    railingWidthPx = 800;
    railingBlock1X = 0;
    railingBlock2X = 800;
  }

  zhuziAnchorNormY = new float[ZHUZI_ANCHOR_COUNT];
  for (int i = 0; i < ZHUZI_ANCHOR_COUNT; i++)
    zhuziAnchorNormY[i] = (i + 1) / (float) ZHUZI_ANCHOR_COUNT;  // 1/6, 2/6, ..., 6/6

  PImage img = loadImage(ZHUZI_IMAGE_PATH);
  if (img == null || img.width <= 0)
    img = loadImage(PILLAR_PATH_PREFIX + "1" + PILLAR_PATH_SUFFIX);
  if (img != null && img.width > 0) {
    int origW = img.width;
    int origH = img.height;
    if (ZHUZI_MAX_TEXTURE_WIDTH > 0 && origW > ZHUZI_MAX_TEXTURE_WIDTH) {
      int newH = (int)((float)origH * ZHUZI_MAX_TEXTURE_WIDTH / origW);
      img.resize(ZHUZI_MAX_TEXTURE_WIDTH, newH);
      println("[zhuzi] " + ZHUZI_IMAGE_PATH + " 原图 " + origW + "×" + origH + " -> 缩放到 " + img.width + "×" + img.height + " (maxWidth " + ZHUZI_MAX_TEXTURE_WIDTH + ")");
    } else {
      println("[zhuzi] " + ZHUZI_IMAGE_PATH + " 原图 " + origW + "×" + origH);
    }
    zhuziImg = img;
  } else {
    zhuziImg = createImage(1, 1, ARGB);
    println("[zhuzi] " + ZHUZI_IMAGE_PATH + " 未加载，使用占位");
  }
  zhuziList.clear();
  zhuziSpawnTimer = 0;
  float centerX = width * 0.5f;
  zhuziList.add(new ZhuziInstance(centerX, ZHUZI_BASE_Y));
  spawnZhuziAtNearestRailing();
  spawnZhuziAtNearestRailing();
  boolean ok = (zhuziImg != null && zhuziImg.width > 1);
  println("test_zhuzi: 柱子 1 张图，" + ZHUZI_ANCHOR_COUNT + " 个对齐点 | 已加载=" + ok + " | scale=" + ZHUZI_SCALE + " | 空格=放一根");
}

// 收集当前所有「栏杆对齐点」的世界 X（两个块各自的对齐点）
ArrayList<Float> getRailingAnchorWorldX() {
  ArrayList<Float> list = new ArrayList<Float>();
  float w = railingWidthPx;
  for (float n : railingAnchorNorm) {
    float x1 = railingBlock1X + n * w;
    float x2 = railingBlock2X + n * w;
    list.add(x1);
    list.add(x2);
  }
  return list;
}

// 在「入场线」spawnX 处，找离 spawnX 最近的栏杆对齐点，返回其世界 X；若无则返回 spawnX
float findNearestRailingAnchorX(float spawnX) {
  ArrayList<Float> anchors = getRailingAnchorWorldX();
  if (anchors.size() == 0) return spawnX;
  float best = anchors.get(0);
  float bestDist = abs(anchors.get(0) - spawnX);
  for (int i = 1; i < anchors.size(); i++) {
    float d = abs(anchors.get(i) - spawnX);
    if (d < bestDist) {
      bestDist = d;
      best = anchors.get(i);
    }
  }
  return best;
}

void spawnZhuziAtNearestRailing() {
  float spawnX = width + 80;
  float anchorWorldX = findNearestRailingAnchorX(spawnX);
  zhuziList.add(new ZhuziInstance(anchorWorldX, ZHUZI_BASE_Y));
}

void testZhuziUpdate(float dt) {
  railingBlock1X -= railingScrollSpeed * dt;
  railingBlock2X -= railingScrollSpeed * dt;
  if (railingBlock1X + railingWidthPx < 0) railingBlock1X = railingBlock2X + railingWidthPx;
  if (railingBlock2X + railingWidthPx < 0) railingBlock2X = railingBlock1X + railingWidthPx;

  for (int i = zhuziList.size() - 1; i >= 0; i--) {
    ZhuziInstance z = zhuziList.get(i);
    z.x -= zhuziScrollSpeed * dt;
    if (z.x < -100) zhuziList.remove(i);
  }

  zhuziSpawnTimer += dt;
  if (zhuziSpawnTimer >= zhuziSpawnInterval) {
    zhuziSpawnTimer = 0;
    spawnZhuziAtNearestRailing();
  }
}

void testZhuziDraw() {
  background(240);

  fill(255, 0, 0);
  textSize(18);
  textAlign(CENTER, TOP);
  text("TEST ZHUZI — 柱子调试（中央应有一根柱子）", width/2, 8);
  textAlign(LEFT, TOP);

  float halfW = railingWidthPx * 0.5f;
  float baseY = ROADSIDE_RAILING_BASE_Y;

  if (railingImg != null && railingImg.width > 0) {
    for (float blockX : new float[] { railingBlock1X, railingBlock2X }) {
      float cx = blockX + halfW;
      if (cx + halfW >= 0 && cx - halfW <= width) {
        pushMatrix();
        translate(cx, baseY);
        scale(ROADSIDE_RAILING_SCALE);
        imageMode(CENTER);
        image(railingImg, 0, 0);
        popMatrix();
      }
      for (float n : railingAnchorNorm) {
        float ax = blockX + n * railingWidthPx;
        if (ax >= -20 && ax <= width + 20) {
          noStroke();
          fill(255, 0, 0);
          ellipse(ax, baseY, 10, 10);
        }
      }
    }
  } else {
    fill(180);
    textAlign(CENTER);
    text("栏杆图未加载: " + ROADSIDE_RAILING_PATH, width/2, 80);
    textAlign(LEFT);
  }

  float displayScale = testZhuziDisplayScale;
  int anchorIdx = zhuziAnchorIndexForRailing;
  if (anchorIdx >= ZHUZI_ANCHOR_COUNT) anchorIdx = ZHUZI_ANCHOR_COUNT - 1;
  float anchorY = zhuziAnchorNormY != null && anchorIdx < zhuziAnchorNormY.length ? zhuziAnchorNormY[anchorIdx] : 1f;
  for (ZhuziInstance z : zhuziList) {
    PImage img = zhuziImg;
    float anchorPxX = 20;
    float anchorPxY = 40;
    if (img != null && img.width > 1) {
      anchorPxX = img.width * zhuziAnchorNormX;
      anchorPxY = img.height * anchorY;
      float drawX = z.x - anchorPxX * displayScale;
      float drawY = z.y - anchorPxY * displayScale;
      pushMatrix();
      translate(drawX, drawY);
      scale(displayScale);
      imageMode(CORNER);
      image(img, 0, 0);
      popMatrix();
      if (z.x >= -20 && z.x <= width + 20 && zhuziAnchorNormY != null) {
        for (int k = 0; k < zhuziAnchorNormY.length; k++) {
          float ay = z.y - anchorPxY * displayScale + img.height * displayScale * zhuziAnchorNormY[k];
          float ax = z.x;
          noStroke();
          fill(k == anchorIdx ? color(0, 255, 0) : color(100, 200, 255));
          ellipse(ax, ay, k == anchorIdx ? 10 : 6, k == anchorIdx ? 10 : 6);
        }
      }
    } else {
      noStroke();
      fill(220, 80, 60);
      float w = 80 * displayScale;
      float h = 160 * displayScale;
      float drawX = z.x - 40 * displayScale;
      float drawY = z.y - 160 * displayScale;
      rect(drawX, drawY, w, h);
      stroke(255, 0, 0);
      noFill();
      rect(drawX, drawY, w, h);
      noStroke();
    }
    if (z.x >= -10 && z.x <= width + 10) {
      noStroke();
      fill(0, 255, 0);
      ellipse(z.x, z.y, 10, 10);
    }
  }

  boolean zhuziLoaded = (zhuziImg != null && zhuziImg.width > 1);
  fill(0);
  textSize(14);
  textAlign(LEFT, TOP);
  text("栏杆对齐点(红) / 柱子 6 等分点(绿=与栏杆对齐点) | 空格=放一根 | 每 " + zhuziSpawnInterval + "s 自动放一根", 10, 10);
  text("柱子: " + zhuziList.size() + " 根 | 1 张图 6 等分点 | 图: " + (zhuziLoaded ? "已加载" : "占位") + " | 比例 " + nf(displayScale, 0, 2), 10, 26);
}
