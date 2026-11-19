// The shipped question bank (assets/content/content.json, built from the
// official PDFs by tool/content/build_content.py) against the published rules.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:gplx_prep/data/articles.dart';
import 'package:gplx_prep/data/memory_repositories.dart';
import 'package:gplx_prep/domain/exam_rules.dart';

void main() {
  final json = jsonDecode(
    File('assets/content/content.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final content = SeedContentRepo.fromJson(json);

  test('600 questions, 60 critical, official chapter ranges', () {
    final all = content.pool('B');
    expect(all, hasLength(600));
    expect(all.map((q) => q.number), List.generate(600, (i) => i + 1));
    expect(all.where((q) => q.isCritical), hasLength(60));
    const ranges = {
      1: (1, 180),
      2: (181, 205),
      3: (206, 263),
      4: (264, 300),
      5: (301, 485),
      6: (486, 600),
    };
    for (final q in all) {
      final (from, to) = ranges[q.topicId]!;
      expect(q.number, inInclusiveRange(from, to), reason: q.key);
      expect(q.options.length, inInclusiveRange(2, 4), reason: q.key);
      expect(
        q.correctPosition,
        inInclusiveRange(1, q.options.length),
        reason: q.key,
      );
    }
    expect(content.isSample, isFalse);
  });

  test('pools per Công văn 2262: A1/A 250 (20 critical), B1 300 (30 critical), others 600', () {
    for (final (code, size, critical) in [
      ('A1', 250, 20),
      ('A', 250, 20),
      ('B1', 300, 30),
      ('B', 600, 60),
      ('DE', 600, 60),
    ]) {
      final pool = content.pool(code);
      expect(pool, hasLength(size), reason: code);
      expect(
        pool.where((q) => q.isCritical),
        hasLength(critical),
        reason: code,
      );
    }
  });

  test('every class can build exams that follow its quota', () {
    for (final cls in content.classes()) {
      for (var seed = 0; seed < 30; seed++) {
        final exam = generateExam(
          cls: cls,
          pool: content.pool(cls.code),
          quota: content.quota(cls.code),
          rng: Random(seed),
        );
        expect(exam, hasLength(cls.examQuestionCount), reason: cls.code);
        expect(exam.where((q) => q.isCritical), hasLength(1), reason: cls.code);
        expect(
          exam.map((q) => q.key).toSet(),
          hasLength(exam.length),
          reason: cls.code,
        );
        final pool = content.pool(cls.code).map((q) => q.key).toSet();
        expect(
          exam.every((q) => pool.contains(q.key)),
          isTrue,
          reason: '${cls.code} drew outside its pool',
        );
      }
    }
  });

  test('every critical question has an explanation (own writing)', () {
    final critical = content.pool('B').where((q) => q.isCritical).toList();
    expect(critical, hasLength(60));
    for (final q in critical) {
      expect(q.explanation, isNotNull, reason: q.key);
      expect(q.explanation!.length, greaterThan(40), reason: q.key);
    }
    // A1/A see their 20 critical questions with explanations too.
    expect(
      content.pool('A1').where((q) => q.isCritical && q.explanation == null),
      isEmpty,
    );
  });

  test('all 600 questions have an explanation (own writing)', () {
    final missing = [
      for (final q in content.pool('B'))
        if ((q.explanation ?? '').length < 40) q.number,
    ];
    expect(missing, isEmpty);
  });

  test('every referenced image file exists; all sign and scenario questions have one', () {
    for (final q in content.pool('B')) {
      if (q.image != null) {
        expect(File(q.image!).existsSync(), isTrue, reason: q.image);
      }
      if (q.topicId >= 5) expect(q.image, isNotNull, reason: q.key);
    }
  });

  test('pass marks per Thông tư 12/2025 (A1 21, A 23, B1 23, B 27, C1 32, C 36, D 41)', () {
    const expected = {
      'A1': 21,
      'A': 23,
      'B1': 23,
      'B': 27,
      'C1': 32,
      'C': 36,
      'D1': 41,
      'D2': 41,
      'D': 41,
    };
    for (final MapEntry(:key, :value) in expected.entries) {
      expect(content.cls(key).passMark, value, reason: key);
      expect(content.cls(key).rulesVerified, isTrue, reason: key);
    }
  });

  test('tips and FAQ load; every referenced question exists', () {
    final a = Articles.fromJson(
      jsonDecode(File('assets/content/articles.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    expect(a.tips, isNotEmpty);
    expect(a.faq.expand((g) => g.items), isNotEmpty);
    final ids = a.tips.map((t) => t.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
    final numbers = content.pool('B').map((q) => q.number).toSet();
    for (final t in a.tips) {
      expect(t.points, isNotEmpty, reason: t.id);
      for (final p in t.points) {
        expect(
          numbers.containsAll(p.refs),
          isTrue,
          reason: '${t.id}: ${p.refs}',
        );
      }
    }
    expect(
      a.faq.expand((g) => g.items).where((i) => i.widget == 'class_table'),
      hasLength(1),
    );
  });

  test('sign library: every chapter V question in exactly one group', () {
    final a = Articles.fromJson(
      jsonDecode(File('assets/content/articles.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    final placed = a.signGroups.expand((g) => g.questionNumbers).toList();
    expect(placed.toSet(), hasLength(placed.length));
    expect(placed.toSet(), List.generate(185, (i) => 301 + i).toSet());
  });
}
