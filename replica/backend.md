# Backend

The app is completely free, offline-only, with no accounts (decided 2026-11-19). The "backend" is the on-device SQLite database. Most of the standard backend checklist does not apply, and each section below says so explicitly instead of leaving it blank.

## Database (done)

| item | state |
| --- | --- |
| engine | SQLite via drift 2.35, through `package:sqlite3` v3 (native library bundled by build hooks; the obsolete `sqlite3_flutter_libs` was removed) |
| schema | [user_db.drift](../app/lib/data/db/user_db.drift) holds the user.db half of [schema.sql](schema.sql): 6 tables, the `one_running_exam` partial unique index, CHECK constraints, and `PRAGMA foreign_keys = ON` |
| migrations | `schemaVersion = 1` in [user_db.dart](../app/lib/data/db/user_db.dart). Every schema change bumps it and adds a step to `MigrationStrategy`. Regenerate with `dart run build_runner build` |
| location | `getApplicationSupportDirectory()/user.db`. Not user-visible; removed on uninstall |
| repositories | [sql_repositories.dart](../app/lib/data/sql_repositories.dart), the same interfaces as the memory repos. Screens did not change |
| web | no SQLite file on web, so the dev preview still uses the memory repos (`open_db_stub.dart`) and nothing persists there |
| content | still `assets/seed/content.json` (32 sample questions). `content.db` and the build pipeline come with the official bank |

**Deviation from schema.sql:** `exam_attempts.exam_set_number` replaces `exam_set_id`. Numbered sets are generated from a fixed seed until `content.db` ships an `exam_sets` table. When it does, migrate in schema version 2.

**Integrity is enforced by the database itself, not only by Dart code:**
- one running exam at a time, via a unique index (tested);
- answers cannot change after submit: the update is guarded by a subquery on `status` (tested);
- `start()` writes the attempt and all of its answer rows in one transaction, and generates the exam *before* the transaction starts, so a class without enough questions writes nothing (tested);
- `submit()` grades the attempt, writes the answers, updates the attempt and records progress in one transaction. A second submit is a no-op (tested).

**Crash and kill recovery:**
- every tap writes the answer immediately;
- after a restart, home shows "Bạn có bài thi đang làm dở" with a "Làm tiếp" button;
- if the deadline passed while the app was dead, reopening the exam grades it straight away as `timed_out`.

**Checked on the iOS simulator (iPhone 17, debug build):**
- **What I did:** picked A1, started an exam, answered question 1, then killed the app with `simctl terminate` and relaunched it.
- **What happened after relaunch:**
  - the app went straight to home, so the class was remembered;
  - the "làm dở (1/25 câu)" banner appeared;
  - "Làm tiếp" reopened the exam with the answer still selected;
  - the timer had kept counting while the app was dead (18:59 → 18:42).
- **Gap found:** a resumed exam reopens at question 1, not at the last question viewed.
- **Not checked:** Android has not been run yet.

### Tests

There are 34 in total, all passing.

| suite | tests | what it covers |
| --- | --- | --- |
| [repo_contract.dart](../app/test/repo_contract.dart) | 12 | the shared repository contract, run against both implementations ([memory_repo_test.dart](../app/test/memory_repo_test.dart) and [sql_repo_test.dart](../app/test/sql_repo_test.dart)), so 24 runs |
| persistence | 1 | writes to a real file, closes the database, reopens it, and checks the running exam, its answers and deadline, the class, bookmarks and the wrong list |
| index | 1 | the database itself rejects a second running exam |
| exam rules | 8 | the exam generator and grading |

## Auth: not applicable

The app has no accounts, by decision. That means:
- there is no sign-up, so Apple's account-deletion rule does not apply;
- data deletion is "Xoá tiến độ" in settings, or uninstalling the app.

## Payments: not applicable

The app is completely free. There is no Stripe and no in-app purchase.

## Email and jobs: not applicable

There is no email and no server. The exam timer is the only time-based behaviour, and it runs on the device from `deadline_at` (UTC milliseconds).

## Integrations: none

There are no third-party APIs. Sentry crash reporting is planned as optional in architecture.md and **not added**. If it is added, it needs a DSN in env, and the privacy text and Play Data safety form must list it.

## `.env.example`

Not written, because the app has no secrets and no environment variables.

## Security checklist

- [x] secrets only in env vars: there are no secrets
- [x] input validated: the database CHECK constraints cover the `chosen_position` range, the status enum and 0/1 flags; the repository API takes typed values only
- [x] authorisation on every read and write: not applicable (one user per device, no network)
- [x] rate limits: not applicable (no auth, no email, no SMS)
- [x] webhooks verify signatures: not applicable (none)
- [x] uploads: not applicable (none)
- [x] no user data in URLs or logs: routes carry only an attempt id or topic id; nothing is logged
- [ ] dependencies audited: no `npm audit` equivalent has been run yet. Review `flutter pub outdated` before release
- [x] privacy policy lists every processor: no processors today, and the in-app text says so. A hosted page is still needed for the stores
- [ ] **Android Auto Backup:** by default Android backs up `user.db` to the user's own Google account. That is acceptable (it is their data), but either say so in the privacy text or set `android:allowBackup="false"`. **Decide before release.**
