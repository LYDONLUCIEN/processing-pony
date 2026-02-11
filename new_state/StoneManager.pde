// ==================== 石头障碍物系统 ====================
// 管理石头障碍物，需要小马跳跃

class Stone {
  PImage img;
  float x, y;
  float scale;
  float speed;
  int typeIndex;
  boolean triggeredJump = false;

  Stone(PImage img, float x, float y, float scale, float speed, int typeIndex) {
    this.img = img;
    this.x = x;
    this.y = y;
    this.scale = scale;
    this.speed = speed;
    this.typeIndex = typeIndex;
    this.triggeredJump = false;
  }

  void update(float dt) {
    x -= speed * dt;
  }

  void display() {
    pushMatrix();
    translate(x, y);
    scale(scale);
    imageMode(CENTER);
    image(img, 0, 0);
    popMatrix();
  }

  boolean isOffScreen() {
    return x < -img.width * scale;
  }

  float getLeftEdge() {
    return x - (img.width * scale) / 2;
  }

  float getRightEdge() {
    return x + (img.width * scale) / 2;
  }

  boolean shouldTriggerJump(float ponyX) {
    if (triggeredJump) return false;

    float dist = this.getLeftEdge() - ponyX;
    if (dist <= STONE_JUMP_TRIGGER_X && dist > 0) {
      triggeredJump = true;
      return true;
    }
    return false;
  }
}

class StoneManager {
  ArrayList<Stone> stones;
  PImage[] stoneImages;
  float spawnTimer = 0;
  float nextSpawnInterval = STONE_SPAWN_INTERVAL;
  boolean autoJumpEnabled = true;

  StoneManager() {
    stones = new ArrayList<Stone>();
    loadStoneImages();
  }

  void loadStoneImages() {
    stoneImages = new PImage[STONE_COUNT];
    for (int i = 0; i < STONE_COUNT; i++) {
      String path = STONE_PATH_PREFIX + (i + 1) + STONE_PATH_SUFFIX;
      PImage original = loadImage(path);

      // 预先缩放以提高性能
      int targetWidth = (int)(original.width * 0.4);
      int targetHeight = (int)(original.height * 0.4);
      original.resize(targetWidth, targetHeight);

      stoneImages[i] = original;
    }
  }

  void spawnStone() {
    int imgIndex = (int)random(stoneImages.length);
    PImage img = stoneImages[imgIndex];
    float x = 800 + img.width * STONE_SCALE / 2;
    float y = STONE_BASE_Y;
    float scale = STONE_SCALE;
    float speed = STONE_SPEED;

    stones.add(new Stone(img, x, y, scale, speed, imgIndex));
  }

  boolean checkAutoJump(float ponyX) {
    if (!autoJumpEnabled) return false;

    for (Stone s : stones) {
      if (s.shouldTriggerJump(ponyX)) {
        return true;
      }
    }
    return false;
  }

  void update(float dt) {
    spawnTimer += dt;

    if (spawnTimer >= nextSpawnInterval) {
      spawnStone();
      spawnTimer = 0;
      nextSpawnInterval = STONE_SPAWN_INTERVAL * random(0.9, 1.3);
    }

    for (int i = stones.size() - 1; i >= 0; i--) {
      Stone s = stones.get(i);
      s.update(dt);

      if (s.isOffScreen()) {
        stones.remove(i);
      }
    }
  }

  void display() {
    for (Stone s : stones) {
      s.display();
    }
  }

  void setAutoJumpEnabled(boolean enabled) {
    this.autoJumpEnabled = enabled;
  }

  boolean isAutoJumpEnabled() {
    return autoJumpEnabled;
  }

  int getCount() {
    return stones.size();
  }

  ArrayList<Stone> getStones() {
    return stones;
  }
}
