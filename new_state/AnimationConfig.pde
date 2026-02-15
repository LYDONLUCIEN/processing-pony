// ==================== AnimationConfig.pde 动画与场景配置 ====================
//
// 目录（按需查找）：
//  一、全局速度
//  二、小马与节奏（位置、跑/跳/起扬、BPM）
//  三、背景（云、山、路边、地面）
//  四、前景装饰（灯笼、柱子、鞭炮）
//  五、石头
//  六、金币红包
//  七、娱乐模式与起扬触发
//  八、输出目录
//

// ==================== 一、全局速度 ====================
// 改这一处即可同步：路边/地面滚动、福袋/礼物盒水平移动速度
final float FORGE_SPEED = 190;

// ==================== 二、小马与节奏 ====================
final float PONY_X = 400;
final float PONY_Y = 380;
final float PONY_SCALE = 1.0;
final float PONY_JUMP_HEIGHT = 300;

// 跑步周期（6 帧 = 1 beat）：主流程由 BPM 驱动，测试由 RUN_FPS 驱动
final int RUN_FRAMES = 6;
final float RUN_FPS = 10;
final float BPM = 129.0;

// 起扬序列
final int QIYANG_TOTAL_FRAMES = 169;
final int QIYANG_START_FRAME = 14;
final float QIYANG_FPS = 12;

// 跳跃
final int JUMP_TOTAL_FRAMES = 23;
final float JUMP_FPS = 8;
final float JUMP_APEX_TIME = (JUMP_TOTAL_FRAMES / 2.0f) / JUMP_FPS;

// ==================== 三、背景（云、山、路边、地面） ====================

final String BACKGROUND_PATH = "../assets/background/background.png";
final float BACKGROUND_SCALE = 1.0;

// 云
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
final float CLOUD_OFFSCREEN_LEFT = 420;
final float CLOUD_MIN_GAP = 320;
final float CLOUD_SPAWN_INTERVAL_MIN = 8.0;
final float CLOUD_SPAWN_INTERVAL_MAX = 15.0;

// 山
final String MOUNTAIN_PATH = "../assets/mountain/finall-all.png";
final float MOUNTAIN_SCALE = 0.66;
final float MOUNTAIN_BASE_Y = 185;
final float MOUNTAIN_SPEED = 10.0;
final int MOUNTAIN_MAX_TEXTURE_WIDTH = 2400;

// 路边（花朵、栏杆、草丛、护栏）
final String ROADSIDE_FLOWER_PATH = "../assets/roadside/flower2.png";
final String ROADSIDE_RAILING_PATH = "../assets/roadside/finall-lg.png";
final float ROADSIDE_FLOWER_SCALE = 0.51;
final float ROADSIDE_FLOWER_BASE_Y = 360;
final float ROADSIDE_FLOWER_SPEED = FORGE_SPEED;
final float ROADSIDE_RAILING_SCALE = 0.38;
final float ROADSIDE_RAILING_BASE_Y = ROADSIDE_FLOWER_BASE_Y - 8;
final float ROADSIDE_RAILING_SPEED = FORGE_SPEED;
final int ROADSIDE_MAX_TEXTURE_WIDTH = 2400;

final String ROADSIDE_GRASS_PATH = "../assets/roadside/flower-back.png";
final float ROADSIDE_GRASS_SCALE = 0.4;
final float ROADSIDE_GRASS_BASE_Y = 570;
final float ROADSIDE_GRASS_SPEED = FORGE_SPEED;
final String ROADSIDE_GUARDRAIL_PATH = "../assets/roadside/finall-lg2.png";
final float ROADSIDE_GUARDRAIL_SCALE = 0.4;
final float ROADSIDE_GUARDRAIL_BASE_Y = ROADSIDE_GRASS_BASE_Y - 8;
final float ROADSIDE_GUARDRAIL_SPEED = FORGE_SPEED;

// 地面
final String GROUND_PATH = "../assets/ground/floor3.png";
final float GROUND_SPEED = FORGE_SPEED;
final float GROUND_Y = 666;
final float GROUND_PARALLELOGRAM_HEIGHT = 200;
final float GROUND_DISPLAY_SCALE = 1.8;
final int GROUND_MAX_TEXTURE_WIDTH = 2400;
final float GROUND_TILT_DEG = 36;
final float GROUND_SLANT_PIXELS = 0;

// ==================== 四、前景装饰（灯笼、柱子、鞭炮） ====================

final String DENGLONG_PATH_PREFIX = "../assets/denglong/dl";
final String DENGLONG_PATH_SUFFIX = ".png";
final int DENGLONG_COUNT = 1;
final int DENGLONG_SPAWN_INTERVAL_BEATS = 4;
final float DENGLONG_SPEED = 320.0;
final float DENGLONG_BASE_Y = 66;
final float DENGLONG_SCALE = 0.25;

final String PILLAR_PATH_PREFIX = "../assets/pillar/pillar_";
final String PILLAR_PATH_SUFFIX = ".png";
final int PILLAR_COUNT = 5;
final int PILLAR_SPAWN_INTERVAL_BEATS = 8;
final float PILLAR_SPEED = 280.0;
final float PILLAR_BASE_Y = 400;
final float PILLAR_SCALE = 0.3;

final String FIRECRACKER_PATH_PREFIX = "../assets/firecracker/firecracker_";
final String FIRECRACKER_PATH_SUFFIX = ".png";
final int FIRECRACKER_COUNT = 5;
final int FIRECRACKER_SPAWN_INTERVAL_BEATS = 6;
final float FIRECRACKER_SPEED = 300.0;
final float FIRECRACKER_BASE_Y = 500;
final float FIRECRACKER_SCALE = 0.2;

// ==================== 五、石头 ====================
final String STONE_PATH_PREFIX = "../assets/stone/st";
final String STONE_PATH_SUFFIX = ".png";
final int STONE_COUNT = 3;
final float STONE_SPAWN_INTERVAL = 6.0;
final float STONE_SPEED = 260.0;
final float STONE_BASE_Y = 480;
final float STONE_SCALE = 0.08;
final float STONE_JUMP_TRIGGER_X = 300;

// ==================== 六、金币红包 ====================
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

// ==================== 七、娱乐模式与起扬触发 ====================
final float QIYANG_TRIGGER_SECONDS_BEFORE_END = 5.0;

final String ENTERTAINMENT_CURSOR_PATH = "../assets/blessings/bag.png";
final float ENTERTAINMENT_CURSOR_SIZE = 36;
final float ENTERTAINMENT_SPAWN_STEP = 22;

// ==================== 八、输出目录 ====================
final String OUTPUT_BASE = "../output";
