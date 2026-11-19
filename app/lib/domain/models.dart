// Plain immutable models. Field names follow replica/schema.sql.

class LicenseClass {
  const LicenseClass({
    required this.code,
    required this.name,
    required this.group,
    required this.description,
    required this.examQuestionCount,
    required this.examMinutes,
    required this.passMark,
    required this.criticalPerExam,
    required this.rulesVerified,
  });

  final String code;
  final String name;
  final String group;
  final String description;
  final int examQuestionCount;
  final int examMinutes;
  final int passMark;
  final int criticalPerExam;
  final bool rulesVerified;

  bool get isMoto => group == 'moto';
}

class Topic {
  const Topic({required this.id, required this.name, required this.shortName});
  final int id;
  final String name;
  final String shortName;
}

class Question {
  const Question({
    required this.key,
    required this.number,
    required this.topicId,
    required this.text,
    required this.options,
    required this.correctPosition,
    required this.isCritical,
    this.explanation,
    this.image,
  });

  final String key;
  final int number;
  final int topicId;
  final String text;
  final List<String> options; // position = index + 1
  final int correctPosition; // 1-based
  final bool isCritical;

  /// Own writing; null until written (the official set has no explanations).
  final String? explanation;

  /// Asset path of the question's picture, as printed in the official set.
  final String? image;

  /// The same question with the critical flag a given class uses.
  Question withCritical(bool critical) => critical == isCritical
      ? this
      : Question(
          key: key,
          number: number,
          topicId: topicId,
          text: text,
          options: options,
          correctPosition: correctPosition,
          isCritical: critical,
          explanation: explanation,
          image: image,
        );
}

enum AttemptStatus { inProgress, submitted, timedOut, abandoned }

class AttemptAnswer {
  const AttemptAnswer({
    required this.position,
    required this.questionKey,
    required this.isCritical,
    this.chosen,
    this.isCorrect,
  });

  final int position;
  final String questionKey;
  final bool isCritical;
  final int? chosen; // null = unanswered
  final bool? isCorrect; // set at grading

  AttemptAnswer copyWith({int? chosen, bool? isCorrect}) => AttemptAnswer(
    position: position,
    questionKey: questionKey,
    isCritical: isCritical,
    chosen: chosen ?? this.chosen,
    isCorrect: isCorrect ?? this.isCorrect,
  );
}

class ExamAttempt {
  const ExamAttempt({
    required this.id,
    required this.classCode,
    required this.status,
    required this.startedAt,
    required this.deadlineAt,
    required this.passMark,
    required this.answers,
    this.examSetNumber,
    this.finishedAt,
    this.score,
    this.passed,
    this.failedOnCritical,
    this.currentPosition = 1,
  });

  final int id;
  final String classCode;
  final int? examSetNumber; // null = random
  final AttemptStatus status;
  final DateTime startedAt;
  final DateTime deadlineAt;
  final DateTime? finishedAt;
  final int passMark;
  final List<AttemptAnswer> answers;
  final int? score;
  final bool? passed;
  final bool? failedOnCritical;

  /// 1-based question on screen when the exam was last open.
  final int currentPosition;

  int get questionCount => answers.length;
  bool get isFinished => status != AttemptStatus.inProgress;
  int get answeredCount => answers.where((a) => a.chosen != null).length;
  Duration get timeUsed => (finishedAt ?? DateTime.now()).difference(startedAt);

  ExamAttempt copyWith({
    AttemptStatus? status,
    DateTime? finishedAt,
    List<AttemptAnswer>? answers,
    int? score,
    bool? passed,
    bool? failedOnCritical,
    int? currentPosition,
  }) => ExamAttempt(
    id: id,
    classCode: classCode,
    examSetNumber: examSetNumber,
    status: status ?? this.status,
    startedAt: startedAt,
    deadlineAt: deadlineAt,
    finishedAt: finishedAt ?? this.finishedAt,
    passMark: passMark,
    answers: answers ?? this.answers,
    score: score ?? this.score,
    passed: passed ?? this.passed,
    failedOnCritical: failedOnCritical ?? this.failedOnCritical,
    currentPosition: currentPosition ?? this.currentPosition,
  );
}

/// "Draw [count] questions from these chapters" (Công văn 2262, section II).
/// Motorbike classes draw one from chapter 3 *or* 4, hence a set of topics.
class Quota {
  const Quota(this.topics, this.count);
  final Set<int> topics;
  final int count;
}

class QuestionProgress {
  const QuestionProgress({
    this.timesSeen = 0,
    this.timesWrong = 0,
    this.lastCorrect,
    this.inWrongList = false,
  });

  final int timesSeen;
  final int timesWrong;
  final bool? lastCorrect;
  final bool inWrongList;
}

/// Where a study session draws its questions from (S08 serves S09–S11 too).
enum StudySource {
  topic,
  critical,
  wrong,
  saved,

  /// The whole class pool, in bank order.
  all,

  /// Answered wrong at least twice, whatever the last answer was.
  often,

  /// Critical questions currently in the wrong list.
  criticalWrong,
}

class ExamSetSummary {
  const ExamSetSummary({required this.number, this.bestScore, this.passed});
  final int number;
  final int? bestScore;
  final bool? passed;
}
