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
final int CLOUD_MAX_CLOUDS = 3;
final float CLOUD_MIN_SCALE = 0.25;
final float CLOUD_MAX_SCALE = 0.35;
final float CLOUD_MIN_Y = 50;
final float CLOUD_MAX_Y = 250;
final float CLOUD_SPEED = 0.2;
final int CLOUD_ALPHA = 180;
// 云朵移出左侧多远才移除（保证运动距离≥1300：从 width+80 到 -CLOUD_OFFSCREEN_LEFT 约 1300+）
final float CLOUD_OFFSCREEN_LEFT = 420;
// 云朵之间最小水平间隔（像素），保证 800 内约 2～3 朵
final float CLOUD_MIN_GAP = 320;
// 云朵生成间隔（秒），补新云频率
final float CLOUD_SPAWN_INTERVAL_MIN = 8.0;
final float CLOUD_SPAWN_INTERVAL_MAX = 15.0;

// ==================== 山层配置 ====================
// 单张 final-all.png，与 floor 相同逻辑：双块无缝滚动（mountain 目录只使用此素材）
final String MOUNTAIN_PATH = "../assets/mountain/finall-all.png";

final float MOUNTAIN_SCALE = 0.66;
final float MOUNTAIN_BASE_Y = 185;
final float MOUNTAIN_SPEED = 10.0;
// 山图加载后最大宽度（像素），超大图会先缩放到此再上传，保证性能
final int MOUNTAIN_MAX_TEXTURE_WIDTH = 2400;

// ==================== 路边近景配置（花朵 + 栏杆） ====================
final float FORGE_SPEED = 190;
// 花朵：floor 与 mountain 接缝处；栏杆：在花朵前
final String ROADSIDE_FLOWER_PATH = "../assets/roadside/flower2.png";
final String ROADSIDE_RAILING_PATH = "../assets/roadside/finall-lg.png";
final float ROADSIDE_FLOWER_SCALE = 0.51;
final float ROADSIDE_FLOWER_BASE_Y = 360;
final float ROADSIDE_FLOWER_SPEED = FORGE_SPEED;
final float ROADSIDE_RAILING_SCALE = 0.38;
final float ROADSIDE_RAILING_BASE_Y = ROADSIDE_FLOWER_BASE_Y - 8;
final float ROADSIDE_RAILING_SPEED = FORGE_SPEED;
final int ROADSIDE_MAX_TEXTURE_WIDTH = 2400;

// 画面最下方：护栏 + 草丛（双条带无缝滚动，从远到近：护栏在下、草丛在上）
final String ROADSIDE_GRASS_PATH = "../assets/roadside/flower-back.png";
final float ROADSIDE_GRASS_SCALE = 0.4;
final float ROADSIDE_GRASS_BASE_Y = 570;
final float ROADSIDE_GRASS_SPEED = FORGE_SPEED;
final String ROADSIDE_GUARDRAIL_PATH = "../assets/roadside/finall-lg2.png";
final float ROADSIDE_GUARDRAIL_SCALE = 0.4;
final float ROADSIDE_GUARDRAIL_BASE_Y = ROADSIDE_GRASS_BASE_Y-8;
final float ROADSIDE_GUARDRAIL_SPEED = FORGE_SPEED;


// ==================== 灯笼配置（按 beat 间隔生成） ====================
final String DENGLONG_PATH_PREFIX = "../assets/denglong/dl";
final String DENGLONG_PATH_SUFFIX = ".png";
final int DENGLONG_COUNT = 5;

final int DENGLONG_SPAWN_INTERVAL_BEATS = 4;  // 每 N 拍生成一个灯笼，控制密度
final float DENGLONG_SPEED = 320.0;           // 移动速度（像素/秒）
final float DENGLONG_BASE_Y = 66;
final float DENGLONG_SCALE = 0.25;

// ==================== 柱子配置（按 beat 间隔生成） ====================
final String PILLAR_PATH_PREFIX = "../assets/pillar/pillar_";
final String PILLAR_PATH_SUFFIX = ".png";
final int PILLAR_COUNT = 5;

final int PILLAR_SPAWN_INTERVAL_BEATS = 8;
final float PILLAR_SPEED = 280.0;
final float PILLAR_BASE_Y = 400;
final float PILLAR_SCALE = 0.3;

// ==================== 鞭炮配置（按 beat 间隔生成） ====================
final String FIRECRACKER_PATH_PREFIX = "../assets/firecracker/firecracker_";
final String FIRECRACKER_PATH_SUFFIX = ".png";
final int FIRECRACKER_COUNT = 5;

final int FIRECRACKER_SPAWN_INTERVAL_BEATS = 6;
final float FIRECRACKER_SPEED = 300.0;
final float FIRECRACKER_BASE_Y = 500;
final float FIRECRACKER_SCALE = 0.2;

// ==================== 石头配置 ====================
final String STONE_PATH_PREFIX = "../assets/stone/st";
final String STONE_PATH_SUFFIX = ".png";
final int STONE_COUNT = 3;

final float STONE_SPAWN_INTERVAL = 6.0;
final float STONE_SPEED = 260.0;
final float STONE_BASE_Y = 480;
final float STONE_SCALE = 0.08;
final float STONE_JUMP_TRIGGER_X = 300;

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
final String GROUND_PATH = "../assets/ground/floor3.png";

// 地面滚动速度（像素/秒，向左）
final float GROUND_SPEED = FORGE_SPEED;

// 地面底边所在的屏幕高度（像素）
final float GROUND_Y = 666;

// 屏幕上平行四边形的高度（像素）
final float GROUND_PARALLELOGRAM_HEIGHT = 200;
// 地面整体缩放（1.0=原样，>1 放大，<1 缩小）
final float GROUND_DISPLAY_SCALE = 1.8;
// 地面图加载后最大宽度（像素），超大图会先缩放到此再使用
final int GROUND_MAX_TEXTURE_WIDTH = 2400;

// 平行四边形倾斜：顶边相对底边向右偏移
// 方式一：用角度，slantPx = heightPx * tan(GROUND_TILT_DEG)
final float GROUND_TILT_DEG = 36;
// 方式二：若 > 0 则直接使用像素值，忽略 GROUND_TILT_DEG（方便调参）
final float GROUND_SLANT_PIXELS = 0;

//floor3的素材 好的配置是：
//GROUND_PARALLELOGRAM_HEIGHT = 200;
//GROUND_MAX_TEXTURE_WIDTH = 2400;
//GROUND_TILT_DEG = 30;

// ==================== 小马配置 ====================
final float PONY_X = 400;  // 居中
final float PONY_Y = 380;
final float PONY_SCALE = 1.0;  // 原始尺寸
final float PONY_JUMP_HEIGHT = 300;
