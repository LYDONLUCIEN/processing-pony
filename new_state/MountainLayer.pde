// ==================== 山层系统 ====================
// 负责管理中景的山峰和山云，移动速度比云层快

class Mountain {
  PImage img;
  float x, y;
  float scale;
  float speed;

  Mountain(PImage img, float x, float y, float scale, float speed) {
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
    image(img, 0, 0);
    popMatrix();
  }

  boolean isOffScreen() {
    return x < -img.width * scale;
  }
}

class MountainCloud {
  PImage img;
  float x, y;
  float scale;
  float speed;

  MountainCloud(PImage img, float x, float y, float scale, float speed) {
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
    tint(255, 220);
    image(img, 0, 0);
    noTint();
    popMatrix();
  }

  boolean isOffScreen() {
    return x < -img.width * scale;
  }
}

class MountainLayer {
  ArrayList<Mountain> mountains;
  ArrayList<MountainCloud> mountainClouds;
  PImage[] mountainImages;
  PImage[] mountainCloudImages;
  float mtCloudSpawnTimer = 0;

  MountainLayer() {
    mountains = new ArrayList<Mountain>();
    mountainClouds = new ArrayList<MountainCloud>();
    loadMountainImages();
    spawnInitialMountains();
    spawnInitialMountainClouds();
  }

  void loadMountainImages() {
    mountainImages = new PImage[MOUNTAIN_COUNT];
    for (int i = 0; i < MOUNTAIN_COUNT; i++) {
      String path = MOUNTAIN_PATH_PREFIX + (i + 1) + MOUNTAIN_PATH_SUFFIX;
      PImage original = loadImage(path);

      // 预先缩放以提高性能
      int targetWidth = (int)(original.width * 0.5);
      int targetHeight = (int)(original.height * 0.5);
      original.resize(targetWidth, targetHeight);

      mountainImages[i] = original;
    }

    mountainCloudImages = new PImage[MOUNTAIN_CLOUD_COUNT];
    for (int i = 0; i < MOUNTAIN_CLOUD_COUNT; i++) {
      String path = MOUNTAIN_CLOUD_PATH_PREFIX + (i + 1) + MOUNTAIN_CLOUD_PATH_SUFFIX;
      PImage original = loadImage(path);

      int targetWidth = (int)(original.width * 0.5);
      int targetHeight = (int)(original.height * 0.5);
      original.resize(targetWidth, targetHeight);

      mountainCloudImages[i] = original;
    }
  }

  void spawnInitialMountains() {
    // 只生成一个山峰
    int imgIndex = (int)random(mountainImages.length);
    PImage img = mountainImages[imgIndex];
    float scale = random(MOUNTAIN_MIN_SCALE, MOUNTAIN_MAX_SCALE);
    float x = 800 + img.width;  // 从屏幕右侧开始
    float y = MOUNTAIN_BASE_Y;  // 固定高度
    float speed = MOUNTAIN_SPEED;

    mountains.add(new Mountain(img, x, y, scale, speed));
  }

  void spawnInitialMountainClouds() {
    int count = (int)random(MOUNTAIN_MIN_MT_CLOUDS, MOUNTAIN_MAX_MT_CLOUDS + 1);

    for (int i = 0; i < count; i++) {
      spawnMountainCloud(random(800));
    }
  }

  void spawnMountain(float startX) {
    int imgIndex = (int)random(mountainImages.length);
    PImage img = mountainImages[imgIndex];
    float scale = random(MOUNTAIN_MIN_SCALE, MOUNTAIN_MAX_SCALE);
    float y = MOUNTAIN_BASE_Y;  // 固定高度
    float speed = MOUNTAIN_SPEED;

    mountains.add(new Mountain(img, startX, y, scale, speed));
  }

  void spawnMountainCloud(float startX) {
    int imgIndex = (int)random(mountainCloudImages.length);
    PImage img = mountainCloudImages[imgIndex];
    float scale = random(MOUNTAIN_MT_CLOUD_MIN_SCALE, MOUNTAIN_MT_CLOUD_MAX_SCALE);
    float y = random(200, 350);
    float speed = MOUNTAIN_MT_CLOUD_SPEED * random(0.9, 1.1);

    mountainClouds.add(new MountainCloud(img, startX, y, scale, speed));
  }

  void update(float dt) {
    // 更新山峰（只保持一个）
    for (int i = mountains.size() - 1; i >= 0; i--) {
      Mountain m = mountains.get(i);
      m.update(dt);
      if (m.isOffScreen()) {
        mountains.remove(i);
        // 当山峰离开屏幕后，在右侧生成新的
        spawnMountain(800 + random(0, 100));
      }
    }

    mtCloudSpawnTimer += dt;
    if (mtCloudSpawnTimer >= random(3.0, 6.0)) {
      spawnMountainCloud(800 + 50);
      mtCloudSpawnTimer = 0;
    }

    for (int i = mountainClouds.size() - 1; i >= 0; i--) {
      MountainCloud mc = mountainClouds.get(i);
      mc.update(dt);
      if (mc.isOffScreen()) {
        mountainClouds.remove(i);
      }
    }
  }

  void display() {
    for (MountainCloud mc : mountainClouds) {
      mc.display();
    }

    for (Mountain m : mountains) {
      m.display();
    }
  }
}
