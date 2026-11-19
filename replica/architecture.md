# Architecture: your GPLX theory-prep app (a rebuild of Ôn Thi GPLX 600 Câu's core features)

Decisions confirmed by the user on 2026-11-19: **Flutter**, **completely free** (no ads, no purchases), **no accounts**, and everything stored on the device.

The result is an offline-only app with no backend. Most of the "server" parts of a normal clone plan don't apply. The work moves into a **content pipeline** that runs on your machine at build time.

## Stack

| layer | choice | why |
| --- | --- | --- |
| app | Flutter (stable), Dart 3, Android + iOS | one codebase for both stores; the original is Android-only, so iOS is free reach |
| state | Riverpod (`flutter_riverpod` + codegen) | testable providers for the exam timer and repositories, no `BuildContext` plumbing |
| navigation | `go_router` | declarative routes map 1:1 to the S-IDs below; deep links come free |
| database | SQLite via `drift` + `sqlite3_flutter_libs` | typed queries, migrations, FTS5 for search, works fully offline |
| content | prebuilt read-only `content.db` in `assets/` + question images as WebP | ships in the binary; nothing to download, so it works on first launch with no network |
| styling | Material 3 `ThemeData` from replica-design tokens | light + dark from one token set |
| crash reporting | Sentry Flutter (free tier), off-device stack traces only, no PII | you need to know when the exam screen crashes; skippable if you want zero third parties |
| analytics | none | free app, no accounts. Keeps the Play "Data safety" form at "no data collected" (apart from crash logs) |
| auth / payments / email / jobs | none | no accounts, no money, no server |
| content pipeline | Dart CLI in `tool/` (`dart run tool/build_content.dart`) | same language as the app; reads reviewed JSON/CSV, validates, writes `content.db` |
| hosting | GitHub Pages | only for the privacy policy and support page the stores require |
| CI / release | GitHub Actions: `flutter analyze`, `flutter test`, content validation; Fastlane or manual store upload | content mistakes are the main risk, so validation runs on every commit |

One app, two SQLite files, no services.

## Schema

18 tables plus one FTS5 index, in [schema.sql](schema.sql), split across two files:

- **`content.db`** (12 tables, read-only, shipped): `content_meta`, `license_classes`, `topics`, `questions`, `question_options`, `class_questions`, `class_topic_quota`, `exam_sets`, `exam_set_questions`, `sign_groups`, `signs`, `articles`, plus `questions_fts`.
- **`user.db`** (6 tables, created on the device): `settings`, `question_progress`, `bookmarks`, `topic_cursor`, `exam_attempts`, `attempt_answers`.

**Access rules:** one user per install, so no RLS and no owner columns. The one rule is that `content.db` is opened read-only (`OpenMode.readOnly`), so a bug can't corrupt the question bank.

**Why two files:** when the official set or the rules change, you ship a new `content.db` in an app update and the learner's progress in `user.db` stays. User rows point at content by stable text keys (`question_key = '2025-123'`, `class_code = 'A1'`), never by rowids.

**Hard constraints in the database, not the UI:**

| constraint | enforced by |
| --- | --- |
| exactly one correct option per question | partial unique index `one_correct_option` |
| pass mark within question count | `CHECK` on `license_classes` |
| only one exam running at a time | partial unique index `one_running_exam` |
| a question appears once per exam | `UNIQUE (attempt_id, question_key)` |
| old results stay right after a rules change | `pass_mark`, `question_count`, `is_critical` copied into the attempt |
| a finished exam has a finish time | `CHECK` on `exam_attempts` |

Checks the pipeline enforces on top of those:

- quotas per class add up to `exam_question_count`;
- every class pool has at least `critical_per_exam` critical questions;
- every question has 2–4 options, an explanation and an image file if it references one;
- 600 questions and 60 critical, matching the official counts.

The schema loads cleanly in SQLite (checked).

## API

There is no HTTP API. The equivalent is the **repository layer** in `lib/data/`: Dart classes that are the only code allowed to touch the databases. Screens go through Riverpod providers that call these.

### Routes (go_router)

| path | screen | notes |
| --- | --- | --- |
| `/onboarding` | S01 class picker | redirect here while `settings.class_code` is empty |
| `/` | S02 home | |
| `/exams` | S03 exam list | |
| `/exams/run/:attemptId` | S04 exam in progress | no back gesture; exit asks to confirm |
| `/exams/result/:attemptId` | S05 result | |
| `/exams/review/:attemptId?filter=wrong` | S06 review | |
| `/topics` | S07 topic list | |
| `/study/:source/:id?` | S08 study mode | `source` is `topic`, `critical`, `wrong`, `saved` or `search`; covers S09–S11 |
| `/signs`, `/signs/:code` | S12 sign library | |
| `/tips`, `/tips/:id` | S13 tips | |
| `/faq` | S14 FAQ | |
| `/settings` | S15 settings | |

