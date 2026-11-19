import 'package:drift/drift.dart';

part 'user_db.g.dart';

@DriftDatabase(include: {'user_db.drift'})
class UserDb extends _$UserDb {
  UserDb(super.e);

  /// Bump on every schema change and add a step in [migration].
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(examAttempts, examAttempts.currentPosition);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
