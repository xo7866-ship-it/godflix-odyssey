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
    required this.imageAsset,
    required this.scriptureReference,
    required this.scriptureText,
    required this.meditation,
    this.devotionalReference = '',
    this.devotionalText = '',
    required this.reflectionPrompt,
    required this.choices,
  });

  final String id;
  final String title;
  final String hook;
  final String story;
  final String question;
  final String imageAsset;
  final String scriptureReference;
  final String scriptureText;
  final String meditation;
  final String devotionalReference;
  final String devotionalText;
  final String reflectionPrompt;
  final List<JourneyChoice> choices;
}

class JourneyAnswer {
  const JourneyAnswer({
    required this.scene,
    required this.choice,
    required this.reflection,
  });

  final JourneyScene scene;
  final JourneyChoice choice;
  final String reflection;
}
