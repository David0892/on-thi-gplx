import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:gplx_prep/domain/exam_rules.dart';
import 'package:gplx_prep/domain/models.dart';

const a1 = LicenseClass(
  code: 'A1', name: 'Hạng A1', group: 'moto', description: '',
  examQuestionCount: 25, examMinutes: 19, passMark: 21, criticalPerExam: 1, rulesVerified: true,
);

List<Question> makePool({int perTopic = 12, int critical = 3}) {
  final out = <Question>[];
  var n = 1;
  for (var t = 1; t <= 5; t++) {
    for (var i = 0; i < perTopic; i++, n++) {
      out.add(Question(
        key: 'q$n', number: n, topicId: t, text: 'Q$n', options: const ['a', 'b', 'c'],
        correctPosition: 2, isCritical: n <= critical, explanation: '',
      ));
    }
  }
  return out;
}

void main() {
  const quota = {1: 9, 2: 3, 3: 4, 4: 5, 5: 3};

  test('exam has the class count, exactly one critical, sorted, no duplicates', () {
    for (var seed = 0; seed < 50; seed++) {
      final exam = generateExam(cls: a1, pool: makePool(), quota: quota, rng: Random(seed));
      expect(exam.length, 25);
      expect(exam.where((q) => q.isCritical).length, 1);
      expect(exam.map((q) => q.key).toSet().length, 25);
      final numbers = exam.map((q) => q.number).toList();
      expect(numbers, [...numbers]..sort());
    }
  });

  test('quota per topic is respected', () {
    final exam = generateExam(cls: a1, pool: makePool(), quota: quota, rng: Random(1));
    for (final MapEntry(key: t, value: count) in quota.entries) {
      expect(exam.where((q) => !q.isCritical && q.topicId == t).length, count);
    }
  });

  test('same seed, same exam', () {
    final a = generateExam(cls: a1, pool: makePool(), quota: quota, rng: Random(7));
    final b = generateExam(cls: a1, pool: makePool(), quota: quota, rng: Random(7));
    expect(a.map((q) => q.key), b.map((q) => q.key));
  });

  test('too small a pool throws NotEnoughQuestions', () {
    expect(
      () => generateExam(cls: a1, pool: makePool(perTopic: 2), quota: const {}, rng: Random(1)),
      throwsA(isA<NotEnoughQuestions>()),
    );
    expect(
      () => generateExam(cls: a1, pool: makePool(critical: 0), quota: quota, rng: Random(1)),
      throwsA(isA<NotEnoughQuestions>()),
    );
  });

  group('grade', () {
    final pool = makePool();
    final byKey = {for (final q in pool) q.key: q};
    List<AttemptAnswer> answers({required int wrong, bool criticalWrong = false, int unanswered = 0}) {
      final exam = generateExam(cls: a1, pool: pool, quota: quota, rng: Random(3));
      var w = wrong, u = unanswered;
      return [
        for (final (i, q) in exam.indexed)
          AttemptAnswer(
            position: i + 1,
            questionKey: q.key,
            isCritical: q.isCritical,
            chosen: q.isCritical
                ? (criticalWrong ? 1 : 2)
                : (u-- > 0 ? null : (w-- > 0 ? 1 : 2)),
          ),
      ];
    }

    test('pass at exactly the pass mark', () {
      final g = grade(answers: answers(wrong: 4), questions: byKey, passMark: 21);
      expect(g.score, 21);
      expect(g.passed, isTrue);
    });

    test('fail one below the pass mark', () {
      final g = grade(answers: answers(wrong: 5), questions: byKey, passMark: 21);
      expect(g.passed, isFalse);
      expect(g.failedOnCritical, isFalse);
    });

    test('a wrong critical fails even with a high score', () {
      final g = grade(answers: answers(wrong: 0, criticalWrong: true), questions: byKey, passMark: 21);
      expect(g.score, 24);
      expect(g.passed, isFalse);
      expect(g.failedOnCritical, isTrue);
    });

    test('unanswered counts as wrong', () {
      final g = grade(answers: answers(wrong: 0, unanswered: 5), questions: byKey, passMark: 21);
      expect(g.score, 20);
      expect(g.passed, isFalse);
    });
  });
}
