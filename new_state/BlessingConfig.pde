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
String[] otherTypes = { "fly", "success", "jiji" };

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

// 进场提前量：素材从右侧到 PONY_X 所需时间（由 FORGE_SPEED、PONY_X 算）
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
final float BLESSING_SHOUDAI_SCALE = 0.9;
final float BLESSING_ROCKET_SCALE_BEHIND = 0.4;   // 后侧火箭
final float BLESSING_ROCKET_SCALE_FRONT  = 0.4;   // 前侧火箭

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

// ==================== 五、礼盒弹出（从礼盒飞到马背） ====================
final float BLESSING_POP_OUT_START_SCALE = 0.08;
final float BLESSING_POP_OUT_DURATION = 0.5;

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
final boolean USE_GIFT_BOX = true;
final String GIFT_BOX_HEAD_PATH = "../assets/blessings/box_head.png";
final String GIFT_BOX_BODY_PATH = "../assets/blessings/box_body.png";

final float GIFT_BOX_STRING_LENGTH_MIN = 50;
final float GIFT_BOX_STRING_LENGTH_MAX = 90;
final float GIFT_BOX_SPEED = FORGE_SPEED;
final float GIFT_BOX_SCALE = 0.3;
final float GIFT_BOX_ANCHOR_Y = 120;
final float GIFT_BOX_HIT_RADIUS = 55;

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
final float GIFT_BOX_FLY_DURATION_MAX = 2.5;
final float GIFT_BOX_OFFSCREEN_MARGIN = 100;
final float GIFT_BOX_PHRASE_Y_OFFSET = -60;
final float GIFT_BOX_SPRITE_Y_OFFSET = -40;

// ==================== 八、马到成功（手袋 + 鞭炮簇） ====================
final int BLESSING_SUCCESS_FIRECRACKER_BURST_COUNT = 3;

// ==================== 九、Getters（代码用，一般不用改） ====================

String getBlessingPhrase(String type) {
  if (type.equals("money")) return "马上有钱";
  if (type.equals("fu")) return "马上有福";
  if (type.equals("elephant")) return "马上有对象";
  if (type.equals("fly")) return "马上起飞";
  if (type.equals("success")) return "马到成功";
  if (type.equals("jiji")) return "马年大吉";
  return "马年大吉";
}

String getBlessingAssetPath(String type) {
  if (type.equals("money")) return "../assets/blessings/money.png";
  if (type.equals("fu")) return "../assets/blessings/fu.png";
  if (type.equals("elephant")) return "../assets/blessings/elephant.png";
  if (type.equals("fly")) return "../assets/blessings/fly.png";
  if (type.equals("success")) return "../assets/blessings/success.png";
  if (type.equals("jiji")) return "../assets/blessings/jiji.png";
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

float getTimelineLuckyBagSpawnInterval() {
  if (timelineRoot != null && timelineRoot.hasKey("luckyBagSpawnInterval"))
    return timelineRoot.getFloat("luckyBagSpawnInterval");
  return 9.0;
}

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
  if (type.equals("shoudai") || type.equals("success")) return BLESSING_SHOUDAI_SCALE;
  if (type.equals("fly") || type.equals("rocket")) return BLESSING_ROCKET_SCALE_BEHIND;
  return BLESSING_SPRITE_SCALE;
}
