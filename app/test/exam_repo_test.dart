// The vertical slice at the data layer: seed -> start -> answer -> submit ->
// wrong list. Runs against the real seed file.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gplx_prep/data/memory_repositories.dart';
import 'package:gplx_prep/domain/exam_rules.dart';
import 'package:gplx_prep/domain/models.dart';

void main() {
  late SeedContentRepo content;
  late MemoryStudyRepo study;
  late MemoryExamRepo exams;

  setUp(() {
    content = SeedContentRepo.fromJson(
      jsonDecode(File('assets/seed/content.json').readAsStringSync()) as Map<String, dynamic>,
    );
    study = MemoryStudyRepo(content, MemoryBookmarkRepo());
    exams = MemoryExamRepo(content, study);
  });

  test('seed is consistent', () {
    expect(content.classes(), hasLength(15));
    for (final q in content.pool('A1')) {
      expect(q.correctPosition, inInclusiveRange(1, q.options.length), reason: q.key);
      expect(q.explanation, isNotEmpty, reason: q.key);
    }
  });

  test('A1: all correct passes, then a wrong critical fails', () async {
    final id = await exams.start('A1');
    var a = await exams.attempt(id);
    expect(a.questionCount, 25);
    for (final x in a.answers) {
      await exams.answer(id, x.position, content.question(x.questionKey).correctPosition);
    }
    a = await exams.submit(id);
    expect(a.score, 25);
    expect(a.passed, isTrue);

    final id2 = await exams.start('A1');
    final b = await exams.attempt(id2);
    for (final x in b.answers) {
      final q = content.question(x.questionKey);
      final wrong = q.correctPosition == 1 ? 2 : 1;
      await exams.answer(id2, x.position, x.isCritical ? wrong : q.correctPosition);
    }
    final graded = await exams.submit(id2);
    expect(graded.score, 24);
    expect(graded.passed, isFalse);
    expect(graded.failedOnCritical, isTrue);

    final wrongList = await study.questions(StudySource.wrong, 'A1');
    expect(wrongList.where((q) => q.isCritical), hasLength(1));
  });

  test('submit twice is a no-op', () async {
    final id = await exams.start('A1');
    final first = await exams.submit(id);
    final second = await exams.submit(id);
    expect(second.finishedAt, first.finishedAt);
  });

  test('starting a new exam abandons the running one', () async {
    final id = await exams.start('A1');
    await exams.start('A1');
    expect((await exams.attempt(id)).status, AttemptStatus.abandoned);
  });

  test('numbered sets are stable', () async {
    final a = await exams.attempt(await exams.start('A1', setNumber: 3));
    final b = await exams.attempt(await exams.start('A1', setNumber: 3));
    expect(a.answers.map((x) => x.questionKey), b.answers.map((x) => x.questionKey));
  });

  test('classes larger than the sample bank throw NotEnoughQuestions', () async {
    expect(() => exams.start('D'), throwsA(isA<NotEnoughQuestions>()));
  });

  test('answering a wrong-list question right takes it off the list', () async {
    final q = content.pool('A1').first;
    await study.record('A1', q.key, correct: false);
    expect(await study.questions(StudySource.wrong, 'A1'), contains(q));
    await study.record('A1', q.key, correct: true);
    expect(await study.questions(StudySource.wrong, 'A1'), isNot(contains(q)));
  });
}
