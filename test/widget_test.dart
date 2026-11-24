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
      expect(scene.meditation, isNotEmpty);
      expect(scene.reflectionPrompt, isNotEmpty);
      expect(scene.closingMessage, isNotEmpty);
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
      '내 삶에 가장 큰 자리를 차지하고 있는 것은 무엇인가요?\n\n그것이 내 삶에 어떤 어려움과 혼란을 야기하고 있나요?\n\n하나님께서는 이에 대해 뭐라고 말씀하실까요? 말씀을 함께 읽어봅시다.',
      '나를 하나님에게서 멀어지게 하는 작은 계기가 있나요?\n\n내가 그 계기를 자꾸 허용하고 마는 이유는 무엇인가요?\n\n하나님께서는 이에 대해 뭐라고 말씀하실까요? 말씀을 함께 읽어봅시다.',
      '하나님의 말씀과 세상 사이에서 나는 보통 어떤 타협을 하나요?\n\n그 타협의 연쇄 반응으로 어떤 일들이 벌어지나요?\n\n하나님께서는 이에 대해 뭐라고 말씀하실까요? 말씀을 함께 읽어봅시다.',
      '나에게 나쁜 영향이 될 줄 모르고 시작했는데, ‘아차’ 했던 것이 있나요?\n\n나는 어떻게 그 악영향에서 벗어날 수 있었나요? (혹은, 아직 벗어나지 못한 이유는 무엇인가요?)\n\n하나님께서는 이에 대해 뭐라고 말씀하실까요? 말씀을 함께 읽어봅시다.',
      '세상에서 방법을 찾으려고 노력했던 것이 있나요?\n\n어떤 노력을 했고, 그 과정과 결과가 어땠나요?\n\n하나님께서는 이에 대해 뭐라고 말씀하실까요? 말씀을 함께 읽어봅시다.',
      '겪어보니 괜히 해봤다 싶은 것이 있었나요?\n\n이것을 몰랐던 때로 돌아가고 싶다, 하는 것이 있나요?\n\n왜 후회하나요?',
      '나쁜 선택지만 남은 최악의 갈림길에 서 본 경험이 있나요?\n\n무엇을 선택했고, 어떤 결과가 남았나요?\n\n하나님께서는 이에 대해 뭐라고 말씀하실까요? 말씀을 함께 읽어봅시다.',
      '살면서 경험한 가장 길고 힘든 시간이 있었나요?\n\n나는 그 시간을 어떻게 견뎠나요?\n\n그 시간은 나에게 어떤 중요한 교훈을 남겼나요?\n\n- 그 시간을 하나님과 함께 견뎠다면(소를 먹지 않음) 그것이 내 삶에 어떤 영향을 미쳤나요?\n\n- 그 시간에 세상에서 해결 방법을 찾으려고(소를 먹음) 노력했던 것이 있나요? 그 과정은 나에게 어떤 결과를 남겼나요?\n\n하나님께서는 이에 대해 뭐라고 말씀하실까요? 말씀을 함께 읽어봅시다.',
      '무엇이 내 삶을 송두리째 흔들었나요?\n\n나는 어떤 상황이었고 어떤 고민까지 해봤나요?\n\n나는 그 상황을 어떻게 극복했나요? 혹은 극복하고 있나요? 혹은 극복하지 못했나요?',
      '언제, 왜, 길을 잃었다는 생각이 들었나요?\n\n어떤 일들이 있었나요?\n\n그때 나는 어떤 상태였나요? 혹은 지금, 나는 어떤 상태라고 생각하나요?\n\n그렇다면 무엇이 나를 오늘 이 자리에 있게 했나요?',
      '상황이 완전히 불리하게 돌아가고 있다고 느낀 적이 있나요?\n\n어떤 상황이었고, 나는 어떤 처지에 있었나요?\n\n신앙을 ‘지켜야’ 했을 때가 있었나요?\n\n사단이 내 신앙을 완전히 장악하고 곧 잡아먹힐 것만 같았던 때가 있었나요?\n\n그 일은 어떻게 결론이 났나요?',
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

  test('provided scene artwork is connected to scenes two through ten', () {
    expect(journeyScenes.skip(1).take(9).map((scene) => scene.imageAsset), [
      'assets/images/scene_2_troy.jpg',
      'assets/images/scene_3_cyclops.jpg',
      'assets/images/scene_4_circe.jpg',
      'assets/images/scene_5_underworld.jpg',
      'assets/images/scene_6_sirens.jpg',
      'assets/images/scene_7_scylla.jpg',
      'assets/images/scene_8_helios.jpg',
      'assets/images/scene_9_storm.png',
      'assets/images/scene_10_calypso.png',
    ]);
  });

  test('all scenes have dedicated mobile artwork', () {
    expect(journeyScenes.map((scene) => scene.mobileImageAsset), [
      'assets/images/scene_1_mobile.png',
      'assets/images/scene_2_troy_mobile.png',
      'assets/images/scene_3_cyclops_mobile.png',
      'assets/images/scene_4_circe_mobile.png',
      'assets/images/scene_5_underworld_mobile.png',
      'assets/images/scene_6_sirens_mobile.png',
      'assets/images/scene_7_scylla_mobile.png',
      'assets/images/scene_8_helios_mobile.png',
      'assets/images/scene_9_storm_mobile.png',
      'assets/images/scene_10_calypso_mobile.png',
      'assets/images/scene_11_ithaca_return_mobile.png',
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
            scene.closingMessage,
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

    expect(devotionalScenes, hasLength(11));
    expect(ithaca.devotionalReference, '시대의 소망 323-324p');
    expect(ithaca.devotionalText, contains('악에 대한 유일의 방어'));
    expect(troy.devotionalReference, '부조와 선지자 71장');
    expect(troy.devotionalText, contains('비밀리에 원칙의 요새를 침식'));
    expect(journeyScenes[5].devotionalReference, '시대의 소망 2장');
    expect(journeyScenes[8].devotionalReference, '시대의 소망 35장');
    expect(journeyScenes[9].devotionalReference, '실물교훈 16장');
    expect(journeyScenes[10].devotionalReference, '마지막날 사건들 2장');
  });

  test('PDF highlights and meditation questions are connected', () {
    final highlightedScenes = journeyScenes
        .where((scene) => scene.devotionalHighlights.isNotEmpty)
        .toList();

    expect(highlightedScenes.map((scene) => scene.id), [
      'ithaca',
      'troy',
      'cyclops',
      'circe',
      'underworld',
      'sirens',
      'scylla',
      'helios',
      'storm',
      'calypso',
      'return',
    ]);
    for (final scene in highlightedScenes) {
      for (final highlight in scene.devotionalHighlights) {
        expect(scene.devotionalText, contains(highlight));
      }
    }

    expect(
      journeyScenes.map((scene) => scene.reflectionPrompt),
      everyElement('말씀을 통해, 하나님께서 나의 문제에 어떻게 대답해 주시는 것 같나요?'),
    );
  });

  test('leader manual directions and closing messages are connected', () {
    expect(journeyScenes.map((scene) => scene.meditation), [
      '내 마음에 하나님이 안 계시면 사단이 들어옵니다.\n\n악에 대한 유일한 방어막은 내 마음의 왕좌에 하나님을 모시는 것입니다.',
      '우리 철옹성을 뚫는 은밀한 유혹이 있습니다.\n\n우리는 경계를 늦추지 말아야 합니다.',
      '본문은 ‘돈’에 초점이 맞추어져 있지만 원리는 모두 같습니다.\n\n하나님 대신 사랑하는 그것이 곧 일만 악의 뿌리가 됩니다.',
      '악은 항상 나쁘게만 다가오지 않습니다.\n\n우리에게 오는 ‘좋은 것’이 정말 무엇인지 가려낼 수 있는 안목이 필요합니다.',
      '사단은 우리를 죽이고 싶어 한다는 사실을 꼭 기억해야 합니다.\n\n하나님만이 우리가 얻을 수 있는 산 대답이 되어주십니다.',
      '우리가 하나님 뜻에 순종했다면 더 많은 것을 누릴 수 있었을 것입니다.\n\n하나님 안에서는 지나간 후회가 과거로 끝나지 않습니다.\n\n놓친 축복은 우리가 어떤 약속을 받았는지를 상기시킵니다.\n\n우리가 돌이키면, 우리는 지금도 그 가능성에 기대를 걸어볼 수 있습니다.',
      '바리새인들의 오만하고 시기질투하는 마음이\n\n예수님께서 주시는 구원도 잃고\n\n백성들의 신망도 잃게 만들었습니다.',
      '끝나지 않는 길고 어두운 순간 속에\n\n이 끝이 막다른 길이어서 내 목숨까지 요구하는 순간에도\n\n하나님께서는 그 길을 이미 모두 걸으신 분으로서\n\n내 곁에 함께하십니다.',
      '가장 큰 절망 속에 결국 털썩 주저앉았을 때,\n\n하늘의 평화를 가지고 우리를 바라보시는 예수님이 계십니다.',
      '자각하지 못하던 내 황폐함을 깨닫게 될 때가 있습니다.\n\n그래도 우리는 아주 망하지 않았습니다.\n\n우리에겐 돌아갈 아버지 집이 있기 때문입니다.',
      '상황이 나를 압도할 때, 상황 위에서 모든 것을 주관하시는 하나님이 계십니다.\n\n그분이 나를 사랑하시기에,\n\n우리는 나를 인도하시는 그분의 섭리를 신뢰할 수 있습니다.',
    ]);

    expect(journeyScenes.map((scene) => scene.closingMessage), [
      '우리 마음의 왕좌에 하나님을 모시면\n\n우리 삶에 헷갈릴 일도 없고 흔들릴 일도 없어질 것입니다.\n\n하나님을 마음에 모시는 우리가 되었으면 좋겠습니다.',
      '사단은 우리가 방심하기를 기다리고,\n\n가장 은밀하고 작은 죄를 우리 마음에 들여보냅니다.\n\n그리고 그것이 우리 온 마음을 트로이의 불바다가 되게 할 것입니다.\n\n사단의 작은 유혹에서 우리 마음을 지킵시다.',
      '세상을 사랑하는 마음을 ‘포기’할 수 있는 우리가 되었으면 좋겠습니다.',
      '나에게 있어서 ‘좋은 것’이라고 생각했던 것이\n\n진짜 그러한가, 아닌가 가려낼 영적인 안목을 기르는 우리가 되었으면 좋겠습니다.',
      '우리가 살 방법을 얻을 수 있는 곳은 오직 하나님 품 안입니다.\n\n하나님 외에는 구원이 없습니다.',
      '하나님 안에서는 아쉬움이 아쉬움으로 끝나지 않습니다.\n\n놓친 축복보다 더 큰 축복을 기대할 수 있는 하나님의 허락에 순종하는\n\n우리가 되었으면 좋겠습니다.',
      '최악의 상황이라는 생각이 들 때,\n\n언제나 우리에게 한 가지 선택지가 더 있다는 사실을 잊지 맙시다.\n\n하늘을 의지하는 선택권입니다.',
      '하나님은 위로의 하나님이십니다.\n\n끝이 보이지 않는 순간에\n\n분명 우리 곁에 계셔서\n\n우리와 함께 견디고 계시는 예수님을 발견하는 우리가 되기를 바랍니다.',
      '압도적인 재앙 속에서 우리 부르짖음을 들으시는 귀가 있다는 것을\n\n잊지 않는 우리가 되었으면 좋겠습니다.',
      '어떤 상황 속에서도 나를 향한 아버지의 사랑이 아직 유효하다는 확신을 잃지 않는\n\n우리가 되었으면 좋겠습니다.',
      '결코 무관심하지 않으신 하나님의 섭리를 기억하는\n\n우리가 되었으면 좋겠습니다.',
    ]);
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
    expect(find.byKey(const Key('scene-intro-title')), findsOneWidget);
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
    final devotionalText = tester.widget<SelectableText>(
      find.byKey(const Key('devotional-text')),
    );
    final highlightedSpans = devotionalText.textSpan!.children!
        .whereType<TextSpan>()
        .where((span) => span.style?.color == const Color(0xFFF5C542))
        .toList();
    expect(highlightedSpans, hasLength(2));
    expect(
      highlightedSpans.every((span) => span.style?.backgroundColor == null),
      isTrue,
    );
    expect(find.text('묵상 질문으로 이동'), findsOneWidget);
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
    expect(find.text('묵상 질문'), findsWidgets);
    expect(find.byKey(const Key('meditation-direction')), findsOneWidget);
    expect(find.text('묵상 방향성'), findsOneWidget);
    expect(
      find.text(
        '내 마음에 하나님이 안 계시면 사단이 들어옵니다.\n\n악에 대한 유일한 방어막은 내 마음의 왕좌에 하나님을 모시는 것입니다.',
      ),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const Key('reflection-field')),
      '결정 전에 기도하기',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await _tapVisible(tester, find.byKey(const Key('complete-scene')));
    await _pumpTransition(tester);

    expect(store.readCompletedSceneIds(), {'ithaca'});
    expect(find.text('마무리 멘트'), findsOneWidget);
    expect(find.byKey(const Key('closing-message')), findsOneWidget);
    expect(
      find.text(
        '우리 마음의 왕좌에 하나님을 모시면\n\n우리 삶에 헷갈릴 일도 없고 흔들릴 일도 없어질 것입니다.\n\n하나님을 마음에 모시는 우리가 되었으면 좋겠습니다.',
      ),
      findsOneWidget,
    );
    expect(find.text('나눔 질문'), findsNothing);
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
    expect(find.byKey(const Key('return-cinematic-background')), findsNothing);
    final mobileAssets = tester
        .widgetList<Image>(find.byType(Image))
        .where((image) => image.image is AssetImage)
        .map((image) => (image.image as AssetImage).assetName)
        .toSet();
    expect(
      mobileAssets,
      contains('assets/images/scene_11_ithaca_return_mobile.png'),
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

  testWidgets('compact episode intro titles use scene-specific safe areas', (
    tester,
  ) async {
    _setViewport(tester, const Size(390, 844));

    const expectedAlignments = <Alignment>[
      Alignment(-0.68, -0.72),
      Alignment(-0.72, 0.28),
      Alignment(0, 0.12),
      Alignment(0.68, 0.48),
      Alignment(0.7, -0.34),
      Alignment(-0.68, 0.5),
      Alignment(-0.58, -0.08),
      Alignment(0.62, 0.1),
      Alignment(-0.7, -0.28),
      Alignment(-0.72, -0.46),
      Alignment(-0.68, -0.54),
    ];

    for (var index = 0; index < journeyScenes.length; index++) {
      final scene = journeyScenes[index];
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: JourneyScreen(
            key: ValueKey(scene.id),
            initialSceneIndex: index,
            completedSceneIds: const <String>{},
            soundOn: false,
            isFullscreen: false,
            onProgress: (_) {},
            onAudioChanged: (_, _) {},
            onAudioPreload: (_) {},
            onToggleSound: () {},
            onToggleFullscreen: (_) {},
            onBackToOverview: () {},
            onReset: () {},
          ),
        ),
      );
      await tester.pump();

      final placement = find.byKey(Key('scene-intro-placement-${scene.id}'));
      expect(
        tester.widget<Align>(placement).alignment,
        expectedAlignments[index],
      );
      final displayedTitle = tester
          .widget<Text>(find.byKey(const Key('scene-intro-title')))
          .data!;
      for (final word in scene.title.split(' ')) {
        final protectedWord = word.runes
            .map((rune) => String.fromCharCode(rune))
            .join('\u2060');
        expect(displayedTitle, contains(protectedWord));
      }
      expect(
        tester
            .getRect(find.byKey(const Key('scene-intro-card')))
            .overlaps(
              tester.getRect(find.byKey(const Key('continue-scene-intro'))),
            ),
        isFalse,
      );
    }
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