### Repository calls, by flow

**F01 Pick a class**

| call | does | input | output |
| --- | --- | --- | --- |
| `ClassRepo.all()` | list classes with rules | — | `List<LicenseClass>` |
| `SettingsRepo.setClass(code)` | store the selected class | `code` | — |
| `SettingsRepo.watchClass()` | stream the current class for every screen | — | `Stream<String?>` |

**F02 Take a mock exam**

| call | does | input | output |
| --- | --- | --- | --- |
| `ExamRepo.listSets(class)` | numbered sets with best score and pass badge | `class` | `List<ExamSetSummary>` |
| `ExamRepo.start(class, {setId})` | build the question list (fixed set or random generator), insert the attempt and its answer rows in one transaction | class, optional set | `attemptId` |
| `ExamRepo.running()` | find an `in_progress` attempt on launch, to offer resume | — | `Attempt?` |
| `ExamRepo.answer(attemptId, pos, choice)` | write the choice immediately | ids, `1..4` | — |
| `ExamRepo.submit(attemptId, {timedOut})` | grade, set score, `passed`, `failed_on_critical`, update `question_progress`, add wrong ones to the wrong list (one transaction) | id | `ExamResult` |
| `ExamRepo.abandon(attemptId)` | user exits without submitting | id | — |

**F03 Review an exam**

| call | does | input | output |
| --- | --- | --- | --- |
| `ExamRepo.review(attemptId, {onlyWrong})` | questions with chosen and correct answers and explanation | id | `List<ReviewItem>` |
| `ExamRepo.history(class)` | past attempts | class | `List<AttemptSummary>` |

**F04 Study a topic**

| call | does | input | output |
| --- | --- | --- | --- |
| `TopicRepo.list(class)` | topics with count and percent answered correctly | class | `List<TopicProgress>` |
| `StudyRepo.questions(source, class, id)` | the question list for any study source | source, class, id | `List<Question>` |
| `StudyRepo.record(class, key, correct)` | update `question_progress`; a wrong answer goes on the wrong list | | — |
| `StudyRepo.saveCursor(class, topic, pos)` | resume point | | — |

**F05 Critical questions**

| call | does | input | output |
| --- | --- | --- | --- |
| `StudyRepo.questions('critical', class)` | the critical questions in this class's pool | class | list |

**F06 Wrong answers**

| call | does | input | output |
| --- | --- | --- | --- |
| `StudyRepo.questions('wrong', class)` | the wrong list | class | list |
| `StudyRepo.record(...)` | answering correctly clears `in_wrong_list` | | |
| `ProgressRepo.clearWrong(class)` | confirm, then clear the wrong list | class | — |

**F07 Signs**

| call | does | input | output |
| --- | --- | --- | --- |
| `SignRepo.groups()`, `SignRepo.byGroup(id)`, `SignRepo.get(code)` | the sign library | | |

**Other**

| call | does | input | output |
| --- | --- | --- | --- |
| `BookmarkRepo.toggle(key)` / `watch(key)` | save a question | key | `Stream<bool>` |
| `ArticleRepo.list(kind)` / `get(id)` | tips and FAQ | | |
| `SearchRepo.questions(q, class)` | FTS5 search that ignores diacritics | text | list |
| `ProgressRepo.reset(class?)` | confirm, then wipe progress for one class or all | | — |
| `ProgressRepo.home(class)` | home stats: percent answered correctly, exams passed, wrong count, readiness | class | `HomeStats` |

### The exam generator

`ExamGenerator.generate(class, rng)` is a pure function with unit tests:

1. Pick `critical_per_exam` critical questions from the class pool.
2. For each topic in `class_topic_quota`, draw `count` non-critical questions from the class pool in that topic. If the critical question's topic has a quota, take one fewer from that topic.
3. Order the questions by official number, as the real exam does. Check this against the real software, and if it is shuffled there, shuffle here too.

The same function builds the fixed `exam_sets` in the pipeline with a fixed seed, so random exams and numbered sets follow identical rules.

**Webhooks in / out:** none.

**Jobs:** none on a server.

**Content pipeline** (`tool/build_content.dart`, run by hand and in CI): reviewed source files → validate → `assets/db/content.db` and `assets/img/`.

