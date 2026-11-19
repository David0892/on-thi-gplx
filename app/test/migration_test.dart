// A user.db written by schema version 1 (before current_position existed)
// must open on the current version with its data intact.
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gplx_prep/data/db/user_db.dart';
import 'package:gplx_prep/data/sql_repositories.dart';
import 'package:sqlite3/sqlite3.dart';

import 'repo_contract.dart' show loadSeed;

void main() {
  test(
    'v1 database upgrades: running exam kept, resume position defaults to 1',
    () async {
      final dir = Directory.systemTemp.createTempSync('gplx_mig_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final path = '${dir.path}/user.db';

      // Exactly the v1 exam tables, as shipped in schema version 1.
      final raw = sqlite3.open(path);
      raw.execute('''
      CREATE TABLE settings ("key" TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL, updated_at INTEGER NOT NULL);
      CREATE TABLE question_progress (class_code TEXT NOT NULL, question_key TEXT NOT NULL,
        times_seen INTEGER NOT NULL DEFAULT 0, times_wrong INTEGER NOT NULL DEFAULT 0, last_correct INTEGER,
        in_wrong_list INTEGER NOT NULL DEFAULT 0, last_answered_at INTEGER, updated_at INTEGER NOT NULL,
        PRIMARY KEY (class_code, question_key));
      CREATE TABLE bookmarks (question_key TEXT NOT NULL PRIMARY KEY, created_at INTEGER NOT NULL);
      CREATE TABLE topic_cursor (class_code TEXT NOT NULL, topic_id INTEGER NOT NULL,
        position INTEGER NOT NULL DEFAULT 0, updated_at INTEGER NOT NULL, PRIMARY KEY (class_code, topic_id));
      CREATE TABLE exam_attempts (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, class_code TEXT NOT NULL,
        exam_set_number INTEGER, content_version INTEGER NOT NULL, status TEXT NOT NULL DEFAULT 'in_progress',
        started_at INTEGER NOT NULL, deadline_at INTEGER NOT NULL, finished_at INTEGER,
        question_count INTEGER NOT NULL, pass_mark INTEGER NOT NULL, score INTEGER, passed INTEGER,
        failed_on_critical INTEGER);
      CREATE UNIQUE INDEX one_running_exam ON exam_attempts (status) WHERE status = 'in_progress';
      CREATE TABLE attempt_answers (attempt_id INTEGER NOT NULL REFERENCES exam_attempts(id) ON DELETE CASCADE,
        position INTEGER NOT NULL, question_key TEXT NOT NULL, is_critical INTEGER NOT NULL,
        chosen_position INTEGER, is_correct INTEGER, answered_at INTEGER,
        PRIMARY KEY (attempt_id, position), UNIQUE (attempt_id, question_key));
      INSERT INTO settings VALUES ('class_code', 'A1', 1);
      INSERT INTO exam_attempts (id, class_code, content_version, started_at, deadline_at, question_count, pass_mark)
        VALUES (7, 'A1', 1, 1000, 9999999999999, 1, 1);
      INSERT INTO attempt_answers (attempt_id, position, question_key, is_critical, chosen_position)
        VALUES (7, 1, 'sample-001', 1, 2);
      PRAGMA user_version = 1;
    ''');
      raw.close();

      final db = UserDb(NativeDatabase(File(path)));
      addTearDown(db.close);
      final content = loadSeed();
      final exams = SqlExamRepo(
        db,
        content,
        SqlStudyRepo(db, content, SqlBookmarkRepo(db)),
      );
      expect(await SqlSettingsRepo(db).selectedClass(), 'A1');
      final running = await exams.running();
      expect(running?.id, 7);
      expect(running!.answers.single.chosen, 2);
      expect(running.currentPosition, 1);
      await exams.setPosition(7, 1);
      expect(db.schemaVersion, greaterThanOrEqualTo(2));
    },
  );
}
