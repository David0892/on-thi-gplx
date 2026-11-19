import 'package:flutter_test/flutter_test.dart';
import 'package:gplx_prep/domain/models.dart';
import 'package:gplx_prep/domain/readiness.dart';

Question q(int n, {bool critical = false, int topic = 1}) => Question(
  key: 'k$n',
  number: n,
  topicId: topic,
  text: 'Câu $n',
  options: const ['a', 'b'],
  correctPosition: 1,
  isCritical: critical,
);

QuestionProgress p({
  int seen = 0,
  int wrong = 0,
  bool? last,
  bool inWrong = false,
}) => QuestionProgress(
  timesSeen: seen,
  timesWrong: wrong,
  lastCorrect: last,
  inWrongList: inWrong,
);

void main() {
  test(
    'mastery: unseen, wrong, right once (shaky), right twice (mastered)',
    () {
      expect(masteryOf(null), Mastery.unseen);
      expect(
        masteryOf(p(seen: 1, wrong: 1, last: false, inWrong: true)),
        Mastery.wrong,
      );
      expect(masteryOf(p(seen: 1, last: true)), Mastery.shaky);
      expect(masteryOf(p(seen: 2, last: true)), Mastery.mastered);
      // Right twice, then wrong: wrong wins.
      expect(
        masteryOf(p(seen: 3, wrong: 1, last: false, inWrong: true)),
        Mastery.wrong,
      );
      // Wrong once, then right once: only one right answer, still shaky.
      expect(masteryOf(p(seen: 2, wrong: 1, last: true)), Mastery.shaky);
    },
  );

  test('score counts mastered fully and shaky as half', () {
    final qs = [q(1), q(2), q(3), q(4)];
    final t = Tally.of(qs, {
      'k1': p(seen: 2, last: true),
      'k2': p(seen: 1, last: true),
      'k3': p(seen: 1, wrong: 1, last: false, inWrong: true),
    });
    expect((t.mastered, t.shaky, t.wrong, t.unseen), (1, 1, 1, 1));
    expect(t.score, closeTo(1.5 / 4, 1e-9));
    expect(t.answered, 3);
    expect(t.right, 2);
  });

  test('ready only when all three conditions hold', () {
    const full = Tally(mastered: 10);
    const r = Readiness(
      pool: full,
      critical: Tally(mastered: 2),
      recentPasses: 3,
      recentExams: 3,
    );
    expect(r.ready, isTrue);
    expect(r.label, 'Sẵn sàng đi thi');
    const notCritical = Readiness(
      pool: full,
      critical: Tally(mastered: 1, wrong: 1),
      recentPasses: 3,
      recentExams: 3,
    );
    expect(notCritical.conditionsMet, 2);
    const fewExams = Readiness(
      pool: full,
      critical: Tally(mastered: 2),
      recentPasses: 2,
      recentExams: 2,
    );
    expect(fewExams.examsSteady, isFalse);
    const low = Readiness(
      pool: Tally(unseen: 10),
      critical: Tally(unseen: 2),
      recentPasses: 0,
      recentExams: 0,
    );
    expect(low.label, 'Cần ôn thêm');
  });

  test('improvements: wrong critical first, at most three', () {
    final pool = [
      q(1, critical: true),
      q(2, topic: 2),
      q(3, topic: 2),
      q(4, topic: 3),
    ];
    final fixes = improvements(
      pool: pool,
      topics: const [
        Topic(id: 1, name: 'Một', shortName: 'Một'),
        Topic(id: 2, name: 'Hai', shortName: 'Hai'),
        Topic(id: 3, name: 'Ba', shortName: 'Ba'),
      ],
      progress: {
        'k1': p(seen: 1, wrong: 1, last: false, inWrong: true),
        'k2': p(seen: 2, wrong: 2, last: false, inWrong: true),
        'k3': p(seen: 1, wrong: 1, last: false, inWrong: true),
      },
    );
    expect(fixes.first.kind, ImprovementKind.criticalWrong);
    expect(fixes.first.path, '/study/criticalWrong');
    expect(fixes.length, lessThanOrEqualTo(3));
    expect(fixes.map((f) => f.kind), contains(ImprovementKind.oftenWrong));
    final topic = fixes.firstWhere((f) => f.kind == ImprovementKind.topicWrong);
    expect(topic.title, 'Hai'); // two wrong in chapter 2
  });
}
