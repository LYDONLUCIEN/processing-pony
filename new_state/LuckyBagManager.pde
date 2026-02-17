// ==================== 福袋/礼物盒管理器 ====================
// 按时间轴生成，检测小马头顶碰撞，触发顶飞/分离 + 字与精灵弹出

class LuckyBagManager {
  ArrayList<LuckyBag> bags;
  ArrayList<GiftBox> giftBoxes;
  PImage bagImage;
  PImage boxHeadImage;
  PImage boxBodyImage;
  int nextTimelineIndex;

  LuckyBagManager() {
    bags = new ArrayList<LuckyBag>();
    giftBoxes = new ArrayList<GiftBox>();
    bagImage = loadImage(LUCKY_BAG_IMAGE_PATH);
    if (bagImage != null && bagImage.width > 400) {
      int w = 400;
      int h = (int)((float)bagImage.height * w / bagImage.width);
      bagImage.resize(w, h);
    }
    if (USE_GIFT_BOX) {
      boxHeadImage = loadImage(GIFT_BOX_HEAD_PATH);
      boxBodyImage = loadImage(GIFT_BOX_BODY_PATH);
      if (boxHeadImage != null && boxHeadImage.width > 400) {
        int w = 400;
        int h = (int)((float)boxHeadImage.height * w / boxHeadImage.width);
        boxHeadImage.resize(w, h);
      }
      if (boxBodyImage != null && boxBodyImage.width > 400) {
        int w = 400;
        int h = (int)((float)boxBodyImage.height * w / boxBodyImage.width);
        boxBodyImage.resize(w, h);
      }
    }
    nextTimelineIndex = 0;
  }

  void resetForRestart() {
    bags.clear();
    giftBoxes.clear();
    nextTimelineIndex = 0;
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
        spawnBouncyWord(phrase, bag.getBagX(), bag.getBagY() - 60, null);
        spawnBlessingSprite(bag.getType(), bag.getBagX(), bag.getBagY() - 40);
        println("[Blessing] Hit lucky bag: " + bag.getType() + " -> " + phrase);
      }
      if (bag.isDone()) bags.remove(i);
    }

    for (int i = giftBoxes.size() - 1; i >= 0; i--) {
      GiftBox box = giftBoxes.get(i);
      box.update(dt);
      if (ponyIsJumping && box.collidesWith(ponyHeadX, ponyHeadY)) {
        box.onHit(ponyHeadX, ponyHeadY);
        String phrase = getBlessingPhrase(box.getType());
        spawnBouncyWord(phrase, box.getBagX(), box.getBagY() + GIFT_BOX_PHRASE_Y_OFFSET, null);
        if (box.getType().equals("fly")) {
          spawnFlyRocketsAtPony();
        } else {
          spawnBlessingSpriteFromBox(box.getType(), box.getBagX(), box.getBagY());
        }
        println("[Blessing] Hit gift box: " + box.getType() + " -> " + phrase);
      }
      if (box.isDone()) giftBoxes.remove(i);
    }
  }

  void spawnFromTimeline(float musicTime) {
    JSONArray arr = getTimelineLuckyBags();
    float leadTime = getBlessingSpawnLeadTime();
    // 撞击时刻 T 礼盒/福袋应到达「头顶位置」X = PONY_X + PONY_HEAD_APEX_OFFSET_X，不是 PONY_X
    float hitX = PONY_X + PONY_HEAD_APEX_OFFSET_X;
    while (nextTimelineIndex < arr.size()) {
      JSONObject ev = arr.getJSONObject(nextTimelineIndex);
      float t = ev.getFloat("time");
      if (musicTime < t - leadTime) break;
      if (t - musicTime < 0) {
        nextTimelineIndex++;
        continue;
      }
      String type = ev.getString("type");
      float startX = hitX + FORGE_SPEED * (t - musicTime);
      if (USE_GIFT_BOX) spawnGiftBox(type, startX);
      else spawnBag(type, startX);
      nextTimelineIndex++;
    }
  }

  void spawnBag(String type, float startX) {
    if (bagImage == null) return;
    float stringLen = random(LUCKY_BAG_STRING_LENGTH_MIN, LUCKY_BAG_STRING_LENGTH_MAX);
    float anchorY = LUCKY_BAG_ANCHOR_Y;
    LuckyBag bag = new LuckyBag(bagImage, startX, anchorY, stringLen, LUCKY_BAG_SPEED, LUCKY_BAG_SCALE, type);
    bags.add(bag);
  }

  void spawnGiftBox(String type, float startX) {
    if (boxHeadImage == null || boxBodyImage == null) return;
    float stringLen = random(GIFT_BOX_STRING_LENGTH_MIN, GIFT_BOX_STRING_LENGTH_MAX);
    // 礼盒中心 Y = 头顶最高点 getPonyHeadApexY() + 调高偏移 GIFT_BOX_APEX_Y_RAISE（负值=更高）
    float anchorY = getPonyHeadApexY() + GIFT_BOX_APEX_Y_RAISE - stringLen;
    GiftBox box = new GiftBox(boxHeadImage, boxBodyImage, startX, anchorY, stringLen, GIFT_BOX_SPEED, GIFT_BOX_SCALE, type);
    giftBoxes.add(box);
  }

  void display() {
    for (LuckyBag bag : bags) bag.display();
    for (GiftBox box : giftBoxes) box.display();
  }

  int getCount() { return bags.size() + giftBoxes.size(); }
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
