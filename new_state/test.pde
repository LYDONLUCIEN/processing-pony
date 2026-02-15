// ==================== 测试草图：按键 1–0 触发效果，仅读正式配置 ====================
// 无背景、无音乐。在 new_state.pde 中将 TEST_MODE 设为 true 后运行本 sketch 即进入测试。
// 所有动画参数来自 AnimationConfig.pde / BlessingConfig.pde，此处不再重复配置。

import java.util.HashMap;

String outputDir;  // 由 OUTPUT_BASE 得到

PImage[] testRunFrames;
PImage[] testJumpFrames;
PImage[] testQiyangFrames;

int runFrameIndex = 0;
float runFrameTime = 0;
float runCycleProgress = 0;

boolean jumping = false;
int jumpFrameIndex = 0;
float jumpFrameTime = 0;

boolean playingQiyang = false;
int qiyangFrameIndex = 0;
float qiyangFrameTime = 0;

String phraseText = "";
float phraseX, phraseY;
float phraseTimer = 0;
float phraseDuration = 5.0;
boolean phraseActive = false;
PFont phraseFont;
int phraseFontSize = 72;
color phraseColor = color(200, 30, 45);
color phraseBorder = color(255, 215, 0);

ArrayList<TestSpriteInstance> spritesBack = new ArrayList<TestSpriteInstance>();
ArrayList<TestSpriteInstance> spritesFront = new ArrayList<TestSpriteInstance>();
HashMap<String, PImage[]> spriteCache = new HashMap<String, PImage[]>();

ArrayList<GiftBox> testGiftBoxes = new ArrayList<GiftBox>();
PImage testBoxHead;
PImage testBoxBody;

float getRunCycleBobY(float cycleProgress, float amplitude, float randomness) {
  float main = amplitude * sin(TWO_PI * cycleProgress);
  float jitter = (randomness > 0) ? randomness * (2 * noise(cycleProgress * 10) - 1) : 0;
  return main + jitter;
}

// getBobOffsetY 使用 BlessingSpriteManager.pde 中的全局定义

void testSetup() {
  outputDir = OUTPUT_BASE;

  testRunFrames = new PImage[RUN_FRAMES];
  for (int i = 0; i < RUN_FRAMES; i++) {
    testRunFrames[i] = loadImage(outputDir + "/run-v4/run-v4_" + nf(i, 2) + ".png");
  }
  testJumpFrames = new PImage[JUMP_TOTAL_FRAMES];
  for (int i = 0; i < JUMP_TOTAL_FRAMES; i++) {
    testJumpFrames[i] = loadImage(outputDir + "/jump-mid-v4/jump-mid-v4_" + nf(i, 2) + ".png");
  }
  testQiyangFrames = new PImage[QIYANG_TOTAL_FRAMES];
  for (int i = 0; i < QIYANG_TOTAL_FRAMES; i++) {
    testQiyangFrames[i] = loadImage(outputDir + "/qiyang/qiyang_" + nf(i, 2) + ".png");
  }

  phraseFont = createFont("data/xinchun.ttf", phraseFontSize);
  if (phraseFont == null) {
    String[] fallbacks = { "Microsoft YaHei", "SimHei", "SimSun", "KaiTi", "FangSong" };
    for (String name : fallbacks) {
      phraseFont = createFont(name, phraseFontSize);
      if (phraseFont != null) { println("Test 使用备用字体: " + name); break; }
    }
  }
  if (phraseFont == null) phraseFont = createFont("Arial", phraseFontSize);

  if (USE_GIFT_BOX) {
    testBoxHead = loadImage(GIFT_BOX_HEAD_PATH);
    testBoxBody = loadImage(GIFT_BOX_BODY_PATH);
    if (testBoxHead != null && testBoxHead.width > 300) {
      int w = 300;
      int h = (int)((float)testBoxHead.height * w / testBoxHead.width);
      testBoxHead.resize(w, h);
    }
    if (testBoxBody != null && testBoxBody.width > 300) {
      int w = 300;
      int h = (int)((float)testBoxBody.height * w / testBoxBody.width);
      testBoxBody.resize(w, h);
    }
  }

  println("1=跳 2=马上有对象 3=马上有钱 4=马上有福 5=马上起飞(双火箭) 6=跨过坎坷 7=跨过阻碍 8=跨过了迷茫 9=马到成功 0=马年大吉(起扬)");
  println("2/3/4 会同时播放头顶礼物盒(盖+盒身分离)动画");
}

