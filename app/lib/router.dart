// One route per screen in replica/recon.md (S01–S15) plus the /design gallery.
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'design/gallery_page.dart';
import 'domain/models.dart';
import 'features/browse/question_page.dart';
import 'features/browse/search_page.dart';
import 'features/browse/signs_page.dart';
import 'features/exam/exam_list_page.dart';
import 'features/exam/exam_result_page.dart';
import 'features/exam/exam_review_page.dart';
import 'features/exam/exam_run_page.dart';
import 'features/guide/faq_page.dart';
import 'features/guide/tips_page.dart';
import 'features/home/home_page.dart';
import 'features/onboarding/class_picker_page.dart';
import 'features/settings/settings_page.dart';
import 'features/study/study_page.dart';
import 'features/shell/app_shell.dart';
import 'features/study/learn_page.dart';
import 'providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(selectedClassProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    refreshListenable: refresh,
    redirect: (context, state) {
      final hasClass = ref.read(selectedClassProvider) != null;
      final atOnboarding = state.matchedLocation == '/onboarding';
      if (!hasClass && !atOnboarding && state.matchedLocation != '/design') {
        return '/onboarding';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding', // S01
        builder: (_, s) =>
            ClassPickerPage(changing: s.uri.queryParameters['change'] == '1'),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/', builder: (_, _) => const HomePage()), // S02
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/learn',
                builder: (_, _) => const LearnPage(),
              ), // S07
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/exams',
                builder: (_, _) => const ExamListPage(),
              ), // S03
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (_, _) => const SettingsPage(),
              ), // S15
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/exams/run/:id', // S04
        builder: (_, s) =>
            ExamRunPage(attemptId: int.parse(s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/exams/result/:id', // S05
        builder: (_, s) =>
            ExamResultPage(attemptId: int.parse(s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/exams/review/:id', // S06
        builder: (_, s) => ExamReviewPage(
          attemptId: int.parse(s.pathParameters['id']!),
          onlyWrong: s.uri.queryParameters['filter'] == 'wrong',
        ),
      ),
      GoRoute(path: '/topics', redirect: (_, _) => '/learn'),
      GoRoute(
        path: '/study/:source', // S08, and S09 critical / S10 wrong / S11 saved
        builder: (_, s) => StudyPage(
          source: StudySource.values.byName(s.pathParameters['source']!),
          topicId: int.tryParse(s.uri.queryParameters['topic'] ?? ''),
        ),
      ),
      GoRoute(path: '/signs', builder: (_, _) => const SignsPage()), // S12
      GoRoute(
        path: '/signs/:id',
        builder: (_, s) => SignGroupPage(groupId: s.pathParameters['id']!),
      ),
      GoRoute(path: '/search', builder: (_, _) => const SearchPage()), // S16
      GoRoute(
        path: '/question/:n',
        builder: (_, s) =>
            QuestionPage(number: int.tryParse(s.pathParameters['n']!) ?? 0),
      ),
      GoRoute(path: '/tips', builder: (_, _) => const TipsPage()), // S13
      GoRoute(
        path: '/tips/:id',
        builder: (_, s) => TipDetailPage(tipId: s.pathParameters['id']!),
      ),
      GoRoute(path: '/faq', builder: (_, _) => const FaqPage()), // S14
      GoRoute(path: '/design', builder: (_, _) => const GalleryPage()),
    ],
  );
});
