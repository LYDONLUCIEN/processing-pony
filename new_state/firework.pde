// ==================== 烟花特效 ====================
// 单独实现，后续可用音频节奏触发。接入方式：在 new_state 的 setup 中 new FireworkManager()，
// draw 中 fireworkUpdate(dt) / fireworkDisplay()，节奏或按键时调用 spawnFirework(x, y)。

ArrayList<FireworkBurst> fireworkBursts = new ArrayList<FireworkBurst>();
int FIREWORK_PARTICLE_COUNT = 48;
float FIREWORK_INIT_SPEED = 180;
float FIREWORK_GRAVITY = 120;
float FIREWORK_FADE_TIME = 1.8;
float FIREWORK_PARTICLE_SIZE = 3;

color[] FIREWORK_COLORS = {
  color(255, 100, 100),
  color(255, 200, 100),
  color(100, 200, 255),
  color(255, 100, 255),
  color(100, 255, 150),
  color(255, 255, 100)
};

class FireworkParticle {
  float x, y;
  float vx, vy;
  float life;
  float maxLife;
  color c;
  float size;

  FireworkParticle(float x, float y, float angle, float speed, color c, float size) {
    this.x = x;
    this.y = y;
    this.vx = cos(angle) * speed;
    this.vy = sin(angle) * speed;
    this.maxLife = FIREWORK_FADE_TIME;
    this.life = maxLife;
    this.c = c;
    this.size = size;
  }

  void update(float dt) {
    x += vx * dt;
    y += vy * dt;
    vy += FIREWORK_GRAVITY * dt;
    life -= dt;
  }

  void display() {
    if (life <= 0) return;
    float alpha = 255 * (life / maxLife);
    fill(red(c), green(c), blue(c), alpha);
    noStroke();
    ellipse(x, y, size * 2, size * 2);
  }

  boolean isDead() {
    return life <= 0 || y > height + 50;
  }
}

class FireworkBurst {
  ArrayList<FireworkParticle> particles;
  float x, y;

  FireworkBurst(float x, float y, color baseColor) {
    this.x = x;
    this.y = y;
    particles = new ArrayList<FireworkParticle>();
    for (int i = 0; i < FIREWORK_PARTICLE_COUNT; i++) {
      float angle = TWO_PI * i / FIREWORK_PARTICLE_COUNT + random(0, 0.3);
      float speed = FIREWORK_INIT_SPEED * random(0.7, 1.2);
      color c = lerpColor(baseColor, color(255, 255, 255), random(0, 0.3));
      float sz = FIREWORK_PARTICLE_SIZE * random(0.8, 1.2);
      particles.add(new FireworkParticle(x, y, angle, speed, c, sz));
    }
  }

  void update(float dt) {
    for (FireworkParticle p : particles) p.update(dt);
  }

  void display() {
    for (FireworkParticle p : particles) p.display();
  }

  boolean isDone() {
    for (FireworkParticle p : particles) {
      if (!p.isDead()) return false;
    }
    return true;
  }
}

void fireworkUpdate(float dt) {
  for (int i = fireworkBursts.size() - 1; i >= 0; i--) {
    FireworkBurst b = fireworkBursts.get(i);
    b.update(dt);
    if (b.isDone()) fireworkBursts.remove(i);
  }
}

void fireworkDisplay() {
  for (FireworkBurst b : fireworkBursts) b.display();
}

void spawnFirework(float x, float y) {
  color c = FIREWORK_COLORS[(int)random(FIREWORK_COLORS.length)];
  fireworkBursts.add(new FireworkBurst(x, y, c));
}

void spawnFirework(float x, float y, color c) {
  fireworkBursts.add(new FireworkBurst(x, y, c));
}
