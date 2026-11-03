class AmbientAudio {
  bool _playing = false;

  bool get isPlaying => _playing;

  Future<void> play() async {
    _playing = true;
  }

  void pause() {
    _playing = false;
  }

  void dispose() {}
}
