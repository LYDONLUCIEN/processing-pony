// ==================== 云层系统 ====================
// 负责管理背景中缓慢移动的云朵；按 800×200 区域限制密度，速度很慢

class Cloud {
  PImage img;
  float x, y;
  float scale;
  float speed;

  Cloud(PImage img, float x, float y, float scale, float speed) {
    this.img = img;
    this.x = x;
    this.y = y;
    this.scale = scale;
    this.speed = speed;
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
    return x < -img.width * scale;
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

      // 预先缩放到中等尺寸以提高性能
      int targetWidth = (int)(original.width * 0.5);
      int targetHeight = (int)(original.height * 0.5);
      original.resize(targetWidth, targetHeight);

      cloudImages[i] = original;
    }
  }

  // 云所在区域格子：每 CLOUD_REGION_WIDTH×CLOUD_REGION_HEIGHT 为一格
  int cloudCellX(float x) {
    return (int) floor(x / CLOUD_REGION_WIDTH);
  }
  int cloudCellY(float y) {
    return (int) floor((y - CLOUD_MIN_Y) / CLOUD_REGION_HEIGHT);
  }

  // 指定格子内现有云数量
  int countCloudsInCell(int cx, int cy) {
    int n = 0;
    for (Cloud c : clouds) {
      if (cloudCellX(c.x) == cx && cloudCellY(c.y) == cy) n++;
    }
    return n;
  }

  void spawnInitialClouds() {
    // 在画面内均匀放几朵，且每 800×200 区域不超过 5 朵
    int count = (int)random(CLOUD_MIN_CLOUDS, CLOUD_MAX_CLOUDS + 1);
    for (int i = 0; i < count; i++) {
      trySpawnCloudInRange(0, width);
    }
    scheduleNextSpawn();
  }

  void spawnCloud(float startX) {
    int imgIndex = (int)random(cloudImages.length);
    PImage img = cloudImages[imgIndex];
    float scale = random(CLOUD_MIN_SCALE, CLOUD_MAX_SCALE);
    float y = random(CLOUD_MIN_Y, CLOUD_MAX_Y);
    float speed = CLOUD_SPEED * random(0.95, 1.05);
    clouds.add(new Cloud(img, startX, y, scale, speed));
  }

  // 在 x 范围内尝试生成一朵云，仅当该格未满（每区最多 5 朵）时才生成
  boolean trySpawnCloudInRange(float xMin, float xMax) {
    float x = random(xMin, xMax);
    float y = random(CLOUD_MIN_Y, CLOUD_MAX_Y);
    int cx = cloudCellX(x);
    int cy = cloudCellY(y);
    if (countCloudsInCell(cx, cy) >= CLOUD_MAX_PER_REGION) return false;
    int imgIndex = (int)random(cloudImages.length);
    PImage img = cloudImages[imgIndex];
    float scale = random(CLOUD_MIN_SCALE, CLOUD_MAX_SCALE);
    float speed = CLOUD_SPEED * random(0.95, 1.05);
    clouds.add(new Cloud(img, x, y, scale, speed));
    return true;
  }

  void scheduleNextSpawn() {
    nextSpawnTime = random(CLOUD_SPAWN_INTERVAL_MIN, CLOUD_SPAWN_INTERVAL_MAX);
  }

  void update(float dt) {
    for (int i = clouds.size() - 1; i >= 0; i--) {
      Cloud cloud = clouds.get(i);
      cloud.update(dt);

      if (cloud.isOffScreen()) {
        clouds.remove(i);
      }
    }

    spawnTimer += dt;
    if (spawnTimer >= nextSpawnTime) {
      float spawnX = width + 80;
      float spawnY = random(CLOUD_MIN_Y, CLOUD_MAX_Y);
      int cx = cloudCellX(spawnX);
      int cy = cloudCellY(spawnY);
      if (countCloudsInCell(cx, cy) < CLOUD_MAX_PER_REGION) {
        spawnCloud(spawnX);
      }
      spawnTimer = 0;
      scheduleNextSpawn();
    }
  }

  void display() {
    for (Cloud cloud : clouds) {
      cloud.display();
    }
  }

  int getCloudCount() {
    return clouds.size();
  }
}