PImage[] getSpriteFrames(String type) {
  if (spriteCache.containsKey(type)) return spriteCache.get(type);
  PImage[] arr = loadTestSpriteFrames(type);
  if (arr != null) spriteCache.put(type, arr);
  return arr;
}

PImage[] loadTestSpriteFrames(String type) {
  String prefix;
  int count;
  if (type.equals("elephant")) { prefix = outputDir + "/" + OUTPUT_ELEPHANT_PREFIX; count = OUTPUT_ELEPHANT_COUNT; }
  else if (type.equals("fudai")) { prefix = outputDir + "/" + OUTPUT_FUDAI_PREFIX; count = OUTPUT_FUDAI_COUNT; }
  else if (type.equals("qiandai")) { prefix = outputDir + "/" + OUTPUT_QIANDAI_PREFIX; count = OUTPUT_QIANDAI_COUNT; }
  else if (type.equals("rocket")) { prefix = outputDir + "/" + OUTPUT_ROCKET_PREFIX; count = OUTPUT_ROCKET_COUNT; }
  else if (type.equals("shoudai")) { prefix = outputDir + "/" + OUTPUT_SHOUDAI_PREFIX; count = OUTPUT_SHOUDAI_COUNT; }
  else return null;
  PImage[] arr = new PImage[count];
  for (int i = 0; i < count; i++) {
    PImage img = loadImage(prefix + nf(i, 2) + OUTPUT_FRAME_SUFFIX);
    if (img != null && img.width > 0) {
      int w = (int)(img.width * 0.5);
      int h = (int)(img.height * 0.5);
      if (w > 0 && h > 0) img.resize(w, h);
    }
    arr[i] = img;
  }
  return arr;
}

void triggerJump() {
  if (!jumping) {
    jumping = true;
    jumpFrameIndex = 0;
    jumpFrameTime = 0;
  }
}

void showPhrase(String text, float cx, float cy) {
  phraseText = text;
  phraseX = cx;
  phraseY = cy - 120;
  phraseTimer = 0;
  phraseActive = true;
}

void spawnHorseBackSprite(String type, float x, float y) {
  PImage[] frames = getSpriteFrames(type);
  if (frames == null || frames.length == 0) return;
  float scale = getBlessingSpriteScale(type);
  spritesFront.add(new TestSpriteInstance(frames, x, y, BLESSING_SPRITE_DURATION, BLESSING_SPRITE_FPS, scale, true));
}

void spawnFrontSprite(String type, float x, float y, float scale) {
  PImage[] frames = getSpriteFrames(type);
  if (frames == null || frames.length == 0) return;
  float phase = random(TWO_PI);
  float bobSpeed = getRunCycleFrequencyHz();
  spritesFront.add(new TestSpriteInstance(frames, x, y, BLESSING_SPRITE_DURATION, BLESSING_SPRITE_FPS, scale, false, bobSpeed, BOB_RUN_CYCLE_AMPLITUDE, BOB_RUN_CYCLE_RANDOMNESS, phase));
}

void spawnTestGiftBox(String type) {
  if (!USE_GIFT_BOX || testBoxHead == null || testBoxBody == null) return;
  float stringLen = random(GIFT_BOX_STRING_LENGTH_MIN, GIFT_BOX_STRING_LENGTH_MAX);
  float anchorY = GIFT_BOX_ANCHOR_Y;
  GiftBox box = new GiftBox(testBoxHead, testBoxBody, PONY_X, anchorY, stringLen, 0, GIFT_BOX_SCALE, type);
  box.onHit(PONY_X, PONY_Y - 80);
  testGiftBoxes.add(box);
}

void spawnTwoRockets() {
  PImage[] frames = getSpriteFrames("rocket");
  if (frames == null || frames.length == 0) return;
  float phase = random(TWO_PI);
  float bobSpeed = getRunCycleFrequencyHz();
  float yBehind = PONY_Y + ROCKET_BEHIND_Y;
  float yFront  = PONY_Y + ROCKET_FRONT_Y;
  spritesBack.add(new TestSpriteInstance(frames, PONY_X + ROCKET_OFFSET_BEHIND_X, yBehind, BLESSING_SPRITE_DURATION, BLESSING_SPRITE_FPS, BLESSING_ROCKET_SCALE_BEHIND, false, bobSpeed, BOB_RUN_CYCLE_AMPLITUDE, BOB_RUN_CYCLE_RANDOMNESS, phase));
  spritesFront.add(new TestSpriteInstance(frames, PONY_X + ROCKET_OFFSET_FRONT_X, yFront, BLESSING_SPRITE_DURATION, BLESSING_SPRITE_FPS, BLESSING_ROCKET_SCALE_FRONT, false, bobSpeed, BOB_RUN_CYCLE_AMPLITUDE, BOB_RUN_CYCLE_RANDOMNESS, phase + 0.5));
}

