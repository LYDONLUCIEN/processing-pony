// ==================== BlessingConfig.pde 祝福与精灵配置 ====================
//
// 目录（按需查找）：
//  一、时间轴 JSON 与进场
//  二、精灵素材（路径 / 帧数 / 播放 FPS·时长·每种精灵可调缩放）
//  三、精灵相对小马位置（马背·手袋·火箭）
//  四、颠簸（与跑动同频 + 幅度·随机性）
//  五、礼盒弹出
//  六、福袋
//  七、礼物盒
//  八、马到成功（手袋 + 鞭炮）
//  九、Getters（供代码调用，一般不用改）
//

// ==================== 一、时间轴 JSON 与进场 ====================
// 从 data/blessings_timeline.json 读取；福袋/石头/其它祝福时间在此定义

JSONObject timelineRoot = null;
String[] luckyBagTypes = { "money", "fu", "elephant" };
String[] stoneTexts = { "跨过坎坷", "跨过阻碍", "跨过了迷茫" };
String[] otherTypes = { "fly", "success", "daji" };

FloatList timelineHitTimes = new FloatList();

void loadBlessingsTimeline() {
  timelineRoot = loadJSONObject("data/blessings_timeline.json");
  timelineHitTimes.clear();
  if (timelineRoot == null) {
    println("WARN: blessings_timeline.json not found, using defaults");
    return;
  }
  if (timelineRoot.hasKey("stoneTexts")) {
    JSONArray arr = timelineRoot.getJSONArray("stoneTexts");
    stoneTexts = new String[arr.size()];
    for (int i = 0; i < arr.size(); i++) stoneTexts[i] = arr.getString(i);
  }
  if (timelineRoot.hasKey("luckyBags")) {
    JSONArray arr = timelineRoot.getJSONArray("luckyBags");
    for (int i = 0; i < arr.size(); i++) timelineHitTimes.append(arr.getJSONObject(i).getFloat("time"));
  }
  if (timelineRoot.hasKey("stones")) {
    JSONArray arr = timelineRoot.getJSONArray("stones");
    for (int i = 0; i < arr.size(); i++) timelineHitTimes.append(arr.getJSONObject(i).getFloat("time"));
  }
  timelineHitTimes.sort();
  FloatList unique = new FloatList();
  for (int i = 0; i < timelineHitTimes.size(); i++) {
    float v = timelineHitTimes.get(i);
    if (unique.size() == 0 || v != unique.get(unique.size() - 1)) unique.append(v);
  }
  timelineHitTimes = unique;
  println("Blessings timeline loaded. Stone texts: " + stoneTexts.length + ", hit times: " + timelineHitTimes.size());
}

// 进场提前量：素材从右侧到 PONY_X 所需时间，严格按 FORGE_SPEED 计算，保证 T 时刻到达 PONY_X
final float BLESSING_SPAWN_LEAD_MARGIN = 80;
float getBlessingSpawnLeadTime() {
  return (width + BLESSING_SPAWN_LEAD_MARGIN - PONY_X) / FORGE_SPEED;
}

// ==================== 二、精灵素材（路径 / 帧数 / 播放 FPS·时长·缩放） ====================
// 主流程与 test 共用；路径 = OUTPUT_BASE + "/" + PREFIX，后缀 = OUTPUT_FRAME_SUFFIX

final String OUTPUT_ELEPHANT_PREFIX = "elephant/elephant_";
final String OUTPUT_FUDAI_PREFIX = "fudai/fudai_";
final String OUTPUT_QIANDAI_PREFIX = "qiandai/qiandai_";
final String OUTPUT_ROCKET_PREFIX = "rocket/rocket_";
final String OUTPUT_SHOUDAI_PREFIX = "shoudai/shoudai_";
final String OUTPUT_FRAME_SUFFIX = ".png";

final int OUTPUT_ELEPHANT_COUNT = 88;
final int OUTPUT_FUDAI_COUNT = 22;
final int OUTPUT_QIANDAI_COUNT = 20;
final int OUTPUT_ROCKET_COUNT = 5;
final int OUTPUT_SHOUDAI_COUNT = 60;

