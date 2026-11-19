// SQLite (drift) implementations of the repository contracts, over user.db.
// Same behaviour as memory_repositories.dart; the shared tests in
// test/repo_contract.dart run against both.
import 'dart:math';

import 'package:drift/drift.dart';

import '../domain/exam_rules.dart';
import '../domain/models.dart';
import 'db/user_db.dart' as db;
import 'repositories.dart';

int _now() => DateTime.now().toUtc().millisecondsSinceEpoch;
DateTime _time(int ms) =>
    DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toLocal();
bool? _bool(int? v) => v == null ? null : v == 1;
int _int(bool v) => v ? 1 : 0;

const _statusToDb = {
  AttemptStatus.inProgress: 'in_progress',
  AttemptStatus.submitted: 'submitted',
  AttemptStatus.timedOut: 'timed_out',
  AttemptStatus.abandoned: 'abandoned',
};
final _statusFromDb = {for (final e in _statusToDb.entries) e.value: e.key};

class SqlSettingsRepo implements SettingsRepo {
  SqlSettingsRepo(this._db);
  final db.UserDb _db;
  static const _classKey = 'class_code';

  @override
  Future<String?> selectedClass() async {
    final row = await (_db.select(
      _db.settings,
    )..where((t) => t.key.equals(_classKey))).getSingleOrNull();
    return row?.value;
  }

  @override
  Future<void> setClass(String code) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(
        db.SettingsCompanion.insert(
          key: _classKey,
          value: code,
          updatedAt: _now(),
        ),
      );
}

class SqlBookmarkRepo implements BookmarkRepo {
  SqlBookmarkRepo(this._db);
  final db.UserDb _db;

  @override
  Future<Set<String>> all() async =>
      (await _db.select(_db.bookmarks).get()).map((r) => r.questionKey).toSet();

  @override
  Future<void> toggle(String questionKey) => _db.transaction(() async {
    final deleted = await (_db.delete(
      _db.bookmarks,
    )..where((t) => t.questionKey.equals(questionKey))).go();
    if (deleted == 0) {
      await _db
          .into(_db.bookmarks)
          .insert(
            db.BookmarksCompanion.insert(
              questionKey: questionKey,
              createdAt: _now(),
            ),
          );
    }
  });
}

class SqlStudyRepo implements StudyRepo {
  SqlStudyRepo(this._db, this.content, this.bookmarks);
  final db.UserDb _db;
  final ContentRepo content;
  final BookmarkRepo bookmarks;

  @override
  Future<List<Question>> questions(
    StudySource source,
    String classCode, {
    int? topicId,
  }) async {
    final pool = content.pool(classCode);
    switch (source) {
      case StudySource.topic:
        return pool.where((q) => q.topicId == topicId).toList();
      case StudySource.critical:
        return pool.where((q) => q.isCritical).toList();
      case StudySource.wrong:
        final rows =
            await (_db.select(_db.questionProgress)..where(
                  (t) =>
                      t.classCode.equals(classCode) & t.inWrongList.equals(1),
                ))
                .get();
        final keys = rows.map((r) => r.questionKey).toSet();
        return pool.where((q) => keys.contains(q.key)).toList();
      case StudySource.saved:
        final saved = await bookmarks.all();
        return pool.where((q) => saved.contains(q.key)).toList();
    }
  }

  @override
  Future<void> record(
    String classCode,
    String questionKey, {
    required bool correct,
  }) => _db.transaction(() async {
    final old =
        await (_db.select(_db.questionProgress)..where(
              (t) =>
                  t.classCode.equals(classCode) &
                  t.questionKey.equals(questionKey),
            ))
            .getSingleOrNull();
    final now = _now();
    await _db
        .into(_db.questionProgress)
        .insertOnConflictUpdate(
          db.QuestionProgressCompanion.insert(
            classCode: classCode,
            questionKey: questionKey,
            timesSeen: Value((old?.timesSeen ?? 0) + 1),
            timesWrong: Value((old?.timesWrong ?? 0) + (correct ? 0 : 1)),
            lastCorrect: Value(_int(correct)),
            // Wrong puts it on the list; answering it right later takes it off.
            inWrongList: Value(_int(!correct)),
            lastAnsweredAt: Value(now),
            updatedAt: now,
          ),
        );
  });

