import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gplx_prep/data/db/user_db.dart';
import 'package:gplx_prep/data/repositories.dart';
import 'package:gplx_prep/data/sql_repositories.dart';
import 'package:gplx_prep/domain/models.dart' show StudySource, AttemptStatus;

import 'repo_contract.dart';

({
  SettingsRepo settings,
  BookmarkRepo bookmarks,
  StudyRepo study,
  ExamRepo exams,
})
sqlRepos(UserDb db, ContentRepo content) {
  final bookmarks = SqlBookmarkRepo(db);
  final study = SqlStudyRepo(db, content, bookmarks);
  return (
    settings: SqlSettingsRepo(db),
    bookmarks: bookmarks,
    study: study,
    exams: SqlExamRepo(db, content, study),
  );
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  UserDb? db;
  runRepoContract('sqlite repos', (content) async {
    db = UserDb(NativeDatabase.memory());
    return sqlRepos(db!, content);
  }, tearDownFn: () async => db?.close());

  group('sqlite persistence across restarts', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('gplx_userdb_'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('a running exam, its answers, progress and settings survive closing the database', () async {
      final file = File('${dir.path}/user.db');
      final content = loadSeed();

      // Session 1: pick a class, start an exam, answer 2 questions, save a question. Then "kill" the app.
      var db1 = UserDb(NativeDatabase(file));
      var r = sqlRepos(db1, content);
      await r.settings.setClass('A1');
      final id = await r.exams.start('A1');
      final a = await r.exams.attempt(id);
      await r.exams.answer(id, 1, 2);
      await r.exams.answer(id, 2, 1);
      await r.bookmarks.toggle(a.answers[3].questionKey);
      await r.study.record('A1', a.answers[4].questionKey, correct: false);
      await db1.close();

      // Session 2: everything is still there and the exam can be finished.
      final db2 = UserDb(NativeDatabase(file));
      r = sqlRepos(db2, content);
      expect(await r.settings.selectedClass(), 'A1');
      final running = await r.exams.running();
      expect(running?.id, id);
      expect(running!.answeredCount, 2);
      expect(running.answers[0].chosen, 2);
      expect(running.deadlineAt, a.deadlineAt);
      expect(await r.bookmarks.all(), {a.answers[3].questionKey});
      expect(await r.study.questions(StudySource.wrong, 'A1'), hasLength(1));

      final done = await r.exams.submit(id, timedOut: true);
      expect(done.status, AttemptStatus.timedOut);
      expect(await r.exams.running(), isNull);
      await db2.close();
    });

    test(
      'the database refuses a second running exam (one_running_exam index)',
      () async {
        final db = UserDb(NativeDatabase.memory());
        final content = loadSeed();
        final r = sqlRepos(db, content);
        await r.exams.start('A1');
        await expectLater(
          db.customInsert(
            "INSERT INTO exam_attempts (class_code, content_version, status, started_at, deadline_at, "
            "question_count, pass_mark) VALUES ('A1', 1, 'in_progress', 1, 2, 25, 21)",
          ),
          throwsA(isA<SqliteException>()),
        );
        await db.close();
      },
    );
  });
}
