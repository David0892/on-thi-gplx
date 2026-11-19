// Readiness (Tổng quan): how close the learner is to passing, from their own
// answers. Pure functions, so the rules are unit-tested without the UI.
import 'models.dart';

/// Where one question stands for this learner.
enum Mastery {
  /// Never answered.
  unseen,

  /// Last answer was wrong (or it sits in the wrong list).
  wrong,

  /// Last answer right, but right only once so far.
  shaky,

  /// Last answer right, and right at least twice in all.
  mastered,
}

Mastery masteryOf(QuestionProgress? p) {
  if (p == null || p.timesSeen == 0) return Mastery.unseen;
  if (p.inWrongList || p.lastCorrect != true) return Mastery.wrong;
  final timesRight = p.timesSeen - p.timesWrong;
  return timesRight >= 2 ? Mastery.mastered : Mastery.shaky;
}

/// Counts for a set of questions (a topic, the critical set, the whole pool).
class Tally {
  const Tally({
    this.unseen = 0,
    this.wrong = 0,
    this.shaky = 0,
    this.mastered = 0,
  });
  final int unseen;
  final int wrong;
  final int shaky;
  final int mastered;

  int get total => unseen + wrong + shaky + mastered;
  int get answered => total - unseen;

  /// Answered and last answer right.
  int get right => shaky + mastered;

  /// Mastered counts fully, a single right answer counts half.
  double get score => total == 0 ? 0 : (mastered + shaky * 0.5) / total;

  static Tally of(
    Iterable<Question> qs,
    Map<String, QuestionProgress> progress,
  ) {
    var u = 0, w = 0, s = 0, m = 0;
    for (final q in qs) {
      switch (masteryOf(progress[q.key])) {
        case Mastery.unseen:
          u++;
        case Mastery.wrong:
          w++;
        case Mastery.shaky:
          s++;
        case Mastery.mastered:
          m++;
      }
    }
    return Tally(unseen: u, wrong: w, shaky: s, mastered: m);
  }
}

/// The score the learner should reach before booking the exam. Set above the
/// pass mark on purpose: a real exam draws questions at random from the pool.
const readinessTarget = 0.9;

/// How many of the most recent exams must all be passes.
const recentExamsNeeded = 3;

class Readiness {
  const Readiness({
    required this.pool,
    required this.critical,
    required this.recentPasses,
    required this.recentExams,
  });

  final Tally pool;
  final Tally critical;

  /// Passes among the last [recentExamsNeeded] submitted exams.
  final int recentPasses;
  final int recentExams;

  double get score => pool.score;

  bool get scoreReached => score >= readinessTarget;
  bool get criticalReady =>
      critical.total > 0 && critical.mastered == critical.total;
  bool get examsSteady =>
      recentExams >= recentExamsNeeded && recentPasses == recentExams;

  int get conditionsMet =>
      [scoreReached, criticalReady, examsSteady].where((x) => x).length;
  bool get ready => conditionsMet == 3;

  /// A short status for the badge on the card.
  String get label => switch (score) {
    _ when ready => 'Sẵn sàng đi thi',
    >= readinessTarget => 'Gần sẵn sàng',
    >= 0.5 => 'Đang tiến bộ',
    _ => 'Cần ôn thêm',
  };
}

/// One suggestion in "Cần cải thiện", most urgent first.
class Improvement {
  const Improvement({
    required this.kind,
    required this.title,
    required this.detail,
    required this.action,
    required this.path,
    this.count = 0,
  });
  final ImprovementKind kind;
  final String title;
  final String detail;
  final String action;
  final String path;
  final int count;
}

enum ImprovementKind { criticalWrong, oftenWrong, topicWrong, unseen }

List<Improvement> improvements({
  required List<Question> pool,
  required List<Topic> topics,
  required Map<String, QuestionProgress> progress,
}) {
  final out = <Improvement>[];
  final criticalWrong = pool
      .where((q) => q.isCritical && masteryOf(progress[q.key]) == Mastery.wrong)
      .length;
  if (criticalWrong > 0) {
    out.add(
      Improvement(
        kind: ImprovementKind.criticalWrong,
        title: 'Sửa câu điểm liệt',
        detail:
            '$criticalWrong câu điểm liệt đang sai. Đi thi mà sai một câu loại này là trượt ngay.',
        action: 'Làm lại $criticalWrong câu',
        path: '/study/criticalWrong',
        count: criticalWrong,
      ),
    );
  }
  final often = pool
      .where((q) => (progress[q.key]?.timesWrong ?? 0) >= 2)
      .length;
  if (often > 0) {
    out.add(
      Improvement(
        kind: ImprovementKind.oftenWrong,
        title: 'Câu bạn hay nhầm',
        detail: '$often câu đã sai từ hai lần trở lên. Đọc kỹ phần giải thích.',
        action: 'Ôn $often câu',
        path: '/study/often',
        count: often,
      ),
    );
  }
  // The chapter with the most questions currently wrong.
  Topic? worst;
  var worstWrong = 0;
  for (final t in topics) {
    final n = pool
        .where(
          (q) =>
              q.topicId == t.id && masteryOf(progress[q.key]) == Mastery.wrong,
        )
        .length;
    if (n > worstWrong) {
      worst = t;
      worstWrong = n;
    }
  }
  if (worst != null) {
    out.add(
      Improvement(
        kind: ImprovementKind.topicWrong,
        title: worst.shortName,
        detail: 'Chương có nhiều câu sai nhất: $worstWrong câu.',
        action: 'Ôn chương này',
        path: '/study/topic?topic=${worst.id}',
        count: worstWrong,
      ),
    );
  }
  // The chapter with the most questions never answered.
  Topic? fresh;
  var freshCount = 0;
  for (final t in topics) {
    final n = pool
        .where(
          (q) =>
              q.topicId == t.id && masteryOf(progress[q.key]) == Mastery.unseen,
        )
        .length;
    if (n > freshCount) {
      fresh = t;
      freshCount = n;
    }
  }
  if (fresh != null && out.length < 3) {
    out.add(
      Improvement(
        kind: ImprovementKind.unseen,
        title: fresh.shortName,
        detail: '$freshCount câu bạn chưa làm lần nào.',
        action: 'Học câu mới',
        path: '/study/topic?topic=${fresh.id}',
        count: freshCount,
      ),
    );
  }
  return out.take(3).toList();
}
