// Repository contracts from replica/architecture.md. Screens only see these.
// Today: in-memory implementations (memory_repositories.dart) loaded from the
// seed JSON. Next: drift implementations over content.db / user.db with the
// same signatures, so no screen code changes.
import '../domain/models.dart';

abstract interface class ContentRepo {
  bool get isSample;
  int get contentVersion;
  List<LicenseClass> classes();
  LicenseClass cls(String code);
  List<Topic> topics();
  Topic topic(int id);
  List<Question> pool(String classCode);
  Question question(String key);
  Map<int, int> quota(String classCode);
  int examSetCount(String classCode);
}

abstract interface class SettingsRepo {
  Future<String?> selectedClass();
  Future<void> setClass(String code);
}

abstract interface class ExamRepo {
  Future<List<ExamSetSummary>> listSets(String classCode);

  /// Throws NotEnoughQuestions when the bank cannot satisfy the class rules.
  Future<int> start(String classCode, {int? setNumber});
  Future<ExamAttempt?> running();
  Future<ExamAttempt> attempt(int id);
  Future<void> answer(int attemptId, int position, int choice);

  /// Idempotent: submitting a finished attempt returns it unchanged.
  Future<ExamAttempt> submit(int attemptId, {bool timedOut = false});
  Future<void> abandon(int attemptId);
  Future<List<ExamAttempt>> history(String classCode);
}

abstract interface class StudyRepo {
  Future<List<Question>> questions(StudySource source, String classCode, {int? topicId});
  Future<void> record(String classCode, String questionKey, {required bool correct});
  Future<Map<String, QuestionProgress>> progress(String classCode);
  Future<int> cursor(String classCode, int topicId);
  Future<void> saveCursor(String classCode, int topicId, int position);
  Future<void> clearWrong(String classCode);
  Future<void> reset(String classCode);
}

abstract interface class BookmarkRepo {
  Future<Set<String>> all();
  Future<void> toggle(String questionKey);
}
