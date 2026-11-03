// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

class ProgressStore {
  ProgressStore({
    int initialCompletedScenes = 0,
    Set<String> initialCompletedSceneIds = const {},
    Map<String, int> initialSelections = const {},
  });

  static const _key = 'godflix.completedScenes';
  static const _completedIdsKey = 'godflix.completedSceneIds';
  static const _selectionsKey = 'godflix.selections';

  int readCompletedScenes() =>
      int.tryParse(html.window.localStorage[_key] ?? '') ?? 0;

  Set<String> readCompletedSceneIds() {
    final raw = html.window.localStorage[_completedIdsKey];
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return {};
      return decoded.whereType<String>().toSet();
    } on FormatException {
      return {};
    }
  }

  Map<String, int> readSelections() {
    final raw = html.window.localStorage[_selectionsKey];
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return {};
      return {
        for (final entry in decoded.entries)
          if (entry.value is int) entry.key: entry.value as int,
      };
    } on FormatException {
      return {};
    }
  }

  void writeCompletedScenes(int value) {
    html.window.localStorage[_key] = value.toString();
  }

  void writeCompletedSceneId(String sceneId) {
    final ids = readCompletedSceneIds()..add(sceneId);
    html.window.localStorage[_completedIdsKey] = jsonEncode(ids.toList());
  }

  void writeSelection(String sceneId, int choiceIndex) {
    final selections = readSelections()..[sceneId] = choiceIndex;
    html.window.localStorage[_selectionsKey] = jsonEncode(selections);
  }

  void clear() {
    html.window.localStorage.remove(_key);
    html.window.localStorage.remove(_completedIdsKey);
    html.window.localStorage.remove(_selectionsKey);
  }
}
