class DhikrModel {
  final String text;
  final String fadl; // فضل الذكر
  final int defaultTarget;

  DhikrModel({
    required this.text,
    required this.fadl,
    this.defaultTarget = 33,
  });
}

class HadithModel {
  final String text;
  final String narrator;
  final String explanation;
  final String source;

  HadithModel({
    required this.text,
    required this.narrator,
    required this.explanation,
    required this.source,
  });
}

class HadithCategory {
  final String id;
  final String name;
  final String iconName;
  final List<HadithModel> hadiths;

  HadithCategory({
    required this.id,
    required this.name,
    required this.iconName,
    required this.hadiths,
  });
}

class VerseModel {
  final String text;
  final String surah;
  final int ayah;
  final String category;
  final String tafsir;
  final String lesson;

  VerseModel({
    required this.text,
    required this.surah,
    required this.ayah,
    required this.category,
    required this.tafsir,
    required this.lesson,
  });
}

class AdhkarModel {
  final String text;
  final int repeat;
  final String source;
  final String virtue;

  AdhkarModel({
    required this.text,
    required this.repeat,
    required this.source,
    required this.virtue,
  });
}

enum AdhkarType { morning, evening, sleep }