void testKeyPressed() {
  if (key == '1') {
    triggerJump();
    println("[1] 跳跃");
  } else if (key == '2') {
    showPhrase("马上有对象", PONY_X, PONY_Y);
    spawnBlessingSpriteFromBox("elephant", PONY_X, GIFT_BOX_ANCHOR_Y);
    spawnTestGiftBox("elephant");
    println("[2] 马上有对象 + 小象(从礼盒弹出到马背) + 礼物盒");
  } else if (key == '3') {
    showPhrase("马上有钱", PONY_X, PONY_Y);
    spawnBlessingSpriteFromBox("qiandai", PONY_X, GIFT_BOX_ANCHOR_Y);
    spawnTestGiftBox("money");
    println("[3] 马上有钱 + 钱袋(从礼盒弹出到马背) + 礼物盒");
  } else if (key == '4') {
    showPhrase("马上有福", PONY_X, PONY_Y);
    spawnBlessingSpriteFromBox("fudai", PONY_X, GIFT_BOX_ANCHOR_Y);
    spawnTestGiftBox("fu");
    println("[4] 马上有福 + 福袋(从礼盒弹出到马背) + 礼物盒");
  } else if (key == '5') {
    showPhrase("马上起飞", PONY_X, PONY_Y);
    spawnTwoRockets();
    println("[5] 马上起飞 + 双火箭(大腿侧)");
  } else if (key == '6') {
    showPhrase("跨过坎坷", PONY_X, PONY_Y);
    println("[6] 跨过坎坷");
  } else if (key == '7') {
    showPhrase("跨过阻碍", PONY_X, PONY_Y);
    println("[7] 跨过阻碍");
  } else if (key == '8') {
    showPhrase("跨过了迷茫", PONY_X, PONY_Y);
    println("[8] 跨过了迷茫");
  } else if (key == '9') {
    showPhrase("马到成功", PONY_X, PONY_Y);
    spawnFrontSprite("shoudai", PONY_X + SHOUDAI_OFFSET_X, PONY_Y + SHOUDAI_OFFSET_Y, getBlessingSpriteScale("shoudai"));
    println("[9] 马到成功 + 手袋");
  } else if (key == '0') {
    showPhrase("马年大吉", PONY_X, PONY_Y);
    if (!playingQiyang) {
      playingQiyang = true;
      qiyangFrameIndex = QIYANG_START_FRAME;
      qiyangFrameTime = 0;
    }
    println("[0] 马年大吉 + 起扬");
  }
}

