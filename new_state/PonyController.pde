// ==================== 小马控制器 ====================
// 负责跑步 / 跳跃状态机，以及与时间线 / 输入的对接

class PonyController extends SceneObject implements BeatListener {
  // 帧序列
  PImage[] runFrames;
  PImage[] jumpFrames;

  int runTotalFrames;
  int jumpTotalFrames;

  // 节奏相关
  float bpm;
  float beatsPerRunCycle;
  float beatsForRemainingJump;

  // 状态：0 = RUN, 1 = JUMP
  int state = 0;
  boolean jumpRequested = false;
  int lastRunIndex = -1;

  // 当前显示帧与调试值
  PImage currentDisplayFrame = null;
  int currentFrameIndex = 0;
  float currentProgress = 0;
  float runCycleOffset = 0;
  float jumpStartTime = 0;

  // 测试模式时间轴（使用秒为单位的时间戳）
  boolean testMode = true;
  float[] jumpTimeline = { 2.0, 4.5, 7.0, 9.5, 12.0 };
  int nextTestIndex = 0;

  PonyController(PImage[] runFrames, PImage[] jumpFrames,
                 float bpm, float beatsPerRunCycle, float beatsForRemainingJump) {
    this.runFrames = runFrames;
    this.jumpFrames = jumpFrames;
    this.runTotalFrames = runFrames != null ? runFrames.length : 0;
    this.jumpTotalFrames = jumpFrames != null ? jumpFrames.length : 0;
    this.bpm = bpm;
    this.beatsPerRunCycle = beatsPerRunCycle;
    this.beatsForRemainingJump = beatsForRemainingJump;
  }

  // 对外接口：请求一次跳跃（来源可以是 "manual" / "stone" / "timeline" 等）
  void requestJump() {
    if (state == 0) {
      jumpRequested = true;
    }
  }

  void setTestMode(boolean enabled) {
    testMode = enabled;
    nextTestIndex = 0;
    if (!testMode) {
      jumpRequested = false;
    }
  }

  void toggleTestMode() {
    setTestMode(!testMode);
  }

  // ========== SceneObject 接口 ==========
  void update(float dt, float musicTime, float beat) {
    float animTime = musicTime;  // 对于小马而言，直接使用音乐时间作为主时间轴

    // 自动测试时间线：基于绝对时间戳的事件
    if (testMode && nextTestIndex < jumpTimeline.length) {
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

      // 在特定帧检查是否需要切到跳跃
      boolean transitionPoint = (index == 4);

      if (transitionPoint && lastRunIndex != 4 && jumpRequested) {
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

    // 在 RUN 状态且有排队跳跃请求时给一个提示
    if (state == 0 && jumpRequested) {
      drawWaitingIcon();
    }
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
    return (state == 0) ? "RUN" : "JUMP";
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