  @override
  Future<Map<String, QuestionProgress>> progress(String classCode) async {
    final rows = await (_db.select(
      _db.questionProgress,
    )..where((t) => t.classCode.equals(classCode))).get();
    return {
      for (final r in rows)
        r.questionKey: QuestionProgress(
          timesSeen: r.timesSeen,
          timesWrong: r.timesWrong,
          lastCorrect: _bool(r.lastCorrect),
          inWrongList: r.inWrongList == 1,
        ),
    };
  }

  @override
  Future<int> cursor(String classCode, int topicId) async {
    final row =
        await (_db.select(_db.topicCursor)..where(
              (t) => t.classCode.equals(classCode) & t.topicId.equals(topicId),
            ))
            .getSingleOrNull();
    return row?.position ?? 0;
  }

  @override
  Future<void> saveCursor(String classCode, int topicId, int position) => _db
      .into(_db.topicCursor)
      .insertOnConflictUpdate(
        db.TopicCursorCompanion.insert(
          classCode: classCode,
          topicId: topicId,
          position: Value(position),
          updatedAt: _now(),
        ),
      );

  @override
  Future<void> clearWrong(String classCode) =>
      (_db.update(
        _db.questionProgress,
      )..where((t) => t.classCode.equals(classCode))).write(
        db.QuestionProgressCompanion(
          inWrongList: const Value(0),
          updatedAt: Value(_now()),
        ),
      );

  @override
  Future<void> reset(String classCode) => _db.transaction(() async {
    await (_db.delete(
      _db.questionProgress,
    )..where((t) => t.classCode.equals(classCode))).go();
    await (_db.delete(
      _db.topicCursor,
    )..where((t) => t.classCode.equals(classCode))).go();
  });
}

class SqlExamRepo implements ExamRepo {
  SqlExamRepo(this._db, this.content, this.study);
  final db.UserDb _db;
  final ContentRepo content;
  final StudyRepo study;

  @override
  Future<List<ExamSetSummary>> listSets(String classCode) async {
    final rows =
        await (_db.select(_db.examAttempts)..where(
              (t) =>
                  t.classCode.equals(classCode) &
                  t.examSetNumber.isNotNull() &
                  t.score.isNotNull(),
            ))
            .get();
    return [
      for (var n = 1; n <= content.examSetCount(classCode); n++)
        () {
          final done = rows.where((r) => r.examSetNumber == n).toList();
          if (done.isEmpty) return ExamSetSummary(number: n);
          return ExamSetSummary(
            number: n,
            bestScore: done.map((r) => r.score!).reduce(max),
            passed: done.any((r) => r.passed == 1),
          );
        }(),
    ];
  }

