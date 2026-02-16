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
final float FORGE_SPEED = 240;

// ==================== 二、小马与节奏 ====================
final float PONY_X = 400;
final float PONY_Y = 380;
final float PONY_SCALE = 1.0;
final float PONY_JUMP_HEIGHT = 50;
// 头部碰撞点（相对 PONY_X；Y 随跳跃高度变化）：用于礼盒/福袋碰撞
final float PONY_HEAD_OFFSET_X = 60;
final float PONY_HEAD_OFFSET_Y = -40;
// 小马头顶在最高点时的位置（用于礼盒垂直对齐、可微调）：头顶 ≈ (PONY_X + APEX_X, PONY_Y + APEX_Y)
final float PONY_HEAD_APEX_OFFSET_X = 60;
final float PONY_HEAD_APEX_OFFSET_Y = -90;
// 胸口位置（相对 PONY_X, PONY_Y）：手袋/马到成功等文字与精灵出现位置
final float PONY_CHEST_OFFSET_X = 42;
final float PONY_CHEST_OFFSET_Y = 42;

// 跑步周期（6 帧 = 1 beat）：主流程由 BPM 驱动，测试由 RUN_FPS 驱动
final int RUN_FRAMES = 6;
final float RUN_FPS = 10;
final float BPM = 129.0;

// 起扬序列（主流程与 test 共用；改这里即可）
final int QIYANG_TOTAL_FRAMES = 158;
final int QIYANG_START_FRAME = 14;   // 从 qiyang_14.png 开始播
final int QIYANG_END_FRAME = 64;     // 到达此帧时背景全部停
final int QIYANG_LOOP_START_FRAME = 75;  // 第一遍播完后，从 qiyang_75.png 开始循环到结尾
final float QIYANG_FPS = 24;
final float QIYANG_LOOP_FPS = 24;   // 循环段播放帧率

// 跳跃：时长由 BPM + beatsForRemainingJump 决定（3 拍），最高点在第 14 帧（0-based 为第 13 帧）
final int JUMP_TOTAL_FRAMES = 23;
final int JUMP_APEX_FRAME = 14;   // 第 14 帧为最高点（1-based）
// 最高点占整段跳跃的比例，用于算起跳提前量：jumpApexTimeSec = (60/bpm)*beatsForRemainingJump * JUMP_APEX_FRACTION
final float JUMP_APEX_FRACTION = (JUMP_APEX_FRAME - 1) / (float) JUMP_TOTAL_FRAMES;
// 仅用于 test.pde 等测试草图的跳跃帧率；主流程用 beat 时长
final float JUMP_FPS = 8;

// ==================== 三、背景（云、山、路边、地面） ====================

final String BACKGROUND_PATH = "../assets/background/background.png";
final float BACKGROUND_SCALE = 1.0;

// ---------- background.png 渐变（与 sky 配合完成转换） ----------
// 未到开始时间时，不透明度 = OPACITY_START；渐变结束后 = OPACITY_END
// 第几秒开始渐变（音乐时间）
final float BACKGROUND_FADE_START_SEC = 82.0f;
// 渐变持续时间（秒），越小变化越快
final float BACKGROUND_FADE_DURATION = 6.0f;
// 起始不透明度 0~1（0=完全透明，1=完全不透明）
final float BACKGROUND_OPACITY_START = 1.0f;   // 一开始背景完全可见
// 结束不透明度 0~1。 渐渐出现 = (0, 1)，渐渐消失 = (1, 0)
final float BACKGROUND_OPACITY_END = 0.0f;     // 最后背景消失，露出天空

// ---------- sky.png 渐变（与 background 配合完成转换） ----------
final String SKY_FILTER_PATH = "../assets/sky2.png";
// 第几秒开始渐变（可与 BACKGROUND_FADE_START_SEC 对齐）
final float SKY_FILTER_START_SEC = 80.0f;
// 渐变持续时间（秒）
final float SKY_FILTER_FADE_DURATION = 6.0f;
// 起始不透明度 0~1（未到开始时间时 = 此值）
final float SKY_FILTER_OPACITY_START = 0.0f;   // 一开始 sky 完全看不见
// 结束不透明度 0~1。 渐渐出现 = (0, 0.8)，渐渐消失 = (0.8, 0)
final float SKY_FILTER_OPACITY_END = 1f;     // 最后看到 sky（深蓝滤镜）

