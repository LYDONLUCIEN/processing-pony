// ==================== 福袋顶出后的精灵动画管理器 ====================
// 顶到福袋时：弹飞 + 四字 + 同时播放对应精灵（小象/金钱/福等），几秒后消失
// 精灵带颠簸：上下起伏（速度、幅度、随机性可配）

// 通用颠簸偏移：一条函数，不同变量配置。返回当前时刻的 Y 偏移（像素）
// t: 已过时间(秒), speed: 颠簸频率(次/秒), amplitude: 上下幅度(像素), phase: 相位(每实例随机), randomness: 随机抖动幅度(像素)
float getBobOffsetY(float t, float speed, float amplitude, float phase, float randomness) {
  float main = amplitude * sin(TWO_PI * speed * t + phase);
  float jitter = (randomness > 0) ? randomness * (2 * noise(phase * 10 + t * 4) - 1) : 0;
  return main + jitter;
}

class BlessingSpriteInstance {
  PImage[] frames;
  float x, y;           // 当前显示位置（无 pop-out 时即目标位置）
  float targetX, targetY;
  float elapsed;
  float duration;
  float fps;
  float scale;
  float bobSpeed;
  float bobAmplitude;
  float bobRandomness;
  float bobPhase;
  float popOutStartX, popOutStartY;
  float popOutDuration;
  float popOutStartScale;

  BlessingSpriteInstance(PImage[] frames, float x, float y, float duration, float fps, float scale,
      float bobSpeed, float bobAmplitude, float bobRandomness, float bobPhase) {
    this.frames = frames;
    this.x = x;
    this.y = y;
    this.targetX = x;
    this.targetY = y;
    this.elapsed = 0;
    this.duration = duration;
    this.fps = fps;
    this.scale = scale;
    this.bobSpeed = bobSpeed;
    this.bobAmplitude = bobAmplitude;
    this.bobRandomness = bobRandomness;
    this.bobPhase = bobPhase;
    this.popOutDuration = 0;
  }

  BlessingSpriteInstance(PImage[] frames, float startX, float startY, float targetX, float targetY,
      float duration, float fps, float scale, float bobSpeed, float bobAmplitude, float bobRandomness, float bobPhase,
      float popOutDuration, float popOutStartScale) {
    this.frames = frames;
    this.popOutStartX = startX;
    this.popOutStartY = startY;
    this.targetX = targetX;
    this.targetY = targetY;
    this.x = targetX;
    this.y = targetY;
    this.elapsed = 0;
    this.duration = duration;
    this.fps = fps;
    this.scale = scale;
    this.bobSpeed = bobSpeed;
    this.bobAmplitude = bobAmplitude;
    this.bobRandomness = bobRandomness;
    this.bobPhase = bobPhase;
    this.popOutDuration = popOutDuration;
    this.popOutStartScale = popOutStartScale;
  }

  void update(float dt) {
    elapsed += dt;
  }

  boolean isDone() {
    return elapsed >= duration;
  }

  void display() {
    if (frames == null || frames.length == 0) return;
    int idx = (int)(elapsed * fps) % frames.length;
    if (idx < 0) idx = 0;
    PImage img = frames[idx];
    if (img == null || img.width <= 0) return;

    float drawX, drawY, drawScale;
    if (popOutDuration > 0 && elapsed < popOutDuration) {
      float t = elapsed / popOutDuration;
      t = t * t * (3 - 2 * t);
      drawX = lerp(popOutStartX, targetX, t);
      drawY = lerp(popOutStartY, targetY, t);
      drawScale = lerp(popOutStartScale, scale, t);
    } else {
      drawX = targetX;
      drawY = targetY;
      drawScale = scale;
    }
    float offsetY = (elapsed >= popOutDuration) ? getBobOffsetY(elapsed - popOutDuration, bobSpeed, bobAmplitude, bobPhase, bobRandomness) : 0;
    pushMatrix();
    translate(drawX, drawY + offsetY);
    scale(drawScale);
    imageMode(CENTER);
    image(img, 0, 0);
    popMatrix();
  }
}

