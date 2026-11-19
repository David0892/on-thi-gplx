// Drives the real app (router, screens, SQLite repos) in widget tests.
// Selectors are visible text and semantics labels, like a user would see.
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gplx_prep/data/articles.dart';
import 'package:gplx_prep/data/db/user_db.dart';
import 'package:gplx_prep/data/memory_repositories.dart';
import 'package:gplx_prep/data/sql_repositories.dart';
import 'package:gplx_prep/design/widgets.dart';
import 'package:gplx_prep/domain/models.dart' show Question;
import 'package:gplx_prep/main.dart';
import 'package:gplx_prep/providers.dart';

import '../repo_contract.dart' show loadSeed;

final SeedContentRepo content = loadSeed();

/// The official bank, as shipped (for screens that need real questions).
final SeedContentRepo bank = SeedContentRepo.fromJson(
  jsonDecode(File('assets/content/content.json').readAsStringSync())
      as Map<String, dynamic>,
);

/// The real tips and FAQ, as shipped.
final Articles articles = Articles.fromJson(
  jsonDecode(File('assets/content/articles.json').readAsStringSync())
      as Map<String, dynamic>,
);

UserDb memoryDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return UserDb(NativeDatabase.memory());
}

/// Starts (or "restarts") the app on [db]. A new key makes it a fresh process
/// as far as the widget tree and providers are concerned; the database stays.
Future<void> launchApp(
  WidgetTester tester,
  UserDb db, {
  Size size = const Size(390, 844),
  double textScale = 1,
  SeedContentRepo? contentRepo,
}) async {
  WidgetController.hitTestWarningShouldBeFatal =
      true; // a missed tap fails the test
  tester.view.physicalSize = size * tester.view.devicePixelRatio;
  addTearDown(tester.view.resetPhysicalSize);
  final initialClass = await tester.runAsync(
    () => SqlSettingsRepo(db).selectedClass(),
  );
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(textScale),
      ),
      child: ProviderScope(
        key: UniqueKey(),
        overrides: [
          contentRepoProvider.overrideWithValue(contentRepo ?? content),
          userDbProvider.overrideWithValue(db),
          initialClassProvider.overrideWithValue(initialClass),
          articlesProvider.overrideWithValue(articles),
        ],
        child: const App(),
      ),
    ),
  );
  await settle(tester);
}

/// pumpAndSettle that also lets real async work (SQLite) finish.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 5)),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
  }
}

Future<void> tapText(WidgetTester tester, String text) async {
  // Lazy lists only build what is near the viewport: scroll the page until it exists.
  if (find.text(text).evaluate().isEmpty &&
      find.byType(Scrollable).evaluate().isNotEmpty) {
    await tester.scrollUntilVisible(
      find.text(text),
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }
  final f = find.text(text).last;
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  // Tap near the top-left: at 200% text a tall option can be partly under the bottom bar.
  final box = tester.getRect(f);
  await tester.tapAt(
    box.topLeft + Offset(8, box.height < 32 ? box.height / 2 : 12),
  );
  await settle(tester);
}

Future<void> scrollToTop(WidgetTester tester) async {
  await tester.fling(
    find.byType(Scrollable).first,
    const Offset(0, 3000),
    5000,
  );
  await settle(tester);
}

Future<void> tapLabel(WidgetTester tester, Pattern label) async {
  // Icon buttons expose their name as a tooltip, everything else as a label.
  final byLabel = find.bySemanticsLabel(label);
  final f =
      (byLabel.evaluate().isNotEmpty ? byLabel : find.byTooltip(label)).first;
  await tester.ensureVisible(f);
  await tester.tap(f);
  await settle(tester);
}

Future<void> pickClass(WidgetTester tester, String code) async {
  // The class grid is a lazy list: scroll until the card is built, then tap it.
  final card = find.byWidgetPredicate((w) => w is ClassCard && w.code == code);
  await tester.scrollUntilVisible(
    card,
    150,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(card.first);
  await tester.pumpAndSettle();
  await tester.tap(card.first);
  await settle(tester);
  await tapText(tester, 'Ôn thi hạng $code');
}

/// The question currently on screen, looked up in the content by its text.
Question currentQuestion(WidgetTester tester) {
  final card = tester.widget<QuestionCard>(find.byType(QuestionCard).first);
  return content.pool('A1').firstWhere((q) => q.text == card.text);
}

Future<void> answerCurrent(
  WidgetTester tester, {
  required bool correctly,
}) async {
  final q = currentQuestion(tester);
  final pos = correctly ? q.correctPosition : (q.correctPosition == 1 ? 2 : 1);
  await tapText(tester, q.options[pos - 1]);
}

Future<void> nextQuestion(WidgetTester tester) =>
    tapLabel(tester, 'Câu tiếp theo');

/// From home, start a random exam and answer all of it.
Future<void> takeExam(
  WidgetTester tester, {
  bool criticalWrong = false,
  bool allWrong = false,
}) async {
  await tapText(tester, 'Thi thử ngay');
  for (var i = 0; i < 25; i++) {
    final q = currentQuestion(tester);
    await answerCurrent(
      tester,
      correctly: !allWrong && !(criticalWrong && q.isCritical),
    );
    if (i < 24) await nextQuestion(tester);
  }
  await tapText(tester, 'Nộp bài'); // bottom bar on the last question
  await tapText(tester, 'Nộp bài'); // confirm dialog
}

Future<void> checkA11y(WidgetTester tester) async {
  final handle = tester.ensureSemantics();
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  handle.dispose();
}

Future<void> runningToPast(UserDb db) => db.customStatement(
  "UPDATE exam_attempts SET started_at = started_at - 3600000, deadline_at = started_at - 1 "
  "WHERE status = 'in_progress'",
);

/// Raw rows, so tests can check what was written without the UI.
Future<List<({String status, int? score})>> attempts(UserDb db) async => [
  for (final r in await db.select(db.examAttempts).get())
    (status: r.status, score: r.score),
];
