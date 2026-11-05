// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:js_interop';

import 'package:flutter/foundation.dart';

class FullscreenController extends ChangeNotifier {
  FullscreenController({bool? isSupported}) : _supportedOverride = isSupported {
    _fullscreenSubscription = html.document.onFullscreenChange.listen((_) {
      notifyListeners();
    });
  }

  final bool? _supportedOverride;
  StreamSubscription<html.Event>? _fullscreenSubscription;

  bool get isSupported =>
      _supportedOverride ?? html.document.fullscreenEnabled == true;
  bool get isFullscreen => html.document.fullscreenElement != null;

  Future<bool> toggle() async {
    if (!isSupported) return false;
    try {
      if (isFullscreen) {
        await _exitFullscreen().toDart;
      } else {
        await html.document.documentElement?.requestFullscreen();
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _fullscreenSubscription?.cancel();
    super.dispose();
  }
}

@JS('document.exitFullscreen')
external JSPromise<JSAny?> _exitFullscreen();
