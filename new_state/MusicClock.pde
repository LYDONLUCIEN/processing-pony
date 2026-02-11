// ==================== 音乐时钟系统 ====================
// 负责将 SoundFile 的播放进度转成「时间 / 拍子」信息

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

  void update() {
    if (song != null) {
      // SoundFile.position() 返回秒
      musicTime = song.position();
    } else {
      // 容错：没有音乐时退回到 millis 计时，避免崩溃
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

