// ==================== 石头障碍物系统 ====================
// 管理石头障碍物，需要小马跳跃

class Stone {
  PImage img;
  float x, y;
  float scale;
  float speed;
  int typeIndex;
  int textIndex;
  boolean triggeredJump = false;
  boolean cleared = false;

  Stone(PImage img, float x, float y, float scale, float speed, int typeIndex, int textIndex) {
    this.img = img;
    this.x = x;
    this.y = y;
    this.scale = scale;
    this.speed = speed;
    this.typeIndex = typeIndex;
    this.textIndex = textIndex;
    this.triggeredJump = false;
    this.cleared = false;
  }

  void update(float dt) {
    x -= speed * dt;
  }

  void display() {
    pushMatrix();
    translate(x, y);
    scale(scale);
    imageMode(CENTER);
    if (img != null && img.width > 1) {
      image(img, 0, 0);
    } else {
      noStroke();
      fill(120, 100, 80);
      ellipse(0, 0, 40, 25);
    }
    popMatrix();
  }

  boolean isOffScreen() {
    float w = (img != null && img.width > 1) ? img.width * scale : 50;
    return x < -w;
  }

  float getLeftEdge() {
    float w = (img != null && img.width > 1) ? img.width * scale : 50;
    return x - w / 2;
  }

  float getRightEdge() {
    float w = (img != null && img.width > 1) ? img.width * scale : 50;
    return x + w / 2;
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

  boolean isCleared() { return cleared; }
  void setCleared() { cleared = true; }
  int getTextIndex() { return textIndex; }
}

class StoneManager {
  ArrayList<Stone> stones;
  PImage[] stoneImages;
  float spawnTimer = 0;
  float nextSpawnInterval = STONE_SPAWN_INTERVAL;
  boolean autoJumpEnabled = true;
  int nextStoneTextIndex = 0;
  int nextStoneTimelineIndex = 0;

  StoneManager() {
    stones = new ArrayList<Stone>();
    loadStoneImages();
  }

  void resetForRestart() {
    stones.clear();
    nextStoneTimelineIndex = 0;
    spawnTimer = 0;
  }

  void spawnFromTimeline(float musicTime) {
    JSONArray arr = getTimelineStones();
    if (arr.size() == 0) return;
    float leadTime = getBlessingSpawnLeadTime();
    while (nextStoneTimelineIndex < arr.size()) {
      JSONObject ev = arr.getJSONObject(nextStoneTimelineIndex);
      float t = ev.getFloat("time");
      if (musicTime < t - leadTime) break;
      if (t - musicTime < 0) {
        nextStoneTimelineIndex++;
        continue;
      }
      int textIdx = ev.hasKey("textIndex") ? ev.getInt("textIndex") : (nextStoneTextIndex++ % max(1, stoneTexts.length));
      float startX = PONY_X + FORGE_SPEED * (t - musicTime);
      spawnOneStone(startX, textIdx, FORGE_SPEED);
      nextStoneTimelineIndex++;
    }
  }

  void spawnOneStone(float startX, int textIdx, float speed) {
    if (stoneImages == null || stoneImages.length == 0) return;
    int imgIndex = (int)random(stoneImages.length);
    PImage img = stoneImages[imgIndex];
    float y = STONE_BASE_Y;
    float scale = STONE_SCALE;
    int textIndex = textIdx % max(1, stoneTexts.length);
    stones.add(new Stone(img, startX, y, scale, speed, imgIndex, textIndex));
  }

  void loadStoneImages() {
    stoneImages = new PImage[STONE_COUNT];
    for (int i = 0; i < STONE_COUNT; i++) {
      String path = STONE_PATH_PREFIX + (i + 1) + STONE_PATH_SUFFIX;
      PImage original = loadImage(path);
      if (original != null && original.width > 0) {
        int targetWidth = (int)(original.width * 0.4);
        int targetHeight = (int)(original.height * 0.4);
        if (targetWidth > 0 && targetHeight > 0) original.resize(targetWidth, targetHeight);
        stoneImages[i] = original;
      } else {
        stoneImages[i] = createImage(1, 1, ARGB);
      }
    }
  }

  void spawnStone() {
    float x = width + 80;
    int textIdx = nextStoneTextIndex % max(1, stoneTexts.length);
    nextStoneTextIndex++;
    spawnOneStone(x, textIdx, STONE_SPEED);
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
    update(dt, -1);
  }

  void update(float dt, float musicTime) {
    if (backgroundFrozen) return;
    if (musicTime >= 0) spawnFromTimeline(musicTime);
    if (getTimelineStones().size() == 0) {
      spawnTimer += dt;
      if (spawnTimer >= nextSpawnInterval) {
        spawnStone();
        spawnTimer = 0;
        nextSpawnInterval = STONE_SPAWN_INTERVAL * random(0.9, 1.3);
      }
    }
    for (int i = stones.size() - 1; i >= 0; i--) {
      Stone s = stones.get(i);
      s.update(dt);
      if (s.isOffScreen()) stones.remove(i);
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