  @override
  Future<int> start(String classCode, {int? setNumber}) async {
    final cls = content.cls(classCode);
    // Same fixed-seed rule as the memory repo, so "Đề 3" is identical in both.
    final seed = classCode.codeUnits.fold(
      17,
      (h, c) => (h * 31 + c) & 0x7fffffff,
    );
    final rng = setNumber == null ? Random() : Random(seed * 31 + setNumber);
    // Generate before the transaction: NotEnoughQuestions must not leave a half-written exam.
    final qs = generateExam(
      cls: cls,
      pool: content.pool(classCode),
      quota: content.quota(classCode),
      rng: rng,
    );

    return _db.transaction(() async {
      final now = _now();
      // One running exam at a time (also enforced by the one_running_exam index).
      await (_db.update(
        _db.examAttempts,
      )..where((t) => t.status.equals('in_progress'))).write(
        db.ExamAttemptsCompanion(
          status: const Value('abandoned'),
          finishedAt: Value(now),
        ),
      );
      final id = await _db
          .into(_db.examAttempts)
          .insert(
            db.ExamAttemptsCompanion.insert(
              classCode: classCode,
              examSetNumber: Value(setNumber),
              contentVersion: content.contentVersion,
              startedAt: now,
              deadlineAt: now + cls.examMinutes * 60 * 1000,
              questionCount: qs.length,
              passMark: cls.passMark,
            ),
          );
      await _db.batch(
        (b) => b.insertAll(_db.attemptAnswers, [
          for (final (i, q) in qs.indexed)
            db.AttemptAnswersCompanion.insert(
              attemptId: id,
              position: i + 1,
              questionKey: q.key,
              isCritical: _int(q.isCritical),
            ),
        ]),
      );
      return id;
    });
  }

  ExamAttempt _toDomain(db.ExamAttempt a, List<db.AttemptAnswer> answers) =>
      ExamAttempt(
        id: a.id,
        classCode: a.classCode,
        examSetNumber: a.examSetNumber,
        status: _statusFromDb[a.status]!,
        startedAt: _time(a.startedAt),
        deadlineAt: _time(a.deadlineAt),
        finishedAt: a.finishedAt == null ? null : _time(a.finishedAt!),
        passMark: a.passMark,
        score: a.score,
        passed: _bool(a.passed),
        failedOnCritical: _bool(a.failedOnCritical),
        currentPosition: a.currentPosition,
        answers: [
          for (final x in answers)
            AttemptAnswer(
              position: x.position,
              questionKey: x.questionKey,
              isCritical: x.isCritical == 1,
              chosen: x.chosenPosition,
              isCorrect: _bool(x.isCorrect),
            ),
        ],
      );

  Future<List<db.AttemptAnswer>> _answers(int id) =>
      (_db.select(_db.attemptAnswers)
            ..where((t) => t.attemptId.equals(id))
            ..orderBy([(t) => OrderingTerm.asc(t.position)]))
          .get();

