// ==================== 灯笼障碍物系统 ====================
// 管理定期出现的灯笼装饰

class Denglong {
  PImage img;
  float x, y;
  float scale;
  float speed;
  int typeIndex;

  Denglong(PImage img, float x, float y, float scale, float speed, int typeIndex) {
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
    image(img, 0, 0);
    popMatrix();
  }

  boolean isOffScreen() {
    return x < -img.width * scale;
  }

  float getRightEdge() {
    return x + (img.width * scale) / 2;
  }

  float getLeftEdge() {
    return x - (img.width * scale) / 2;
  }
}

class DenglongManager {
  ArrayList<Denglong> denglongs;
  PImage[] denglongImages;
  int lastSpawnBeat = -9999;  // 上次生成时的 beat，按 beat 间隔生成

  DenglongManager() {
    denglongs = new ArrayList<Denglong>();
    loadDenglongImages();
  }

  void loadDenglongImages() {
    denglongImages = new PImage[DENGLONG_COUNT];
    for (int i = 0; i < DENGLONG_COUNT; i++) {
      String path = DENGLONG_PATH_PREFIX + (i + 1) + DENGLONG_PATH_SUFFIX;
      PImage original = loadImage(path);

      // 预先缩放以提高性能
      int targetWidth = (int)(original.width * 0.4);
      int targetHeight = (int)(original.height * 0.4);
      original.resize(targetWidth, targetHeight);

      denglongImages[i] = original;
    }
  }

  void spawnDenglong() {
    int imgIndex = (int)random(denglongImages.length);
    PImage img = denglongImages[imgIndex];
    float x = 800 + img.width * DENGLONG_SCALE / 2;
    float y = DENGLONG_BASE_Y + random(-20, 20);
    float scale = DENGLONG_SCALE;
    float speed = DENGLONG_SPEED;

    denglongs.add(new Denglong(img, x, y, scale, speed, imgIndex));
  }

  void update(float dt) {
    if (backgroundFrozen) return;

    if (currentBeatIndex - lastSpawnBeat >= DENGLONG_SPAWN_INTERVAL_BEATS) {
      spawnDenglong();
      lastSpawnBeat = currentBeatIndex;
    }

    for (int i = denglongs.size() - 1; i >= 0; i--) {
      Denglong d = denglongs.get(i);
      d.update(dt);

      if (d.isOffScreen()) {
        denglongs.remove(i);
      }
    }
  }

  void display() {
    for (Denglong d : denglongs) {
      d.display();
    }
  }

  ArrayList<Denglong> getDenglongs() {
    return denglongs;
  }

  int getCount() {
    return denglongs.size();
  }
}
