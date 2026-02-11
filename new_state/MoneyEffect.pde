// ==================== 金币红包特效系统 ====================
// 点击小马时触发的粒子效果

class MoneyParticle {
  PImage img;
  float x, y;
  float vx, vy;
  float scale;
  float rotation;
  float rotationSpeed;
  float alpha = 255;
  float lifetime = 0;

  MoneyParticle(PImage img, float x, float y, float vx, float vy, float scale) {
    this.img = img;
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    this.scale = scale;
    this.rotation = random(TWO_PI);
    this.rotationSpeed = random(-5, 5);
  }

  void update(float dt) {
    x += vx * dt;
    y += vy * dt;

    vy += MONEY_GRAVITY * dt;

    rotation += rotationSpeed * dt;

    lifetime += dt;
    if (lifetime >= MONEY_FADE_TIME) {
      alpha = 0;
    } else {
      float fadeProgress = lifetime / MONEY_FADE_TIME;
      alpha = 255 * (1 - fadeProgress);
    }
  }

  void display() {
    if (alpha <= 0) return;

    pushMatrix();
    translate(x, y);
    rotate(rotation);
    scale(scale);
    imageMode(CENTER);
    tint(255, alpha);
    image(img, 0, 0);
    noTint();
    popMatrix();
  }

  boolean isDead() {
    return alpha <= 0 || y > 600 + 100;
  }
}

class MoneyEffect {
  ArrayList<MoneyParticle> particles;
  PImage[] moneyImages;

  MoneyEffect() {
    particles = new ArrayList<MoneyParticle>();
    loadMoneyImages();
  }

  void loadMoneyImages() {
    moneyImages = new PImage[MONEY_PATHS.length];
    for (int i = 0; i < MONEY_PATHS.length; i++) {
      PImage original = loadImage(MONEY_PATHS[i]);

      // 预先缩放以提高性能
      int targetWidth = (int)(original.width * 0.3);
      int targetHeight = (int)(original.height * 0.3);
      original.resize(targetWidth, targetHeight);

      moneyImages[i] = original;
    }
  }

  void spawn(float centerX, float centerY) {
    int count = MONEY_PARTICLE_COUNT;

    for (int i = 0; i < count; i++) {
      int imgIndex = (int)random(moneyImages.length);
      PImage img = moneyImages[imgIndex];

      float offsetX = random(-MONEY_SPREAD_X, MONEY_SPREAD_X);
      float offsetY = random(-MONEY_SPREAD_Y / 2, MONEY_SPREAD_Y / 2);
      float x = centerX + offsetX;
      float y = centerY + offsetY;

      float vx = random(-50, 50);
      float vy = random(-MONEY_MAX_SPEED, -MONEY_MIN_SPEED);

      float scale = MONEY_BASE_SCALE * random(0.8, 1.2);

      particles.add(new MoneyParticle(img, x, y, vx, vy, scale));
    }
  }

  void update(float dt) {
    for (int i = particles.size() - 1; i >= 0; i--) {
      MoneyParticle p = particles.get(i);
      p.update(dt);

      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }

  void display() {
    for (MoneyParticle p : particles) {
      p.display();
    }
  }

  int getParticleCount() {
    return particles.size();
  }

  boolean isActive() {
    return particles.size() > 0;
  }
}