// 播放：每种精灵可单独设 FPS、显示时长（秒）、缩放
final float BLESSING_SPRITE_FPS_ELEPHANT = 30;
final float BLESSING_SPRITE_FPS_MONEY   = 24;
final float BLESSING_SPRITE_FPS_FU      = 24;
final float BLESSING_SPRITE_DURATION_ELEPHANT = 3.6;
final float BLESSING_SPRITE_DURATION_MONEY   = 3.6;
final float BLESSING_SPRITE_DURATION_FU      = 3.6;
final float BLESSING_SPRITE_FPS = 24;
final float BLESSING_SPRITE_DURATION = 2.8;
final float BLESSING_SPRITE_SCALE = 0.5;   // 默认（未知 type 时用）

// 每种精灵可单独调缩放（马背顶出 / 马到成功手袋 / 马上起飞双火箭分别设）
final float BLESSING_SPRITE_SCALE_ELEPHANT = 0.36;
final float BLESSING_SPRITE_SCALE_MONEY   = 0.30;
final float BLESSING_SPRITE_SCALE_FU      = 0.45;
final float BLESSING_SHOUDAI_SCALE = 0.2;
final float BLESSING_ROCKET_SCALE_BEHIND = 0.5;   // 后侧火箭
final float BLESSING_ROCKET_SCALE_FRONT  = 0.52;   // 前侧火箭

// 测试用马背颠簸幅度（runCycleProgress 驱动）
final float BOB_RUN_CYCLE_AMPLITUDE = 4.0;
final float BOB_RUN_CYCLE_RANDOMNESS = 1.0;

// ==================== 三、精灵相对小马位置 (PONY_X, PONY_Y) ====================
// 小马中心在 AnimationConfig：PONY_X = 400, PONY_Y = 380

// 马背上精灵（顶出后落点）：elephant / 钱袋 / 福袋
final float BLESSING_PONY_OFFSET_ELEPHANT_X = -33;
final float BLESSING_PONY_OFFSET_ELEPHANT_Y = -10;
final float BLESSING_PONY_OFFSET_MONEY_X = -33;
final float BLESSING_PONY_OFFSET_MONEY_Y = -17;
final float BLESSING_PONY_OFFSET_FU_X = -33;
final float BLESSING_PONY_OFFSET_FU_Y = -8;

// 手袋（马到成功）
final float SHOUDAI_OFFSET_X = 0;
final float SHOUDAI_OFFSET_Y = -40;

// 火箭（马上起飞，双枚）：位置相对 (PONY_X, PONY_Y)，高度与缩放分别可调
final float ROCKET_OFFSET_BEHIND_X = -50;
final float ROCKET_OFFSET_FRONT_X = -65;
final float ROCKET_BEHIND_Y = 20;   // 后侧火箭 Y 偏移（PONY_Y + 此值）
final float ROCKET_FRONT_Y  = 22;   // 前侧火箭 Y 偏移（PONY_Y + 此值）

// ==================== 四、颠簸（与跑动同频 + 幅度·随机性） ====================
// 频率由公式统一：主流程 BPM/60，测试 RUN_FPS/RUN_FRAMES

float getRunCycleFrequencyHz() {
  if (TEST_MODE) return RUN_FPS / (float) RUN_FRAMES;
  return BPM / 60.0;
}

final float BOB_AMPLITUDE_ELEPHANT = 4.0;
final float BOB_RANDOMNESS_ELEPHANT = 1.5;
final float BOB_AMPLITUDE_MONEY = 3.5;
final float BOB_RANDOMNESS_MONEY = 1.0;
final float BOB_AMPLITUDE_FU = 3.5;
final float BOB_RANDOMNESS_FU = 1.0;
final float BOB_AMPLITUDE_FLY = 5.0;
final float BOB_RANDOMNESS_FLY = 2.0;

// ==================== 五、礼盒弹出与渐隐 ====================
// 从盒子掉落到马背：抛物线弧高（像素，正=弧向上）、时长、起始缩放（小点更明显）
final float BLESSING_POP_OUT_ARC_HEIGHT = 120;   // 抛物线弧高，0=直线
final float BLESSING_POP_OUT_START_SCALE = 0.06; // 起始很小，慢慢变大
final float BLESSING_POP_OUT_DURATION = 1.0;     // 掉落时长（秒），加长更顺
// 精灵（elephant/fudai/qiandai 等）结束前渐隐时长（秒）
final float BLESSING_SPRITE_FADE_DURATION = 0.6;
// 礼盒盖/盒身飞出去后，移除前渐隐时长（秒）
final float GIFT_BOX_FADE_DURATION = 0.5;

