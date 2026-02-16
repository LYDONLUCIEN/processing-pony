// ==================== 柱子装饰系统（按 beat 间隔生成） ====================

class Pillar {
  PImage img;
  float x, y;
  float scale;
  float speed;
  int typeIndex;

  Pillar(PImage img, float x, float y, float scale, float speed, int typeIndex) {
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
      fill(200, 160, 100);
      rect(0, 0, 30, 80);
      fill(180, 140, 80);
      rect(-2, -42, 34, 12);
    }
    popMatrix();
  }

  boolean isOffScreen() {
    float w = (img != null && img.width > 1) ? img.width * scale : 50;
    return x < -w;
  }
}

class PillarManager {
  ArrayList<Pillar> pillars;
  PImage[] pillarImages;
  int lastSpawnBeat = -9999;

  PillarManager() {
    pillars = new ArrayList<Pillar>();
    loadPillarImages();
  }

  void loadPillarImages() {
    pillarImages = new PImage[PILLAR_COUNT];
    for (int i = 0; i < PILLAR_COUNT; i++) {
      String path = PILLAR_PATH_PREFIX + (i + 1) + PILLAR_PATH_SUFFIX;
      PImage original = loadImage(path);
      if (original != null && original.width > 0) {
        int targetWidth = (int)(original.width * 0.4);
        int targetHeight = (int)(original.height * 0.4);
        original.resize(targetWidth, targetHeight);
        pillarImages[i] = original;
      } else {
        pillarImages[i] = createImage(1, 1, ARGB);
      }
    }
  }

  void spawnPillar() {
    if (pillarImages == null || pillarImages.length == 0) return;
    int imgIndex = (int)random(pillarImages.length);
    PImage img = pillarImages[imgIndex];
    if (img == null || img.width <= 0) return;
    float x = width + 100 + img.width * PILLAR_SCALE / 2;
    float y = PILLAR_BASE_Y + random(-20, 20);
    pillars.add(new Pillar(img, x, y, PILLAR_SCALE, PILLAR_SPEED, imgIndex));
  }

  void update(float dt) {
    if (backgroundFrozen) return;

    if (currentBeatIndex - lastSpawnBeat >= PILLAR_SPAWN_INTERVAL_BEATS) {
      spawnPillar();
      lastSpawnBeat = currentBeatIndex;
    }

    for (int i = pillars.size() - 1; i >= 0; i--) {
      Pillar p = pillars.get(i);
      p.update(dt);
      if (p.isOffScreen()) pillars.remove(i);
    }
  }

  void display() {
    for (Pillar p : pillars) p.display();
  }
}
