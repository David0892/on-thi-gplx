// Behaviour every repository implementation must have. Run against the
// memory repos and the SQLite repos (memory_repo_test.dart, sql_repo_test.dart).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gplx_prep/data/memory_repositories.dart';
import 'package:gplx_prep/data/repositories.dart';
import 'package:gplx_prep/domain/exam_rules.dart';
import 'package:gplx_prep/domain/models.dart';

typedef Repos = ({
  SettingsRepo settings,
  BookmarkRepo bookmarks,
  StudyRepo study,
  ExamRepo exams,
});

SeedContentRepo loadSeed() => SeedContentRepo.fromJson(
      jsonDecode(File('assets/seed/content.json').readAsStringSync()) as Map<String, dynamic>,
    );

void runRepoContract(String name, Future<Repos> Function(ContentRepo content) make,
    {Future<void> Function()? tearDownFn}) {
  group(name, () {
    late ContentRepo content;
    late Repos r;

    setUp(() async {
      content = loadSeed();
      r = await make(content);
    });
    if (tearDownFn != null) tearDown(tearDownFn);

    test('seed is consistent', () {
      expect(content.classes(), hasLength(15));
      for (final q in content.pool('A1')) {
        expect(q.correctPosition, inInclusiveRange(1, q.options.length), reason: q.key);
        expect(q.explanation, isNotEmpty, reason: q.key);
      }
    });

    test('settings: no class at first, then the chosen one', () async {
      expect(await r.settings.selectedClass(), isNull);
      await r.settings.setClass('B');
      await r.settings.setClass('A1');
      expect(await r.settings.selectedClass(), 'A1');
    });

    test('A1: all correct passes, then a wrong critical fails', () async {
      final id = await r.exams.start('A1');
      var a = await r.exams.attempt(id);
      expect(a.questionCount, 25);
      expect(a.answers.where((x) => x.isCritical), hasLength(1));
      for (final x in a.answers) {
        await r.exams.answer(id, x.position, content.question(x.questionKey).correctPosition);
      }
      a = await r.exams.submit(id);
      expect(a.status, AttemptStatus.submitted);
      expect(a.score, 25);
      expect(a.passed, isTrue);

      final id2 = await r.exams.start('A1');
      final b = await r.exams.attempt(id2);
      for (final x in b.answers) {
        final q = content.question(x.questionKey);
        final wrong = q.correctPosition == 1 ? 2 : 1;
        await r.exams.answer(id2, x.position, x.isCritical ? wrong : q.correctPosition);
      }
      final graded = await r.exams.submit(id2);
      expect(graded.score, 24);
      expect(graded.passed, isFalse);
      expect(graded.failedOnCritical, isTrue);

      final wrongList = await r.study.questions(StudySource.wrong, 'A1');
      expect(wrongList.where((q) => q.isCritical), hasLength(1));
      expect(await r.exams.history('A1'), hasLength(2));
    });

    test('timed-out submit is recorded as timed out', () async {
      final id = await r.exams.start('A1');
      final a = await r.exams.submit(id, timedOut: true);
      expect(a.status, AttemptStatus.timedOut);
      expect(a.score, 0);
    });

    test('submit twice is a no-op; answers after submit are ignored', () async {
      final id = await r.exams.start('A1');
      final first = await r.exams.submit(id);
      await r.exams.answer(id, 1, 2);
      final second = await r.exams.submit(id);
      expect(second.finishedAt, first.finishedAt);
      expect((await r.exams.attempt(id)).answers.first.chosen, isNull);
    });

    test('starting a new exam abandons the running one', () async {
      final id = await r.exams.start('A1');
      expect((await r.exams.running())?.id, id);
      final id2 = await r.exams.start('A1');
      expect((await r.exams.attempt(id)).status, AttemptStatus.abandoned);
      expect((await r.exams.running())?.id, id2);
    });

    test('numbered sets are stable and track the best score', () async {
      final a = await r.exams.attempt(await r.exams.start('A1', setNumber: 3));
      final b = await r.exams.attempt(await r.exams.start('A1', setNumber: 3));
      expect(a.answers.map((x) => x.questionKey), b.answers.map((x) => x.questionKey));
      await r.exams.submit(b.id);
      final sets = await r.exams.listSets('A1');
      expect(sets[2].bestScore, 0);
      expect(sets[0].bestScore, isNull);
    });

    test('classes larger than the sample bank throw and write nothing', () async {
      await expectLater(r.exams.start('D'), throwsA(isA<NotEnoughQuestions>()));
      expect(await r.exams.running(), isNull);
    });

    test('wrong list: answering right takes it off; clear and reset work', () async {
      final q = content.pool('A1').first;
      await r.study.record('A1', q.key, correct: false);
      expect(await r.study.questions(StudySource.wrong, 'A1'), contains(q));
      await r.study.record('A1', q.key, correct: true);
      expect(await r.study.questions(StudySource.wrong, 'A1'), isNot(contains(q)));

      await r.study.record('A1', q.key, correct: false);
      await r.study.clearWrong('A1');
      expect(await r.study.questions(StudySource.wrong, 'A1'), isEmpty);
      expect((await r.study.progress('A1'))[q.key]?.timesWrong, 2);

      await r.study.reset('A1');
      expect(await r.study.progress('A1'), isEmpty);
    });

    test('progress is kept per class', () async {
      final q = content.pool('A1').first;
      await r.study.record('A1', q.key, correct: true);
      expect(await r.study.progress('B'), isEmpty);
    });

    test('bookmarks toggle and feed the saved list', () async {
      final q = content.pool('A1')[5];
      await r.bookmarks.toggle(q.key);
      expect(await r.study.questions(StudySource.saved, 'A1'), [q]);
      await r.bookmarks.toggle(q.key);
      expect(await r.bookmarks.all(), isEmpty);
    });

    test('topic cursor is saved per class and topic', () async {
      await r.study.saveCursor('A1', 2, 3);
      expect(await r.study.cursor('A1', 2), 3);
      expect(await r.study.cursor('A1', 1), 0);
      expect(await r.study.cursor('B', 2), 0);
    });
  });
}
