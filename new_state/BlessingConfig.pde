// ==================== 祝福时间轴与福袋配置 ====================
// 从 data/blessings_timeline.json 读取时间轴；福袋/字/石头配对在此定义

JSONObject timelineRoot = null;
String[] luckyBagTypes = { "money", "fu", "elephant" };
String[] stoneTexts = { "跨过坎坷", "跨过阻碍", "跨过了迷茫" };
String[] otherTypes = { "fly", "success", "jiji" };

// 类型 → 四字祝福（福袋顶出）
String getBlessingPhrase(String type) {
  if (type.equals("money")) return "马上有钱";
  if (type.equals("fu")) return "马上有福";
  if (type.equals("elephant")) return "马上有对象";
  if (type.equals("fly")) return "马上起飞";
  if (type.equals("success")) return "马到成功";
  if (type.equals("jiji")) return "马年大吉";
  return "马年大吉";
}

// 类型 → 配套素材路径（福袋三类 + 其它三类）
String getBlessingAssetPath(String type) {
  if (type.equals("money")) return "../assets/blessings/money.png";
  if (type.equals("fu")) return "../assets/blessings/fu.png";
  if (type.equals("elephant")) return "../assets/blessings/elephant.png";
  if (type.equals("fly")) return "../assets/blessings/fly.png";
  if (type.equals("success")) return "../assets/blessings/success.png";
  if (type.equals("jiji")) return "../assets/blessings/jiji.png";
  return "";
}

// 石头文案索引 → 四字
String getStonePhrase(int index) {
  if (index >= 0 && index < stoneTexts.length) return stoneTexts[index];
  return stoneTexts[0];
}

void loadBlessingsTimeline() {
  timelineRoot = loadJSONObject("data/blessings_timeline.json");
  if (timelineRoot == null) {
    println("WARN: blessings_timeline.json not found, using defaults");
    return;
  }
  if (timelineRoot.hasKey("stoneTexts")) {
    JSONArray arr = timelineRoot.getJSONArray("stoneTexts");
    stoneTexts = new String[arr.size()];
    for (int i = 0; i < arr.size(); i++) stoneTexts[i] = arr.getString(i);
  }
  println("Blessings timeline loaded. Stone texts: " + stoneTexts.length);
}

JSONArray getTimelineLuckyBags() {
  if (timelineRoot != null && timelineRoot.hasKey("luckyBags"))
    return timelineRoot.getJSONArray("luckyBags");
  return new JSONArray();
}

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

// 起扬动作触发时间（音乐秒），到达后在下一次 run 过渡帧切到起扬；缺省或很大则不起扬
float getTimelineQiyangTime() {
  if (timelineRoot != null && timelineRoot.hasKey("qiyangTime"))
    return timelineRoot.getFloat("qiyangTime");
  return 99999.0;
}

// ==================== 福袋动画参数（可调） ====================
final String LUCKY_BAG_IMAGE_PATH = "../assets/blessings/bag.png";
final float LUCKY_BAG_STRING_LENGTH_MIN = 60;
final float LUCKY_BAG_STRING_LENGTH_MAX = 100;
final float LUCKY_BAG_SPEED = 180;
final float LUCKY_BAG_SCALE = 0.12;
final float LUCKY_BAG_ANCHOR_Y = 120;
final float LUCKY_BAG_FLY_UP_VY = -320;
final float LUCKY_BAG_FLY_UP_VX_RANDOM = 80;
final float LUCKY_BAG_GLOW_DURATION = 0.4;
final float LUCKY_BAG_GLOW_RADIUS = 80;
final float LUCKY_BAG_STRING_RETRACT_SPEED = 400;
final float LUCKY_BAG_HIT_RADIUS = 55;
