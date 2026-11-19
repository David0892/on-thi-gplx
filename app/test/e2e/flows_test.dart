// End-to-end flows F01–F07 from replica/test-plan.md. Case IDs in test names.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gplx_prep/data/db/user_db.dart';
import 'package:gplx_prep/features/browse/question_page.dart';
import 'package:gplx_prep/features/guide/faq_page.dart';
import 'package:gplx_prep/design/widgets.dart';

import 'harness.dart';

void main() {
  late UserDb db;
  setUp(() => db = memoryDb());
  tearDown(() => db.close());

  group('F01 pick a class', () {
    testWidgets(
      'F01-E1 + F01-H1: button disabled until a class is picked, then home',
      (tester) async {
        await launchApp(tester, db);
        expect(find.text('Chọn một hạng để tiếp tục'), findsOneWidget);
        final button = tester.widget<FilledButton>(
          find.ancestor(
            of: find.text('Chọn một hạng để tiếp tục'),
            matching: find.byType(FilledButton),
          ),
        );
        expect(button.onPressed, isNull);
        await pickClass(tester, 'A1');
        expect(find.text('Hạng A1'), findsWidgets);
        expect(find.text('Thi thử ngay'), findsOneWidget);
      },
    );

    testWidgets('F01-E2: restart after picking lands on home', (tester) async {
      await launchApp(tester, db);
      await pickClass(tester, 'A1');
      await launchApp(tester, db);
      expect(find.text('Thi thử ngay'), findsOneWidget);
      expect(find.text('Bạn đang ôn thi bằng hạng nào?'), findsNothing);
    });

    testWidgets('F01-E3: change class from the chip keeps A1 progress apart', (
      tester,
    ) async {
      await launchApp(tester, db);
      await pickClass(tester, 'A1');
      await tapText(tester, 'Ôn theo chủ đề');
      await tapText(tester, 'Quy định chung và quy tắc giao thông');
      await answerCurrent(tester, correctly: true);
      await tester.pageBack();
      await settle(tester);
      await tester.pageBack();
      await settle(tester);
      expect(find.text('1/32 câu đã trả lời đúng'), findsOneWidget);

      await tapLabel(tester, RegExp('Đang ôn hạng A1'));
      await pickClass(tester, 'B');
      expect(find.text('Hạng B'), findsWidgets);
      expect(find.text('0/32 câu đã trả lời đúng'), findsOneWidget);
    });
  });

  group('F02 mock exam', () {
    testWidgets('F02-H1: all correct passes 25/25', (tester) async {
      await launchApp(tester, db);
      await pickClass(tester, 'A1');
      await takeExam(tester);
      expect(find.text('25/25'), findsOneWidget);
      expect(find.text('Đạt'), findsOneWidget);
    });

    testWidgets('F02-E1: submitting with blanks warns and scores 0', (
      tester,
    ) async {
      await launchApp(tester, db);
      await pickClass(tester, 'A1');
      await tapText(tester, 'Thi thử ngay');
      await tapText(tester, 'Nộp');
      expect(
        find.textContaining('Bạn còn 25 câu chưa trả lời'),
        findsOneWidget,
      );
      await tapText(tester, 'Nộp bài');
      expect(find.text('0/25'), findsOneWidget);
      expect(find.text('Chưa đạt'), findsOneWidget);
      expect(find.text('Bỏ trống'), findsOneWidget);
    });

    testWidgets('F02-E2: one wrong critical fails a 24/25 exam', (
      tester,
    ) async {
      await launchApp(tester, db);
      await pickClass(tester, 'A1');
      await takeExam(tester, criticalWrong: true);
      expect(find.text('24/25'), findsOneWidget);
      expect(find.text('Chưa đạt'), findsOneWidget);
      expect(find.textContaining('Sai câu điểm liệt'), findsOneWidget);
    });

    testWidgets(
      'F02-E3: double tap on Nộp opens one dialog and records one result',
      (tester) async {
        await launchApp(tester, db);
        await pickClass(tester, 'A1');
        await tapText(tester, 'Thi thử ngay');
        final submit = find.text('Nộp').last;
        await tester.tap(submit);
        await tester.tap(submit, warnIfMissed: false);
        await settle(tester);
        expect(find.byType(AlertDialog), findsOneWidget);
        await tapText(tester, 'Nộp bài');
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text('0/25'), findsOneWidget);
        final all = await tester.runAsync(() => attempts(db));
        expect(all!.where((a) => a.score != null), hasLength(1));
      },
    );

    testWidgets('F02-E4: back mid-exam asks, then abandons', (tester) async {
      await launchApp(tester, db);
      await pickClass(tester, 'A1');
      await tapText(tester, 'Thi thử ngay');
      await tester.binding.handlePopRoute();
      await settle(tester);
      expect(find.text('Thoát bài thi?'), findsOneWidget);
      await tapText(tester, 'Thoát');
      expect(find.text('Làm đề ngẫu nhiên'), findsOneWidget);
      final all = await tester.runAsync(() => attempts(db));
      expect(all!.single.status, 'abandoned');
    });

    testWidgets('F02-E5: killed mid-exam, resumed with the answer kept', (
      tester,
    ) async {
      await launchApp(tester, db);
      await pickClass(tester, 'A1');
      await tapText(tester, 'Thi thử ngay');
      final q = currentQuestion(tester);
      await answerCurrent(tester, correctly: true);

      await launchApp(tester, db); // restart
      expect(
        find.textContaining('Bạn có bài thi đang làm dở (1/25 câu)'),
        findsOneWidget,
      );
      await tapText(tester, 'Làm tiếp');
      expect(currentQuestion(tester).key, q.key);
      final option = tester.widget<AnswerOption>(
        find.ancestor(
          of: find.text(q.options[q.correctPosition - 1]),
          matching: find.byType(AnswerOption),
        ),
      );
      expect(option.state, AnswerState.selected);
    });

    testWidgets(
      'F02-E6: reopened after the deadline goes straight to a timed-out result',
      (tester) async {
        await launchApp(tester, db);
        await pickClass(tester, 'A1');
        await tapText(tester, 'Thi thử ngay');
        await answerCurrent(tester, correctly: true);
        await tester.runAsync(() => runningToPast(db));

        await launchApp(tester, db);
        await tapText(tester, 'Làm tiếp');
        expect(find.text('Hết giờ: bài đã được nộp tự động.'), findsOneWidget);
        expect(find.text('1/25'), findsOneWidget);
        final all = await tester.runAsync(() => attempts(db));
        expect(all!.single.status, 'timed_out');
      },
    );

    testWidgets('F02-E7: resuming returns to the last question viewed', (
      tester,
    ) async {
      await launchApp(tester, db);
      await pickClass(tester, 'A1');
      await tapText(tester, 'Thi thử ngay');
      for (var i = 0; i < 4; i++) {
        await nextQuestion(tester);
      }
      expect(find.text('Câu 5/25'), findsWidgets);

      await launchApp(tester, db);
      await tapText(tester, 'Làm tiếp');
      expect(find.text('Câu 5/25'), findsWidgets);
    });

    testWidgets(
      'F02-N1: a class bigger than the bank shows a dialog and writes nothing',
      (tester) async {
        await launchApp(tester, db);
        await pickClass(tester, 'D');
        await tapText(tester, 'Thi thử ngay');
        expect(find.text('Chưa đủ câu hỏi'), findsOneWidget);
        await tapText(tester, 'Đã hiểu');
        expect(await tester.runAsync(() => attempts(db)), isEmpty);
      },
    );
  });

  group('F03 review', () {
    testWidgets('F03-H1: review wrong answers after a failed exam', (
      tester,
    ) async {
      await launchApp(tester, db);
      await pickClass(tester, 'A1');
      await takeExam(tester, criticalWrong: true);
      await tapText(tester, 'Xem lại câu sai');
      expect(find.text('Câu sai (1)'), findsOneWidget);
      expect(find.byType(QuestionCard), findsOneWidget);
      expect(find.text('Giải thích'), findsOneWidget);
      final states = tester
          .widgetList<AnswerOption>(find.byType(AnswerOption))
          .map((o) => o.state);
      expect(states, containsAll([AnswerState.wrong, AnswerState.missed]));
    });

    testWidgets('F03-E1: a perfect exam has nothing wrong to review', (
      tester,
    ) async {
      await launchApp(tester, db);
      await pickClass(tester, 'A1');
      await takeExam(tester);
      expect(find.text('Xem lại câu sai'), findsNothing);
      await tapText(tester, 'Xem lại cả bài');
      await tapText(tester, 'Câu sai (0)');
      expect(find.text('Không sai câu nào'), findsOneWidget);
    });
  });

  group('F04 study a topic', () {
    testWidgets(
      'F04-H1: wrong answer reveals, explains and joins the wrong list',
      (tester) async {
        await launchApp(tester, db);
        await pickClass(tester, 'A1');
        await tapText(tester, 'Ôn theo chủ đề');
        await tapText(tester, 'Văn hoá giao thông và đạo đức người lái');
        await answerCurrent(tester, correctly: false);
        expect(find.text('Giải thích'), findsOneWidget);
        final states = tester
            .widgetList<AnswerOption>(find.byType(AnswerOption))
            .map((o) => o.state);
        expect(states, containsAll([AnswerState.wrong, AnswerState.missed]));
        await tester.pageBack();
        await settle(tester);
        await tester.pageBack();
        await settle(tester);
        expect(find.bySemanticsLabel('Câu sai, 1 câu'), findsOneWidget);
      },
    );

    testWidgets('F04-E1: reopening a topic resumes where you left', (
      tester,
    ) async {
      await launchApp(tester, db);
      await pickClass(tester, 'A1');
      await tapText(tester, 'Ôn theo chủ đề');
      await tapText(tester, 'Kỹ thuật lái xe');
      await tapText(tester, 'Tiếp');
      await tapText(tester, 'Tiếp');
      expect(find.text('Câu 3/5'), findsWidgets);
      await tester.pageBack();
      await settle(tester);
      await tapText(tester, 'Kỹ thuật lái xe');
      expect(find.text('Câu 3/5'), findsWidgets);
    });

    testWidgets('F04-E2: the last question offers a summary', (tester) async {
      await launchApp(tester, db);
      await pickClass(tester, 'A1');
      await tapText(tester, 'Ôn theo chủ đề');
      await tapText(tester, 'Văn hoá giao thông và đạo đức người lái');
      for (var i = 0; i < 4; i++) {
        await answerCurrent(tester, correctly: true);
        if (i < 3) await tapText(tester, 'Tiếp');
      }
      await tapText(tester, 'Hoàn thành');
      expect(find.text('Bạn đã trả lời 4/4 câu, đúng 4 câu.'), findsOneWidget);
    });
  });

  testWidgets('F05-H1: critical drill shows only critical questions', (
    tester,
  ) async {
    await launchApp(tester, db);
    await pickClass(tester, 'A1');
    await tapText(tester, 'Câu điểm liệt');
    expect(find.text('Câu 1/3'), findsWidgets);
    expect(find.text('Điểm liệt'), findsOneWidget);
  });

  group('F06 wrong answers', () {
    testWidgets('F06-E1: empty at first', (tester) async {
      await launchApp(tester, db);
      await pickClass(tester, 'A1');
      await tapText(tester, 'Câu sai');
      expect(find.text('Chưa có câu sai nào'), findsOneWidget);
    });

    testWidgets('F06-H1: answering right in the list removes it next time', (
      tester,
    ) async {
      await launchApp(tester, db);
      await pickClass(tester, 'A1');
      await tapText(tester, 'Ôn theo chủ đề');
      await tapText(tester, 'Kỹ thuật lái xe');
      await answerCurrent(tester, correctly: false);
      await tester.pageBack();
      await settle(tester);
      await tester.pageBack();
      await settle(tester);
      await tapText(tester, 'Câu sai');
      expect(find.text('Câu 1/1'), findsWidgets);
      await answerCurrent(tester, correctly: true);
      await tester.pageBack();
      await settle(tester);
      await tapText(tester, 'Câu sai');
      expect(find.text('Chưa có câu sai nào'), findsOneWidget);
    });

    testWidgets('F06-E2: clearing the list keeps progress', (tester) async {
      await launchApp(tester, db);
      await pickClass(tester, 'A1');
      await takeExam(tester, allWrong: true);
      await tapLabel(tester, 'Về trang chủ');
      await tapText(tester, 'Câu sai');
      await tapLabel(tester, 'Xoá danh sách');
      await tapText(tester, 'Xoá');
      expect(find.text('Chưa có câu sai nào'), findsOneWidget);
    });
  });

  group('S12 sign library (official bank)', () {
    testWidgets('F07-H1: group → question with answer and explanation', (
      tester,
    ) async {
      await launchApp(tester, db, contentRepo: bank);
      await pickClass(tester, 'B');
      await tapText(tester, 'Biển báo');
      await tapText(tester, 'Vạch kẻ đường');
      expect(find.byType(QuestionRow), findsWidgets);
      await tapText(tester, 'Câu 478');
      expect(find.text('Câu 478/600'), findsOneWidget);
      final q = bank.pool('B').firstWhere((q) => q.number == 478);
      final correct = tester.widget<AnswerOption>(
        find.byWidgetPredicate(
          (w) => w is AnswerOption && w.position == q.correctPosition,
        ),
      );
      expect(correct.state, AnswerState.correct);
      expect(find.textContaining('vạch tim đường'), findsWidgets);
    });

    testWidgets('F07-E1: groups only count questions in the class pool', (
      tester,
    ) async {
      await launchApp(tester, db, contentRepo: bank);
      await pickClass(tester, 'A1');
      await tapText(tester, 'Biển báo');
      final a1 = bank.pool('A1').map((q) => q.number).toSet();
      final g = articles.signGroups.first;
      final n = g.questionNumbers.where(a1.contains).length;
      expect(find.text('$n câu · ${g.summary}'), findsOneWidget);
    });
  });

  group('S16 search (official bank)', () {
    testWidgets('F08-H1: words without accents find the question', (
      tester,
    ) async {
      await launchApp(tester, db, contentRepo: bank);
      await pickClass(tester, 'B');
      await tapLabel(tester, 'Tìm câu hỏi');
      await tester.enterText(find.byType(TextField), 'nong do con');
      await settle(tester);
      expect(find.text('Câu 24'), findsOneWidget);
      await tapText(tester, 'Câu 24');
      expect(find.text('Câu 24/600'), findsOneWidget);
    });

    testWidgets('F08-H2: a number opens that question; no match says so', (
      tester,
    ) async {
      await launchApp(tester, db, contentRepo: bank);
      await pickClass(tester, 'B');
      await tapLabel(tester, 'Tìm câu hỏi');
      await tester.enterText(find.byType(TextField), 'câu 145');
      await settle(tester);
      expect(find.text('1 câu'), findsOneWidget);
      expect(find.text('Câu 145'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'xyzzy khong co');
      await settle(tester);
      expect(find.text('Không tìm thấy câu nào'), findsOneWidget);
    });

    testWidgets('F08-E1: a question outside the class still opens, flagged', (
      tester,
    ) async {
      await launchApp(tester, db, contentRepo: bank);
      await pickClass(tester, 'A1');
      final a1 = bank.pool('A1').map((q) => q.number).toSet();
      final outside = List.generate(
        600,
        (i) => i + 1,
      ).firstWhere((n) => !a1.contains(n));
      final ctx = tester.element(find.byType(Scaffold).first);
      GoRouter.of(ctx).push('/question/$outside');
      await settle(tester);
      expect(find.text('Câu $outside/600'), findsOneWidget);
      expect(
        find.text('Câu này không có trong bộ câu của Hạng A1.'),
        findsOneWidget,
      );
      expect(find.byType(CriticalBadge), findsNothing);
    });
  });

  testWidgets('S13-H1: tips list opens an article with its points', (
    tester,
  ) async {
    await launchApp(tester, db);
    await pickClass(tester, 'A1');
    await tapText(tester, 'Mẹo ghi nhớ');
    expect(find.text('Tốc độ tối đa'), findsOneWidget);
    await tapText(tester, 'Khoảng cách an toàn');
    expect(find.textContaining('tối thiểu 35 m'), findsOneWidget);
    expect(find.text('Câu liên quan: 161'), findsOneWidget);
    await tester.pageBack();
    await settle(tester);
    expect(find.text('Tốc độ tối đa'), findsOneWidget);
  });

  testWidgets('S13-E1: unknown tip id shows a not-found state', (tester) async {
    await launchApp(tester, db);
    await pickClass(tester, 'A1');
    final ctx = tester.element(find.byType(Scaffold).first);
    GoRouter.of(ctx).push('/tips/khong-co');
    await settle(tester);
    expect(find.text('Không tìm thấy mẹo này'), findsOneWidget);
  });

  testWidgets('S14-H1: FAQ answer expands, class table matches the rules', (
    tester,
  ) async {
    await launchApp(tester, db);
    await pickClass(tester, 'A1');
    await tapText(tester, 'Hỏi đáp');
    expect(find.text('Hỏi đáp về kỳ thi'), findsOneWidget);
    await tapText(
      tester,
      'Thi lý thuyết có bao nhiêu câu, làm trong bao lâu, đúng bao nhiêu câu thì đỗ?',
    );
    expect(find.byType(ClassRulesTable), findsOneWidget);
    for (final k in content.classes()) {
      expect(
        find.text('${k.passMark}/${k.examQuestionCount}'),
        findsWidgets,
        reason: k.code,
      );
    }
    expect(find.text('BE*'), findsOneWidget); // unverified rules are flagged
  });

  testWidgets('S15-H1: reset progress empties home stats', (tester) async {
    await launchApp(tester, db);
    await pickClass(tester, 'A1');
    await takeExam(tester, criticalWrong: true);
    await tapLabel(tester, 'Về trang chủ');
    expect(find.text('24/32 câu đã trả lời đúng'), findsOneWidget);
    await tapLabel(tester, 'Cài đặt');
    await tapText(tester, 'Xoá tiến độ Hạng A1');
    await tapText(tester, 'Xoá tiến độ');
    await tester.pageBack();
    await settle(tester);
    expect(find.text('0/32 câu đã trả lời đúng'), findsOneWidget);
  });
}
