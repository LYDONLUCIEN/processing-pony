// ==================== 鞭炮装饰系统（按 beat 间隔生成） ====================

class Firecracker {
  PImage img;
  float x, y;
  float scale;
  float speed;
  int typeIndex;

  Firecracker(PImage img, float x, float y, float scale, float speed, int typeIndex) {
    this.img = img;
    this.x = x;
    this.y = y;
    this.scale = scale;
    this.speed = speed;
    this.typeIndex = typeIndex;
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
      fill(255, 180, 50);
      ellipse(0, 0, 24, 60);
      fill(255, 220, 100);
      ellipse(0, -18, 14, 20);
    }
    popMatrix();
  }

  boolean isOffScreen() {
    float w = (img != null && img.width > 1) ? img.width * scale : 40;
    return x < -w;
  }
}

class FirecrackerManager {
  ArrayList<Firecracker> firecrackers;
  PImage[] firecrackerImages;
  int lastSpawnBeat = -9999;

  FirecrackerManager() {
    firecrackers = new ArrayList<Firecracker>();
    loadFirecrackerImages();
  }

  void clearAll() {
    firecrackers.clear();
    lastSpawnBeat = -9999;
  }

  void loadFirecrackerImages() {
    firecrackerImages = new PImage[FIRECRACKER_COUNT];
    for (int i = 0; i < FIRECRACKER_COUNT; i++) {
      String path = FIRECRACKER_PATH_PREFIX + (i + 1) + FIRECRACKER_PATH_SUFFIX;
      PImage original = loadImage(path);
      if (original != null && original.width > 0) {
        int targetWidth = (int)(original.width * 0.4);
        int targetHeight = (int)(original.height * 0.4);
        original.resize(targetWidth, targetHeight);
        firecrackerImages[i] = original;
      } else {
        firecrackerImages[i] = createImage(1, 1, ARGB);
      }
    }
  }

  void spawnFirecracker() {
    if (firecrackerImages == null || firecrackerImages.length == 0) return;
    int imgIndex = (int)random(firecrackerImages.length);
    PImage img = firecrackerImages[imgIndex];
    if (img == null || img.width <= 0) return;
    float x = width + 100 + img.width * FIRECRACKER_SCALE / 2;
    float y = FIRECRACKER_BASE_Y + random(-20, 20);
    firecrackers.add(new Firecracker(img, x, y, FIRECRACKER_SCALE, FIRECRACKER_SPEED, imgIndex));
  }

  // 马到成功等时机：从右侧爆一簇鞭炮（若干枚同时进场）
  void spawnBurst(int count) {
    if (firecrackerImages == null || firecrackerImages.length == 0) return;
    for (int i = 0; i < count; i++) {
      int imgIndex = (int)random(firecrackerImages.length);
      PImage img = firecrackerImages[imgIndex];
      if (img == null || img.width <= 0) continue;
      float x = width + 100 + i * 50 + random(-20, 20) + img.width * FIRECRACKER_SCALE / 2;
      float y = FIRECRACKER_BASE_Y + random(-30, 30);
      firecrackers.add(new Firecracker(img, x, y, FIRECRACKER_SCALE, FIRECRACKER_SPEED, imgIndex));
    }
  }

  void update(float dt) {
    if (backgroundFrozen) return;

    if (currentBeatIndex - lastSpawnBeat >= FIRECRACKER_SPAWN_INTERVAL_BEATS) {
      spawnFirecracker();
      lastSpawnBeat = currentBeatIndex;
    }

    for (int i = firecrackers.size() - 1; i >= 0; i--) {
      Firecracker f = firecrackers.get(i);
      f.update(dt);
      if (f.isOffScreen()) firecrackers.remove(i);
    }
  }

  void display() {
    for (Firecracker f : firecrackers) f.display();
  }
}
