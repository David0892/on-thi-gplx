import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gplx_prep/data/memory_repositories.dart';
import 'package:gplx_prep/domain/search.dart';

void main() {
  final bank = SeedContentRepo.fromJson(
    jsonDecode(File('assets/content/content.json').readAsStringSync())
        as Map<String, dynamic>,
  );
  final all = bank.pool('B');

  test('folding drops Vietnamese accents, case and extra spaces', () {
    expect(foldVietnamese('  Đường   CAO tốc '), 'duong cao toc');
    expect(foldVietnamese('Biển báo hiệu'), 'bien bao hieu');
    // Decomposed input (base letter + combining mark) folds the same way.
    expect(foldVietnamese('Biển'), 'bien');
  });

  test('a number, with or without "câu", finds exactly that question', () {
    expect(searchQuestions(all, '145').single.number, 145);
    expect(searchQuestions(all, 'Câu 7').single.number, 7);
    expect(searchQuestions(all, '601'), isEmpty);
  });

  test('every word must match, accents optional, options included', () {
    final r = searchQuestions(all, 'nong do con');
    expect(r.map((q) => q.number), contains(24));
    expect(
      r.every((q) {
        final h = foldVietnamese('${q.text} ${q.options.join(' ')}');
        return h.contains('nong') && h.contains('do') && h.contains('con');
      }),
      isTrue,
    );
    // "70 m" lives only in an answer option of Câu 158.
    expect(
      searchQuestions(all, '100 km/h 70 m').map((q) => q.number),
      contains(158),
    );
  });

  test('empty or blank query returns nothing; results keep bank order', () {
    expect(searchQuestions(all, '   '), isEmpty);
    final r = searchQuestions(all, 'biển').map((q) => q.number).toList();
    expect(r, [...r]..sort());
    expect(r.length, greaterThan(100));
  });
}
