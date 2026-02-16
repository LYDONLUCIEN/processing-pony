// ==================== 音乐时钟系统 ====================
// 负责将 SoundFile 的播放进度转成「时间 / 拍子」信息
// 音乐停止后时间继续推进（musicTime += dt），保证起扬等动画不卡住；背景停止由起扬动画触发

class MusicClock {
  SoundFile song;
  float bpm;

  // 当前音乐时间（秒）
  float musicTime = 0;
  // 从开始播放到现在，已经过了多少拍（可带小数）
  float beat = 0;
  // 当前是第几拍（取整）
  int beatIndex = 0;

  MusicClock(SoundFile song, float bpm) {
    this.song = song;
    this.bpm = bpm;
  }

  void update(float dt) {
    if (song != null && song.duration() > 0) {
      if (!song.isPlaying()) {
        // 音乐一停就靠 dt 推进时间，起扬等动画不卡住
        musicTime += dt;
      } else {
        musicTime = song.position();
      }
    } else if (song != null) {
      float pos = song.position();
      musicTime = pos;
    } else {
      musicTime = millis() / 1000.0;
    }

    float secondsPerBeat = 60.0 / bpm;
    if (secondsPerBeat <= 0) {
      beat = 0;
      beatIndex = 0;
      return;
    }

    beat = musicTime / secondsPerBeat;
    beatIndex = int(floor(beat));
  }
}
