// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

class AmbientAudio {
  html.AudioElement? _audio;
  bool _playing = false;

  bool get isPlaying => _playing;

  Future<void> play() async {
    final audio = _audio ??=
        html.AudioElement('assets/assets/audio/sea_wind.wav')
          ..loop = true
          ..volume = 0.22;
    try {
      await audio.play();
      _playing = true;
    } catch (_) {
      _playing = false;
    }
  }

  void pause() {
    _audio?.pause();
    _playing = false;
  }

  void dispose() {
    _audio?.pause();
    _audio = null;
  }
}
