class JourneyChoice {
  const JourneyChoice({
    required this.label,
    required this.tag,
    required this.application,
  });

  final String label;
  final String tag;
  final String application;
}

class JourneyScene {
  const JourneyScene({
    required this.id,
    required this.title,
    required this.hook,
    required this.story,
    required this.question,
    required this.discussion,
    required this.imageAsset,
    required this.mobileImageAsset,
    this.audioAsset = 'assets/audio/sea_wind.wav',
    required this.scriptureReference,
    required this.scriptureText,
    required this.meditation,
    this.devotionalReference = '',
    this.devotionalText = '',
    this.devotionalHighlights = const [],
    required this.reflectionPrompt,
    required this.choices,
  });

  final String id;
  final String title;
  final String hook;
  final String story;
  final String question;
  final String discussion;
  final String imageAsset;
  final String mobileImageAsset;
  final String audioAsset;
  final String scriptureReference;
  final String scriptureText;
  final String meditation;
  final String devotionalReference;
  final String devotionalText;
  final List<String> devotionalHighlights;
  final String reflectionPrompt;
  final List<JourneyChoice> choices;
}

class JourneyAnswer {
  const JourneyAnswer({required this.scene, required this.reflection});

  final JourneyScene scene;
  final String reflection;
}
