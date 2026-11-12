import '../../domain/entities/onboarding_question_entity.dart';

abstract final class OnboardingQuestionLogic {
  static List<OnboardingQuestionEntity> visibleQuestions(
    List<OnboardingQuestionEntity> questions,
    Map<String, dynamic> answers,
  ) {
    return questions
        .where((question) => isVisible(question, answers))
        .toList(growable: false);
  }

  static bool isVisible(
    OnboardingQuestionEntity question,
    Map<String, dynamic> answers,
  ) {
    final dependencyId = question.showOnlyIfQuestionId;
    if (dependencyId == null || dependencyId.isEmpty) return true;

    final expected = question.showOnlyIfAnswerValue;
    if (expected == null) return true;

    if (!answers.containsKey(dependencyId)) return false;
    return valuesMatch(answers[dependencyId], expected);
  }

  static bool valuesMatch(dynamic actual, dynamic expected) {
    if (actual == expected) return true;

    final expectedText = expected.toString().toLowerCase();
    if (actual is bool) {
      return expectedText == actual.toString();
    }
    if (actual is List) {
      return actual.map((value) => value.toString()).contains(expected.toString());
    }
    return actual.toString() == expected.toString();
  }

  static bool isAnswerValid(
    OnboardingQuestionEntity question,
    dynamic answer,
  ) {
    if (!question.required) return true;

    return switch (question.type) {
      OnboardingQuestionType.text =>
        answer is String && answer.trim().isNotEmpty,
      OnboardingQuestionType.number =>
        answer is String && num.tryParse(answer.trim()) != null,
      OnboardingQuestionType.boolean => answer is bool,
      OnboardingQuestionType.singleChoice =>
        answer is String && answer.isNotEmpty,
      OnboardingQuestionType.multiChoice =>
        answer is List && answer.isNotEmpty,
      OnboardingQuestionType.photo =>
        answer is List && answer.isNotEmpty,
    };
  }

  static String optionLabel(
    OnboardingQuestionOptionEntity option,
    String locale,
  ) =>
      locale.startsWith('ar') ? option.labelAr : option.labelEn;

  /// Some API questions are typed as MULTI_CHOICE but are mutually exclusive
  /// (e.g. weights vs cardio vs both).
  static bool allowsMultipleSelections(OnboardingQuestionEntity question) {
    if (question.type != OnboardingQuestionType.multiChoice) return false;

    final combined = '${question.questionEn} ${question.questionAr}';
    final lower = combined.toLowerCase();

    if (lower.contains('multi') ||
        combined.contains('أكثر من') ||
        combined.contains('عدة') ||
        combined.contains('اختر كل')) {
      return true;
    }

    if (lower.contains('prefer') || combined.contains('تفضل')) {
      return false;
    }

    final values = question.options.map((o) => o.value.toUpperCase()).toSet();
    if (values.contains('BOTH') && values.length <= 4) {
      return false;
    }

    final hasWeights = values.any(
      (v) => v.contains('WEIGHT') || v.contains('OZAN'),
    );
    final hasCardio = values.any((v) => v.contains('CARDIO'));
    if (hasWeights && hasCardio) {
      return false;
    }

    return true;
  }
}
