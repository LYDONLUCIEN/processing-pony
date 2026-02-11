// ==================== 云层系统 ====================
// 负责管理背景中缓慢移动的云朵

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

      // 预先缩放到中等尺寸以提高性能
      int targetWidth = (int)(original.width * 0.5);
      int targetHeight = (int)(original.height * 0.5);
      original.resize(targetWidth, targetHeight);

      cloudImages[i] = original;
    }
  }

  void spawnInitialClouds() {
    int count = (int)random(CLOUD_MIN_CLOUDS, CLOUD_MAX_CLOUDS + 1);
    for (int i = 0; i < count; i++) {
      spawnCloud(random(800));
    }
    scheduleNextSpawn();
  }

  void spawnCloud(float startX) {
    int imgIndex = (int)random(cloudImages.length);
    PImage img = cloudImages[imgIndex];
    float scale = random(CLOUD_MIN_SCALE, CLOUD_MAX_SCALE);
    float y = random(CLOUD_MIN_Y, CLOUD_MAX_Y);
    float speed = CLOUD_SPEED * random(0.8, 1.2);

    clouds.add(new Cloud(img, startX, y, scale, speed));
  }

  void scheduleNextSpawn() {
    nextSpawnTime = random(2.0, 5.0);
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
      spawnCloud(800 + 100);
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