// 云（约 800 像素内同时 3～5 朵；可山前/山后，山前概率更高）
final String CLOUD_PATH_PREFIX = "../assets/cloud/cd";
final String CLOUD_PATH_SUFFIX = ".png";
final int CLOUD_COUNT = 5;
final int CLOUD_MIN_CLOUDS = 3;        // 800px 内最少朵数
final int CLOUD_MAX_CLOUDS = 5;       // 800px 内最多朵数
final float CLOUD_MIN_SCALE = 0.18;    // 显示缩放下限，改小更小
final float CLOUD_MAX_SCALE = 0.28;    // 显示缩放上限
final float CLOUD_MIN_Y = 50;
final float CLOUD_MAX_Y = 250;
// 云朵从左向右看是「从右向左」移动，单位 像素/秒；太小会像静止，太大则太快（FORGE_SPEED≈240 可作参考）
final float CLOUD_SPEED = 2;
final int CLOUD_ALPHA = 220;
final float CLOUD_LOAD_SCALE = 0.5;    // 加载时缩放，改小云图更小
final float CLOUD_OFFSCREEN_LEFT = 420;
final float CLOUD_MIN_GAP = 180;       // 朵间最小间隔（小一点可塞更多，如 3～5 朵/800px）
final float CLOUD_SPAWN_INTERVAL_MIN = 5.0;
final float CLOUD_SPAWN_INTERVAL_MAX = 11.0;
// 云在山前的概率 0~1（0.7 = 70% 山前、30% 山后）
final float CLOUD_IN_FRONT_OF_MOUNTAIN_PROB = 0.7f;
// 固定在山后的高层云：数量 1～2 朵，Y 更小=更靠上（像素）
final int CLOUD_HIGH_BACK_COUNT_MIN = 1;
final int CLOUD_HIGH_BACK_COUNT_MAX = 2;
final float CLOUD_HIGH_BACK_Y_MIN = 25.0f;
final float CLOUD_HIGH_BACK_Y_MAX = 95.0f;

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

// 柱子 zhuzi（与 flower/railing 同逻辑：FORGE_SPEED 无缝双块滚动，在花丛/栏杆后、山前）
final String ZHUZI_IMAGE_PATH = "../assets/zhuzi/zhuzi.png";
final float ZHUZI_SCALE = 1.4f;           // 显示缩放，细节可调
final float ZHUZI_BASE_Y = ROADSIDE_RAILING_BASE_Y-100;
final float ZHUZI_SPEED = FORGE_SPEED;
final int ZHUZI_MAX_TEXTURE_WIDTH = 2400;   // 加载时若图更宽则等比压缩，0 表示不压缩
// test_zhuzi 与栏杆对齐用
final int ZHUZI_ANCHOR_COUNT = 6;

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

// ==================== 六、金币红包（点击/按住倾泻的元宝·钱币·红包） ====================
// 【大小】MONEY_BASE_SCALE：粒子显示缩放，改小更小（如 0.05），改大更大（如 0.12）
// 【密度】MONEY_PARTICLE_COUNT：每次生成粒子个数，改小更稀疏（如 4），改大更密（如 12）
// 【密度】HOLD_SPAWN_INTERVAL（见下方「娱乐/Hold」）：按住时每批间隔，改大倾泻更慢/更稀
// 【扩散】MONEY_SPREAD_X/Y：生成时相对中心偏移范围；素材加载缩放见 MoneyEffect.pde 内 0.3
final String[] MONEY_PATHS = {
  "../assets/money/hb1.png",
  "../assets/money/hb2.png",
  "../assets/money/hb3.png",
  "../assets/money/hb4.png",
  "../assets/money/mn1.png",
  "../assets/money/yb1.png",
  "../assets/money/yb2.png"
};
final int MONEY_PARTICLE_COUNT = 6;
final float MONEY_SPREAD_X = 100;
final float MONEY_SPREAD_Y = 200;
final float MONEY_GRAVITY = 150.0;
final float MONEY_MIN_SPEED = 60.0;
final float MONEY_MAX_SPEED = 150.0;
final float MONEY_FADE_TIME = 3;
final float MONEY_BASE_SCALE = 0.06;

// ==================== 七、娱乐模式与起扬触发 ====================
final float QIYANG_TRIGGER_SECONDS_BEFORE_END = 5.0;

final String ENTERTAINMENT_CURSOR_PATH = "../assets/blessings/bag.png";
final float ENTERTAINMENT_CURSOR_SIZE = 36;
final String CURSOR_FINGER_PATH = "../assets/finger/finger.png";  // 替换默认鼠标图标
final float CURSOR_FINGER_SIZE = 20;
final float ENTERTAINMENT_SPAWN_STEP = 22;
// Hold 模式：按住鼠标时每隔多少秒在鼠标位置生成一批元宝/钱币/红包（越小倾泻越快）
final float HOLD_SPAWN_INTERVAL = 0.06;

// ==================== 八、输出目录 ====================
final String OUTPUT_BASE = "../output";
