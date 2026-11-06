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
      expect(scene.discussion, isNotEmpty);
      expect(scene.scriptureReference, isNotEmpty);
      expect(scene.reflectionPrompt, isNotEmpty);
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
      '조용하지만 분명히 역사하시는 하나님을 경험해 본 적이 있나요?',
    ]);
  });

  test('discussion copy matches the approved wording exactly', () {
    expect(journeyScenes.map((scene) => scene.discussion), [
      '우리는 하나님을 믿으면서도 때로는 그분을 잊은 채 살아갑니다. 중요한 결정을 혼자 내리고, 모든 책임을 스스로 감당하려 애쓰기도 합니다. 그렇게 분주하게 살아가다 문득, 무엇을 위해 이토록 애쓰고 있는지 알 수 없어지는 순간이 찾아오기도 합니다.',
      '누구에게나 유독 약해지는 순간이 있습니다. 다른 일에는 흔들리지 않다가도 어떤 상황이나 감정 앞에서는 쉽게 무너지곤 합니다. 몇 번이고 다짐했지만 같은 실수를 반복하는 자신의 모습에 실망하기도 합니다.',
      '처음에는 그저 사소한 선택이었습니다. 이 정도는 괜찮을 거라 생각했고, 언제든 마음만 먹으면 돌아갈 수 있다고 믿었습니다. 그러나 시간이 흐른 뒤 돌아보면, 어느새 처음에는 생각지도 못했던 곳에 서 있는 자신을 발견하기도 합니다.',
      '잘못된 선택이라는 것을 알면서도 마음이 끌리는 순간이 있습니다. 때로는 그 선택을 정당화할 이유들이 너무도 그럴듯하게 느껴집니다. 결국 우리는 누군가에게 속기보다 스스로 만들어 낸 변명에 설득되어 버리기도 합니다.',
      '문제가 생기면 당장 무언가를 해야만 할 것 같은 조급함이 찾아옵니다. 사람을 찾아가고, 정보를 모으고, 할 수 있는 모든 방법을 동원하지만 마음은 좀처럼 편안해지지 않습니다. 모든 힘을 쏟아낸 뒤에야 혼자서는 해결할 수 없는 일도 있다는 사실을 깨닫곤 합니다.',
      '처음에는 단순한 호기심이었을지도 모릅니다. 하지만 한 번 경험한 즐거움이 자꾸만 생각나고, 잊었다고 여겼던 마음이 어느 순간 다시 고개를 들기도 합니다. 어떤 경험은 지나간 뒤에도 오랫동안 마음에 남아 우리의 선택을 흔들어 놓습니다.',
      '살다 보면 어느 쪽을 선택해도 마음이 무거운 순간이 있습니다. 모두를 지키고 싶지만 그럴 수 없고, 최선을 다했음에도 누군가에게 상처를 남기기도 합니다. 무엇이 최선이었는지 끝내 확신하지 못한 채, 그 선택의 무게를 오래도록 짊어지고 살아가기도 합니다.',
      '아무리 노력해도 상황이 달라지지 않는 시간이 있습니다. 처음에는 희망을 품고 기다렸지만, 시간이 길어질수록 기대보다 지친 마음이 앞서기도 합니다. 하루하루를 버텨내는 것만으로도 벅차서, 내일을 생각할 힘조차 남아 있지 않은 날도 있습니다.',
      '하나님을 믿고 의지했음에도 이해할 수 없는 일이 일어날 때가 있습니다. 간절히 기도했지만 바라던 결과를 얻지 못하고, 소중히 여겼던 것을 잃어버리기도 합니다. 그런 순간에는 지금까지 믿어 왔던 것마저 낯설게 느껴지고, 하나님을 향한 마음에 깊은 침묵이 찾아오기도 합니다.',
      '처음부터 하나님을 떠나려고 했던 것은 아닙니다. 그저 하루하루 바쁘게 살아가다 보니 기도하는 시간이 줄어들고, 어느새 예배도 익숙한 습관이 되어버립니다. 그렇게 시간이 흐른 어느 날, 하나님과 가까웠던 시절의 자신이 문득 낯설고 그립게 느껴지기도 합니다.',
      '살아가는 동안에는 미처 깨닫지 못했던 은혜들이 있습니다. 힘들었던 시절 곁을 지켜준 사람, 예상하지 못한 순간에 열렸던 길, 무너지지 않고 지나온 시간들이 그렇습니다. 돌아보면 평범한 일상이라고 생각했던 순간들 속에도 하나님의 손길이 조용히 머물러 있었음을 깨닫게 됩니다.',
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
    expect(landingAssets, contains('assets/images/godflix_logo_g_v1.png'));
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
    expect(find.byKey(const Key('scene-discussion')), findsNothing);
    expect(find.text('왕이 없는 섬, 이타카'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    expect(find.byKey(const Key('scene-story')), findsNothing);
    expect(find.byKey(const Key('continue-scene-intro')), findsOneWidget);
    await _revealScene(tester);

    expect(
      find.byKey(const Key('scene-intro-title')).hitTestable(),
      findsNothing,
    );
    expect(find.byKey(const Key('scene-story')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('current-episode-title'))).data,
      '왕이 없는 섬, 이타카',
    );
    expect(find.byKey(const Key('scene-discussion')), findsNothing);
    expect(find.byKey(const Key('open-choices')), findsOneWidget);
    expect(find.text('어떻게 할까요?'), findsNothing);
    await _tapVisible(tester, find.byKey(const Key('open-choices')));
    await _pumpTransition(tester);

    expect(find.byKey(const Key('scene-discussion')), findsOneWidget);
    expect(
      find.text('내 삶에 하나님이 계시지 않아 생긴 어려움과 혼란이 있나요?').hitTestable(),
      findsOneWidget,
    );
    expect(find.text('어떻게 할까요?'), findsNothing);

    expect(store.readSelections(), isEmpty);
    await _tapVisible(tester, find.byKey(const Key('open-scripture')));
    await _pumpTransition(tester);

    expect(find.text('사사기 17장 6절'), findsOneWidget);
    final scriptureCard = tester.widget<Container>(
      find.byKey(const Key('scripture-card')),
    );
    expect(
      (scriptureCard.decoration! as BoxDecoration).color,
      const Color(0xFFF5C542),
    );
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
    expect(find.byKey(const Key('scene-story')), findsOneWidget);
    expect(find.text('요새를 무너뜨리는 ‘바늘구멍’'), findsOneWidget);
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

    expect(find.text('요새를 무너뜨리는 ‘바늘구멍’'), findsOneWidget);
    expect(find.text('2 / 11 · 줄거리'), findsOneWidget);
    expect(find.byKey(const Key('current-stage-status')), findsOneWidget);
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
    await tester.tap(find.byKey(const Key('continue-scene-intro')));
    await _pumpTransition(tester);

    expect(find.text('1 / 11 · 줄거리'), findsOneWidget);
    await _tapVisible(tester, find.byKey(const Key('open-choices')));
    await _pumpTransition(tester);
    expect(find.byKey(const Key('scene-discussion')), findsOneWidget);

    tester
        .widget<IconButton>(find.byKey(const Key('back-step')))
        .onPressed
        ?.call();
    await _pumpTransition(tester);
    expect(find.byKey(const Key('scene-story')), findsOneWidget);
    expect(
      find.byKey(const Key('scene-discussion')).hitTestable(),
      findsNothing,
    );

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
        matching: find.textContaining('내 삶에 하나님이 계시지 않아'),
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
    await tester.tap(find.byKey(const Key('continue-scene-intro')));
    await _pumpTransition(tester);
    expect(find.byKey(const Key('toggle-fullscreen')), findsOneWidget);
    expect(find.text('11 / 11 · 줄거리'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact step transitions restart at the top without a jump', (
    tester,
  ) async {
    _setViewport(tester, const Size(390, 844));
    await tester.pumpWidget(GodflixApp(progressStore: ProgressStore()));

    await tester.tap(find.byKey(const Key('start-journey')));
    await _pumpDeparture(tester);
    await tester.tap(find.byKey(const Key('skip-overview-intro')));
    await _pumpTransition(tester);
    await _tapVisible(tester, find.byKey(const Key('map-scene-0')));
    await _pumpTransition(tester);
    final introTitle = find.byKey(const Key('scene-intro-title')).hitTestable();
    final introNext = find
        .byKey(const Key('continue-scene-intro'))
        .hitTestable();
    expect(find.text('에피소드 1'), findsOneWidget);
    expect(tester.getTopLeft(introTitle).dx, lessThan(80));
    expect(tester.getTopLeft(introTitle).dy, lessThan(200));
    expect(tester.getBottomRight(introNext).dx, greaterThan(300));
    expect(tester.getBottomRight(introNext).dy, greaterThan(700));
    await _revealScene(tester);
    await _tapVisible(tester, find.byKey(const Key('open-choices')));
    await _pumpTransition(tester);

    final question = find
        .text('내 삶에 하나님이 계시지 않아 생긴 어려움과 혼란이 있나요?')
        .hitTestable();
    expect(question, findsOneWidget);
    expect(tester.getTopLeft(question).dy, lessThan(360));
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide iPad keeps the map and top-aligned step transitions', (
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

    await _tapVisible(tester, find.byKey(const Key('map-scene-0')));
    await _pumpTransition(tester);
    final introTitle = find.byKey(const Key('scene-intro-title')).hitTestable();
    final introNext = find
        .byKey(const Key('continue-scene-intro'))
        .hitTestable();
    expect(introTitle, findsOneWidget);
    expect(tester.getTopLeft(introTitle).dx, lessThan(80));
    expect(tester.getTopLeft(introTitle).dy, lessThan(200));
    expect(tester.getBottomRight(introNext).dx, greaterThan(900));
    expect(tester.getBottomRight(introNext).dy, greaterThan(650));
    await _revealScene(tester);
    await _tapVisible(tester, find.byKey(const Key('open-choices')));
    await _pumpTransition(tester);

    final question = find
        .text('내 삶에 하나님이 계시지 않아 생긴 어려움과 혼란이 있나요?')
        .hitTestable();
    expect(question, findsOneWidget);
    expect(tester.getTopLeft(question).dy, lessThan(360));
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
  await tester.tap(find.byKey(const Key('continue-scene-intro')));
  await _pumpTransition(tester);
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
}
