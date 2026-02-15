// ==================== 小马控制器 ====================
// 负责跑步 / 跳跃 / 起扬状态机，以及与时间线 / 输入的对接

class PonyController extends SceneObject implements BeatListener {
  // 帧序列
  PImage[] runFrames;
  PImage[] jumpFrames;
  PImage[] qiyangFrames;

  int runTotalFrames;
  int jumpTotalFrames;
  int qiyangTotalFrames;

  // 节奏相关
  float bpm;
  float beatsPerRunCycle;
  float beatsForRemainingJump;
  float beatsForQiyang;

  int qiyangStartFrame;
  int qiyangEndFrame;
  int qiyangLoopStartFrame;  // 第一遍播完后，从该帧开始循环（如 72 = qiyang_72.png）
  float qiyangLoopFPS;       // 循环段播放帧率

  // 状态：0 = RUN, 1 = JUMP, 2 = QIYANG
  int state = 0;
  boolean jumpRequested = false;
  boolean qiyangRequested = false;
  int lastRunIndex = -1;
  boolean qiyangInLoop = false;   // 起扬第一遍播完后，进入 72～结尾 循环
  float qiyangLoopPhaseStartTime = 0;

  PImage currentDisplayFrame = null;
  int currentFrameIndex = 0;
  float currentProgress = 0;
  float runCycleOffset = 0;
  float jumpStartTime = 0;
  float qiyangStartTime = 0;

  // 测试模式时间轴（使用秒为单位的时间戳）
  boolean testMode = true;
  float[] jumpTimeline = { 2.0, 4.5, 7.0, 9.5, 12.0 };
  int nextTestIndex = 0;

  PonyController(PImage[] runFrames, PImage[] jumpFrames, PImage[] qiyangFrames,
                 float bpm, float beatsPerRunCycle, float beatsForRemainingJump, float beatsForQiyang,
                 int qiyangStartFrame, int qiyangEndFrame, int qiyangLoopStartFrame, float qiyangLoopFPS) {
    this.runFrames = runFrames;
    this.jumpFrames = jumpFrames;
    this.qiyangFrames = qiyangFrames;
    this.runTotalFrames = runFrames != null ? runFrames.length : 0;
    this.jumpTotalFrames = jumpFrames != null ? jumpFrames.length : 0;
    this.qiyangTotalFrames = qiyangFrames != null ? qiyangFrames.length : 0;
    this.bpm = bpm;
    this.beatsPerRunCycle = beatsPerRunCycle;
    this.beatsForRemainingJump = beatsForRemainingJump;
    this.beatsForQiyang = beatsForQiyang;
    this.qiyangStartFrame = qiyangStartFrame;
    this.qiyangEndFrame = qiyangEndFrame;
    this.qiyangLoopStartFrame = qiyangLoopStartFrame;
    this.qiyangLoopFPS = qiyangLoopFPS;
  }

  void requestJump() {
    if (state == 0) {
      jumpRequested = true;
    }
  }

  // 起扬：在时间轴到达 qiyangTime 时调用，下次 run 过渡帧切到起扬动作
  void requestQiyang() {
    if (state == 0) {
      qiyangRequested = true;
    }
  }

  void setTestMode(boolean enabled) {
    testMode = enabled;
    nextTestIndex = 0;
    if (!testMode) {
      jumpRequested = false;
      qiyangRequested = false;
    }
  }

  void toggleTestMode() {
    setTestMode(!testMode);
  }

