// ==================== test_firework：烟花测试 ====================
// 在 new_state.pde 中将 TEST_FIREWORK 设为 true 后运行，用于调试爆炸音效与粒子动画。
// 空格 / 鼠标左键 = 发射一发；B = 连发 5 发。粒子参数在 BlessingConfig.pde 可调。

FireworkManager testFireworkManager;
SoundFile testExplosionSound;

void testFireworkSetup() {
  testFireworkManager = new FireworkManager();
  testExplosionSound = null;
  if (FIREWORK_EXPLODE_SOUND_PATH != null && FIREWORK_EXPLODE_SOUND_PATH.length() > 0) {
    testExplosionSound = new SoundFile(this, FIREWORK_EXPLODE_SOUND_PATH);
    if (testExplosionSound != null) {
      testFireworkManager.setExplosionSound(testExplosionSound);
      println("[test_firework] 爆炸音效已加载: " + FIREWORK_EXPLODE_SOUND_PATH);
    } else {
      println("[test_firework] 音效加载失败: " + FIREWORK_EXPLODE_SOUND_PATH + "，请放置文件后重试");
    }
  } else {
    println("[test_firework] 未配置 FIREWORK_EXPLODE_SOUND_PATH，不播放音效");
  }
  prevMillis = millis();
  println("[test_firework] 空格/左键=一发 | B=连发5发 | 粒子参数见 BlessingConfig");
}

void testFireworkDraw() {
  int currMillis = millis();
  float dt = (currMillis - prevMillis) / 1000.0;
  if (dt > 0.2) dt = 0.016f;
  prevMillis = currMillis;

  background(20, 20, 45);
  if (testFireworkManager != null) {
    testFireworkManager.update(dt);
    testFireworkManager.display();
  }

  fill(255);
  noStroke();
  textSize(14);
  textAlign(LEFT, TOP);
  text("TEST FIREWORK — 空格/左键=发射一发 | B=连发5发", 10, 10);
  text("粒子: COUNT=" + FIREWORK_PARTICLE_COUNT + " FADE=" + nf(FIREWORK_PARTICLE_FADE_TIME, 0, 1) + "s SPEED=" + FIREWORK_PARTICLE_SPEED + " SIZE=" + nf(FIREWORK_PARTICLE_SIZE_MIN, 0, 1) + "~" + nf(FIREWORK_PARTICLE_SIZE_MAX, 0, 1), 10, 28);
  text("音效: " + (testExplosionSound != null ? FIREWORK_EXPLODE_SOUND_PATH : "未加载"), 10, 46);
}

void testFireworkKeyPressed() {
  if (key == ' ') {
    if (testFireworkManager != null) testFireworkManager.spawnFirework();
  }
  if (key == 'b' || key == 'B') {
    if (testFireworkManager != null) testFireworkManager.spawnBurst(5);
  }
}

void testFireworkMousePressed() {
  if (mouseButton == LEFT && testFireworkManager != null) {
    testFireworkManager.spawnFirework();
  }
}