// ==================== 六、福袋 ====================
final String LUCKY_BAG_IMAGE_PATH = "../assets/blessings/bag.png";
final float LUCKY_BAG_STRING_LENGTH_MIN = 60;
final float LUCKY_BAG_STRING_LENGTH_MAX = 100;
final float LUCKY_BAG_SPEED = FORGE_SPEED;
final float LUCKY_BAG_SCALE = 0.12;
final float LUCKY_BAG_ANCHOR_Y = 120;
final float LUCKY_BAG_FLY_UP_VY = -320;
final float LUCKY_BAG_FLY_UP_VX_RANDOM = 80;
final float LUCKY_BAG_GLOW_DURATION = 0.4;
final float LUCKY_BAG_GLOW_RADIUS = 80;
final float LUCKY_BAG_STRING_RETRACT_SPEED = 400;
final float LUCKY_BAG_HIT_RADIUS = 55;

// ==================== 七、礼物盒（盖+盒身，吊在空中微动，被顶后旋转飞出） ====================
//
// ---------- 盒盖(head) 与 盒身(body) 位置关系（调这些即可） ----------
//  ・盒身中心：(boxX, boxCenterY)，其中 boxCenterY = anchorY + stringLength（悬挂时加 bob）
//  ・盒盖中心：(boxX, boxCenterY + GIFT_BOX_LID_Y_OFFSET)
//  ・GIFT_BOX_LID_Y_OFFSET：盖相对盒身中心的 Y 偏移。负值=盖在盒身上方，正值=盖在盒身下方
//  ・GIFT_BOX_LID_OFFSET_X：盖相对盒身中心的 X 偏移。正=盖在盒身右侧，负=左侧，0=对齐
//  ・GIFT_BOX_SCALE：盖和盒身共用，整体缩放
//  ・GIFT_BOX_APEX_Y_RAISE：礼盒整体相对小马头顶最高点的 Y 偏移（负=更高，正=更低）
//  ・GIFT_BOX_STRING_LENGTH_MIN/MAX：绳长随机范围，影响 boxCenterY 的基准
//
final boolean USE_GIFT_BOX = true;
final String GIFT_BOX_HEAD_PATH = "../assets/blessings/box_head.png";
final String GIFT_BOX_BODY_PATH = "../assets/blessings/box_body.png";

final float GIFT_BOX_STRING_LENGTH_MIN = 50;
final float GIFT_BOX_STRING_LENGTH_MAX = 90;
final float GIFT_BOX_SPEED = FORGE_SPEED;
final float GIFT_BOX_SCALE = 0.3;
// 礼盒整体 Y 偏移：礼盒中心 Y = getPonyHeadApexY() + 此值（负=更高）
final float GIFT_BOX_APEX_Y_RAISE = 0;
// 旧固定锚点（仅 test 等用）；主流程用 getPonyHeadApexY() + GIFT_BOX_APEX_Y_RAISE - stringLen
final float GIFT_BOX_ANCHOR_Y_FALLBACK = 120;
final float GIFT_BOX_ANCHOR_Y = GIFT_BOX_ANCHOR_Y_FALLBACK;
final float GIFT_BOX_HIT_RADIUS = 55;
// 盖子相对盒身中心的 Y 偏移（负值=盖在盒身上方，如 -18 表示盖在盒身上方 18 像素）
final float GIFT_BOX_LID_Y_OFFSET = -18;
// 盖子相对盒身中心的 X 偏移（正=盖在盒身右侧，负=左侧，0=对齐）
final float GIFT_BOX_LID_OFFSET_X = 5;

final float GIFT_BOX_BOB_AMPLITUDE = 8;
final float GIFT_BOX_BOB_SPEED = 0.6;

final float GIFT_BOX_LID_VY = -280;
final float GIFT_BOX_LID_VX_MIN = 60;
final float GIFT_BOX_LID_VX_MAX = 120;
final float GIFT_BOX_BODY_VY = -220;
final float GIFT_BOX_BODY_VX_MIN = 60;
final float GIFT_BOX_BODY_VX_MAX = 120;
final float GIFT_BOX_GRAVITY = 320;
final float GIFT_BOX_LID_OMEGA = 9;
final float GIFT_BOX_BODY_OMEGA = 7;