## The parts that bite

- **Answer-key accuracy (the biggest risk).** One wrong answer key teaches a learner to fail a real exam.
  - Transcribe from the official Công văn 2262 appendix, not from any app.
  - Enter the data twice independently (or have it checked by a second person) and let the pipeline diff the two.
  - Add a "Báo lỗi câu hỏi" button that opens an email or form, so users can report mistakes.
- **Rules drift.** A draft amendment to Thông tư 12/2025 is already in progress. Rules live in `license_classes` and `class_topic_quota`, never in Dart constants. `rules_verified = 0` shows a small "đang cập nhật" note for classes whose numbers come from secondary sources (D1 to DE).
- **Topic quotas are unknown.** The official per-class draw (how many questions per chapter) isn't in the public sources found so far. Until it is, use quotas proportional to the class pool and label them as an approximation. Find the official table before launch.
- **Timer and process death.** The timer counts down to `deadline_at`, read from the database, rather than an in-memory countdown. If the app is killed mid-exam, `ExamRepo.running()` offers to resume on next launch. If the deadline has passed by then, it auto-submits as `timed_out`. Answers are written on each tap.
  - Backgrounding keeps the clock running, like a real exam. Say so on the start screen.
- **Time zones.** Not an issue: everything is stored as UTC millis and only displayed in local time. There is no scheduling.
- **Races.** Only one: a double-tap on submit. Guard it with the `in_progress → submitted` status change inside the transaction, and with `one_running_exam`.
- **Idempotency.** `submit` is a no-op if the attempt is already finished.
- **Content updates.** On launch, if `content_meta.content_version` is newer than `settings.last_content_version`:
  - keep progress for question keys that still exist;
  - drop keys that don't, with a one-line notice ("Bộ đề đã cập nhật");
  - leave old attempts readable, since their copied fields keep them valid.
  - A new official set (a new `bank_code`) means new keys, so progress starts over. Tell the user.
- **App size.** About 200 question images plus about 300 sign images. WebP or SVG keeps this to a few MB. Check the APK stays well under 50 MB.
- **Search.** FTS5 with `remove_diacritics 2`, so "bien bao cam" finds "biển báo cấm".
- **Offline.** Fully offline by design. The only network calls are Sentry (optional) and the report-a-mistake link.
- **Accessibility.**
  - Answer states can't rely on colour alone: use ✓/✗ icons as well.
  - Text must scale up to 200% without the question card overflowing.
- **Privacy and store policy.**
  - The app collects nothing.
  - Publish a privacy policy anyway; the original's developer site has none.
  - Include the "not an official government product" disclaimer in the app and the listing (Play's policy on government impersonation).
- **Data deletion.** "Xoá tiến độ" in settings, or uninstall. There is no server copy.

## Build order

**1. Vertical slice: one class, one exam, end to end, ugly**
- Screens: S01 (A1 only), S04, S05.
- Data: `content.db` with A1 rules, the topics, and **25 real questions hand-entered** (including at least one critical); `user.db` with `settings`, `exam_attempts`, `attempt_answers`.
- Code: `ExamGenerator`, `ExamRepo.start/answer/submit/running`, and the deadline timer.
- Done when: start an A1 exam, answer, kill the app, reopen, resume, submit, and see pass, fail-by-score and fail-by-critical correctly. This proves drift, the asset database, the timer and grading.

**2. Must-haves**
- *Content:* the pipeline in `tool/`, all 600 questions with the A1/A pool mapping, critical flags, images and validation in CI. This runs in parallel with the app work and is the longest track.
- *Exam:* S02 home, S03 (random exam only), S06 review with the wrong filter, and the question jump grid.
- *Study:* S07 and S08 with instant feedback and explanations, S09 critical, S10 wrong answers with the empty state, S11 saved with the empty state; `question_progress`, `bookmarks`, `StudyRepo`.
- *All classes:* fill `license_classes` for all 15 classes with their pools, and switch class in S15.

**3. Should-haves**
- Numbered exam sets with best score, the progress ring and topic bars, `topic_cursor` resume, and exam history.
- S13 tips and S14 FAQ (your own writing), reset progress, and the disclaimer and privacy screen.

**4. Could-haves**
- S12 sign library, search, dark mode.
- Readiness score: the share of your last 5 exams passed, with critical failures counted heavily.
- Text-to-speech for questions (`flutter_tts`).

**5. Fixes from `/replica-entrepreneur`**, once it has read the original's reviews.
