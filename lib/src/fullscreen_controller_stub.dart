import 'package:flutter/foundation.dart';

class FullscreenController extends ChangeNotifier {
  FullscreenController({this.isSupported = false});

  final bool isSupported;
  bool _fullscreen = false;

  bool get isFullscreen => _fullscreen;

  Future<bool> toggle() async {
    if (!isSupported) return false;
    _fullscreen = !_fullscreen;
    notifyListeners();
    return true;
  }
}
