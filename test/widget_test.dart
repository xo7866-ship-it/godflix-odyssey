import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:godflix/ambient_audio.dart';
import 'package:godflix/data/scenes.dart';
import 'package:godflix/fullscreen_controller.dart';
import 'package:godflix/godflix_app.dart';
import 'package:godflix/progress_store.dart';

void main() {
  test('all eleven journey scenes have complete interaction content', () {
    expect(journeyScenes, hasLength(11));
    expect(journeyScenes.map((scene) => scene.id).toSet(), hasLength(11));
    for (final scene in journeyScenes) {
      expect(scene.story, isNotEmpty);
      expect(scene.scriptureReference, isNotEmpty);
      expect(scene.reflectionPrompt, isNotEmpty);
      expect(scene.choices, hasLength(3));
    }
  });

  test('episode titles match the approved wording exactly', () {
    expect(journeyScenes.map((scene) => scene.title), [
      '왕이 없는 섬, 이타카',
      '철옹성을 무너뜨린 속임수, 트로이 목마',
      '양을 따라간 곳에서 만난 괴물, 외눈박이 거인',
      '위험한 초대, 키르케의 섬과 돼지들',
      '죽은 자들에게 묻는 비극, 테이레시아스',
      '들을 수 없는 노래, 세이렌',
      '비참한 선택, 소용돌이와 여섯 괴물',
      '가장 잔인한 농담, 제우스 섬의 소들',
      '부서지는 배와 절규, 격심한 폭풍',
      '넘어진 자리, 칼립소의 섬',
      '왕의 귀환, 다시, 이타카',
    ]);
  });

  test('scene hooks match the approved yellow captions exactly', () {
    expect(journeyScenes.map((scene) => scene.hook), [
      '왕이 없는 섬에 들끓는 ‘구혼자들’',
      '요새를 무너뜨리는 ‘바늘구멍’',
      '홀린 듯 빨려 들어간 ‘함정’',
      '치명적인 ‘친절’',
      '어리석은 ‘구조요청’',
      '죽음이 부르는 ‘유혹’',
      '최악과 차악 사이에서',
      '마음을 무너뜨리는 ‘조롱’',
      '가장 두려운 결과 ‘몰살’',
      '무감각의 ‘무덤’',
      '숨어든 ‘진짜’',
    ]);
  });

  test('scene questions match the updated source document', () {
    expect(journeyScenes.map((scene) => scene.question), [
      '내 삶에 하나님이 계시지 않아 생긴 어려움과 혼란이 있나요?',
      '나를 넘어뜨리는 단 한 가지 유혹이 있나요?',
      '작은 타협이 걷잡을 수 없이 커다란 죄에 빠지는 시발점이 되었던 적이 있나요?',
      '나에게 가장 교묘히 다가오는 죄의 유혹은 무엇인가요?',
      '하나님을 떠나 방법을 찾으려고 고군분투했던 적이 있나요?',
      '차라리 모르는 게 나았다고 생각하는 죄가 있나요?',
      '막다른 길에 다다른 경험이 있나요?',
      '끝이 보이지 않는 긴 터널 가운데 서 있다고 느껴본 적이 있나요?',
      '신앙의 여정에서 내가 가장 혹심하게 흔들렸던 적이 있나요?',
      '신앙에서 길을 잃어버렸던 적이 있나요?',
      '아무리 사단의 목소리가 커도, 조용하지만 분명히 역사하시는 하나님을 경험해 본 적이 있나요?',
    ]);
  });

  test('updated source stories and Calypso scripture are connected', () {
    expect(journeyScenes[1].story, contains('10년을 버틴 성은 하룻밤만에'));
    expect(journeyScenes[5].story, contains('내가 어긴 약속들의 노래'));
    expect(journeyScenes[9].hook, '무감각의 ‘무덤’');
    expect(journeyScenes[9].story, startsWith('늙은 남자는'));
    expect(journeyScenes[9].story, contains('파편을 모읍니다'));
    expect(journeyScenes[9].scriptureReference, '이사야 17장 9절');
    expect(journeyScenes[9].scriptureText, contains('네 구원의 하나님을 잊어버리며'));
    expect(journeyScenes[10].story, startsWith('“--”'));
  });

  test('provided scene artwork is connected to scenes two through eight', () {
    expect(journeyScenes.skip(1).take(7).map((scene) => scene.imageAsset), [
      'assets/images/scene_2_troy.jpg',
      'assets/images/scene_3_cyclops.jpg',
      'assets/images/scene_4_circe.jpg',
      'assets/images/scene_5_underworld.jpg',
      'assets/images/scene_6_sirens.jpg',
      'assets/images/scene_7_scylla.jpg',
      'assets/images/scene_8_helios.jpg',
    ]);
  });

  test('episode audio is connected and the return uses sea ambience', () {
    expect(journeyScenes.map((scene) => scene.audioAsset), [
      'assets/audio/scene_1_ithaca.m4a',
      'assets/audio/scene_2_troy.m4a',
      'assets/audio/scene_3_cyclops.m4a',
      'assets/audio/scene_4_circe.m4a',
      'assets/audio/scene_5_underworld.m4a',
      'assets/audio/scene_6_sirens.m4a',
      'assets/audio/scene_7_scylla.m4a',
      'assets/audio/scene_8_helios.m4a',
      'assets/audio/scene_9_storm.m4a',
      'assets/audio/scene_10_calypso.m4a',
      AmbientAudio.defaultAsset,
    ]);
  });

  test('ambient audio remembers the active track and ducked volume', () async {
    final audio = AmbientAudio();
    await audio.play(asset: 'assets/audio/scene_6_sirens.m4a', volume: 0.32);
    expect(audio.isPlaying, isTrue);
    expect(audio.asset, 'assets/audio/scene_6_sirens.m4a');
    expect(audio.volume, 0.32);

    audio.setVolume(0.09);
    expect(audio.volume, 0.09);
    audio.pause();
    expect(audio.isPlaying, isFalse);
  });

  test('journey content uses Seventh-day Adventist terminology', () {
    final content = journeyScenes
        .expand(
          (scene) => [
            scene.title,
            scene.hook,
            scene.story,
            scene.question,
            scene.scriptureText,
            scene.meditation,
            scene.devotionalReference,
            scene.devotionalText,
            scene.reflectionPrompt,
            ...scene.choices.expand(
              (choice) => [choice.label, choice.tag, choice.application],
            ),
          ],
        )
        .join(' ');

    expect(content, isNot(contains('세례')));
    expect(content, isNot(contains('주일')));
    expect(content, contains('요한의 침례'));
  });

  test('devotional passages are connected to their scenes', () {
    final devotionalScenes = journeyScenes
        .where((scene) => scene.devotionalText.isNotEmpty)
        .toList();
    final ithaca = journeyScenes.firstWhere((scene) => scene.id == 'ithaca');
    final troy = journeyScenes.firstWhere((scene) => scene.id == 'troy');

    expect(devotionalScenes, hasLength(7));
    expect(ithaca.devotionalReference, '시대의 소망 323-324p');
    expect(ithaca.devotionalText, contains('악에 대한 유일의 방어'));
    expect(troy.devotionalReference, '부조와 선지자 71장');
    expect(troy.devotionalText, contains('비밀리에 원칙의 요새를 침식'));
  });

  test('Ithaca story uses the approved three paragraphs', () {
    final ithaca = journeyScenes.firstWhere((scene) => scene.id == 'ithaca');

    expect(
      ithaca.story,
      '“날 선택하고 이 기다림을 끝내요”\n\n'
      '왕이 없는 왕성은 이미 침범당했습니다.\n\n'
      '물리칠 능력이 없는 어머니와 아들은 더 이상 지킬 수 있는 명예도, 체면도 없습니다.',
    );
  });

  testWidgets('first scene reaches scripture and the next scene', (
    tester,
  ) async {
    final store = ProgressStore();
    await tester.pumpWidget(GodflixApp(progressStore: store));

    expect(
      find.byKey(const Key('landing-cinematic-background')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('fluttering-sail')), findsOneWidget);
    final landingAssets = tester
        .widgetList<Image>(find.byType(Image))
        .where((image) => image.image is AssetImage)
        .map((image) => (image.image as AssetImage).assetName)
        .toSet();
    expect(landingAssets, contains('assets/images/landing_ithaca_plate.png'));
    expect(landingAssets, contains('assets/images/landing_ithaca_ship.png'));
    expect(find.text('여정 시작하기'), findsOneWidget);
    await tester.tap(find.byKey(const Key('start-journey')));
    await tester.pump();

    final departure = tester.widget<AnimatedSlide>(
      find.byKey(const Key('ship-departure')),
    );
    expect(departure.offset, const Offset(-1.25, 0.12));
    expect(find.text('오디세이 여정 지도'), findsNothing);
    await _pumpDeparture(tester);

    expect(find.text('오디세이 여정 지도'), findsNothing);
    await _revealOverview(tester);
    expect(find.text('오디세이 여정 지도'), findsOneWidget);
    expect(find.byKey(const Key('fluttering-sail')), findsNothing);
    final overviewAssets = tester
        .widgetList<Image>(find.byType(Image))
        .where((image) => image.image is AssetImage)
        .map((image) => (image.image as AssetImage).assetName)
        .toSet();
    expect(overviewAssets, contains('assets/images/landing_ithaca_plate.png'));
    expect(
      overviewAssets,
      isNot(contains('assets/images/landing_ithaca_ship.png')),
    );
    expect(find.byKey(const Key('map-scene-10')), findsOneWidget);
    expect(
      tester
          .widgetList<Image>(find.byType(Image))
          .any(
            (image) =>
                image.image is AssetImage &&
                (image.image as AssetImage).assetName.endsWith(
                  'odyssey_map_ancient.png',
                ),
          ),
      isTrue,
    );
    await _tapVisible(tester, find.byKey(const Key('map-scene-0')));
    await _pumpTransition(tester);

    expect(find.byKey(const Key('scene-story')), findsNothing);
    expect(find.byKey(const Key('scene-choices')), findsNothing);
    await _revealScene(tester);

    expect(find.text('왕이 없는 섬, 이타카'), findsOneWidget);
    expect(find.byKey(const Key('scene-story')), findsOneWidget);
    expect(find.byKey(const Key('scene-choices')), findsNothing);
    await _tapVisible(tester, find.byKey(const Key('open-choices')));
    await _pumpTransition(tester);

    expect(find.byKey(const Key('scene-choices')), findsOneWidget);

    await _tapVisible(tester, find.text('잠시 멈추고 기준을 다시 묻는다'));
    await tester.pump();
    expect(store.readSelections(), {'ithaca': 2});
    await _tapVisible(tester, find.byKey(const Key('open-scripture')));
    await _pumpTransition(tester);

    expect(find.text('사사기 17장 6절'), findsOneWidget);
    expect(find.byKey(const Key('devotional-heading')), findsOneWidget);
    expect(find.text('시대의 소망 323-324p'), findsOneWidget);
    expect(find.byKey(const Key('devotional-text')), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.descendant(
              of: find.byKey(const Key('open-reflection')),
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed,
      isNotNull,
    );
    await _tapVisible(tester, find.byKey(const Key('open-reflection')));
    await _pumpTransition(tester);
    await tester.enterText(
      find.byKey(const Key('reflection-field')),
      '결정 전에 기도하기',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await _tapVisible(tester, find.byKey(const Key('complete-scene')));
    await _pumpTransition(tester);

    expect(store.readCompletedSceneIds(), {'ithaca'});
    await _tapVisible(tester, find.byKey(const Key('next-scene')));
    await _pumpTransition(tester);
    await _revealScene(tester);
    expect(find.text('철옹성을 무너뜨린 속임수, 트로이 목마'), findsOneWidget);
  });

  testWidgets('saved progress resumes at the second scene', (tester) async {
    final store = ProgressStore(
      initialCompletedScenes: 1,
      initialSelections: const {'ithaca': 2},
    );
    await tester.pumpWidget(GodflixApp(progressStore: store));

    expect(find.text('이어서 여정하기'), findsOneWidget);
    await tester.tap(find.byKey(const Key('start-journey')));
    await _pumpDeparture(tester);
    await _revealOverview(tester);
    expect(find.text('1 / 11 장면 완료'), findsOneWidget);
    await _tapVisible(tester, find.byKey(const Key('map-scene-1')));
    await _pumpTransition(tester);
    await _revealScene(tester);

    expect(find.text('철옹성을 무너뜨린 속임수, 트로이 목마'), findsOneWidget);
    expect(find.text('2 / 11 · 줄거리'), findsOneWidget);
    expect(find.byKey(const Key('current-choice-status')), findsOneWidget);
    expect(find.byKey(const Key('scene-progress-11')), findsOneWidget);
    final sceneImage = tester
        .widgetList<Image>(find.byType(Image))
        .firstWhere(
          (image) =>
              image.image is AssetImage &&
              (image.image as AssetImage).assetName.endsWith(
                'scene_2_troy.jpg',
              ),
        );
    expect(sceneImage.alignment, const Alignment(-0.36, 0));
  });

  testWidgets('return scene uses the layered cinematic background', (
    tester,
  ) async {
    await tester.pumpWidget(GodflixApp(progressStore: ProgressStore()));

    await tester.tap(find.byKey(const Key('start-journey')));
    await _pumpDeparture(tester);
    await tester.tap(find.byKey(const Key('skip-overview-intro')));
    await _pumpTransition(tester);
    await _tapVisible(tester, find.byKey(const Key('map-scene-10')));
    await _pumpTransition(tester);

    expect(
      find.byKey(const Key('return-cinematic-background')),
      findsOneWidget,
    );
    final assets = tester
        .widgetList<Image>(find.byType(Image))
        .where((image) => image.image is AssetImage)
        .map((image) => (image.image as AssetImage).assetName)
        .toSet();
    expect(assets, contains('assets/images/scene_11_ithaca_plate.png'));
    expect(assets, contains('assets/images/scene_11_ithaca_ship.png'));
  });

  testWidgets('intro skip, journey log, and back navigation work', (
    tester,
  ) async {
    final store = ProgressStore();
    await tester.pumpWidget(GodflixApp(progressStore: store));

    await tester.tap(find.byKey(const Key('start-journey')));
    await _pumpDeparture(tester);
    await tester.tap(find.byKey(const Key('skip-overview-intro')));
    await _pumpTransition(tester);
    await _tapVisible(tester, find.byKey(const Key('map-scene-0')));
    await _pumpTransition(tester);
    await tester.tap(find.byKey(const Key('skip-scene-intro')));
    await _pumpTransition(tester);

    expect(find.text('1 / 11 · 줄거리'), findsOneWidget);
    await _tapVisible(tester, find.byKey(const Key('open-choices')));
    await _pumpTransition(tester);
    await _tapVisible(tester, find.text('잠시 멈추고 기준을 다시 묻는다'));
    await tester.pump();

    tester
        .widget<IconButton>(find.byKey(const Key('back-step')))
        .onPressed
        ?.call();
    await _pumpTransition(tester);
    expect(find.byKey(const Key('scene-story')), findsOneWidget);
    expect(find.byKey(const Key('scene-choices')).hitTestable(), findsNothing);

    tester
        .widget<IconButton>(find.byKey(const Key('back-step')))
        .onPressed
        ?.call();
    await _pumpTransition(tester);
    expect(find.text('오디세이 여정 지도'), findsOneWidget);

    await tester.tap(find.byKey(const Key('map-journey-log')));
    await _pumpTransition(tester);
    expect(find.text('0 / 11 장면 완료'), findsNWidgets(2));
    expect(find.byKey(const Key('journey-log-ithaca')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('journey-log-ithaca')),
        matching: find.textContaining('의지'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('compact map shows the map above eleven ordered episodes', (
    tester,
  ) async {
    _setViewport(tester, const Size(390, 844));
    await tester.pumpWidget(GodflixApp(progressStore: ProgressStore()));

    await tester.tap(find.byKey(const Key('start-journey')));
    await _pumpDeparture(tester);
    await tester.tap(find.byKey(const Key('skip-overview-intro')));
    await _pumpTransition(tester);

    expect(find.byKey(const Key('compact-map-layout')), findsOneWidget);
    expect(find.byKey(const Key('regular-map-layout')), findsNothing);
    expect(find.byKey(const Key('compact-map-image')), findsOneWidget);
    for (var index = 0; index < journeyScenes.length; index++) {
      expect(find.byKey(Key('map-scene-$index')), findsOneWidget);
    }
    expect(
      tester.getBottomLeft(find.byKey(const Key('compact-map-image'))).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('map-scene-0'))).dy),
    );
    expect(tester.takeException(), isNull);

    await _tapVisible(tester, find.byKey(const Key('map-scene-10')));
    await _pumpTransition(tester);
    expect(
      find.byKey(const Key('return-cinematic-background')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('skip-scene-intro')));
    await _pumpTransition(tester);
    expect(find.byKey(const Key('toggle-fullscreen')), findsOneWidget);
    expect(find.text('11 / 11 · 줄거리'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide iPad layout keeps the positioned journey map', (
    tester,
  ) async {
    _setViewport(tester, const Size(1024, 768));
    await tester.pumpWidget(GodflixApp(progressStore: ProgressStore()));

    await tester.tap(find.byKey(const Key('start-journey')));
    await _pumpDeparture(tester);
    await tester.tap(find.byKey(const Key('skip-overview-intro')));
    await _pumpTransition(tester);

    expect(find.byKey(const Key('regular-map-layout')), findsOneWidget);
    expect(find.byKey(const Key('compact-map-layout')), findsNothing);
    expect(find.byKey(const Key('map-scene-10')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fullscreen is user-selected and tracks its exit state', (
    tester,
  ) async {
    final fullscreen = FullscreenController(isSupported: true);
    await tester.pumpWidget(
      GodflixApp(
        progressStore: ProgressStore(),
        fullscreenController: fullscreen,
      ),
    );

    expect(fullscreen.isFullscreen, isFalse);
    await tester.tap(find.byKey(const Key('toggle-fullscreen-landing')));
    await tester.pump();
    expect(fullscreen.isFullscreen, isTrue);
    expect(find.byIcon(Icons.fullscreen_exit), findsOneWidget);

    await tester.tap(find.byKey(const Key('toggle-fullscreen-landing')));
    await tester.pump();
    expect(fullscreen.isFullscreen, isFalse);
    expect(find.byIcon(Icons.fullscreen), findsOneWidget);
  });

  testWidgets('unsupported fullscreen shows web app guidance', (tester) async {
    await tester.pumpWidget(GodflixApp(progressStore: ProgressStore()));

    await tester.tap(find.byKey(const Key('toggle-fullscreen-landing')));
    await _pumpTransition(tester);

    expect(find.byKey(const Key('fullscreen-help')), findsOneWidget);
    expect(find.textContaining('홈 화면에 추가'), findsOneWidget);
  });
}

void _setViewport(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
}

Future<void> _pumpTransition(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _pumpDeparture(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 1900));
}

Future<void> _revealOverview(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(milliseconds: 800));
}

Future<void> _revealScene(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
}