  // ========== SceneObject 接口 ==========
  void update(float dt, float musicTime, float beat) {
    float animTime = musicTime;  // 对于小马而言，直接使用音乐时间作为主时间轴

    // 自动测试时间线：基于绝对时间戳的事件（起扬未请求时才自动跳）
    if (testMode && !qiyangRequested && nextTestIndex < jumpTimeline.length) {
      if (animTime >= jumpTimeline[nextTestIndex]) {
        requestJump();
        println("[AUTO] Timeline jump at " + nf(animTime, 0, 2) + "s");
        nextTestIndex++;
      }
    }

    // --- 状态机 ---
    currentFrameIndex = 0;
    currentProgress = 0;

    if (state == 0) {
      // ================= RUNNING =================
      float relativeRunTime = animTime - runCycleOffset;
      float durationPerCycle = (60.0 / bpm) * beatsPerRunCycle;
      float currentCycleProgress = (relativeRunTime % durationPerCycle) / durationPerCycle;

      if (currentCycleProgress < 0) currentCycleProgress += 1.0;

      int index = int(currentCycleProgress * runTotalFrames);
      if (index >= runTotalFrames) index = runTotalFrames - 1;

      currentProgress = currentCycleProgress;

      boolean transitionPoint = (index == 4);

      // 优先起扬，再跳跃
      if (transitionPoint && lastRunIndex != 4 && qiyangRequested && qiyangTotalFrames > 0) {
        currentDisplayFrame = runFrames[index];
        lastRunIndex = index;
        currentFrameIndex = index;
        state = 2;
        qiyangStartTime = animTime;
        qiyangRequested = false;
        println(">>> 起扬: RUN[4] -> QIYANG at " + nf(animTime, 0, 2));

      } else if (transitionPoint && lastRunIndex != 4 && jumpRequested) {
        currentDisplayFrame = runFrames[index];
        lastRunIndex = index;
        currentFrameIndex = index;
        state = 1;
        jumpStartTime = animTime;
        jumpRequested = false;
        println(">>> 起跳: RUN[4] -> JUMP[3] at " + nf(animTime, 0, 2));

      } else {
        lastRunIndex = index;
        currentFrameIndex = index;
        currentDisplayFrame = runFrames[index];
      }

    } else if (state == 2) {
      // ================= QIYANG：第一遍 14～结尾，播完后从 qiyangLoopStartFrame(72)～结尾 循环；到 qiyangEndFrame 时主流程冻结背景 =================
      int lastFrame = max(qiyangStartFrame, qiyangTotalFrames - 1);
      int playFrames = max(1, lastFrame - qiyangStartFrame + 1);
      float timeSinceQiyang = animTime - qiyangStartTime;
      float totalQiyangSec = (60.0 / bpm) * beatsForQiyang;
      currentProgress = totalQiyangSec > 0 ? min(1.0f, timeSinceQiyang / totalQiyangSec) : 1.0f;

      if (currentProgress >= 1.0f && !qiyangInLoop) {
        qiyangInLoop = true;
        qiyangLoopPhaseStartTime = animTime;
      }

      if (qiyangInLoop) {
        int loopStart = min(qiyangLoopStartFrame, qiyangTotalFrames - 1);
        int loopLen = max(1, qiyangTotalFrames - loopStart);
        float t = (animTime - qiyangLoopPhaseStartTime) * qiyangLoopFPS;
        int frameInLoop = (int)(t % loopLen);
        int idx = loopStart + frameInLoop;
        if (idx >= qiyangTotalFrames) idx = qiyangTotalFrames - 1;
        currentFrameIndex = idx;
        currentDisplayFrame = qiyangFrames != null && idx < qiyangTotalFrames ? qiyangFrames[idx] : runFrames[0];
      } else if (currentProgress >= 1.0f) {
        currentFrameIndex = lastFrame;
        currentDisplayFrame = qiyangFrames != null && lastFrame < qiyangTotalFrames ? qiyangFrames[lastFrame] : runFrames[0];
      } else {
        int idx = qiyangStartFrame + (int)(currentProgress * playFrames);
        if (idx > lastFrame) idx = lastFrame;
        if (idx < qiyangStartFrame) idx = qiyangStartFrame;
        currentFrameIndex = idx;
        currentDisplayFrame = qiyangFrames != null && idx < qiyangTotalFrames ? qiyangFrames[idx] : runFrames[0];
      }

    } else if (state == 1) {
      // ================= JUMPING =================
      float timeSinceJump = animTime - jumpStartTime;

      int jumpStartFrame = 3;
      int framesToPlay = jumpTotalFrames - jumpStartFrame;

      float durationPerFrame = ((60.0 / bpm) * beatsForRemainingJump) / framesToPlay;
      float totalJumpDurationSec = durationPerFrame * jumpTotalFrames;

      float effectiveTime = timeSinceJump + (jumpStartFrame * durationPerFrame);
      currentProgress = effectiveTime / totalJumpDurationSec;

      if (timeSinceJump < 0) {
        // 倒带保护：如果时间被拖回去了，回到 RUN 状态并重新排队
        state = 0;
        jumpRequested = true;
        lastRunIndex = -1;
        currentDisplayFrame = runFrames[0];

      } else if (currentProgress >= 1.0) {
        // 跳跃结束，回到 RUN
        state = 0;
        lastRunIndex = -1;
        runCycleOffset = animTime;
        println("<<< 落地：重置跑步相位");

        currentDisplayFrame = runFrames[0];
        currentFrameIndex = 0;
        currentProgress = 0;

      } else {
        int index = int(currentProgress * jumpTotalFrames);
        if (index < 0) index = 0;
        if (index >= jumpTotalFrames) index = jumpTotalFrames - 1;
        currentFrameIndex = index;
        currentDisplayFrame = jumpFrames[index];
      }
    }
  }

  void draw() {
    if (currentDisplayFrame != null) {
      drawPony(currentDisplayFrame);
    }

    if (state == 0 && jumpRequested) drawWaitingIcon();
    if (state == 0 && qiyangRequested) drawWaitingIcon();
  }

  // ========== BeatListener 接口（目前保留为扩展点） ==========
  void onBeat(int beatIndex, float musicTime) {
    // 将来可以在这里处理严格对拍的事件，例如：
    // - 在特定 beat 上重置 runCycleOffset
    // - 在谱面指令中直接请求跳跃
  }

  // ========== 调试与 UI 所需的只读访问 ==========
  int getCurrentFrameIndex() {
    return currentFrameIndex;
  }

  float getCurrentProgress() {
    return currentProgress;
  }

  String getStateLabel() {
    if (state == 0) return "RUN";
    if (state == 1) return "JUMP";
    if (state == 2) return "QIYANG";
    return "RUN";
  }

  float getRunCycleOffset() {
    return runCycleOffset;
  }

  boolean isTestMode() {
    return testMode;
  }

  float[] getJumpTimeline() {
    return jumpTimeline;
  }

  int getNextTestIndex() {
    return nextTestIndex;
  }

  // 命中判定（用于点击小马触发特效）
  boolean isMouseOver(int mx, int my) {
    float ponyLeft = PONY_X - 100;
    float ponyRight = PONY_X + 100;
    float ponyTop = PONY_Y - 150;
    float ponyBottom = PONY_Y + 50;
    return mx >= ponyLeft && mx <= ponyRight && my >= ponyTop && my <= ponyBottom;
  }
}

