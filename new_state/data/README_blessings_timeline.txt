祝福时间轴配置文件说明
========================

编辑 data/blessings_timeline.json 即可配置各种素材出现的时间（单位：音乐秒）。

一、如何配置时间轴
-----------------
1. 用记事本或编辑器打开 new_state/data/blessings_timeline.json
2. 所有时间都是「音乐播放到第几秒」时触发
3. 改完保存后，重新运行 sketch 生效

二、各项配置说明
---------------

【福袋】luckyBags
  - 数组，每项 { "time": 秒数, "type": "money"|"fu"|"elephant" }
  - 到达 time 秒时，从右侧进入一个福袋；顶到后弹出对应四字 + 素材
  - money = 马上有钱 + money.png
  - fu = 马上有福 + fu.png
  - elephant = 马上有对象 + elephant.png
  - 示例：{"time":5,"type":"money"} 表示第 5 秒出现「马上有钱」福袋

【石头文案】stoneTexts
  - 数组，如 ["跨过坎坷", "跨过阻碍", "跨过了迷茫"]
  - 小马跳过石头后，按顺序循环弹出这些字（不配图）

【其它祝福】otherAnimations
  - 数组，每项 { "time": 秒数, "type": "fly"|"success"|"jiji" }
  - 到达 time 秒时，在屏幕中央弹出四字 + 配套素材（若有）
  - fly = 马上起飞, success = 马到成功, jiji = 马年大吉
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
