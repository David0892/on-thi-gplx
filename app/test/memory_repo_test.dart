import 'package:gplx_prep/data/memory_repositories.dart';

import 'repo_contract.dart';

void main() {
  runRepoContract('memory repos', (content) async {
    final bookmarks = MemoryBookmarkRepo();
    final study = MemoryStudyRepo(content, bookmarks);
    return (
      settings: MemorySettingsRepo(),
      bookmarks: bookmarks,
      study: study,
      exams: MemoryExamRepo(content, study),
    );
  });
}
