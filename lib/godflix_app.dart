import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'ambient_audio.dart';
import 'data/scenes.dart';
import 'models/scene.dart';
import 'progress_store.dart';

const _gold = Color(0xFFF5C542);
const _ink = Color(0xFF090B0F);

class GodflixApp extends StatefulWidget {
  const GodflixApp({super.key, this.progressStore});

  final ProgressStore? progressStore;

  @override
  State<GodflixApp> createState() => _GodflixAppState();
}

class _GodflixAppState extends State<GodflixApp> {
  late final ProgressStore _progressStore;
  late final AmbientAudio _ambientAudio;
  late Set<String> _completedSceneIds;
  late Map<String, int> _selectedChoices;
  int _selectedSceneIndex = 0;
  bool _soundOn = false;
  bool _journeyStarted = false;
  bool _storySeen = false;
  bool _mapSeen = false;

  @override
  void initState() {
    super.initState();
    _progressStore = widget.progressStore ?? ProgressStore();
    _ambientAudio = AmbientAudio();
    _completedSceneIds = _progressStore.readCompletedSceneIds();
    final legacyCount = _progressStore.readCompletedScenes().clamp(
      0,
      journeyScenes.length,
    );
    if (_completedSceneIds.isEmpty && legacyCount > 0) {
      _completedSceneIds = journeyScenes
          .take(legacyCount)
          .map((scene) => scene.id)
          .toSet();
      for (final sceneId in _completedSceneIds) {
        _progressStore.writeCompletedSceneId(sceneId);
      }
    }
    _selectedChoices = _progressStore.readSelections();
  }

  void _beginDeparture() {
    unawaited(_ambientAudio.play());
    setState(() => _soundOn = true);
  }

  void _startJourney() {
    setState(() => _journeyStarted = true);
  }

  void _continueFromStory(int sceneIndex) {
    setState(() {
      _selectedSceneIndex = sceneIndex;
      _storySeen = true;
      _mapSeen = true;
    });
  }

  void _recordProgress(String sceneId) {
    _completedSceneIds = {..._completedSceneIds, sceneId};
    _progressStore.writeCompletedSceneId(sceneId);
    setState(() {});
  }

  void _recordSelection(String sceneId, int choiceIndex) {
    _selectedChoices = {..._selectedChoices, sceneId: choiceIndex};
    _progressStore.writeSelection(sceneId, choiceIndex);
    setState(() {});
  }

  void _toggleSound() {
    if (_soundOn) {
      _ambientAudio.pause();
    } else {
      unawaited(_ambientAudio.play());
    }
    setState(() => _soundOn = !_soundOn);
  }

  void _resetJourney() {
    _progressStore.clear();
    _ambientAudio.pause();
    setState(() {
      _completedSceneIds = {};
      _selectedChoices = {};
      _selectedSceneIndex = 0;
      _journeyStarted = false;
      _storySeen = false;
      _mapSeen = false;
      _soundOn = false;
    });
  }

  void _backToOverview() {
    setState(() => _storySeen = false);
  }

  @override
  void dispose() {
    _ambientAudio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GODFLIX 오디세이',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _ink,
        colorScheme: const ColorScheme.dark(
          primary: _gold,
          secondary: Color(0xFFE50914),
          surface: Color(0xFF151922),
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Noto Sans KR',
          fontFamilyFallback: const [
            'Malgun Gothic',
            'Apple SD Gothic Neo',
            'sans-serif',
          ],
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _gold,
            foregroundColor: const Color(0xFF241A04),
            minimumSize: const Size(0, 54),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      home: !_journeyStarted
          ? LandingScreen(
              completedScenes: _completedSceneIds.length,
              onDeparture: _beginDeparture,
              onStart: _startJourney,
            )
          : !_storySeen
          ? StoryOverviewScreen(
              onSceneSelected: _continueFromStory,
              completedSceneIds: _completedSceneIds,
              selectedChoices: _selectedChoices,
              showImmediately: _mapSeen,
              soundOn: _soundOn,
              onToggleSound: _toggleSound,
            )
          : JourneyScreen(
              initialSceneIndex: _selectedSceneIndex,
              completedSceneIds: _completedSceneIds,
              selectedChoices: _selectedChoices,
              soundOn: _soundOn,
              onProgress: _recordProgress,
              onSelection: _recordSelection,
              onToggleSound: _toggleSound,
              onBackToOverview: _backToOverview,
              onReset: _resetJourney,
            ),
    );
  }
}

class LandingScreen extends StatefulWidget {
  const LandingScreen({
    super.key,
    required this.completedScenes,
    required this.onDeparture,
    required this.onStart,
  });

  final int completedScenes;
  final VoidCallback onDeparture;
  final VoidCallback onStart;

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  Timer? _departureTimer;
  bool _departing = false;

  @override
  void dispose() {
    _departureTimer?.cancel();
    super.dispose();
  }

