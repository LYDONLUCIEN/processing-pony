// ==================== 祝福字弹出（参考 word.pde） ====================
// 多字海绵弹效果（支持 4 字、5 字等）+ 可选配套素材图
// 样式：喜庆红字 + 鎏金镶边 + 外发光，可配置

// 配色（中国喜庆风，可改）
color BLESSING_TEXT_RED = color(200, 30, 45);        // 主色：喜庆红
color BLESSING_BORDER_GOLD = color(255, 215, 0);     // 鎏金镶边
color BLESSING_BORDER_GOLD_DARK = color(218, 165, 32);
color BLESSING_GLOW_RED = color(255, 100, 80);      // 外发光红
color BLESSING_GLOW_GOLD = color(255, 220, 100);    // 外发光金
color BLESSING_SHADOW = color(80, 20, 20);          // 阴影
int BLESSING_BORDER_THICKNESS = 2;                   // 镶边厚度（像素）
int BLESSING_GLOW_LAYERS = 5;                        // 外发光层数

// 祝福字位置与高度：固定居中时用 FIXED_X/FIXED_Y；否则用 centerX / centerY + Y_OFFSET
// 调字的高度：固定位置时改 BLESSING_WORD_FIXED_Y（越大越靠下）；非固定时改 BLESSING_WORD_Y_OFFSET
boolean BLESSING_WORD_USE_FIXED_POSITION = true;     // true = 始终固定位置，方便你调
float BLESSING_WORD_FIXED_X = 400;                   // 固定 X（画面中心）
float BLESSING_WORD_FIXED_Y = 180;                   // 固定 Y，调此值可调字的高度
float BLESSING_WORD_Y_OFFSET = -200;                 // 非固定时：相对传入 centerY 的偏移
float BLESSING_WORD_ARC_AMPLITUDE = 18;              // 弧度幅度（像素），左到右 低高高低

// 字体：系统字体名 或 data 目录下 .ttf/.otf 文件名（如 "data/YourFont.ttf"）
String BLESSING_FONT_NAME = "data/xinchun.ttf";
int BLESSING_FONT_SIZE = 72;

PFont blessingFont;
ArrayList<BouncyChar> bouncyChars = new ArrayList<BouncyChar>();
String currentPhrase = "";
float phraseCenterX, phraseCenterY;
float charSpacing = 90;
float wordTimer = 0;
boolean wordActive = false;
PImage pairedAsset = null;
float assetX, assetY, assetScale = 0.2;
float assetPopTimer = 0;
float wordDuration = 8.0;

void initBlessingFont() {
  blessingFont = createFont(BLESSING_FONT_NAME, BLESSING_FONT_SIZE);
  if (blessingFont == null) blessingFont = createFont("Arial", BLESSING_FONT_SIZE);
  if (blessingFont != null) println("Blessing font: " + BLESSING_FONT_NAME + " " + BLESSING_FONT_SIZE + "pt");
}

void spawnBouncyWord(String phrase, float centerX, float centerY, PImage asset) {
  if (phrase == null || phrase.length() == 0) return;
  bouncyChars.clear();
  currentPhrase = phrase;
  if (BLESSING_WORD_USE_FIXED_POSITION) {
    phraseCenterX = BLESSING_WORD_FIXED_X;
    phraseCenterY = BLESSING_WORD_FIXED_Y;
  } else {
    phraseCenterX = centerX;
    phraseCenterY = centerY + BLESSING_WORD_Y_OFFSET;
  }
  wordActive = true;
  wordTimer = 0;
  pairedAsset = asset;
  assetPopTimer = 0;

  int len = phrase.length();
  float totalW = (len - 1) * charSpacing;
  float startX = phraseCenterX - totalW / 2;
  float arcAmp = BLESSING_WORD_ARC_AMPLITUDE;
  float denom = (len > 1) ? (len - 1) : 1;

  // 左到右 低高高低：中间二字上翘（arcY 负），两端在基线
  for (int i = 0; i < len; i++) {
    char c = phrase.charAt(i);
    float x = startX + i * charSpacing;
    float arcY = -arcAmp * sin(PI * i / denom);
    float y = phraseCenterY + arcY;
    bouncyChars.add(new BouncyChar(c, x, y, i * 6));
  }
}

void updateBouncyWord(float dt) {
  if (!wordActive) return;
  wordTimer += dt;
  if (pairedAsset != null) assetPopTimer += dt;

  for (BouncyChar bc : bouncyChars) bc.update();
  if (wordTimer > wordDuration) wordActive = false;
}

