import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/memory_repositories.dart';
import 'data/repositories.dart';
import 'domain/models.dart';

/// Overridden in main() once the seed is loaded.
final contentRepoProvider = Provider<ContentRepo>((ref) => throw UnimplementedError());

final settingsRepoProvider = Provider<SettingsRepo>((ref) => MemorySettingsRepo());
final bookmarkRepoProvider = Provider<BookmarkRepo>((ref) => MemoryBookmarkRepo());
final studyRepoProvider = Provider<StudyRepo>(
  (ref) => MemoryStudyRepo(ref.watch(contentRepoProvider), ref.watch(bookmarkRepoProvider)),
);
final examRepoProvider = Provider<ExamRepo>(
  (ref) => MemoryExamRepo(ref.watch(contentRepoProvider), ref.watch(studyRepoProvider)),
);

/// Bumped after every write, so read providers refetch. The drift version can
/// replace this with table watches.
class Revision extends Notifier<int> {
  @override
  int build() => 0;
  void bump() => state++;
}

final revisionProvider = NotifierProvider<Revision, int>(Revision.new);

/// Read from the settings repo in main() before the first frame, so the router
/// redirect never runs while the class is still loading (a cold-start deep
/// link must still land on onboarding).
final initialClassProvider = Provider<String?>((ref) => null);

class SelectedClass extends Notifier<String?> {
  @override
  String? build() => ref.read(initialClassProvider);

  Future<void> set(String code) async {
    await ref.read(settingsRepoProvider).setClass(code);
    state = code;
  }
}

final selectedClassProvider = NotifierProvider<SelectedClass, String?>(SelectedClass.new);

/// The selected class, for screens that only render after onboarding.
final currentClassProvider = Provider<LicenseClass>((ref) {
  final code = ref.watch(selectedClassProvider);
  final content = ref.watch(contentRepoProvider);
  return content.cls(code ?? 'A1');
});

final progressProvider = FutureProvider<Map<String, QuestionProgress>>((ref) {
  ref.watch(revisionProvider);
  return ref.read(studyRepoProvider).progress(ref.watch(currentClassProvider).code);
});

final bookmarksProvider = FutureProvider<Set<String>>((ref) {
  ref.watch(revisionProvider);
  return ref.read(bookmarkRepoProvider).all();
});

final examSetsProvider = FutureProvider<List<ExamSetSummary>>((ref) {
  ref.watch(revisionProvider);
  return ref.read(examRepoProvider).listSets(ref.watch(currentClassProvider).code);
});

final historyProvider = FutureProvider<List<ExamAttempt>>((ref) {
  ref.watch(revisionProvider);
  return ref.read(examRepoProvider).history(ref.watch(currentClassProvider).code);
});

final attemptProvider = FutureProvider.family<ExamAttempt, int>((ref, id) {
  ref.watch(revisionProvider);
  return ref.read(examRepoProvider).attempt(id);
});

typedef StudyKey = ({StudySource source, int? topicId});

/// The list is fixed when the session opens; it does not refetch on every
/// answer, otherwise answering a "wrong" question right would make it vanish
/// mid-session.
final studyQuestionsProvider = FutureProvider.autoDispose.family<List<Question>, StudyKey>((ref, key) {
  return ref.read(studyRepoProvider).questions(
        key.source,
        ref.read(currentClassProvider).code,
        topicId: key.topicId,
      );
});

class HomeStats {
  const HomeStats({required this.mastered, required this.total, required this.wrong, required this.saved,
      required this.examsPassed, required this.examsTaken});
  final int mastered;
  final int total;
  final int wrong;
  final int saved;
  final int examsPassed;
  final int examsTaken;
  double get masteredShare => total == 0 ? 0 : mastered / total;
}

final homeStatsProvider = FutureProvider<HomeStats>((ref) async {
  final cls = ref.watch(currentClassProvider);
  final pool = ref.watch(contentRepoProvider).pool(cls.code);
  final progress = await ref.watch(progressProvider.future);
  final saved = await ref.watch(bookmarksProvider.future);
  final history = await ref.watch(historyProvider.future);
  return HomeStats(
    mastered: pool.where((q) => progress[q.key]?.lastCorrect == true).length,
    total: pool.length,
    wrong: pool.where((q) => progress[q.key]?.inWrongList ?? false).length,
    saved: pool.where((q) => saved.contains(q.key)).length,
    examsPassed: history.where((a) => a.passed == true).length,
    examsTaken: history.length,
  );
});