final float GIFT_BOX_GLOW_DURATION = 0.35;
final float GIFT_BOX_GLOW_RADIUS = 70;
final float GIFT_BOX_FLY_DURATION_MAX = 3.6;
final float GIFT_BOX_OFFSCREEN_MARGIN = 100;
final float GIFT_BOX_PHRASE_Y_OFFSET = -60;
final float GIFT_BOX_SPRITE_Y_OFFSET = -40;

// ==================== 八、马到成功（绶带 + 手袋 + 鞭炮簇） ====================
//
// ---------- SHOUDAI 绶带相关参数一览（调这些即可） ----------
// 【大小】SHOUDAI_RIBBON_SCALE：整体缩放（不压缩、保持图片比例，仅此一项即可）
// 【动画】SHOUDAI_RIBBON_FPS：播帧帧率；OUTPUT_SHOUDAI_COUNT（本文件上方）= 60 帧
// 【旋转】SHOUDAI_RIBBON_ANGLE_DEG：度，正=顺时针，负=逆时针，0=不旋转
// 【位置】SHOUDAI_RIBBON_BASE_Y：绶带垂直位置（像素，越大越靠下）
// 【位置】SHOUDAI_RIBBON_OFFSET_X / OFFSET_Y：在基准上的 X、Y 微调
// 【生成】SHOUDAI_RIBBON_SPAWN_MARGIN：从屏幕右缘外多少像素开始出现
// 【碰撞】SHOUDAI_HIT_OFFSET_X：相对 PONY_CHEST 的 X，正=更靠右才触发；HIT_OFFSET_Y 预留
// 【其它】SHOUDAI_DURATION_BEFORE_QIYANG、BLESSING_SUCCESS_FIRECRACKER_BURST_COUNT 等见下方
//
// 绶带：从右向左以 FORGE_SPEED 运动，碰到小马胸口时触发马到成功（不压缩、保持比例，只调 SCALE）
final float SHOUDAI_RIBBON_SCALE = 0.5f;
// 播帧帧率：改大动画更顺（如 30），改小更省性能
final float SHOUDAI_RIBBON_FPS = 30;
// 旋转角度（度）：正数=顺时针，负数=逆时针，0=不旋转
final float SHOUDAI_RIBBON_ANGLE_DEG = 25f;
// 帧数由 OUTPUT_SHOUDAI_COUNT（本文件上方）决定，共 60 帧
//
final float SHOUDAI_RIBBON_SPAWN_MARGIN = 80;   // 绶带从屏幕右侧外多少像素处生成
// ---------- 绶带位置（相对偏移，便于微调） ----------
// 绶带基准 Y（像素，越大越靠下）；最终 Y = BASE_Y + OFFSET_Y
final float SHOUDAI_RIBBON_BASE_Y = 460;
final float SHOUDAI_RIBBON_OFFSET_X = 0;  // 绶带生成/运动起点 X 的偏移（0=用 SPAWN_MARGIN）
final float SHOUDAI_RIBBON_OFFSET_Y = 0;  // 绶带 Y 的偏移（0=用 BASE_Y）
// ---------- 绶带与 PONY_CHEST 的碰撞点（相对胸口） ----------
// 碰撞判定：绶带中心 X 到达 (PONY_CHEST_X + HIT_OFFSET_X) 时触发；Y 暂未参与判定
final float SHOUDAI_HIT_OFFSET_X = 30;  // 相对 PONY_CHEST 的 X 偏移（正=更靠右才触发）
final float SHOUDAI_HIT_OFFSET_Y = 40;  // 相对 PONY_CHEST 的 Y 偏移（预留）
// 马到成功触发后，手袋播放 X 秒再触发起扬（马儿奔跑 → 绶带碰胸口 → 手袋播 X 秒 → 起扬）
final float SHOUDAI_DURATION_BEFORE_QIYANG = 5.0f;
final int BLESSING_SUCCESS_FIRECRACKER_BURST_COUNT = 3;
// 烟花：在 success（马到成功）触发前 N 秒开始放，之后持续到关闭
final float FIREWORK_SUCCESS_LEAD_SEC = 3.0f;
final float FIREWORK_SUCCESS_SPAWN_INTERVAL = 1.2f;

