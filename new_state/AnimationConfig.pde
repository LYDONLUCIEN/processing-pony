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

final int CLOUD_MIN_CLOUDS = 1;
final int CLOUD_MAX_CLOUDS = 2;
final float CLOUD_MIN_SCALE = 0.25;
final float CLOUD_MAX_SCALE = 0.35;
final float CLOUD_MIN_Y = 50;
final float CLOUD_MAX_Y = 250;
final float CLOUD_SPEED = 0.2;
final int CLOUD_ALPHA = 180;
// 每 800×200 区域最多云朵数，越大越密
final float CLOUD_REGION_WIDTH = 800;
final float CLOUD_REGION_HEIGHT = 200;
final int CLOUD_MAX_PER_REGION = 3;
// 云朵生成间隔（秒），越大越稀疏
final float CLOUD_SPAWN_INTERVAL_MIN = 5.0;
final float CLOUD_SPAWN_INTERVAL_MAX = 10.0;

// ==================== 山层配置 ====================
// 单张 final-all.png，与 floor 相同逻辑：双块无缝滚动（mountain 目录只使用此素材）
final String MOUNTAIN_PATH = "../assets/mountain/finall-all.png";

final float MOUNTAIN_SCALE = 0.65;
final float MOUNTAIN_BASE_Y = 320;
final float MOUNTAIN_SPEED = 10.0;
// 山图加载后最大宽度（像素），超大图会先缩放到此再上传，保证性能
final int MOUNTAIN_MAX_TEXTURE_WIDTH = 2400;

// ==================== 路边近景配置（花朵 + 栏杆） ====================
// 花朵：floor 与 mountain 接缝处；栏杆：在花朵前
final String ROADSIDE_FLOWER_PATH = "../assets/roadside/flower.png";
final String ROADSIDE_RAILING_PATH = "../assets/roadside/finall-lg.png";
final float ROADSIDE_FLOWER_SCALE = 0.36;
final float ROADSIDE_FLOWER_BASE_Y = 480;
final float ROADSIDE_FLOWER_SPEED = 180.0;
final float ROADSIDE_RAILING_SCALE = 0.5;
final float ROADSIDE_RAILING_BASE_Y = 480;
final float ROADSIDE_RAILING_SPEED = 180.0;
final int ROADSIDE_MAX_TEXTURE_WIDTH = 2400;

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

// 屏幕上平行四边形的高度（像素）
final float GROUND_PARALLELOGRAM_HEIGHT = 250;
// 地面图加载后最大宽度（像素），超大图会先缩放到此再使用
final int GROUND_MAX_TEXTURE_WIDTH = 2400;

// 平行四边形倾斜：顶边相对底边向右偏移
// 方式一：用角度，slantPx = heightPx * tan(GROUND_TILT_DEG)
final float GROUND_TILT_DEG = 25.0;
// 方式二：若 > 0 则直接使用像素值，忽略 GROUND_TILT_DEG（方便调参）
final float GROUND_SLANT_PIXELS = 0;

// ==================== 小马配置 ====================
final float PONY_X = 400;  // 居中
final float PONY_Y = 380;
final float PONY_SCALE = 1.0;  // 原始尺寸
final float PONY_JUMP_HEIGHT = 100;
