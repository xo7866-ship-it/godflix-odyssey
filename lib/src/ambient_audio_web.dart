// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';

import 'dart:html' as html;

class AmbientAudio {
  static const defaultAsset = 'assets/audio/sea_wind.wav';

  html.AudioElement? _audio;
  Timer? _fadeTimer;
  bool _playing = false;
  String _asset = defaultAsset;
  double _volume = 0.32;
  int _playRequest = 0;

  bool get isPlaying => _playing;
  String get asset => _asset;
  double get volume => _volume;

  Future<void> play({String? asset, double? volume}) async {
    final nextAsset = asset ?? _asset;
    final targetVolume = (volume ?? _volume).clamp(0, 1).toDouble();
    final request = ++_playRequest;
    _fadeTimer?.cancel();
    _volume = targetVolume;

    final trackChanged = _audio == null || _asset != nextAsset;
    if (trackChanged) {
      _audio?.pause();
      _audio?.remove();
      html.document.getElementById('godflix-ambient-audio')?.remove();
      _asset = nextAsset;
      _audio = html.AudioElement('assets/$nextAsset')
        ..id = 'godflix-ambient-audio'
        ..loop = true
        ..preload = 'auto'
        ..setAttribute('data-target-volume', targetVolume.toString())
        ..style.display = 'none'
        ..volume = 0;
      html.document.body?.append(_audio!);
    }
    final audio = _audio!;
    try {
      await audio.play();
      if (request != _playRequest) {
        audio.pause();
        return;
      }
      _playing = true;
      _fadeTo(targetVolume, const Duration(milliseconds: 650));
    } catch (_) {
      _playing = false;
    }
  }

  void setVolume(
    double volume, {
    Duration fade = const Duration(milliseconds: 500),
  }) {
    _volume = volume.clamp(0, 1).toDouble();
    final audio = _audio;
    if (audio == null) return;
    audio.setAttribute('data-target-volume', _volume.toString());
    if (!_playing) {
      audio.volume = _volume;
      return;
    }
    _fadeTo(_volume, fade);
  }

  void _fadeTo(double target, Duration duration) {
    _fadeTimer?.cancel();
    final audio = _audio;
    if (audio == null) return;
    audio.setAttribute('data-target-volume', target.toString());
    const steps = 16;
    final start = audio.volume;
    final interval = (duration.inMilliseconds / steps)
        .round()
        .clamp(1, 1000)
        .toInt();
    var step = 0;
    _fadeTimer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      step += 1;
      final progress = step / steps;
      audio.volume = start + ((target - start) * progress);
      audio.setAttribute(
        'data-current-volume',
        audio.volume.toStringAsFixed(3),
      );
      if (step >= steps) timer.cancel();
    });
  }

  void pause() {
    _playRequest += 1;
    _fadeTimer?.cancel();
    _audio?.pause();
    _playing = false;
  }

  void dispose() {
    pause();
    _audio?.remove();
    _audio = null;
  }
}
