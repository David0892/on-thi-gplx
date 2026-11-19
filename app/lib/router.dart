// One route per screen in replica/recon.md (S01–S15) plus the /design gallery.
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'design/gallery_page.dart';
import 'domain/models.dart';
import 'features/exam/exam_list_page.dart';
import 'features/exam/exam_result_page.dart';
import 'features/exam/exam_review_page.dart';
import 'features/exam/exam_run_page.dart';
import 'features/home/home_page.dart';
import 'features/onboarding/class_picker_page.dart';
import 'features/settings/settings_page.dart';
import 'features/stub_page.dart';
import 'features/study/study_page.dart';
import 'features/study/topic_list_page.dart';
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
      if (!hasClass && !atOnboarding && state.matchedLocation != '/design') return '/onboarding';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding', // S01
        builder: (_, s) => ClassPickerPage(changing: s.uri.queryParameters['change'] == '1'),
      ),
      GoRoute(path: '/', builder: (_, _) => const HomePage()), // S02
      GoRoute(path: '/exams', builder: (_, _) => const ExamListPage()), // S03
      GoRoute(
        path: '/exams/run/:id', // S04
        builder: (_, s) => ExamRunPage(attemptId: int.parse(s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/exams/result/:id', // S05
        builder: (_, s) => ExamResultPage(attemptId: int.parse(s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/exams/review/:id', // S06
        builder: (_, s) => ExamReviewPage(
          attemptId: int.parse(s.pathParameters['id']!),
          onlyWrong: s.uri.queryParameters['filter'] == 'wrong',
        ),
      ),
      GoRoute(path: '/topics', builder: (_, _) => const TopicListPage()), // S07
      GoRoute(
        path: '/study/:source', // S08, and S09 critical / S10 wrong / S11 saved
        builder: (_, s) => StudyPage(
          source: StudySource.values.byName(s.pathParameters['source']!),
          topicId: int.tryParse(s.uri.queryParameters['topic'] ?? ''),
        ),
      ),
      GoRoute(path: '/signs', builder: (_, _) => const StubPage(title: 'Biển báo', screenId: 'S12')),
      GoRoute(path: '/tips', builder: (_, _) => const StubPage(title: 'Mẹo ghi nhớ', screenId: 'S13')),
      GoRoute(path: '/faq', builder: (_, _) => const StubPage(title: 'Hỏi đáp về kỳ thi', screenId: 'S14')),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()), // S15
      GoRoute(path: '/design', builder: (_, _) => const GalleryPage()),
    ],
  );
});
