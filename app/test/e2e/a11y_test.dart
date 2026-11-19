// A11Y-1 and F02-E8 from replica/test-plan.md: Flutter's accessibility
// guidelines on every main screen, and the exam at 320px with 200% text.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gplx_prep/data/db/user_db.dart';

import 'harness.dart';

void main() {
  late UserDb db;
  setUp(() => db = memoryDb());
  tearDown(() => db.close());

  testWidgets('A11Y-1 onboarding', (tester) async {
    await launchApp(tester, db);
    await checkA11y(tester);
  });

  testWidgets('A11Y-1 home', (tester) async {
    await launchApp(tester, db);
    await pickClass(tester, 'A1');
    await checkA11y(tester);
  });

  testWidgets('A11Y-1 exam, answered', (tester) async {
    await launchApp(tester, db);
    await pickClass(tester, 'A1');
    await tapText(tester, 'Thi thử ngay');
    await answerCurrent(tester, correctly: true);
    await checkA11y(tester);
    await tester.binding.handlePopRoute(); // leave so the timer stops
    await settle(tester);
    await tapText(tester, 'Thoát');
  });

  testWidgets('A11Y-1 result and review', (tester) async {
    await launchApp(tester, db);
    await pickClass(tester, 'A1');
    await takeExam(tester, criticalWrong: true);
    await checkA11y(tester);
    await tapText(tester, 'Xem lại câu sai');
    await checkA11y(tester);
  });

  testWidgets('A11Y-1 study with explanation', (tester) async {
    await launchApp(tester, db);
    await pickClass(tester, 'A1');
    await tapText(tester, 'Ôn theo chủ đề');
    await checkA11y(tester);
    await tapText(tester, 'Kỹ thuật lái xe');
    await answerCurrent(tester, correctly: false);
    await checkA11y(tester);
  });

  testWidgets('A11Y-1 tips and FAQ', (tester) async {
    await launchApp(tester, db);
    await pickClass(tester, 'A1');
    await tapText(tester, 'Mẹo ghi nhớ');
    await checkA11y(tester);
    await tapText(tester, 'Tốc độ tối đa');
    await checkA11y(tester);
    await tester.pageBack();
    await settle(tester);
    await tester.pageBack();
    await settle(tester);
    await tapText(tester, 'Hỏi đáp');
    await tapText(
      tester,
      'Thi lý thuyết có bao nhiêu câu, làm trong bao lâu, đúng bao nhiêu câu thì đỗ?',
    );
    await checkA11y(tester);
  });

  testWidgets('S13/S14 at 320px, text 200%: no overflow', (tester) async {
    await launchApp(tester, db, size: const Size(320, 640), textScale: 2);
    await pickClass(tester, 'A1');
    await tapText(tester, 'Mẹo ghi nhớ');
    await tapText(tester, 'Tốc độ tối đa');
    await tester.pageBack();
    await settle(tester);
    await tester.pageBack();
    await settle(tester);
    await tapText(tester, 'Hỏi đáp');
    await tapText(
      tester,
      'Thi lý thuyết có bao nhiêu câu, làm trong bao lâu, đúng bao nhiêu câu thì đỗ?',
    );
    expect(find.text('A1'), findsWidgets);
  });

  for (final (w, h) in [(320.0, 640.0), (390.0, 844.0)]) {
    testWidgets(
      'F02-E8: ${w.toInt()}px wide, text 200%, whole exam flow has no overflow',
      (tester) async {
        await launchApp(tester, db, size: Size(w, h), textScale: 2);
        await pickClass(tester, 'A1');
        await takeExam(tester, criticalWrong: true);
        expect(find.text('24/25'), findsOneWidget);
        await tapText(tester, 'Xem lại câu sai');
        expect(find.text('Giải thích'), findsOneWidget);
      },
    );
  }
}
