import 'dart:math';

import 'models.dart';

class NotEnoughQuestions implements Exception {
  NotEnoughQuestions(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Builds the question list for one exam, following the class rules:
/// exactly [LicenseClass.criticalPerExam] critical questions, the rest drawn
/// per topic from [quota] (topicId -> count). With no quota, the rest is drawn
/// uniformly from the pool. Result is ordered by official question number.
///
/// Pure: same [rng] seed gives the same exam. Used for random exams and for
/// the fixed numbered sets.
List<Question> generateExam({
  required LicenseClass cls,
  required List<Question> pool,
  required Map<int, int> quota,
  required Random rng,
}) {
  final critical = pool.where((q) => q.isCritical).toList()..shuffle(rng);
  final normal = pool.where((q) => !q.isCritical).toList();
  final need = cls.examQuestionCount - cls.criticalPerExam;

  if (critical.length < cls.criticalPerExam) {
    throw NotEnoughQuestions(
      '${cls.name} cần ${cls.criticalPerExam} câu điểm liệt, bộ câu hỏi hiện có ${critical.length}.',
    );
  }

  final picked = <Question>[...critical.take(cls.criticalPerExam)];

  if (quota.isNotEmpty) {
    final total = quota.values.fold(0, (a, b) => a + b);
    if (total != need) {
      throw StateError('Quota for ${cls.code} sums to $total, expected $need');
    }
    for (final MapEntry(key: topic, value: count) in quota.entries) {
      final inTopic = normal.where((q) => q.topicId == topic).toList()
        ..shuffle(rng);
      if (inTopic.length < count) {
        throw NotEnoughQuestions(
          '${cls.name} cần $count câu ở chủ đề $topic, bộ câu hỏi hiện có ${inTopic.length}.',
        );
      }
      picked.addAll(inTopic.take(count));
    }
  } else {
    if (normal.length < need) {
      throw NotEnoughQuestions(
        '${cls.name} cần ${cls.examQuestionCount} câu, bộ câu hỏi hiện chỉ có ${normal.length + critical.length}.',
      );
    }
    picked.addAll((normal..shuffle(rng)).take(need));
  }

  picked.sort((a, b) => a.number.compareTo(b.number));
  return picked;
}

class Grade {
  const Grade({
    required this.answers,
    required this.score,
    required this.passed,
    required this.failedOnCritical,
  });

  final List<AttemptAnswer> answers;
  final int score;
  final bool passed;
  final bool failedOnCritical;
}

/// Unanswered counts as wrong. A wrong or unanswered critical question fails
/// the exam whatever the score.
Grade grade({
  required List<AttemptAnswer> answers,
  required Map<String, Question> questions,
  required int passMark,
}) {
  var score = 0;
  var criticalFail = false;
  final graded = [
    for (final a in answers)
      () {
        final ok =
            a.chosen != null &&
            a.chosen == questions[a.questionKey]!.correctPosition;
        if (ok) score++;
        if (!ok && a.isCritical) criticalFail = true;
        return a.copyWith(isCorrect: ok);
      }(),
  ];
  return Grade(
    answers: graded,
    score: score,
    passed: !criticalFail && score >= passMark,
    failedOnCritical: criticalFail,
  );
}
