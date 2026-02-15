祝福时间轴配置文件说明
========================

编辑 data/blessings_timeline.json 即可配置各种素材出现的时间（单位：音乐秒 = 小马动画播放时间）。

一、时间含义（重要）
-----------------
  - luckyBags 和 stones 里的 "time" = 小马应在「最高点」撞击到该素材的音乐秒数。
  - 程序会根据 FORGE_SPEED、PONY_X、起跳到最高点时间，自动计算：
    1) 素材何时进场、放在哪一 x 位置；
    2) 在 time - JUMP_APEX_TIME 触发起跳。
  - 因此只需在 JSON 里写「撞击时刻」T，石头/福袋/礼物盒的进场位置和起跳时间都会自动算好。

二、各项配置说明
---------------

【福袋/礼物盒】luckyBags
  - 数组，每项 { "time": 秒数, "type": "money"|"fu"|"elephant" }
  - time = 小马在最高点顶到该福袋/礼物盒的音乐秒数；进场位置与石头逻辑一致（由速度与 T 反推）
  - money = 马上有钱，fu = 马上有福，elephant = 马上有对象

【石头】stones（可选）
  - 数组，每项 { "time": 秒数 (, "textIndex": 0|1|2 可选) }
  - time = 小马在最高点跳过该石头的音乐秒数；进场位置与福袋/礼物盒同一套公式计算
  - 若配置了 stones，则不再按间隔自动生成石头；若不配 stones，则仍按 stoneTextInterval 间隔生成

【石头文案】stoneTexts
  - 数组，如 ["跨过坎坷", "跨过阻碍", "跨过了迷茫"]
  - 小马跳过石头后，按顺序（或 textIndex）弹出这些字（不配图）

【其它祝福】otherAnimations
  - 数组，每项 { "time": 秒数, "type": "fly"|"success"|"jiji" }
  - 到达 time 秒时，在屏幕中央弹出四字 + 配套素材（若有）
  - fly = 马上起飞；success = 马到成功（四字 + 手袋动画 + 鞭炮一簇）；jiji = 马年大吉
  - 马到成功无跳跃/礼盒/石头，仅手袋与鞭炮
  - 示例：{"time":30,"type":"fly"} 表示第 30 秒弹出「马上起飞」

【起扬】qiyangTime
  - 一个数字（秒）
  - 音乐播到该秒时，小马会在下一次 run 过渡帧切到起扬动作
  - 示例：45 表示第 45 秒触发起扬

三、可选字段
-----------
luckyBagSpawnInterval: 福袋备用生成间隔（秒）
stoneTextInterval: 石头文案相关间隔（秒）

四、素材路径（在 BlessingConfig.pde 中改）
-----------
福袋图: assets/blessings/bag.png
福袋三类: money.png, fu.png, elephant.png
其它三类: fly.png, success.png, jiji.png（可选）