// ==================== 九、马年大吉（手袋持续播放 + 烟花） ====================
final float BLESSING_DAJI_SHOUDAI_DURATION = 8.0;   // 大吉时手袋播放时长（秒）
final int BLESSING_DAJI_FIREWORK_COUNT = 5;         // 大吉时连续发射烟花数量
// 烟花（Processing 绘制）：从画面下方发射，在天空 Y 50~200 爆炸
final float FIREWORK_EXPLODE_Y_MIN = 50;
final float FIREWORK_EXPLODE_Y_MAX = 200;
final float FIREWORK_RISE_SPEED = 420;
final int FIREWORK_PARTICLE_COUNT = 120;   // 粒子更多、更集中
final float FIREWORK_PARTICLE_FADE_TIME = 1.2;
final float FIREWORK_PARTICLE_SPEED = 90;  // 速度降低，爆炸更集中
// 粒子更小（像素）
final float FIREWORK_PARTICLE_SIZE_MIN = 1.2f;
final float FIREWORK_PARTICLE_SIZE_MAX = 2.8f;
// 爆炸音效（空串表示不播放）；路径相对 sketch 或绝对
final String FIREWORK_EXPLODE_SOUND_PATH = "../assets/sound/explosion.wav";

// ==================== 十、Getters（代码用，一般不用改） ====================

String getBlessingPhrase(String type) {
  if (type.equals("money")) return "马上有钱";
  if (type.equals("fu")) return "马上有福";
  if (type.equals("elephant")) return "马上有对象";
  if (type.equals("fly")) return "马上起飞";
  if (type.equals("success")) return "马到成功";
  if (type.equals("daji")) return "马年大吉";
  return "马年大吉";
}

// 祝福语旁图标：使用 output 目录下对应序列的第一帧（与精灵动画同源）
String getBlessingAssetPath(String type) {
  String base = OUTPUT_BASE;
  String suf = OUTPUT_FRAME_SUFFIX;
  if (type.equals("money")) return base + "/" + OUTPUT_QIANDAI_PREFIX + "00" + suf;
  if (type.equals("fu")) return base + "/" + OUTPUT_FUDAI_PREFIX + "00" + suf;
  if (type.equals("elephant")) return base + "/" + OUTPUT_ELEPHANT_PREFIX + "00" + suf;
  if (type.equals("fly")) return base + "/" + OUTPUT_ROCKET_PREFIX + "00" + suf;
  if (type.equals("success")) return base + "/" + OUTPUT_SHOUDAI_PREFIX + "00" + suf;
  if (type.equals("daji")) return base + "/" + OUTPUT_SHOUDAI_PREFIX + "00" + suf;
  return "";
}

String getStonePhrase(int index) {
  if (index >= 0 && index < stoneTexts.length) return stoneTexts[index];
  return stoneTexts[0];
}

JSONArray getTimelineLuckyBags() {
  if (timelineRoot != null && timelineRoot.hasKey("luckyBags"))
    return timelineRoot.getJSONArray("luckyBags");
  return new JSONArray();
}

JSONArray getTimelineStones() {
  if (timelineRoot != null && timelineRoot.hasKey("stones"))
    return timelineRoot.getJSONArray("stones");
  return new JSONArray();
}

int getTimelineHitTimeCount() { return timelineHitTimes.size(); }
float getTimelineHitTime(int i) { return timelineHitTimes.get(i); }

JSONArray getTimelineOtherAnimations() {
  if (timelineRoot != null && timelineRoot.hasKey("otherAnimations"))
    return timelineRoot.getJSONArray("otherAnimations");
  return new JSONArray();
}

float getTimelineStoneTextInterval() {
  if (timelineRoot != null && timelineRoot.hasKey("stoneTextInterval"))
    return timelineRoot.getFloat("stoneTextInterval");
  return 6.0;
}

float getTimelineQiyangTime() {
  if (timelineRoot != null && timelineRoot.hasKey("qiyangTime"))
    return timelineRoot.getFloat("qiyangTime");
  return 99999.0;
}