  void _depart() {
    if (_departing) return;
    setState(() => _departing = true);
    widget.onDeparture();
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 1800);
    _departureTimer = Timer(duration, () {
      if (mounted) widget.onStart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = widget.completedScenes >= journeyScenes.length;
    final hasProgress = widget.completedScenes > 0 && !isComplete;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _LayeredSailingBackground(
            key: const Key('landing-cinematic-background'),
            plateAsset: 'assets/images/landing_ithaca_plate.png',
            shipAsset: 'assets/images/landing_ithaca_ship.png',
            sourceSize: const Size(1448, 1086),
            narrowAlignment: const Alignment(-0.2, 0),
            sailPolygon: const [
              Offset(0.138, 0.448),
              Offset(0.462, 0.498),
              Offset(0.451, 0.733),
              Offset(0.139, 0.754),
            ],
            sailPivot: const Offset(0.318, 0.46),
            departing: _departing,
            semanticsLabel: '배를 타고 이타카로 향하는 오디세이 여정',
          ),
          AnimatedOpacity(
            opacity: _departing ? 0.28 : 1,
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOut,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x33000000),
                    Color(0x66000000),
                    Color(0xF20A0B0E),
                  ],
                  stops: [0, 0.42, 1],
                ),
              ),
            ),
          ),
          IgnorePointer(
            ignoring: _departing,
            child: AnimatedSlide(
              offset: _departing ? const Offset(0, 0.04) : Offset.zero,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeIn,
              child: AnimatedOpacity(
                opacity: _departing ? 0 : 1,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeIn,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _Brand(),
                            const SizedBox(height: 28),
                            Text(
                              '오디세이\n하늘 가는 여정',
                              style: Theme.of(context).textTheme.displayMedium
                                  ?.copyWith(
                                    fontSize: 52,
                                    height: 1.08,
                                    fontWeight: FontWeight.w900,
                                    shadows: const [
                                      Shadow(
                                        blurRadius: 20,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '이야기 속 선택을 지나 말씀을 만나고,\n오늘의 삶에 적용할 한 걸음을 정합니다.',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    height: 1.55,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                key: const Key('start-journey'),
                                onPressed: _depart,
                                icon: Icon(
                                  isComplete
                                      ? Icons.auto_stories
                                      : Icons.explore,
                                ),
                                label: Text(
                                  isComplete
                                      ? '완주 기록 보기'
                                      : hasProgress
                                      ? '이어서 여정하기'
                                      : '여정 시작하기',
                                ),
                              ),
                            ),
                            if (hasProgress) ...[
                              const SizedBox(height: 12),
                              Text(
                                '${widget.completedScenes}개의 장면을 완료했습니다.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.72),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StoryOverviewScreen extends StatefulWidget {
  const StoryOverviewScreen({
    super.key,
    required this.onSceneSelected,
    required this.completedSceneIds,
    required this.selectedChoices,
    required this.showImmediately,
    required this.soundOn,
    required this.onToggleSound,
  });

  final ValueChanged<int> onSceneSelected;
  final Set<String> completedSceneIds;
  final Map<String, int> selectedChoices;
  final bool showImmediately;
  final bool soundOn;
  final VoidCallback onToggleSound;

  @override
  State<StoryOverviewScreen> createState() => _StoryOverviewScreenState();
}

class _StoryOverviewScreenState extends State<StoryOverviewScreen> {
  Timer? _revealTimer;
  bool _showStory = false;

  @override
  void initState() {
    super.initState();
    _showStory = widget.showImmediately;
    if (!_showStory) {
      _revealTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showStory = true);
      });
    }
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  void _revealNow() {
    _revealTimer?.cancel();
    setState(() => _showStory = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _LivingBackground(
            imageAsset: 'assets/images/landing_ithaca_plate.png',
            alignment: Alignment(0.25, 0),
            semanticsLabel: '배가 출항한 뒤의 이타카 바다',
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            child: !_showStory
                ? const SizedBox.shrink(key: ValueKey('overview-background'))
                : Stack(
                    key: const ValueKey('overview-story'),
                    fit: StackFit.expand,
                    children: [
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x55000000), Color(0xD908090C)],
                          ),
                        ),
                      ),
                      SafeArea(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 760),
                              child: _StepPanel(
                                eyebrow: 'THE ODYSSEY',
                                title: '오디세이 여정 지도',
                                children: [
                                  Text(
                                    '트로이에서 이타카까지 이어지는 11개의 장면입니다. 원하는 장면을 선택해 이야기와 말씀, 예언의 신 묵상 본문을 만나보세요.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(height: 1.75),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Text(
                                        '${widget.completedSceneIds.length} / ${journeyScenes.length} 장면 완료',
                                        style: const TextStyle(
                                          color: _gold,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const Spacer(),
                                      OutlinedButton.icon(
                                        key: const Key('map-journey-log'),
                                        onPressed: () =>
                                            showModalBottomSheet<void>(
                                              context: context,
                                              backgroundColor: const Color(
                                                0xFF151922,
                                              ),
                                              showDragHandle: true,
                                              isScrollControlled: true,
                                              builder: (context) =>
                                                  _JourneyLogSheet(
                                                    selectedChoices:
                                                        widget.selectedChoices,
                                                    completedSceneIds: widget
                                                        .completedSceneIds,
                                                  ),
                                            ),
                                        icon: const Icon(Icons.route),
                                        label: const Text('나의 여정'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 22),
                                  _AncientJourneyMap(
                                    completedSceneIds: widget.completedSceneIds,
                                    onSceneSelected: widget.onSceneSelected,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_showStory)
                      IconButton.filledTonal(
                        key: const Key('skip-overview-intro'),
                        tooltip: '연출 건너뛰기',
                        onPressed: _revealNow,
                        icon: const Icon(Icons.fast_forward),
                      ),
                    const SizedBox(width: 6),
                    IconButton.filledTonal(
                      key: const Key('toggle-sound-overview'),
                      tooltip: widget.soundOn ? '소리 끄기' : '소리 켜기',
                      onPressed: widget.onToggleSound,
                      icon: Icon(
                        widget.soundOn ? Icons.volume_up : Icons.volume_off,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AncientJourneyMap extends StatelessWidget {
  const _AncientJourneyMap({
    required this.completedSceneIds,
    required this.onSceneSelected,
  });

  final Set<String> completedSceneIds;
  final ValueChanged<int> onSceneSelected;

  static const _positions = <Offset>[
    Offset(0.58, 0.50),
    Offset(0.86, 0.30),
    Offset(0.16, 0.62),
    Offset(0.34, 0.23),
    Offset(0.43, 0.43),
    Offset(0.39, 0.33),
    Offset(0.35, 0.55),
    Offset(0.30, 0.70),
    Offset(0.54, 0.75),
    Offset(0.27, 0.82),
    Offset(0.75, 0.59),
  ];

  static const _labels = <String>[
    '왕이 없는 이타카',
    '트로이 목마',
    '외눈박이 거인',
    '키르케의 섬',
    '테이레시아스',
    '세이렌',
    '스킬라와 카리브디스',
    '헬리오스의 소',
    '격심한 폭풍',
    '칼립소의 섬',
    '왕의 귀환',
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mapWidth = constraints.maxWidth;
        final mapHeight = mapWidth * 9 / 16;
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: mapWidth,
            height: mapHeight,
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 3,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/odyssey_map_ancient.png',
                      fit: BoxFit.cover,
                      semanticLabel: '고대 지중해 오디세이 여정 지도',
                    ),
                  ),
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x12000000), Color(0x52000000)],
                        ),
                      ),
                    ),
                  ),
                  for (var index = 0; index < journeyScenes.length; index++)
                    Positioned(
                      left: _positions[index].dx * mapWidth,
                      top: _positions[index].dy * mapHeight,
                      child: FractionalTranslation(
                        translation: Offset(
                          _positions[index].dx > 0.64 ? -1 : -0.08,
                          -0.5,
                        ),
                        child: _MapMarkerButton(
                          key: Key('map-scene-$index'),
                          number: index + 1,
                          label: _labels[index],
                          complete: completedSceneIds.contains(
                            journeyScenes[index].id,
                          ),
                          compact: mapWidth < 600,
                          onTap: () => onSceneSelected(index),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MapMarkerButton extends StatelessWidget {
  const _MapMarkerButton({
    super.key,
    required this.number,
    required this.label,
    required this.complete,
    required this.compact,
    required this.onTap,
  });

  final int number;
  final String label;
  final bool complete;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$number번 $label${complete ? ', 완료' : ''}',
      child: Material(
        color: const Color(0xE31A1712),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: complete ? _gold : const Color(0xFFCFB77A)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: EdgeInsets.fromLTRB(4, 4, compact ? 7 : 10, 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: compact ? 23 : 28,
                  height: compact ? 23 : 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: complete ? _gold : const Color(0xFF342B1E),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$number',
                    style: TextStyle(
                      color: complete ? const Color(0xFF241A04) : _gold,
                      fontSize: compact ? 9 : 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(width: compact ? 4 : 7),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFFFF1C8),
                    fontWeight: FontWeight.w800,
                  ).copyWith(fontSize: compact ? 8 : 11),
                ),
                if (complete) ...[
                  SizedBox(width: compact ? 3 : 5),
                  Icon(Icons.check, size: compact ? 10 : 14, color: _gold),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum JourneyStep {
  background,
  story,
  choice,
  scripture,
  reflection,
  complete,
  summary,
}

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({
    super.key,
    required this.initialSceneIndex,
    required this.completedSceneIds,
    required this.selectedChoices,
    required this.soundOn,
    required this.onProgress,
    required this.onSelection,
    required this.onToggleSound,
    required this.onBackToOverview,
    required this.onReset,
  });

  final int initialSceneIndex;
  final Set<String> completedSceneIds;
  final Map<String, int> selectedChoices;
  final bool soundOn;
  final ValueChanged<String> onProgress;
  final void Function(String sceneId, int choiceIndex) onSelection;
  final VoidCallback onToggleSound;
  final VoidCallback onBackToOverview;
  final VoidCallback onReset;

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  late int _sceneIndex;
  late JourneyStep _step;
  Timer? _sceneRevealTimer;
  JourneyChoice? _selectedChoice;
  final _reflectionController = TextEditingController();
  final _answers = <JourneyAnswer>[];

  JourneyScene get _scene => journeyScenes[_sceneIndex];

  @override
  void initState() {
    super.initState();
    _sceneIndex = widget.initialSceneIndex;
    _step = JourneyStep.background;
    _selectedChoice = _savedChoiceFor(_sceneIndex);
    if (_step == JourneyStep.background) _scheduleSceneStory();
  }

  @override
  void dispose() {
    _sceneRevealTimer?.cancel();
    _reflectionController.dispose();
    super.dispose();
  }

  void _scheduleSceneStory() {
    _sceneRevealTimer?.cancel();
    _sceneRevealTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _step = JourneyStep.story);
    });
  }

  void _revealSceneNow() {
    _sceneRevealTimer?.cancel();
    setState(() => _step = JourneyStep.story);
  }

  void _goTo(JourneyStep step) {
    setState(() => _step = step);
  }

  void _goBack() {
    switch (_step) {
      case JourneyStep.story:
        widget.onBackToOverview();
        return;
      case JourneyStep.choice:
        _goTo(JourneyStep.story);
        return;
      case JourneyStep.scripture:
        _goTo(JourneyStep.choice);
        return;
      case JourneyStep.reflection:
        _goTo(JourneyStep.scripture);
        return;
      case JourneyStep.complete:
        _goTo(JourneyStep.reflection);
        return;
      case JourneyStep.background:
      case JourneyStep.summary:
        return;
    }
  }

  void _selectChoice(JourneyChoice choice) {
    widget.onSelection(_scene.id, _scene.choices.indexOf(choice));
    setState(() => _selectedChoice = choice);
  }

  JourneyChoice? _savedChoiceFor(int sceneIndex) {
    final scene = journeyScenes[sceneIndex];
    final choiceIndex = widget.selectedChoices[scene.id];
    if (choiceIndex == null ||
        choiceIndex < 0 ||
        choiceIndex >= scene.choices.length) {
      return null;
    }
    return scene.choices[choiceIndex];
  }

  void _completeScene() {
    final choice = _selectedChoice;
    if (choice == null) return;
    _answers.removeWhere((answer) => answer.scene.id == _scene.id);
    _answers.add(
      JourneyAnswer(
        scene: _scene,
        choice: choice,
        reflection: _reflectionController.text.trim(),
      ),
    );
    widget.onProgress(_scene.id);
    _goTo(JourneyStep.complete);
  }

  void _nextScene() {
    if (_sceneIndex == journeyScenes.length - 1) {
      _goTo(JourneyStep.summary);
      return;
    }
    setState(() {
      _sceneIndex += 1;
      _selectedChoice = _savedChoiceFor(_sceneIndex);
      _reflectionController.clear();
      _step = JourneyStep.background;
    });
    _scheduleSceneStory();
  }

  @override
  Widget build(BuildContext context) {
    final showScene = _step != JourneyStep.summary;
    final backgroundOnly = _step == JourneyStep.background;
    final brightenScene =
        _step == JourneyStep.story || _step == JourneyStep.choice;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            child: showScene && _scene.id == 'return'
                ? _LayeredSailingBackground(
                    key: const ValueKey('return-cinematic-background'),
                    plateAsset: 'assets/images/scene_11_ithaca_plate.png',
                    shipAsset: 'assets/images/scene_11_ithaca_ship.png',
                    sourceSize: const Size(1672, 941),
                    narrowAlignment: const Alignment(-0.62, 0),
                    semanticsLabel: '${_scene.title} 배경',
                  )
                : _LivingBackground(
                    key: ValueKey(showScene ? _scene.imageAsset : 'summary'),
                    imageAsset: showScene
                        ? _scene.imageAsset
                        : 'assets/images/scene_3.jpg',
                    alignment: showScene
                        ? _scene.id == 'troy'
                              ? const Alignment(-0.78, 0)
                              : const Alignment(0.35, 0)
                        : const Alignment(0.25, 0),
                    semanticsLabel: showScene
                        ? '${_scene.title} 배경'
                        : '이타카로 돌아가는 배',
                  ),
          ),
          AnimatedOpacity(
            opacity: backgroundOnly ? 0 : 1,
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: brightenScene
                      ? const [
                          Color(0x1F000000),
                          Color(0x4808090C),
                          Color(0x9408090C),
                        ]
                      : const [
                          Color(0x66000000),
                          Color(0xAA08090C),
                          Color(0xFA08090C),
                        ],
                  stops: const [0, 0.38, 1],
                ),
              ),
            ),
          ),
          IgnorePointer(
            ignoring: backgroundOnly,
            child: AnimatedSlide(
              offset: backgroundOnly ? const Offset(0, 0.018) : Offset.zero,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: backgroundOnly ? 0 : 1,
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                child: SafeArea(
                  child: Column(
                    children: [
                      if (!backgroundOnly)
                        _JourneyHeader(
                          sceneIndex: _sceneIndex,
                          step: _step,
                          completedSceneIds: widget.completedSceneIds,
                          selectedChoices: widget.selectedChoices,
                          soundOn: widget.soundOn,
                          onBack: _goBack,
                          onToggleSound: widget.onToggleSound,
                          onReset: widget.onReset,
                        ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 760),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 320),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 0.015),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    ),
                                child: _buildStep(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IgnorePointer(
            ignoring: !backgroundOnly,
            child: AnimatedOpacity(
              opacity: backgroundOnly ? 1 : 0,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              child: SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton.filledTonal(
                          key: const Key('background-map-back'),
                          tooltip: '여정 지도로',
                          onPressed: widget.onBackToOverview,
                          icon: const Icon(Icons.map_outlined),
                        ),
                        IconButton.filledTonal(
                          key: const Key('skip-scene-intro'),
                          tooltip: '연출 건너뛰기',
                          onPressed: _revealSceneNow,
                          icon: const Icon(Icons.fast_forward),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      JourneyStep.background => const SizedBox.shrink(
        key: ValueKey('scene-background'),
      ),
      JourneyStep.story => _SceneStoryStep(
        key: ValueKey('${_scene.id}-story'),
        scene: _scene,
        onNext: () => _goTo(JourneyStep.choice),
      ),
      JourneyStep.choice => _ChoiceStep(
        key: ValueKey('${_scene.id}-choice'),
        scene: _scene,
        selectedChoice: _selectedChoice,
        onSelect: _selectChoice,
        onNext: _selectedChoice == null
            ? null
            : () => _goTo(JourneyStep.scripture),
      ),
      JourneyStep.scripture => _ScriptureStep(
        key: ValueKey('${_scene.id}-scripture'),
        scene: _scene,
        choice: _selectedChoice!,
        onNext: () => _goTo(JourneyStep.reflection),
      ),
      JourneyStep.reflection => _ReflectionStep(
        key: ValueKey('${_scene.id}-reflection'),
        scene: _scene,
        controller: _reflectionController,
        onComplete: _completeScene,
      ),
      JourneyStep.complete => _CompleteStep(
        key: ValueKey('${_scene.id}-complete'),
        scene: _scene,
        choice: _selectedChoice!,
        reflection: _reflectionController.text.trim(),
        isLast: _sceneIndex == journeyScenes.length - 1,
        onNext: _nextScene,
      ),
      JourneyStep.summary => _SummaryStep(
        key: const ValueKey('summary'),
        answers: _answers,
        selectedChoices: widget.selectedChoices,
        onReset: widget.onReset,
      ),
    };
  }
}

class _JourneyHeader extends StatelessWidget {
  const _JourneyHeader({
    required this.sceneIndex,
    required this.step,
    required this.completedSceneIds,
    required this.selectedChoices,
    required this.soundOn,
    required this.onBack,
    required this.onToggleSound,
    required this.onReset,
  });

  final int sceneIndex;
  final JourneyStep step;
  final Set<String> completedSceneIds;
  final Map<String, int> selectedChoices;
  final bool soundOn;
  final VoidCallback onBack;
  final VoidCallback onToggleSound;
  final VoidCallback onReset;

  String get _stepLabel => switch (step) {
    JourneyStep.background => '장면',
    JourneyStep.story => '줄거리',
    JourneyStep.choice => '선택',
    JourneyStep.scripture => '말씀',
    JourneyStep.reflection => '적용',
    JourneyStep.complete => '기록',
    JourneyStep.summary => '완주',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (step != JourneyStep.summary)
                IconButton(
                  key: const Key('back-step'),
                  tooltip: '이전 화면',
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                ),
              const _Brand(compact: true),
              const Spacer(),
              Text(
                step == JourneyStep.summary
                    ? '여정 완료'
                    : '${sceneIndex + 1} / ${journeyScenes.length} · $_stepLabel',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                key: const Key('open-journey-log'),
                tooltip: '나의 여정',
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: const Color(0xFF151922),
                  showDragHandle: true,
                  isScrollControlled: true,
                  builder: (context) => _JourneyLogSheet(
                    selectedChoices: selectedChoices,
                    completedSceneIds: completedSceneIds,
                  ),
                ),
                icon: const Icon(Icons.route),
              ),
              IconButton(
                key: const Key('toggle-sound'),
                tooltip: soundOn ? '소리 끄기' : '소리 켜기',
                onPressed: onToggleSound,
                icon: Icon(soundOn ? Icons.volume_up : Icons.volume_off),
              ),
              IconButton(
                tooltip: '여정 초기화',
                onPressed: onReset,
                icon: const Icon(Icons.restart_alt),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (var index = 0; index < journeyScenes.length; index++) ...[
                Expanded(
                  child: Semantics(
                    label:
                        '${index + 1}번 장면, '
                        '${completedSceneIds.contains(journeyScenes[index].id)
                            ? '완료'
                            : index == sceneIndex && step != JourneyStep.summary
                            ? '진행 중'
                            : '미완료'}',
                    child: AnimatedContainer(
                      key: Key('scene-progress-${index + 1}'),
                      duration: const Duration(milliseconds: 240),
                      height: index == sceneIndex && step != JourneyStep.summary
                          ? 7
                          : 5,
                      decoration: BoxDecoration(
                        color:
                            completedSceneIds.contains(journeyScenes[index].id)
                            ? _gold
                            : index == sceneIndex && step != JourneyStep.summary
                            ? _gold.withValues(alpha: 0.65)
                            : Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                if (index < journeyScenes.length - 1) const SizedBox(width: 4),
              ],
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              if (step != JourneyStep.summary)
                Text(
                  '현재 선택 · ${_choiceTag(journeyScenes[sceneIndex])}',
                  key: const Key('current-choice-status'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              const Spacer(),
              Text(
                '${completedSceneIds.length}개 완료',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.52),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _choiceTag(JourneyScene scene) {
    final choiceIndex = selectedChoices[scene.id];
    if (choiceIndex == null ||
        choiceIndex < 0 ||
        choiceIndex >= scene.choices.length) {
      return '미선택';
    }
    return scene.choices[choiceIndex].tag;
  }
}

class _JourneyLogSheet extends StatelessWidget {
  const _JourneyLogSheet({
    required this.selectedChoices,
    required this.completedSceneIds,
  });

  final Map<String, int> selectedChoices;
  final Set<String> completedSceneIds;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.72,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '나의 여정',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                '${completedSceneIds.length} / ${journeyScenes.length} 장면 완료',
                style: const TextStyle(color: _gold),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: journeyScenes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final scene = journeyScenes[index];
                    final choiceIndex = selectedChoices[scene.id];
                    final choice =
                        choiceIndex != null &&
                            choiceIndex >= 0 &&
                            choiceIndex < scene.choices.length
                        ? scene.choices[choiceIndex]
                        : null;
                    return Container(
                      key: Key('journey-log-${scene.id}'),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: completedSceneIds.contains(scene.id)
                              ? _gold.withValues(alpha: 0.55)
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            completedSceneIds.contains(scene.id)
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: completedSceneIds.contains(scene.id)
                                ? _gold
                                : Colors.white38,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${index + 1}. ${scene.title}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  choice == null
                                      ? '아직 선택하지 않았습니다.'
                                      : '${choice.tag} · ${choice.label}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SceneStoryStep extends StatelessWidget {
  const _SceneStoryStep({super.key, required this.scene, required this.onNext});

  final JourneyScene scene;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _StepPanel(
      eyebrow: 'ODYSSEY SCENE',
      title: scene.title,
      children: [
        Text(
          scene.hook,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: _gold,
            height: 1.35,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          scene.story,
          key: const Key('scene-story'),
          style: const TextStyle(fontSize: 17, height: 1.75),
        ),
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _gold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _gold.withValues(alpha: 0.38)),
          ),
          child: Text(
            scene.question,
            style: const TextStyle(fontSize: 17, height: 1.55),
          ),
        ),
        const SizedBox(height: 20),
        _PrimaryButton(
          key: const Key('open-choices'),
          label: '어떻게 할까요?',
          icon: Icons.help_outline,
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _ChoiceStep extends StatelessWidget {
  const _ChoiceStep({
    super.key,
    required this.scene,
    required this.selectedChoice,
    required this.onSelect,
    required this.onNext,
  });

  final JourneyScene scene;
  final JourneyChoice? selectedChoice;
  final ValueChanged<JourneyChoice> onSelect;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return _StepPanel(
      eyebrow: '나의 선택',
      title: '어떻게 할까요?',
      children: [
        Text(
          scene.question,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.6),
        ),
        const SizedBox(height: 20),
        Column(
          key: const Key('scene-choices'),
          children: [
            for (final choice in scene.choices) ...[
              _ChoiceCard(
                choice: choice,
                selected: identical(choice, selectedChoice),
                onTap: () => onSelect(choice),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            _PrimaryButton(
              key: const Key('open-scripture'),
              label: '말씀으로 이동',
              icon: Icons.menu_book,
              onPressed: onNext,
            ),
          ],
        ),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final JourneyChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected
            ? _gold.withValues(alpha: 0.17)
            : Colors.white.withValues(alpha: 0.07),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: selected ? _gold : Colors.white.withValues(alpha: 0.18),
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? _gold : Colors.white70,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    choice.label,
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScriptureStep extends StatelessWidget {
  const _ScriptureStep({
    super.key,
    required this.scene,
    required this.choice,
    required this.onNext,
  });

  final JourneyScene scene;
  final JourneyChoice choice;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _StepPanel(
      eyebrow: 'STORY TO SCRIPTURE',
      title: '이야기에서 말씀으로',
      children: [
        _ScriptureCard(scene: scene),
        const SizedBox(height: 24),
        Text(
          '예언의 신 묵상 본문',
          key: const Key('devotional-heading'),
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: _gold, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        _DevotionalCard(scene: scene),
        const SizedBox(height: 20),
        Text(
          '말씀 묵상',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: _gold, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          scene.meditation,
          style: const TextStyle(fontSize: 16, height: 1.75),
        ),
        const SizedBox(height: 20),
        Text(
          '선택과 연결된 적용',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: _gold, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          choice.application,
          style: const TextStyle(fontSize: 16, height: 1.65),
        ),
        const SizedBox(height: 28),
        _PrimaryButton(
          key: const Key('open-reflection'),
          label: '나에게 적용하기',
          icon: Icons.edit_note,
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _DevotionalCard extends StatelessWidget {
  const _DevotionalCard({required this.scene});

  final JourneyScene scene;

  @override
  Widget build(BuildContext context) {
    final hasDevotional = scene.devotionalText.isNotEmpty;
    return Container(
      key: const Key('devotional-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _gold.withValues(alpha: 0.42)),
      ),
      child: hasDevotional
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scene.devotionalReference,
                  style: const TextStyle(
                    color: _gold,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  scene.devotionalText,
                  key: const Key('devotional-text'),
                  style: const TextStyle(fontSize: 16, height: 1.8),
                ),
              ],
            )
          : Text(
              '한글 원고에 이 장면의 예언의 신 묵상 본문이 아직 작성되지 않았습니다.',
              key: const Key('devotional-missing'),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.6,
              ),
            ),
    );
  }
}

class _ScriptureCard extends StatelessWidget {
  const _ScriptureCard({required this.scene});

  final JourneyScene scene;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1E3BC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _gold.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            scene.scriptureReference,
            style: const TextStyle(
              color: Color(0xFF7A321C),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            scene.scriptureText,
            style: const TextStyle(
              color: Color(0xFF352313),
              fontSize: 17,
              height: 1.65,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectionStep extends StatelessWidget {
  const _ReflectionStep({
    super.key,
    required this.scene,
    required this.controller,
    required this.onComplete,
  });

  final JourneyScene scene;
  final TextEditingController controller;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return _StepPanel(
      eyebrow: '나의 적용',
      title: scene.reflectionPrompt,
      children: [
        TextField(
          key: const Key('reflection-field'),
          controller: controller,
          maxLength: 160,
          minLines: 4,
          maxLines: 7,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: '한 문장으로 적어 보세요. 비워 두어도 괜찮습니다.',
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.42),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: _gold, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '작성한 문장은 서버로 전송하지 않으며 현재 여정에서만 사용합니다.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.68),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),
        _PrimaryButton(
          key: const Key('complete-scene'),
          label: '장면 기록하기',
          icon: Icons.bookmark_added,
          onPressed: onComplete,
        ),
      ],
    );
  }
}

class _CompleteStep extends StatelessWidget {
  const _CompleteStep({
    super.key,
    required this.scene,
    required this.choice,
    required this.reflection,
    required this.isLast,
    required this.onNext,
  });

  final JourneyScene scene;
  final JourneyChoice choice;
  final String reflection;
  final bool isLast;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _StepPanel(
      eyebrow: '장면 완료',
      title: scene.title,
      children: [
        _SummaryRow(label: '선택', value: choice.label),
        _SummaryRow(label: '주제', value: choice.tag),
        _SummaryRow(label: '말씀', value: scene.scriptureReference),
        if (reflection.isNotEmpty)
          _SummaryRow(label: '나의 적용', value: reflection),
        const SizedBox(height: 28),
        _PrimaryButton(
          key: const Key('next-scene'),
          label: isLast ? '여정 돌아보기' : '다음 장면으로',
          icon: isLast ? Icons.auto_stories : Icons.arrow_forward,
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _SummaryStep extends StatelessWidget {
  const _SummaryStep({
    super.key,
    required this.answers,
    required this.selectedChoices,
    required this.onReset,
  });

  final List<JourneyAnswer> answers;
  final Map<String, int> selectedChoices;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final savedChoices = <(JourneyScene, JourneyChoice)>[];
    for (final scene in journeyScenes) {
      final choiceIndex = selectedChoices[scene.id];
      if (choiceIndex != null &&
          choiceIndex >= 0 &&
          choiceIndex < scene.choices.length) {
        savedChoices.add((scene, scene.choices[choiceIndex]));
      }
    }

    return _StepPanel(
      eyebrow: 'JOURNEY COMPLETE',
      title: '다시 이타카를 향해',
      children: [
        Text(
          savedChoices.isEmpty
              ? '두 장면의 여정을 완료했습니다. 각 장면에서 만난 말씀과 적용을 다시 떠올려 보세요.'
              : '당신이 지나온 선택과 적용을 한곳에 모았습니다.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.6),
        ),
        const SizedBox(height: 20),
        for (final savedChoice in savedChoices) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  savedChoice.$1.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text('${savedChoice.$2.tag} · ${savedChoice.$2.label}'),
                const SizedBox(height: 6),
                Text(
                  savedChoice.$1.scriptureReference,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
                if (_reflectionFor(savedChoice.$1.id).isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(_reflectionFor(savedChoice.$1.id)),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        _PrimaryButton(
          key: const Key('reset-journey'),
          label: '새 여정 시작하기',
          icon: Icons.restart_alt,
          onPressed: onReset,
        ),
      ],
    );
  }

  String _reflectionFor(String sceneId) {
    for (final answer in answers) {
      if (answer.scene.id == sceneId) return answer.reflection;
    }
    return '';
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: const TextStyle(color: _gold, fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _LayeredSailingBackground extends StatefulWidget {
  const _LayeredSailingBackground({
    super.key,
    required this.plateAsset,
    required this.shipAsset,
    required this.sourceSize,
    required this.narrowAlignment,
    required this.semanticsLabel,
    this.sailPolygon = const [],
    this.sailPivot,
    this.departing = false,
  });

  final String plateAsset;
  final String shipAsset;
  final Size sourceSize;
  final Alignment narrowAlignment;
  final String semanticsLabel;
  final List<Offset> sailPolygon;
  final Offset? sailPivot;
  final bool departing;

  @override
  State<_LayeredSailingBackground> createState() =>
      _LayeredSailingBackgroundState();
}

class _LayeredSailingBackgroundState extends State<_LayeredSailingBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool? _motionDisabled;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disabled = MediaQuery.disableAnimationsOf(context);
    if (_motionDisabled == disabled) return;
    _motionDisabled = disabled;
    if (disabled) {
      _controller.stop();
      _controller.value = 0.5;
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticsLabel,
      image: true,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = Curves.easeInOut.transform(_controller.value);
            final wave = math.sin(progress * math.pi * 2);
            return LayoutBuilder(
              builder: (context, constraints) {
                final alignment = constraints.maxWidth < 700
                    ? widget.narrowAlignment
                    : Alignment.center;
                final fittedSize = applyBoxFit(
                  BoxFit.cover,
                  widget.sourceSize,
                  constraints.biggest,
                ).destination;
                final fittedOrigin = Offset(
                  (constraints.maxWidth - fittedSize.width) *
                      ((alignment.x + 1) / 2),
                  (constraints.maxHeight - fittedSize.height) *
                      ((alignment.y + 1) / 2),
                );
                final sailPivot = widget.sailPivot == null
                    ? Offset.zero
                    : fittedOrigin +
                          Offset(
                            widget.sailPivot!.dx * fittedSize.width,
                            widget.sailPivot!.dy * fittedSize.height,
                          );

                Widget shipImage() => Image.asset(
                  widget.shipAsset,
                  fit: BoxFit.cover,
                  alignment: alignment,
                  excludeFromSemantics: true,
                );

                Widget shipLayer = shipImage();
                if (widget.sailPolygon.isNotEmpty) {
                  final sailClipper = _CoverPolygonClipper(
                    sourceSize: widget.sourceSize,
                    alignment: alignment,
                    points: widget.sailPolygon,
                  );
                  shipLayer = Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipPath(
                        clipper: _CoverPolygonClipper(
                          sourceSize: widget.sourceSize,
                          alignment: alignment,
                          points: widget.sailPolygon,
                          inverted: true,
                        ),
                        child: shipImage(),
                      ),
                      Transform.scale(
                        scaleX: 1 + (wave * 0.012),
                        scaleY: 1 - (wave.abs() * 0.004),
                        origin: sailPivot,
                        alignment: null,
                        child: Transform.rotate(
                          angle: wave * 0.0025,
                          origin: sailPivot,
                          alignment: null,
                          child: ClipPath(
                            key: const Key('fluttering-sail'),
                            clipper: sailClipper,
                            child: ShaderMask(
                              blendMode: BlendMode.modulate,
                              shaderCallback: (bounds) => LinearGradient(
                                begin: Alignment(-1 + (wave * 0.12), -0.4),
                                end: Alignment(1 + (wave * 0.12), 0.4),
                                colors: const [
                                  Colors.white,
                                  Color(0xFFF0D6C0),
                                  Colors.white,
                                ],
                                stops: [0, 0.52, 1],
                              ).createShader(bounds),
                              child: shipImage(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRect(
                      child: Transform.translate(
                        offset: Offset(-7 * progress, -2 * progress),
                        child: Transform.scale(
                          scale: 1.045 + (0.025 * progress),
                          child: Image.asset(
                            widget.plateAsset,
                            fit: BoxFit.cover,
                            alignment: alignment,
                            excludeFromSemantics: true,
                          ),
                        ),
                      ),
                    ),
                    AnimatedSlide(
                      key: const Key('ship-departure'),
                      offset: widget.departing
                          ? const Offset(-1.25, 0.12)
                          : Offset.zero,
                      duration: const Duration(milliseconds: 1700),
                      curve: Curves.easeInCubic,
                      child: AnimatedScale(
                        scale: widget.departing ? 0.9 : 1,
                        duration: const Duration(milliseconds: 1700),
                        curve: Curves.easeInCubic,
                        child: AnimatedOpacity(
                          opacity: widget.departing ? 0 : 1,
                          duration: const Duration(milliseconds: 1700),
                          curve: const Interval(0.72, 1, curve: Curves.easeOut),
                          child: Transform.translate(
                            offset: Offset(-2 * wave, 7 * wave),
                            child: Transform.rotate(
                              angle: wave * 0.0035,
                              alignment: const Alignment(-0.55, 0.75),
                              child: Transform.scale(
                                scale: 1 + (wave.abs() * 0.0025),
                                child: shipLayer,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: CustomPaint(
                        painter: _AtmospherePainter(progress: progress),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CoverPolygonClipper extends CustomClipper<Path> {
  const _CoverPolygonClipper({
    required this.sourceSize,
    required this.alignment,
    required this.points,
    this.inverted = false,
  });

  final Size sourceSize;
  final Alignment alignment;
  final List<Offset> points;
  final bool inverted;

  @override
  Path getClip(Size size) {
    final fittedSize = applyBoxFit(BoxFit.cover, sourceSize, size).destination;
    final origin = Offset(
      (size.width - fittedSize.width) * ((alignment.x + 1) / 2),
      (size.height - fittedSize.height) * ((alignment.y + 1) / 2),
    );
    final polygon = Path();
    for (var index = 0; index < points.length; index++) {
      final point =
          origin +
          Offset(
            points[index].dx * fittedSize.width,
            points[index].dy * fittedSize.height,
          );
      if (index == 0) {
        polygon.moveTo(point.dx, point.dy);
      } else {
        polygon.lineTo(point.dx, point.dy);
      }
    }
    polygon.close();
    if (!inverted) return polygon;
    return Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      polygon,
    );
  }

  @override
  bool shouldReclip(covariant _CoverPolygonClipper oldClipper) =>
      oldClipper.sourceSize != sourceSize ||
      oldClipper.alignment != alignment ||
      oldClipper.points != points ||
      oldClipper.inverted != inverted;
}

class _LivingBackground extends StatefulWidget {
  const _LivingBackground({
    super.key,
    required this.imageAsset,
    required this.alignment,
    required this.semanticsLabel,
  });

  final String imageAsset;
  final Alignment alignment;
  final String semanticsLabel;

  @override
  State<_LivingBackground> createState() => _LivingBackgroundState();
}

class _LivingBackgroundState extends State<_LivingBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool? _motionDisabled;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disabled = MediaQuery.disableAnimationsOf(context);
    if (_motionDisabled == disabled) return;
    _motionDisabled = disabled;
    if (disabled) {
      _controller.stop();
      _controller.value = 0.5;
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticsLabel,
      image: true,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = Curves.easeInOut.transform(_controller.value);
            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRect(
                  child: Transform.rotate(
                    angle: (progress - 0.5) * 0.006,
                    alignment: Alignment.bottomLeft,
                    child: Transform.translate(
                      offset: Offset(18 * (progress - 0.5), 5 * progress),
                      child: Transform.scale(
                        scale: 1.06 + (0.035 * progress),
                        child: Image.asset(
                          widget.imageAsset,
                          fit: BoxFit.cover,
                          alignment: widget.alignment,
                          excludeFromSemantics: true,
                        ),
                      ),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: CustomPaint(
                    painter: _AtmospherePainter(progress: progress),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AtmospherePainter extends CustomPainter {
  const _AtmospherePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    final cloudX = (size.width * 1.45 * progress) - (size.width * 0.35);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cloudX, size.height * 0.18),
        width: size.width * 0.36,
        height: size.height * 0.075,
      ),
      cloudPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width - (cloudX * 0.55), size.height * 0.3),
        width: size.width * 0.25,
        height: size.height * 0.055,
      ),
      cloudPaint..color = Colors.white.withValues(alpha: 0.05),
    );

    for (var layer = 0; layer < 3; layer++) {
      final baseY = size.height * (0.7 + (layer * 0.045));
      final amplitude = 5.0 + (layer * 2.5);
      final path = Path()..moveTo(0, baseY);
      for (double x = 0; x <= size.width; x += 12) {
        final phase =
            ((x / size.width) * math.pi * 4.2) +
            (progress * math.pi * 2) +
            layer;
        path.lineTo(x, baseY + (math.sin(phase) * amplitude));
      }
      path
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = Color.fromRGBO(
            50 + (layer * 12),
            105 + (layer * 8),
            140 + (layer * 12),
            0.07,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _StepPanel extends StatelessWidget {
  const _StepPanel({
    required this.eyebrow,
    required this.title,
    required this.children,
  });

  final String eyebrow;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xD9141720),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 32,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              color: _gold,
              fontSize: 12,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(height: 1.25, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (!compact)
          Text(
            '동중한합회 청년연합예배',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        const Text(
          'GODFLIX',
          style: TextStyle(
            color: Color(0xFFE50914),
            letterSpacing: 1.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
