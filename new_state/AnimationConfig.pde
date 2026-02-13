// ==================== 动画配置系统 ====================
// 所有动画参数都可以在这里调整

// 注意：不要在这里定义 SCENE_WIDTH 和 SCENE_HEIGHT
// 因为 size() 函数需要字面量参数，不能使用变量

// ==================== 背景层配置 ====================
final String BACKGROUND_PATH = "../assets/background/background.png";
final float BACKGROUND_SCALE = 1.0;

// ==================== 云层配置 ====================
final String CLOUD_PATH_PREFIX = "../assets/cloud/cd";
final String CLOUD_PATH_SUFFIX = ".png";
final int CLOUD_COUNT = 5;

final int CLOUD_MIN_CLOUDS = 2;
final int CLOUD_MAX_CLOUDS = 4;
final float CLOUD_MIN_SCALE = 0.35;
final float CLOUD_MAX_SCALE = 0.55;
final float CLOUD_MIN_Y = 30;
final float CLOUD_MAX_Y = 180;
final float CLOUD_SPEED = 3.0;
final int CLOUD_ALPHA = 180;

// ==================== 山层配置 ====================
final String MOUNTAIN_PATH_PREFIX = "../assets/mountain/mt";
final String MOUNTAIN_PATH_SUFFIX = ".png";
final int MOUNTAIN_COUNT = 3;

final String MOUNTAIN_CLOUD_PATH_PREFIX = "../assets/mountain/mt-cloud";
final String MOUNTAIN_CLOUD_PATH_SUFFIX = ".png";
final int MOUNTAIN_CLOUD_COUNT = 3;

final int MOUNTAIN_MIN_MOUNTAINS = 1;  // 改为1，只显示一个山峰
final int MOUNTAIN_MAX_MOUNTAINS = 1;
final float MOUNTAIN_MIN_SCALE = 0.4;  // 增大一些
final float MOUNTAIN_MAX_SCALE = 0.6;
final float MOUNTAIN_BASE_Y = 400;  // 固定高度
final float MOUNTAIN_SPEED = 10.0;  // 放慢速度

final int MOUNTAIN_MIN_MT_CLOUDS = 1;
final int MOUNTAIN_MAX_MT_CLOUDS = 2;
final float MOUNTAIN_MT_CLOUD_MIN_SCALE = 0.6;
final float MOUNTAIN_MT_CLOUD_MAX_SCALE = 0.6;
final float MOUNTAIN_MT_CLOUD_SPEED = 30.0;

// ==================== 灯笼配置 ====================
final String DENGLONG_PATH_PREFIX = "../assets/denglong/dl";
final String DENGLONG_PATH_SUFFIX = ".png";
final int DENGLONG_COUNT = 5;

final float DENGLONG_SPAWN_INTERVAL = 6;
final float DENGLONG_SPEED = 320.0;
final float DENGLONG_BASE_Y = 66;
final float DENGLONG_SCALE = 0.25;

// ==================== 石头配置 ====================
final String STONE_PATH_PREFIX = "../assets/stone/st";
final String STONE_PATH_SUFFIX = ".png";
final int STONE_COUNT = 3;

final float STONE_SPAWN_INTERVAL = 6.0;
final float STONE_SPEED = 220.0;
final float STONE_BASE_Y = 480;
final float STONE_SCALE = 0.08;
final float STONE_JUMP_TRIGGER_X = 220;

// ==================== 金币红包配置 ====================
final String[] MONEY_PATHS = {
  "../assets/money/hb1.png",
  "../assets/money/hb2.png",
  "../assets/money/hb3.png",
  "../assets/money/hb4.png",
  "../assets/money/mn1.png",
  "../assets/money/yb1.png",
  "../assets/money/yb2.png"
};

final int MONEY_PARTICLE_COUNT = 8;
final float MONEY_SPREAD_X = 100;
final float MONEY_SPREAD_Y = 200;
final float MONEY_GRAVITY = 150.0;
final float MONEY_MIN_SPEED = 60.0;
final float MONEY_MAX_SPEED = 150.0;
final float MONEY_FADE_TIME = 3;
final float MONEY_BASE_SCALE = 0.08;

// ==================== 地面配置 ====================
// ==================== 地面配置 ====================
// floor2.png 在 new_state/data 目录下
final String GROUND_PATH = "../assets/ground/floor2.png";

// 地面滚动速度（像素/秒，向左）
final float GROUND_SPEED = 200.0;

// 地面底边所在的屏幕高度（像素）
final float GROUND_Y = 600;

// 把 556 像素高压缩成屏幕上的 270 像素高
final float GROUND_PARALLELOGRAM_HEIGHT = 250;

// 顶边相对底边水平偏移多少像素（决定平行四边形斜的程度，可以慢慢调）
final float GROUND_TILT_DEG = 25.0;
final float GROUND_SLANT_PIXELS = 300.0;

// ==================== 小马配置 ====================
final float PONY_X = 400;  // 居中
final float PONY_Y = 380;
final float PONY_SCALE = 1.0;  // 原始尺寸
final float PONY_JUMP_HEIGHT = 100;