void testDraw() {
  background(220);
  float dt = 1.0 / 60.0;

  if (playingQiyang) {
    qiyangFrameTime += dt;
    float frameDur = 1.0 / QIYANG_FPS;
    if (qiyangFrameTime >= frameDur) {
      qiyangFrameTime -= frameDur;
      qiyangFrameIndex++;
    }
    if (qiyangFrameIndex >= QIYANG_TOTAL_FRAMES) playingQiyang = false;
  } else if (jumping) {
    jumpFrameTime += dt;
    float frameDur = 1.0 / JUMP_FPS;
    if (jumpFrameTime >= frameDur) {
      jumpFrameTime -= frameDur;
      jumpFrameIndex++;
    }
    if (jumpFrameIndex >= JUMP_TOTAL_FRAMES) {
      jumping = false;
      jumpFrameIndex = 0;
    }
  } else {
    runFrameTime += dt;
    float frameDur = 1.0 / RUN_FPS;
    if (runFrameTime >= frameDur) {
      runFrameTime -= frameDur;
      runFrameIndex = (runFrameIndex + 1) % RUN_FRAMES;
    }
    runCycleProgress = (runFrameIndex + runFrameTime / frameDur) / (float) RUN_FRAMES;
  }

  for (int i = spritesBack.size() - 1; i >= 0; i--) {
    TestSpriteInstance s = spritesBack.get(i);
    s.update(dt);
    if (s.isDone()) spritesBack.remove(i);
  }
  for (TestSpriteInstance s : spritesBack) s.display(runCycleProgress);

  PImage ponyImg;
  if (playingQiyang && testQiyangFrames != null && qiyangFrameIndex < testQiyangFrames.length) {
    ponyImg = testQiyangFrames[qiyangFrameIndex];
  } else {
    ponyImg = jumping ? testJumpFrames[jumpFrameIndex] : testRunFrames[runFrameIndex];
  }
  if (ponyImg != null) {
    pushMatrix();
    translate(PONY_X, PONY_Y);
    scale(PONY_SCALE);
    imageMode(CENTER);
    image(ponyImg, 0, 0);
    popMatrix();
  }

  for (int i = spritesFront.size() - 1; i >= 0; i--) {
    TestSpriteInstance s = spritesFront.get(i);
    s.update(dt);
    if (s.isDone()) spritesFront.remove(i);
  }
  for (TestSpriteInstance s : spritesFront) s.display(runCycleProgress);

  for (int i = testGiftBoxes.size() - 1; i >= 0; i--) {
    GiftBox box = testGiftBoxes.get(i);
    box.update(dt);
    if (box.isDone()) testGiftBoxes.remove(i);
  }
  for (GiftBox box : testGiftBoxes) box.display();

  if (blessingSpriteManager != null) {
    blessingSpriteManager.update(dt);
    blessingSpriteManager.display();
  }

  phraseTimer += dt;
  if (phraseTimer > phraseDuration) phraseActive = false;
  if (phraseActive && phraseText.length() > 0 && phraseFont != null) {
    textFont(phraseFont);
    textAlign(CENTER, CENTER);
    textSize(phraseFontSize);
    noStroke();
    for (int t = 2; t > 0; t--) {
      fill(phraseBorder);
      text(phraseText, phraseX - t, phraseY);
      text(phraseText, phraseX + t, phraseY);
      text(phraseText, phraseX, phraseY - t);
      text(phraseText, phraseX, phraseY + t);
    }
    fill(phraseColor);
    text(phraseText, phraseX, phraseY);
  }

  fill(0);
  textAlign(LEFT, TOP);
  textSize(14);
  text("1=跳 2=对象 3=有钱 4=有福 5=起飞 6=坎坷 7=阻碍 8=迷茫 9=成功 0=大吉(起扬)", 10, 10);
  if (USE_GIFT_BOX) text("2/3/4 含头顶礼物盒(盖+盒身分离)", 10, 26);
}

class TestSpriteInstance {
  PImage[] frames;
  float x, y;
  float elapsed;
  float duration;
  float fps;
  float scale;
  boolean useRunCycleBob;
  float bobSpeed, bobAmplitude, bobRandomness, bobPhase;

  TestSpriteInstance(PImage[] frames, float x, float y, float duration, float fps, float scale, boolean useRunCycleBob) {
    this(frames, x, y, duration, fps, scale, useRunCycleBob, 0, 0, 0, 0);
  }

  TestSpriteInstance(PImage[] frames, float x, float y, float duration, float fps, float scale,
      boolean useRunCycleBob, float bobSpeed, float bobAmplitude, float bobRandomness, float bobPhase) {
    this.frames = frames;
    this.x = x;
    this.y = y;
    this.elapsed = 0;
    this.duration = duration;
    this.fps = fps;
    this.scale = scale;
    this.useRunCycleBob = useRunCycleBob;
    this.bobSpeed = bobSpeed;
    this.bobAmplitude = bobAmplitude;
    this.bobRandomness = bobRandomness;
    this.bobPhase = bobPhase;
  }

  void update(float dt) { elapsed += dt; }

  boolean isDone() { return elapsed >= duration; }

  void display(float runCycleProgress) {
    if (frames == null || frames.length == 0) return;
    int idx = (int)(elapsed * fps) % frames.length;
    if (idx < 0) idx = 0;
    PImage img = frames[idx];
    if (img == null || img.width <= 0) return;
    float offsetY;
    if (useRunCycleBob) {
      offsetY = getRunCycleBobY(runCycleProgress, BOB_RUN_CYCLE_AMPLITUDE, BOB_RUN_CYCLE_RANDOMNESS);
    } else {
      offsetY = getBobOffsetY(elapsed, bobSpeed, bobAmplitude, bobPhase, bobRandomness);
    }
    pushMatrix();
    translate(x, y + offsetY);
    scale(scale);
    imageMode(CENTER);
    image(img, 0, 0);
    popMatrix();
  }
}
