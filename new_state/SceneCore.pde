// ==================== 场景与节拍事件核心 ====================
// 把所有动效模块统一抽象成 SceneObject，便于集中调度与解耦

// --- 节拍监听接口（用于未来的谱面 / 节奏触发） ---
interface BeatListener {
  void onBeat(int beatIndex, float musicTime);
}

// --- 场景对象基类 ---
abstract class SceneObject {
  // 置为 false 后，Scene 会在下一帧把该对象移除
  boolean active = true;

  // dt: 帧间隔（秒），musicTime / beat: 全局音乐时间与拍子位置
  abstract void update(float dt, float musicTime, float beat);
  abstract void draw();

  // 生命周期回调（可选）
  void onSpawn() {
  }

  void onDestroy() {
  }
}

// --- 场景管理器：统一 update / draw / 回收 ---
class Scene {
  ArrayList<SceneObject> objects = new ArrayList<SceneObject>();

  void add(SceneObject obj) {
    if (obj == null) return;
    objects.add(obj);
    obj.onSpawn();
  }

  void updateAll(float dt, float musicTime, float beat) {
    for (int i = objects.size() - 1; i >= 0; i--) {
      SceneObject o = objects.get(i);
      if (o == null) {
        objects.remove(i);
        continue;
      }

      if (!o.active) {
        o.onDestroy();
        objects.remove(i);
      } else {
        o.update(dt, musicTime, beat);
      }
    }
  }

  void drawAll() {
    for (int i = 0; i < objects.size(); i++) {
      SceneObject o = objects.get(i);
      if (o != null) {
        o.draw();
      }
    }
  }
}

// --- 节拍事件分发器 ---
class BeatDispatcher {
  ArrayList<BeatListener> listeners = new ArrayList<BeatListener>();
  int lastBeatIndex = -1;

  void addListener(BeatListener l) {
    if (l == null) return;
    listeners.add(l);
  }

  void update(MusicClock clock) {
    if (clock == null) return;

    if (clock.beatIndex != lastBeatIndex) {
      lastBeatIndex = clock.beatIndex;
      for (BeatListener l : listeners) {
        l.onBeat(clock.beatIndex, clock.musicTime);
      }
    }
  }
}

// ==================== 现有 Layer 的简单包装 ====================
// 只负责把原来的 update(dt) / display() 接到 SceneObject 上

class CloudLayerObject extends SceneObject {
  CloudLayer layer;

  CloudLayerObject(CloudLayer layer) {
    this.layer = layer;
  }

  void update(float dt, float musicTime, float beat) {
    if (layer != null) {
      layer.update(dt);
    }
  }

  void draw() {
    if (layer != null) {
      layer.display();
    }
  }
}

class MountainLayerObject extends SceneObject {
  MountainLayer layer;

  MountainLayerObject(MountainLayer layer) {
    this.layer = layer;
  }

  void update(float dt, float musicTime, float beat) {
    if (layer != null) {
      layer.update(dt);
    }
  }

  void draw() {
    if (layer != null) {
      layer.display();
    }
  }
}

class DenglongManagerObject extends SceneObject {
  DenglongManager manager;

  DenglongManagerObject(DenglongManager manager) {
    this.manager = manager;
  }

  void update(float dt, float musicTime, float beat) {
    if (manager != null) manager.update(dt);
  }

  void draw() {
    if (manager != null) manager.display();
  }
}

class PillarManagerObject extends SceneObject {
  PillarManager manager;

  PillarManagerObject(PillarManager manager) {
    this.manager = manager;
  }

  void update(float dt, float musicTime, float beat) {
    if (manager != null) manager.update(dt);
  }

  void draw() {
    if (manager != null) manager.display();
  }
}

class FirecrackerManagerObject extends SceneObject {
  FirecrackerManager manager;

  FirecrackerManagerObject(FirecrackerManager manager) {
    this.manager = manager;
  }

  void update(float dt, float musicTime, float beat) {
    if (manager != null) manager.update(dt);
  }

  void draw() {
    if (manager != null) manager.display();
  }
}

// --- 路边近景层（预留：花盆、草丛、树木等，位于地面之上、小马之下） ---
class RoadsideLayerObject extends SceneObject {
  RoadsideLayer layer;

  RoadsideLayerObject(RoadsideLayer layer) {
    this.layer = layer;
  }

  void update(float dt, float musicTime, float beat) {
    if (layer != null) layer.update(dt);
  }

  void draw() {
    if (layer != null) layer.display();
  }
}

class GroundManagerObject extends SceneObject {
  GroundManager manager;

  GroundManagerObject(GroundManager manager) {
    this.manager = manager;
  }

  void update(float dt, float musicTime, float beat) {
    if (manager != null) {
      manager.update(dt);
    }
  }

  void draw() {
    if (manager != null) {
      manager.display();
    }
  }
}

class StoneManagerObject extends SceneObject {
  StoneManager manager;

  StoneManagerObject(StoneManager manager) {
    this.manager = manager;
  }

  void update(float dt, float musicTime, float beat) {
    if (manager != null) {
      manager.update(dt);
    }
  }

  void draw() {
    if (manager != null) {
      manager.display();
    }
  }
}

class MoneyEffectObject extends SceneObject {
  MoneyEffect effect;

  MoneyEffectObject(MoneyEffect effect) {
    this.effect = effect;
  }

  void update(float dt, float musicTime, float beat) {
    if (effect != null) {
      effect.update(dt);
    }
  }

  void draw() {
    if (effect != null) {
      effect.display();
    }
  }
}


