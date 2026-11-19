// In-memory stand-ins for the drift repositories. Same behaviour, no persistence:
// progress is lost when the app restarts. Replace in /replica-backend.
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../domain/exam_rules.dart';
import '../domain/models.dart';
import 'repositories.dart';

class SeedContentRepo implements ContentRepo {
  SeedContentRepo._(this._json);

  static Future<SeedContentRepo> load([AssetBundle? bundle]) async {
    final raw = await (bundle ?? rootBundle).loadString('assets/seed/content.json');
    return SeedContentRepo.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  factory SeedContentRepo.fromJson(Map<String, dynamic> json) => SeedContentRepo._(json).._parse();

  final Map<String, dynamic> _json;
  late final List<LicenseClass> _classes;
  late final List<Topic> _topics;
  late final List<Question> _questions;
  late final Map<String, Question> _byKey;
  late final Map<String, Map<int, int>> _quotas;

  void _parse() {
    _classes = [
      for (final c in _json['classes'] as List)
        LicenseClass(
          code: c['code'], name: c['name'], group: c['group'], description: c['description'],
          examQuestionCount: c['count'], examMinutes: c['minutes'], passMark: c['pass'],
          criticalPerExam: c['critical'], rulesVerified: c['verified'],
        ),
    ];
    _topics = [
      for (final t in _json['topics'] as List) Topic(id: t['id'], name: t['name'], shortName: t['short']),
    ];
    final bank = _json['meta']['bank_code'] as String;
    _questions = [
      for (final q in _json['questions'] as List)
        Question(
          key: '$bank-${(q['n'] as int).toString().padLeft(3, '0')}',
          number: q['n'], topicId: q['topic'], text: q['text'],
          options: List<String>.from(q['options']), correctPosition: q['correct'],
          isCritical: q['critical'], explanation: q['explanation'], image: q['image'],
        ),
    ];
    _byKey = {for (final q in _questions) q.key: q};
    _quotas = {
      for (final MapEntry(:key, :value) in (_json['quotas'] as Map<String, dynamic>).entries)
        key: {for (final e in (value as Map<String, dynamic>).entries) int.parse(e.key): e.value as int},
    };
  }

  @override
  bool get isSample => _json['meta']['is_sample'] == true;
  @override
  int get contentVersion => _json['meta']['content_version'] as int;
  @override
  List<LicenseClass> classes() => _classes;
  @override
  LicenseClass cls(String code) => _classes.firstWhere((c) => c.code == code);
  @override
  List<Topic> topics() => _topics;
  @override
  Topic topic(int id) => _topics.firstWhere((t) => t.id == id);
  @override
  List<Question> pool(String classCode) => _questions; // pools: {"*": "all"} in the seed
  @override
  Question question(String key) => _byKey[key]!;
  @override
  Map<int, int> quota(String classCode) => _quotas[classCode] ?? const {};
  @override
  int examSetCount(String classCode) => 5;
}

class MemorySettingsRepo implements SettingsRepo {
  String? _class;
  @override
  Future<String?> selectedClass() async => _class;
  @override
  Future<void> setClass(String code) async => _class = code;
}

class MemoryStudyRepo implements StudyRepo {
  MemoryStudyRepo(this.content, this.bookmarks);
  final ContentRepo content;
  final BookmarkRepo bookmarks;
  final _progress = <String, Map<String, QuestionProgress>>{};
  final _cursors = <String, int>{};

  Map<String, QuestionProgress> _of(String c) => _progress.putIfAbsent(c, () => {});

  @override
  Future<List<Question>> questions(StudySource source, String classCode, {int? topicId}) async {
    final pool = content.pool(classCode);
    switch (source) {
      case StudySource.topic:
        return pool.where((q) => q.topicId == topicId).toList();
      case StudySource.critical:
        return pool.where((q) => q.isCritical).toList();
      case StudySource.wrong:
        final p = _of(classCode);
        return pool.where((q) => p[q.key]?.inWrongList ?? false).toList();
      case StudySource.saved:
        final saved = await bookmarks.all();
        return pool.where((q) => saved.contains(q.key)).toList();
    }
  }

  @override
  Future<void> record(String classCode, String questionKey, {required bool correct}) async {
    final p = _of(classCode);
    final old = p[questionKey] ?? const QuestionProgress();
    p[questionKey] = QuestionProgress(
      timesSeen: old.timesSeen + 1,
      timesWrong: old.timesWrong + (correct ? 0 : 1),
      lastCorrect: correct,
      // Wrong puts it on the list; answering it right later takes it off.
      inWrongList: !correct,
    );
  }

  @override
  Future<Map<String, QuestionProgress>> progress(String classCode) async => Map.of(_of(classCode));
  @override
  Future<int> cursor(String classCode, int topicId) async => _cursors['$classCode/$topicId'] ?? 0;
  @override
  Future<void> saveCursor(String classCode, int topicId, int position) async =>
      _cursors['$classCode/$topicId'] = position;