// 马到成功（success）事件在时间轴上的时刻；无则返回 99999
float getTimelineSuccessTime() {
  if (timelineRoot == null || !timelineRoot.hasKey("otherAnimations")) return 99999.0;
  JSONArray arr = timelineRoot.getJSONArray("otherAnimations");
  for (int i = 0; i < arr.size(); i++) {
    JSONObject ev = arr.getJSONObject(i);
    if (ev.getString("type").equals("success")) return ev.getFloat("time");
  }
  return 99999.0;
}

// 绶带从生成点到碰撞点所需时间（successTime 时绶带中心恰好到达碰撞点）
float getShoudaiRibbonLeadTime() {
  float startX = width + SHOUDAI_RIBBON_SPAWN_MARGIN + SHOUDAI_RIBBON_OFFSET_X;
  float hitX = PONY_X + PONY_CHEST_OFFSET_X + SHOUDAI_HIT_OFFSET_X;
  return (startX - hitX) / FORGE_SPEED;
}

float getBlessingBobSpeed(String type) { return getRunCycleFrequencyHz(); }

float getBlessingBobAmplitude(String type) {
  if (type.equals("elephant")) return BOB_AMPLITUDE_ELEPHANT;
  if (type.equals("money") || type.equals("qiandai")) return BOB_AMPLITUDE_MONEY;
  if (type.equals("fu") || type.equals("fudai")) return BOB_AMPLITUDE_FU;
  if (type.equals("fly")) return BOB_AMPLITUDE_FLY;
  return 4.0;
}

float getBlessingBobRandomness(String type) {
  if (type.equals("elephant")) return BOB_RANDOMNESS_ELEPHANT;
  if (type.equals("money") || type.equals("qiandai")) return BOB_RANDOMNESS_MONEY;
  if (type.equals("fu") || type.equals("fudai")) return BOB_RANDOMNESS_FU;
  if (type.equals("fly")) return BOB_RANDOMNESS_FLY;
  return 1.0;
}

float getBlessingSpriteFPS(String type) {
  if (type.equals("elephant")) return BLESSING_SPRITE_FPS_ELEPHANT;
  if (type.equals("money") || type.equals("qiandai")) return BLESSING_SPRITE_FPS_MONEY;
  if (type.equals("fu") || type.equals("fudai")) return BLESSING_SPRITE_FPS_FU;
  return 24;
}

float getBlessingSpriteDuration(String type) {
  if (type.equals("elephant")) return BLESSING_SPRITE_DURATION_ELEPHANT;
  if (type.equals("money") || type.equals("qiandai")) return BLESSING_SPRITE_DURATION_MONEY;
  if (type.equals("fu") || type.equals("fudai")) return BLESSING_SPRITE_DURATION_FU;
  return 2.8;
}

float getBlessingPonyOffsetX(String type) {
  if (type.equals("elephant")) return BLESSING_PONY_OFFSET_ELEPHANT_X;
  if (type.equals("money") || type.equals("qiandai")) return BLESSING_PONY_OFFSET_MONEY_X;
  if (type.equals("fu") || type.equals("fudai")) return BLESSING_PONY_OFFSET_FU_X;
  return 0;
}

float getBlessingPonyOffsetY(String type) {
  if (type.equals("elephant")) return BLESSING_PONY_OFFSET_ELEPHANT_Y;
  if (type.equals("money") || type.equals("qiandai")) return BLESSING_PONY_OFFSET_MONEY_Y;
  if (type.equals("fu") || type.equals("fudai")) return BLESSING_PONY_OFFSET_FU_Y;
  return -50;
}

float getBlessingSpriteScale(String type) {
  if (type.equals("elephant")) return BLESSING_SPRITE_SCALE_ELEPHANT;
  if (type.equals("money") || type.equals("qiandai")) return BLESSING_SPRITE_SCALE_MONEY;
  if (type.equals("fu") || type.equals("fudai")) return BLESSING_SPRITE_SCALE_FU;
  if (type.equals("shoudai") || type.equals("success") || type.equals("daji")) return BLESSING_SHOUDAI_SCALE;
  if (type.equals("fly") || type.equals("rocket")) return BLESSING_ROCKET_SCALE_BEHIND;
  if (type.equals("fly_back")) return BLESSING_ROCKET_SCALE_BEHIND;
  if (type.equals("fly_front")) return BLESSING_ROCKET_SCALE_FRONT;
  return BLESSING_SPRITE_SCALE;
}
