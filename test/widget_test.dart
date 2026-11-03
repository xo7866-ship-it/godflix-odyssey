import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:godflix/data/scenes.dart';
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

  test('HWP devotional passages are connected to their scenes', () {
    final devotionalScenes = journeyScenes
        .where((scene) => scene.devotionalText.isNotEmpty)
        .toList();
    final troy = journeyScenes.firstWhere((scene) => scene.id == 'troy');

    expect(devotionalScenes, hasLength(6));
    expect(troy.devotionalReference, '부조와 선지자 71장');
    expect(troy.devotionalText, contains('비밀리에 원칙의 요새를 침식'));
  });

  testWidgets('first scene reaches scripture and the next scene', (
    tester,
  ) async {
    final store = ProgressStore();
    await tester.pumpWidget(GodflixApp(progressStore: store));

    expect(find.text('여정 시작하기'), findsOneWidget);
    await tester.tap(find.byKey(const Key('start-journey')));
    await _pumpTransition(tester);

    expect(find.text('오디세이 여정 지도'), findsNothing);
    await _revealOverview(tester);
    expect(find.text('오디세이 여정 지도'), findsOneWidget);
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

    expect(find.text('왕이 없는 섬 이타카'), findsOneWidget);
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
    expect(find.byKey(const Key('devotional-missing')), findsOneWidget);
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
    await _tapVisible(tester, find.byKey(const Key('complete-scene')));
    await _pumpTransition(tester);

    expect(store.readCompletedSceneIds(), {'ithaca'});
    await _tapVisible(tester, find.byKey(const Key('next-scene')));
    await _pumpTransition(tester);
    await _revealScene(tester);
    expect(find.text('철옹성을 무너뜨린 트로이 목마'), findsOneWidget);
  });

  testWidgets('saved progress resumes at the second scene', (tester) async {
    final store = ProgressStore(
      initialCompletedScenes: 1,
      initialSelections: const {'ithaca': 2},
    );
    await tester.pumpWidget(GodflixApp(progressStore: store));

    expect(find.text('이어서 여정하기'), findsOneWidget);
    await tester.tap(find.byKey(const Key('start-journey')));
    await _pumpTransition(tester);
    await _revealOverview(tester);
    expect(find.text('1 / 11 장면 완료'), findsOneWidget);
    await _tapVisible(tester, find.byKey(const Key('map-scene-1')));
    await _pumpTransition(tester);
    await _revealScene(tester);

    expect(find.text('철옹성을 무너뜨린 트로이 목마'), findsOneWidget);
    expect(find.text('2 / 11 · 줄거리'), findsOneWidget);
    expect(find.byKey(const Key('current-choice-status')), findsOneWidget);
    expect(find.byKey(const Key('scene-progress-11')), findsOneWidget);
    final sceneImage = tester
        .widgetList<Image>(find.byType(Image))
        .firstWhere(
          (image) =>
              image.image is AssetImage &&
              (image.image as AssetImage).assetName.endsWith('scene_2.jpg'),
        );
    expect(sceneImage.alignment, const Alignment(-0.78, 0));
  });

  testWidgets('intro skip, journey log, and back navigation work', (
    tester,
  ) async {
    final store = ProgressStore();
    await tester.pumpWidget(GodflixApp(progressStore: store));

    await tester.tap(find.byKey(const Key('start-journey')));
    await _pumpTransition(tester);
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
}

Future<void> _pumpTransition(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _revealOverview(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
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