class BlessingSpriteManager {
  HashMap<String, PImage[]> spriteSets;
  ArrayList<BlessingSpriteInstance> instances;

  BlessingSpriteManager() {
    spriteSets = new HashMap<String, PImage[]>();
    instances = new ArrayList<BlessingSpriteInstance>();
    loadSprites();
  }

  void loadSprites() {
    loadOne("elephant", OUTPUT_BASE + "/" + OUTPUT_ELEPHANT_PREFIX, OUTPUT_ELEPHANT_COUNT);
    loadOne("money",   OUTPUT_BASE + "/" + OUTPUT_QIANDAI_PREFIX, OUTPUT_QIANDAI_COUNT);
    loadOne("fu",      OUTPUT_BASE + "/" + OUTPUT_FUDAI_PREFIX, OUTPUT_FUDAI_COUNT);
    loadOne("shoudai", OUTPUT_BASE + "/" + OUTPUT_SHOUDAI_PREFIX, OUTPUT_SHOUDAI_COUNT);
  }

  void loadOne(String type, String pathPrefix, int count) {
    if (count <= 0) return;
    PImage[] arr = new PImage[count];
    for (int i = 0; i < count; i++) {
      String path = pathPrefix + nf(i, 2) + OUTPUT_FRAME_SUFFIX;
      PImage img = loadImage(path);
      if (img != null && img.width > 0) {
        int w = (int)(img.width * 0.5);
        int h = (int)(img.height * 0.5);
        if (w > 0 && h > 0) img.resize(w, h);
      }
      arr[i] = img;
    }
    spriteSets.put(type, arr);
  }

  void spawn(String type, float x, float y) {
    PImage[] frames = spriteSets.get(spriteKey(type));
    if (frames == null || frames.length == 0) return;
    float duration = getBlessingSpriteDuration(type);
    float fps = getBlessingSpriteFPS(type);
    float bobSpeed = getBlessingBobSpeed(type);
    float bobAmp = getBlessingBobAmplitude(type);
    float bobRand = getBlessingBobRandomness(type);
    float bobPhase = random(TWO_PI);
    float scale = getBlessingSpriteScale(type);
    BlessingSpriteInstance inst = new BlessingSpriteInstance(
      frames, x, y, duration, fps, scale,
      bobSpeed, bobAmp, bobRand, bobPhase);
    instances.add(inst);
  }

  String spriteKey(String type) {
    if (type.equals("qiandai")) return "money";
    if (type.equals("fudai")) return "fu";
    if (type.equals("success")) return "shoudai";
    return type;
  }

  void spawnFromBox(String type, float boxX, float boxY, float ponyX, float ponyY) {
    PImage[] frames = spriteSets.get(spriteKey(type));
    if (frames == null || frames.length == 0) return;
    float targetX = ponyX + getBlessingPonyOffsetX(type);
    float targetY = ponyY + getBlessingPonyOffsetY(type);
    float duration = getBlessingSpriteDuration(type);
    float fps = getBlessingSpriteFPS(type);
    float bobSpeed = getBlessingBobSpeed(type);
    float bobAmp = getBlessingBobAmplitude(type);
    float bobRand = getBlessingBobRandomness(type);
    float bobPhase = random(TWO_PI);
    float scale = getBlessingSpriteScale(type);
    BlessingSpriteInstance inst = new BlessingSpriteInstance(
      frames, boxX, boxY, targetX, targetY,
      duration, fps, scale,
      bobSpeed, bobAmp, bobRand, bobPhase,
      BLESSING_POP_OUT_DURATION, BLESSING_POP_OUT_START_SCALE);
    instances.add(inst);
  }

  void update(float dt) {
    if (backgroundFrozen) return;
    for (int i = instances.size() - 1; i >= 0; i--) {
      BlessingSpriteInstance inst = instances.get(i);
      inst.update(dt);
      if (inst.isDone()) instances.remove(i);
    }
  }

  void display() {
    for (BlessingSpriteInstance inst : instances) {
      inst.display();
    }
  }
}
