// ==================== 烟花系统（Processing 绘制，山后发射、天空爆炸） ====================
// 从画面下方发射，在 Y 50~200 爆炸；粒子大小/音效在 BlessingConfig 可调

class FireworkParticle {
  float x, y, vx, vy, life, maxLife;
  color c;
  float size;  // 绘制半径（可调）

  FireworkParticle(float x, float y, float vx, float vy, float maxLife, color c, float size) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    this.life = maxLife;
    this.maxLife = maxLife;
    this.c = c;
    this.size = size > 0 ? size : 4;
  }

  void update(float dt) {
    x += vx * dt;
    y += vy * dt;
    life -= dt;
  }

  void draw() {
    if (life <= 0) return;
    float alpha = 255 * (life / maxLife);
    float speed = sqrt(vx * vx + vy * vy);
    if (speed < 1) speed = 1;
    float k = FIREWORK_PARTICLE_TAIL_LEN / speed;
    float tx = x - vx * k;
    float ty = y - vy * k;
    // 长尾：沿速度反方向画线段，再画头部圆点
    stroke(red(c), green(c), blue(c), alpha * 0.5f);
    strokeWeight(max(size * 1.8f, 1.2f));
    line(tx, ty, x, y);
    noStroke();
    fill(red(c), green(c), blue(c), alpha);
    ellipse(x, y, size * 2, size * 2);
  }

  boolean isDead() {
    return life <= 0;
  }
}

class Firework {
  float x, y;
  float vy;
  float explodeAtY;
  boolean exploded;
  boolean justExploded;  // 本帧刚爆炸，用于触发音效
  ArrayList<FireworkParticle> particles;
  boolean done;

  Firework(float startX, float explodeY) {
    x = startX;
    y = height + 30;
    vy = -FIREWORK_RISE_SPEED;
    explodeAtY = explodeY;
    exploded = false;
    justExploded = false;
    particles = new ArrayList<FireworkParticle>();
    done = false;
  }

  void update(float dt) {
    if (!exploded) {
      y += vy * dt;
      if (y <= explodeAtY) {
        explode();
      }
      return;
    }
    for (int i = particles.size() - 1; i >= 0; i--) {
      FireworkParticle p = particles.get(i);
      p.update(dt);
      if (p.isDead()) particles.remove(i);
    }
    if (particles.size() == 0) done = true;
  }

  void explode() {
    exploded = true;
    justExploded = true;
    color c = FIREWORK_COLORS.length > 0 ? FIREWORK_COLORS[(int)random(FIREWORK_COLORS.length)] : color(255, 200, 100);
    for (int i = 0; i < FIREWORK_PARTICLE_COUNT; i++) {
      float angle = random(TWO_PI);
      float speed = FIREWORK_PARTICLE_SPEED * random(0.4, 1.0);
      float vx = cos(angle) * speed;
      float vy = sin(angle) * speed * 0.6;
      float sz = random(FIREWORK_PARTICLE_SIZE_MIN, FIREWORK_PARTICLE_SIZE_MAX);
      particles.add(new FireworkParticle(x, y, vx, vy, FIREWORK_PARTICLE_FADE_TIME, c, sz));
    }
  }

  boolean justExploded() { return justExploded; }
  void clearJustExploded() { justExploded = false; }

  void draw() {
    if (!exploded) {
      noStroke();
      fill(255, 220, 150, 200);
      ellipse(x, y, 3, 8);
      return;
    }
    for (FireworkParticle p : particles) {
      p.draw();
    }
  }

  boolean isDone() {
    return done;
  }
}

class FireworkManager {
  ArrayList<Firework> fireworks;
  SoundFile explosionSound;  // 爆炸音效，可选

  FireworkManager() {
    fireworks = new ArrayList<Firework>();
    explosionSound = null;
  }

  void setExplosionSound(SoundFile s) {
    explosionSound = s;
  }

  void spawnFirework() {
    float x = random(width * 0.15, width * 0.85);
    float explodeY = random(FIREWORK_EXPLODE_Y_MIN, FIREWORK_EXPLODE_Y_MAX);
    fireworks.add(new Firework(x, explodeY));
  }

  void spawnBurst(int count) {
    for (int i = 0; i < count; i++) {
      spawnFirework();
    }
  }

  void update(float dt) {
    for (int i = fireworks.size() - 1; i >= 0; i--) {
      Firework f = fireworks.get(i);
      f.update(dt);
      if (f.justExploded()) {
        if (explosionSound != null) explosionSound.play();
        f.clearJustExploded();
      }
      if (f.isDone()) fireworks.remove(i);
    }
  }

  void display() {
    for (Firework f : fireworks) {
      f.draw();
    }
  }
}