  @override
  Future<ExamAttempt> attempt(int id) async {
    final a = await (_db.select(
      _db.examAttempts,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (a == null) throw StateError('No attempt $id');
    return _toDomain(a, await _answers(id));
  }

  @override
  Future<ExamAttempt?> running() async {
    final a = await (_db.select(
      _db.examAttempts,
    )..where((t) => t.status.equals('in_progress'))).getSingleOrNull();
    return a == null ? null : _toDomain(a, await _answers(a.id));
  }

  @override
  Future<void> answer(int attemptId, int position, int choice) async {
    // The subquery guard means a finished exam can never be changed.
    await (_db.update(_db.attemptAnswers)..where(
          (t) =>
              t.attemptId.equals(attemptId) &
              t.position.equals(position) &
              existsQuery(
                _db.selectOnly(_db.examAttempts)
                  ..addColumns([_db.examAttempts.id])
                  ..where(
                    _db.examAttempts.id.equals(attemptId) &
                        _db.examAttempts.status.equals('in_progress'),
                  ),
              ),
        ))
        .write(
          db.AttemptAnswersCompanion(
            chosenPosition: Value(choice),
            answeredAt: Value(_now()),
          ),
        );
  }

  @override
  Future<void> setPosition(int attemptId, int position) async {
    await (_db.update(_db.examAttempts)..where(
          (t) => t.id.equals(attemptId) & t.status.equals('in_progress'),
        ))
        .write(db.ExamAttemptsCompanion(currentPosition: Value(position)));
  }

  @override
  Future<ExamAttempt> submit(int attemptId, {bool timedOut = false}) =>
      _db.transaction(() async {
        final a = await attempt(attemptId);
        if (a.isFinished) return a; // double-tap on submit is a no-op
        final g = grade(
          answers: a.answers,
          questions: {
            for (final x in a.answers)
              x.questionKey: content.question(x.questionKey),
          },
          passMark: a.passMark,
        );
        await _db.batch((b) {
          for (final x in g.answers) {
            b.update(
              _db.attemptAnswers,
              db.AttemptAnswersCompanion(isCorrect: Value(_int(x.isCorrect!))),
              where: (t) =>
                  t.attemptId.equals(attemptId) & t.position.equals(x.position),
            );
          }
        });
        await (_db.update(
          _db.examAttempts,
        )..where((t) => t.id.equals(attemptId))).write(
          db.ExamAttemptsCompanion(
            status: Value(timedOut ? 'timed_out' : 'submitted'),
            finishedAt: Value(_now()),
            score: Value(g.score),
            passed: Value(_int(g.passed)),
            failedOnCritical: Value(_int(g.failedOnCritical)),
          ),
        );
        for (final x in g.answers) {
          await study.record(a.classCode, x.questionKey, correct: x.isCorrect!);
        }
        return attempt(attemptId);
      });

  @override
  Future<void> abandon(int attemptId) async {
    await (_db.update(_db.examAttempts)..where(
          (t) => t.id.equals(attemptId) & t.status.equals('in_progress'),
        ))
        .write(
          db.ExamAttemptsCompanion(
            status: const Value('abandoned'),
            finishedAt: Value(_now()),
          ),
        );
  }

  @override
  Future<List<ExamAttempt>> history(String classCode) async {
    final rows =
        await (_db.select(_db.examAttempts)
              ..where(
                (t) => t.classCode.equals(classCode) & t.score.isNotNull(),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
            .get();
    return [for (final r in rows) _toDomain(r, await _answers(r.id))];
  }
}

/// Run once per launch, before any screen reads user data. When the question
/// bank changes (content_version), user rows that point at questions which no
/// longer exist are removed, so no screen can meet an unknown question key.
/// Returns true when something was cleaned up (worth telling the user).
Future<bool> reconcileWithContent(db.UserDb udb, ContentRepo content) =>
    udb.transaction(() async {
      const key = 'content_version';
      final row = await (udb.select(
        udb.settings,
      )..where((t) => t.key.equals(key))).getSingleOrNull();
      if (row?.value == '${content.contentVersion}') return false;

      var removed = 0;
      for (final p in await udb.select(udb.questionProgress).get()) {
        if (!content.hasQuestion(p.questionKey)) {
          removed +=
              await (udb.delete(udb.questionProgress)..where(
                    (t) =>
                        t.classCode.equals(p.classCode) &
                        t.questionKey.equals(p.questionKey),
                  ))
                  .go();
        }
      }
      for (final b in await udb.select(udb.bookmarks).get()) {
        if (!content.hasQuestion(b.questionKey)) {
          removed += await (udb.delete(
            udb.bookmarks,
          )..where((t) => t.questionKey.equals(b.questionKey))).go();
        }
      }
      // Topic numbering may change with the bank: resume points start over.
      removed += await udb.delete(udb.topicCursor).go();
      // An exam that contains an unknown question cannot be shown or graded.
      final stale = <int>{
        for (final a in await udb.select(udb.attemptAnswers).get())
          if (!content.hasQuestion(a.questionKey)) a.attemptId,
      };
      for (final id in stale) {
        await (udb.delete(
          udb.attemptAnswers,
        )..where((t) => t.attemptId.equals(id))).go();
        removed += await (udb.delete(
          udb.examAttempts,
        )..where((t) => t.id.equals(id))).go();
      }
      await udb
          .into(udb.settings)
          .insertOnConflictUpdate(
            db.SettingsCompanion.insert(
              key: key,
              value: '${content.contentVersion}',
              updatedAt: _now(),
            ),
          );
      return row != null && removed > 0;
    });
