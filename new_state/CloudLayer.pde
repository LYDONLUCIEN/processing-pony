// ==================== 云层系统 ====================
// 负责管理背景中缓慢移动的云朵；按 800×200 区域限制密度，速度很慢

class Cloud {
  PImage img;
  float x, y;
  float scale;
  float speed;
  boolean inFrontOfMountain;  // true = 画在山前，false = 画在山后
  boolean isHighBack;         // true = 固定在山后的高层云，始终在 displayBack 中画

  Cloud(PImage img, float x, float y, float scale, float speed, boolean inFrontOfMountain) {
    this(img, x, y, scale, speed, inFrontOfMountain, false);
  }

  Cloud(PImage img, float x, float y, float scale, float speed, boolean inFrontOfMountain, boolean isHighBack) {
    this.img = img;
    this.x = x;
    this.y = y;
    this.scale = scale;
    this.speed = speed;
    this.inFrontOfMountain = inFrontOfMountain;
    this.isHighBack = isHighBack;
  }

  void update(float dt) {
    x -= speed * dt;
  }

  void display() {
    if (img == null) return;
    pushMatrix();
    translate(x, y);
    scale(scale);
    imageMode(CENTER);
    tint(255, CLOUD_ALPHA);
    image(img, 0, 0);
    noTint();
    popMatrix();
  }

  boolean isOffScreen() {
    if (img == null) return true;
    // 移出左侧 CLOUD_OFFSCREEN_LEFT 才移除，保证运动距离超过约 1300
    return x < -CLOUD_OFFSCREEN_LEFT;
  }
}

class CloudLayer {
  ArrayList<Cloud> clouds;
  PImage[] cloudImages;
  float spawnTimer = 0;
  float nextSpawnTime = 0;

  CloudLayer() {
    clouds = new ArrayList<Cloud>();
    loadCloudImages();
    spawnInitialClouds();
  }

  void loadCloudImages() {
    cloudImages = new PImage[CLOUD_COUNT];
    for (int i = 0; i < CLOUD_COUNT; i++) {
      String path = CLOUD_PATH_PREFIX + (i + 1) + CLOUD_PATH_SUFFIX;
      PImage original = loadImage(path);

      if (original == null) {
        println("ERROR: Failed to load cloud image: " + path + ", using placeholder");
        cloudImages[i] = createImage(10, 10, ARGB);
        continue;
      }

      // 按 CLOUD_LOAD_SCALE 缩放（调大则云图更大、更显眼）
      int targetWidth = (int)(original.width * CLOUD_LOAD_SCALE);
      int targetHeight = (int)(original.height * CLOUD_LOAD_SCALE);
      if (targetWidth > 0 && targetHeight > 0) original.resize(targetWidth, targetHeight);

      cloudImages[i] = original;
    }
  }

  // 与最近云的水平距离是否 >= CLOUD_MIN_GAP
  boolean hasMinGapFromOthers(float newX) {
    for (Cloud c : clouds) {
      if (abs(c.x - newX) < CLOUD_MIN_GAP) return false;
    }
    return true;
  }

  void spawnInitialClouds() {
    // 在 800 宽度内均匀放 3～5 朵，保持 CLOUD_MIN_GAP 间隔
    int count = (int)random(CLOUD_MIN_CLOUDS, CLOUD_MAX_CLOUDS + 1);
    float span = max(CLOUD_MIN_GAP, (width - CLOUD_MIN_GAP) / max(1, count - 1));
    for (int i = 0; i < count; i++) {
      float x = CLOUD_MIN_GAP * 0.5f + i * span + random(-span * 0.2f, span * 0.2f);
      if (x > width - CLOUD_MIN_GAP * 0.5f) x = width - CLOUD_MIN_GAP * 0.5f;
      if (x < CLOUD_MIN_GAP * 0.5f) x = CLOUD_MIN_GAP * 0.5f;
      if (hasMinGapFromOthers(x)) {
        int imgIndex = (int)random(cloudImages.length);
        PImage img = cloudImages[imgIndex];
        float scale = random(CLOUD_MIN_SCALE, CLOUD_MAX_SCALE);
        float y = random(CLOUD_MIN_Y, CLOUD_MAX_Y);
        float speed = CLOUD_SPEED * random(0.95f, 1.05f);
        boolean inFront = random(1) < CLOUD_IN_FRONT_OF_MOUNTAIN_PROB;
        clouds.add(new Cloud(img, x, y, scale, speed, inFront, false));
      }
    }
    // 固定在山后的高层云 1～2 朵，位置更高，从右侧入画
    int highCount = (int)random(CLOUD_HIGH_BACK_COUNT_MIN, CLOUD_HIGH_BACK_COUNT_MAX + 1);
    for (int i = 0; i < highCount; i++) {
      float startX = width + 60 + i * 200 + random(0, 150);
      spawnHighBackCloud(startX);
    }
    scheduleNextSpawn();
  }

  void spawnCloud(float startX) {
    if (!hasMinGapFromOthers(startX)) return;
    int imgIndex = (int)random(cloudImages.length);
    PImage img = cloudImages[imgIndex];
    float scale = random(CLOUD_MIN_SCALE, CLOUD_MAX_SCALE);
    float y = random(CLOUD_MIN_Y, CLOUD_MAX_Y);
    float speed = CLOUD_SPEED * random(0.95f, 1.05f);
    boolean inFront = random(1) < CLOUD_IN_FRONT_OF_MOUNTAIN_PROB;
    clouds.add(new Cloud(img, startX, y, scale, speed, inFront, false));
  }

  /** 固定在山后的高层云（1～2 朵），Y 更高，始终在山后 */
  void spawnHighBackCloud(float startX) {
    int imgIndex = (int)random(cloudImages.length);
    PImage img = cloudImages[imgIndex];
    float scale = random(CLOUD_MIN_SCALE, CLOUD_MAX_SCALE);
    float y = random(CLOUD_HIGH_BACK_Y_MIN, CLOUD_HIGH_BACK_Y_MAX);
    float speed = CLOUD_SPEED * random(0.9f, 1.1f);
    clouds.add(new Cloud(img, startX, y, scale, speed, false, true));
  }

  int getHighBackCloudCount() {
    int n = 0;
    for (Cloud c : clouds) if (c.isHighBack) n++;
    return n;
  }

  void scheduleNextSpawn() {
    nextSpawnTime = random(CLOUD_SPAWN_INTERVAL_MIN, CLOUD_SPAWN_INTERVAL_MAX);
  }

  void update(float dt) {
    if (backgroundFrozen) return;
    for (int i = clouds.size() - 1; i >= 0; i--) {
      Cloud cloud = clouds.get(i);
      cloud.update(dt);

      if (cloud.isOffScreen()) {
        if (cloud.isHighBack) {
          spawnHighBackCloud(width + 80);
        }
        clouds.remove(i);
      }
    }

    spawnTimer += dt;
    if (spawnTimer >= nextSpawnTime) {
      float spawnX = width + 80;
      spawnCloud(spawnX);
      spawnTimer = 0;
      scheduleNextSpawn();
    }
  }

  void display() {
    for (Cloud cloud : clouds) cloud.display();
  }

  /** 山后的云（先画） */
  void displayBack() {
    for (Cloud cloud : clouds) {
      if (!cloud.inFrontOfMountain) cloud.display();
    }
  }

  /** 山前的云（后画，在山层之后） */
  void displayFront() {
    for (Cloud cloud : clouds) {
      if (cloud.inFrontOfMountain) cloud.display();
    }
  }

  int getCloudCount() {
    return clouds.size();
  }
}
