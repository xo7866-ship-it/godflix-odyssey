class ProgressStore {
  ProgressStore({
    int initialCompletedScenes = 0,
    Set<String> initialCompletedSceneIds = const {},
    Map<String, int> initialSelections = const {},
  }) : _completedScenes = initialCompletedScenes,
       _completedSceneIds = Set.of(initialCompletedSceneIds),
       _selections = Map.of(initialSelections);

  int _completedScenes;
  final Set<String> _completedSceneIds;
  final Map<String, int> _selections;

  int readCompletedScenes() => _completedScenes;

  Set<String> readCompletedSceneIds() => Set.unmodifiable(_completedSceneIds);

  Map<String, int> readSelections() => Map.unmodifiable(_selections);

  void writeCompletedScenes(int value) {
    _completedScenes = value;
  }

  void writeCompletedSceneId(String sceneId) {
    _completedSceneIds.add(sceneId);
  }

  void writeSelection(String sceneId, int choiceIndex) {
    _selections[sceneId] = choiceIndex;
  }

  void clear() {
    _completedScenes = 0;
    _completedSceneIds.clear();
    _selections.clear();
  }
}
