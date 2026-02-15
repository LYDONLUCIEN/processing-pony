// ==================== 福袋管理器 ====================
// 按时间轴生成福袋，检测小马头顶碰撞，触发顶飞 + 字弹出

class LuckyBagManager {
  ArrayList<LuckyBag> bags;
  PImage bagImage;
  int nextTimelineIndex;
  float lastSpawnTime;
  float spawnInterval;

  LuckyBagManager() {
    bags = new ArrayList<LuckyBag>();
    bagImage = loadImage(LUCKY_BAG_IMAGE_PATH);
    if (bagImage != null && bagImage.width > 400) {
      int w = 400;
      int h = (int)((float)bagImage.height * w / bagImage.width);
      bagImage.resize(w, h);
    }
    nextTimelineIndex = 0;
    lastSpawnTime = -999;
    spawnInterval = getTimelineLuckyBagSpawnInterval();
  }

  void update(float dt, float musicTime, float ponyHeadX, float ponyHeadY, boolean ponyIsJumping) {
    if (backgroundFrozen) return;
    spawnFromTimeline(musicTime);

    for (int i = bags.size() - 1; i >= 0; i--) {
      LuckyBag bag = bags.get(i);
      bag.update(dt);

      if (ponyIsJumping && bag.collidesWith(ponyHeadX, ponyHeadY)) {
        bag.onHit(ponyHeadX, ponyHeadY);
        String phrase = getBlessingPhrase(bag.getType());
        PImage asset = loadBlessingAsset(bag.getType());
        spawnBouncyWord(phrase, bag.getBagX(), bag.getBagY() - 60, asset);
        println("[Blessing] Hit lucky bag: " + bag.getType() + " -> " + phrase);
      }

      if (bag.isDone()) bags.remove(i);
    }
  }

  void spawnFromTimeline(float musicTime) {
    JSONArray arr = getTimelineLuckyBags();
    while (nextTimelineIndex < arr.size()) {
      JSONObject ev = arr.getJSONObject(nextTimelineIndex);
      float t = ev.getFloat("time");
      if (musicTime < t) break;
      String type = ev.getString("type");
      spawnBag(type);
      nextTimelineIndex++;
    }
  }

  void spawnBag(String type) {
    if (bagImage == null) return;
    float stringLen = random(LUCKY_BAG_STRING_LENGTH_MIN, LUCKY_BAG_STRING_LENGTH_MAX);
    float anchorY = LUCKY_BAG_ANCHOR_Y;
    float startX = width + 80;
    LuckyBag bag = new LuckyBag(bagImage, startX, anchorY, stringLen, LUCKY_BAG_SPEED, LUCKY_BAG_SCALE, type);
    bags.add(bag);
  }

  void display() {
    for (LuckyBag bag : bags) bag.display();
  }

  int getCount() { return bags.size(); }
}

PImage loadBlessingAsset(String type) {
  String path = getBlessingAssetPath(type);
  if (path == null || path.length() == 0) return null;
  PImage img = loadImage(path);
  if (img != null && img.width > 200) {
    int w = 200;
    int h = (int)((float)img.height * w / img.width);
    img.resize(w, h);
  }
  return img;
}