  @override
  Future<void> clearWrong(String classCode) async {
    final p = _of(classCode);
    for (final MapEntry(:key, :value) in p.entries.toList()) {
      p[key] = QuestionProgress(
        timesSeen: value.timesSeen, timesWrong: value.timesWrong,
        lastCorrect: value.lastCorrect, inWrongList: false,
      );
    }
  }

  @override
  Future<void> reset(String classCode) async {
    _progress.remove(classCode);
    _cursors.removeWhere((k, _) => k.startsWith('$classCode/'));
  }
}

class MemoryBookmarkRepo implements BookmarkRepo {
  final _keys = <String>{};
  @override
  Future<Set<String>> all() async => Set.of(_keys);
  @override
  Future<void> toggle(String questionKey) async =>
      _keys.contains(questionKey) ? _keys.remove(questionKey) : _keys.add(questionKey);
}

class MemoryExamRepo implements ExamRepo {
  MemoryExamRepo(this.content, this.study, {DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

  final ContentRepo content;
  final StudyRepo study;
  final DateTime Function() _now;
  final _attempts = <int, ExamAttempt>{};
  var _nextId = 1;

  @override
  Future<List<ExamSetSummary>> listSets(String classCode) async {
    return [
      for (var n = 1; n <= content.examSetCount(classCode); n++)
        () {
          final done = _attempts.values
              .where((a) => a.classCode == classCode && a.examSetNumber == n && a.isFinished && a.score != null)
              .toList();
          if (done.isEmpty) return ExamSetSummary(number: n);
          done.sort((a, b) => b.score!.compareTo(a.score!));
          return ExamSetSummary(
            number: n,
            bestScore: done.first.score,
            passed: done.any((a) => a.passed == true),
          );
        }(),
    ];
  }

  @override
  Future<int> start(String classCode, {int? setNumber}) async {
    final existing = await running();
    if (existing != null) await abandon(existing.id); // one running exam at a time
    final cls = content.cls(classCode);
    // Numbered sets use a fixed seed, so "Đề 3" is the same for every learner.
    // String.hashCode is not stable across runs, so hash the code units ourselves.
    final seed = classCode.codeUnits.fold(17, (h, c) => (h * 31 + c) & 0x7fffffff);
    final rng = setNumber == null ? Random() : Random(seed * 31 + setNumber);
    final qs = generateExam(cls: cls, pool: content.pool(classCode), quota: content.quota(classCode), rng: rng);
    final now = _now();
    final id = _nextId++;
    _attempts[id] = ExamAttempt(
      id: id,
      classCode: classCode,
      examSetNumber: setNumber,
      status: AttemptStatus.inProgress,
      startedAt: now,
      deadlineAt: now.add(Duration(minutes: cls.examMinutes)),
      passMark: cls.passMark,
      answers: [
        for (final (i, q) in qs.indexed)
          AttemptAnswer(position: i + 1, questionKey: q.key, isCritical: q.isCritical),
      ],
    );
    return id;
  }

  @override
  Future<ExamAttempt?> running() async =>
      _attempts.values.where((a) => a.status == AttemptStatus.inProgress).firstOrNull;

  @override
  Future<ExamAttempt> attempt(int id) async {
    final a = _attempts[id];
    if (a == null) throw StateError('No attempt $id');
    return a;
  }

  @override
  Future<void> answer(int attemptId, int position, int choice) async {
    final a = await attempt(attemptId);
    if (a.isFinished) return;
    _attempts[attemptId] = a.copyWith(answers: [
      for (final x in a.answers) x.position == position ? x.copyWith(chosen: choice) : x,
    ]);
  }

  @override
  Future<ExamAttempt> submit(int attemptId, {bool timedOut = false}) async {
    final a = await attempt(attemptId);
    if (a.isFinished) return a; // double-tap on submit is a no-op
    final g = grade(
      answers: a.answers,
      questions: {for (final x in a.answers) x.questionKey: content.question(x.questionKey)},
      passMark: a.passMark,
    );
    final done = a.copyWith(
      status: timedOut ? AttemptStatus.timedOut : AttemptStatus.submitted,
      finishedAt: _now(),
      answers: g.answers,
      score: g.score,
      passed: g.passed,
      failedOnCritical: g.failedOnCritical,
    );
    _attempts[attemptId] = done;
    for (final x in g.answers) {
      await study.record(a.classCode, x.questionKey, correct: x.isCorrect!);
    }
    return done;
  }

  @override
  Future<void> abandon(int attemptId) async {
    final a = await attempt(attemptId);
    if (a.isFinished) return;
    _attempts[attemptId] = a.copyWith(status: AttemptStatus.abandoned, finishedAt: _now());
  }

  @override
  Future<List<ExamAttempt>> history(String classCode) async {
    final list = _attempts.values
        .where((a) => a.classCode == classCode && a.score != null)
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return list;
  }
}