void drawBouncyWord() {
  if (!wordActive) return;
  if (blessingFont != null) textFont(blessingFont);
  textAlign(CENTER, CENTER);

  for (BouncyChar bc : bouncyChars) bc.display();

  if (pairedAsset != null && assetPopTimer > 0.3) {
    float t = (assetPopTimer - 0.3) / 0.5;
    if (t > 1) t = 1;
    float s = 0.15 + 0.1 * (1 - pow(1 - t, 2));
    pushMatrix();
    translate(phraseCenterX, phraseCenterY - 60);
    scale(s);
    imageMode(CENTER);
    image(pairedAsset, 0, 0);
    popMatrix();
  }
}

// ========== 单字海绵弹（参考 word.pde） ==========
class BouncyChar {
  char c;
  float x, y;
  float scale = 0;
  float targetScale = 1.0;
  float scaleVelocity = 0;
  float scaleX = 0, scaleY = 0;
  float velocityX = 0, velocityY = 0;
  float rotation = 0, rotationVel = 0;
  float delay, timer = 0;
  boolean active = false;
  float springK = 0.08;
  float damping = 0.88;

  BouncyChar(char c, float x, float y, float delay) {
    this.c = c;
    this.x = x;
    this.y = y;
    this.delay = delay;
  }

  void update() {
    timer++;
    if (timer < delay) return;
    active = true;

    float force = (targetScale - scale) * springK;
    scaleVelocity += force;
    scaleVelocity *= damping;
    scale += scaleVelocity;

    float speed = abs(scaleVelocity);
    float targetScaleX = scale + scaleVelocity * 0.5;
    float targetScaleY = scale - scaleVelocity * 0.3;
    float forceX = (targetScaleX - scaleX) * 0.15;
    float forceY = (targetScaleY - scaleY) * 0.15;
    velocityX += forceX;
    velocityY += forceY;
    velocityX *= 0.85;
    velocityY *= 0.85;
    scaleX += velocityX;
    scaleY += velocityY;

    if (speed > 0.01) rotation += scaleVelocity * 0.3;
    float rotationForce = (0 - rotation) * 0.1;
    rotationVel += rotationForce;
    rotationVel *= 0.9;
    rotation += rotationVel;

    if (abs(scaleVelocity) < 0.01) {
      float breathe = sin(timer * 0.05) * 0.03;
      scaleX = 1.0 + breathe;
      scaleY = 1.0 - breathe * 0.5;
    }
  }

  void display() {
    if (!active) return;
    textSize(BLESSING_FONT_SIZE);
    pushMatrix();
    translate(x, y);
    rotate(rotation);
    scale(scaleX, scaleY);
    String ch = str(c);

    // 1. 外发光（多层从大到小，红→金渐变透明）
    noStroke();
    for (int i = BLESSING_GLOW_LAYERS; i > 0; i--) {
      float r = 1.0 + i * 0.04;
      float alpha = 25 * (BLESSING_GLOW_LAYERS - i + 1);
      fill(lerpColor(BLESSING_GLOW_RED, BLESSING_GLOW_GOLD, i / (float)BLESSING_GLOW_LAYERS), alpha);
      pushMatrix();
      scale(r);
      text(ch, 0, 0);
      popMatrix();
    }

    // 2. 阴影（偏右下，加深立体感）
    fill(BLESSING_SHADOW, 120);
    text(ch, 3, 4);

    // 3. 鎏金镶边（多方向偏移描边）
    int t = BLESSING_BORDER_THICKNESS;
    fill(BLESSING_BORDER_GOLD_DARK);
    text(ch, -t, -t);
    text(ch, 0, -t);
    text(ch, t, -t);
    text(ch, t, 0);
    text(ch, t, t);
    text(ch, 0, t);
    text(ch, -t, t);
    text(ch, -t, 0);
    fill(BLESSING_BORDER_GOLD);
    text(ch, -t+1, -t+1);
    text(ch, 1, -t+1);
    text(ch, t-1, -t+1);
    text(ch, t-1, 1);
    text(ch, t-1, t-1);
    text(ch, 1, t-1);
    text(ch, -t+1, t-1);
    text(ch, -t+1, 1);

    // 4. 主色：喜庆红
    fill(BLESSING_TEXT_RED);
    text(ch, 0, 0);

    // 5. 高光（左上角轻微提亮，增加立体）
    fill(255, 255, 255, 50);
    text(ch, -1, -2);
    popMatrix();
  }
}
