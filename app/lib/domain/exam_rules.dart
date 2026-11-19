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
/// per chapter group from [quota]. With no quota, the rest is drawn
/// uniformly from the pool. Result is ordered by official question number.
///
/// Pure: same [rng] seed gives the same exam. Used for random exams and for
/// the fixed numbered sets.
List<Question> generateExam({
  required LicenseClass cls,
  required List<Question> pool,
  required List<Quota> quota,
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
    final total = quota.fold(0, (a, q) => a + q.count);
    if (total != need) {
      throw StateError('Quota for ${cls.code} sums to $total, expected $need');
    }
    for (final group in quota) {
      final inGroup =
          normal.where((q) => group.topics.contains(q.topicId)).toList()
            ..shuffle(rng);
      if (inGroup.length < group.count) {
        throw NotEnoughQuestions(
          '${cls.name} cần ${group.count} câu ở chương ${group.topics.join('/')}, '
          'bộ câu hỏi hiện có ${inGroup.length}.',
        );
      }
      picked.addAll(inGroup.take(group.count));
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
