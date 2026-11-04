class AmbientAudio {
  static const defaultAsset = 'assets/audio/sea_wind.wav';

  bool _playing = false;
  String _asset = defaultAsset;
  double _volume = 0.32;

  bool get isPlaying => _playing;
  String get asset => _asset;
  double get volume => _volume;

  Future<void> play({String? asset, double? volume}) async {
    if (asset != null) _asset = asset;
    if (volume != null) setVolume(volume);
    _playing = true;
  }

  void setVolume(
    double volume, {
    Duration fade = const Duration(milliseconds: 500),
  }) {
    _volume = volume.clamp(0, 1).toDouble();
  }

  void pause() {
    _playing = false;
  }

  void dispose() {}
}
