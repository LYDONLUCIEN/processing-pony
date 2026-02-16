祝福时间轴配置文件说明
========================

编辑 data/blessings_timeline.json 即可配置各种素材出现的时间（单位：音乐秒 = 小马动画播放时间）。

一、时间含义（重要）
-----------------
  - luckyBags 和 stones 里的 "time" = T = 小马应在「最高点」撞击到该素材的音乐秒数。
  - 起跳不是立刻执行：requestJump 后要等 run 到过渡帧（第 4 帧）才真正起跳，再经「起跳到最高点」时间到达顶点。
  - 程序自动计算：
    1) 起跳请求提前量 = 最长等 run 一周期（1 beat）+ 起跳到最高点时间 → 在 T - 此值 时 requestJump；
    2) 福袋/礼盒/石头进场提前量 = (屏幕右缘 - PONY_X) / FORGE_SPEED → 在 T - 此值 时生成，startX = PONY_X + FORGE_SPEED * 此值，保证 T 时刻到达 PONY_X。
  - 因此只需在 JSON 里写撞击时刻 T，进场位置和起跳时间都会自动算好。

二、各项配置说明
---------------

【福袋/礼物盒】luckyBags
  - 数组，每项 { "time": 秒数, "type": "money"|"fu"|"elephant" }
  - time = 小马在最高点顶到该福袋/礼物盒的音乐秒数；进场位置与石头逻辑一致（由速度与 T 反推）
  - money = 马上有钱，fu = 马上有福，elephant = 马上有对象

【石头】stones（可选）
  - 数组，每项 { "time": 秒数, "textIndex": 0|1|2 }（建议每块石头都写明 textIndex，避免歧义）
  - time = 小马在最高点跳过该石头的音乐秒数；进场位置与福袋/礼物盒同一套公式计算
  - textIndex = 该石头对应 stoneTexts 的下标：0=第 1 句，1=第 2 句，2=第 3 句…… 这样每块石头的文案固定，不会随机也不会重复错配
  - 若某条不写 textIndex，则按 stones 数组顺序依次轮换（第 1 块→0，第 2 块→1，第 3 块→2，第 4 块→0…）
  - 若配置了 stones，则不再按间隔自动生成石头；若不配 stones，则仍按 stoneTextInterval 间隔生成

【石头文案】stoneTexts
  - 数组，如 ["跨过坎坷", "跨过阻碍", "跨过了迷茫"]
  - 每块石头的文案由该石头在 stones 里配置的 textIndex 决定：stoneTexts[textIndex] 即为跳过该石头后弹出的文字
  - 石头与文案一一对应：stones[i].textIndex 指向 stoneTexts 中的第几句，不会随机

【其它祝福】otherAnimations
  - 数组，每项 { "time": 秒数, "type": "fly"|"success"|"daji" }
  - 到达 time 秒时，在屏幕中央弹出四字 + 配套素材（若有）
  - fly = 马上起飞；success = 马到成功（四字 + 手袋动画 + 鞭炮一簇）；daji = 马年大吉（四字 + 手袋持续播放 + 烟花）
  - 马到成功无跳跃/礼盒/石头，仅手袋与鞭炮；马年大吉为手袋长时间播放 + Processing 绘制烟花
  - 示例：{"time":30,"type":"fly"} 表示第 30 秒弹出「马上起飞」

【起扬】qiyangTime
  - 一个数字（秒）
  - 音乐播到该秒时，小马会在下一次 run 过渡帧切到起扬动作
  - 示例：45 表示第 45 秒触发起扬

三、可选字段与「是否冲突」说明
-----------------------------
【luckyBagSpawnInterval】
  - 含义：早期预留的「按固定间隔（秒）生成福袋/礼盒」的间隔值。
  - 与 time 冲突吗？不冲突。当前逻辑只按 luckyBags[].time 精确生成，每个礼盒的出现时刻完全由对应那一项的 time 决定。
  - 现状：该值在代码中已不再参与生成逻辑（仅被读取后未使用），可视为废弃/预留。JSON 里保留或删掉都不影响 luckyBags 的 time 控制；若保留，可填 9 等任意数字，仅作占位。

stoneTextInterval: 石头文案相关间隔（秒）（在未配置 stones 数组时使用）

四、可微调参数位置（按需改）
---------------------------
【小马头顶 / 礼盒对齐】AnimationConfig.pde
  - PONY_HEAD_APEX_OFFSET_X = 60   → 最高点时头顶 X = PONY_X + 此值
  - PONY_HEAD_APEX_OFFSET_Y = -90  → 最高点时头顶 Y = PONY_Y + 此值（礼盒中心对齐此高度）
  - PONY_HEAD_OFFSET_X / PONY_HEAD_OFFSET_Y → 碰撞检测用的头部相对偏移
  - PONY_JUMP_HEIGHT → 跳跃弧线高度

【礼盒 / box 位置】BlessingConfig.pde
  - GIFT_BOX_APEX_Y_RAISE = 0  → 礼盒中心 Y = 头顶最高点 + 此值；要调高礼盒改为负数（如 -10 = 高 10 像素）
  - GIFT_BOX_STRING_LENGTH_MIN/MAX → 绳长范围，影响盒体上下位置
  - GIFT_BOX_LID_Y_OFFSET = -18   → 盖子相对盒身 Y（负=盖在上方）

【石头】StoneManager 使用同一 FORGE_SPEED；T 时刻石头水平到达 PONY_X 正下方（地面），无需改 Y。

【手袋 / 马到成功等】BlessingConfig.pde
  - SHOUDAI_OFFSET_X / SHOUDAI_OFFSET_Y → 手袋相对 (PONY_X, PONY_Y) 的偏移
  - 文字与精灵出现位置：new_state.pde 里用 PONY_CHEST_OFFSET_X/Y（胸口）→ AnimationConfig 中 PONY_CHEST_OFFSET_X = 42, PONY_CHEST_OFFSET_Y = 42

【起跳与节奏】AnimationConfig.pde + new_state.pde
  - 起跳请求提前量 = getJumpRequestLeadTimeSec() = run 一周期 + 起跳到最高点时间（由 BPM、beatsPerRunCycle、beatsForRemainingJump、JUMP_APEX_FRACTION 决定）

五、素材路径（在 BlessingConfig.pde 中改）
-----------
福袋图: assets/blessings/bag.png
福袋三类: money.png, fu.png, elephant.png
其它三类: fly / success / daji（图标用 output 下 shoudai 首帧；烟花为 Processing 绘制）
