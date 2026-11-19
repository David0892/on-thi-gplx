# Test plan: GPLX prep app (Flutter)

- **Build:** first run on `91c9e76`; all cases re-run green on `3ccd5d0`.
- **Date:** 2026-11-19.
- **Environment:** local; seed content (32 sample questions); `user.db` as in-memory SQLite (or a temp file for restart cases).

## How the tests run

This is a Flutter app, so the skill's Playwright setup does not apply. The equivalent is end-to-end **widget tests** in `app/test/e2e/`:
- They drive the real app: router, every screen and the SQLite repositories.
- They find widgets by visible text and semantics labels, not by widget types.
- They fail on any `FlutterError`, which covers layout overflow and exceptions; this is the Flutter equivalent of "fail on console errors".
- They run Flutter's accessibility guidelines (tap target size, labelled tap targets, text contrast) on each main screen, in place of axe.

Run them with:

```bash
cd app && flutter test test/e2e
```

**Auto** column: `e2e` means a widget test drives the UI; `unit` means a repository or domain test; `manual` means a person or the simulator.

**Edge cases from the skill's checklist that do not apply:**
- second user's data: one user per device, no accounts;
- expired session: no sessions;
- slow network: the app makes no network calls;
- card declined: the app is free.

**Edge cases that do apply:**
- accents (all content is Vietnamese);
- long content at 200% text scale and 320px width;
- double tap on submit;
- back button mid-exam;
- kill or restart mid-exam;
- offline (the app is offline by design);
- keyboard only and screen reader labels.

| case | flow | type | steps | expected | auto | result |
| --- | --- | --- | --- | --- | --- | --- |
| F01-H1 | pick a class | happy | fresh install, open the app, tap A1, tap "Ôn thi hạng A1" | home shows Hạng A1 | e2e | pass |
| F01-E1 | | edge: nothing picked | fresh install | continue button disabled, "Chọn một hạng để tiếp tục" | e2e | pass |
| F01-E2 | | edge: restart after picking | pick A1, restart app | lands on home, not onboarding | e2e | pass |
| F01-E3 | | edge: change class later | home → chip → B → confirm | home shows Hạng B; A1 progress untouched | e2e | pass (after BUG-009 fix) |
| F02-H1 | mock exam, pass | happy | home → Thi thử ngay → answer all 25 correctly → Nộp bài → confirm | result "Đạt", 25/25 | e2e | pass |
| F02-E1 | | edge: submit with blanks | start, submit at once | dialog says 25 unanswered; result "Chưa đạt", 0/25, 25 blank | e2e | pass |
| F02-E2 | | edge: critical wrong, rest right | answer everything right except the critical question | "Chưa đạt", "Sai câu điểm liệt", 24/25 | e2e | pass |
| F02-E3 | | edge: double tap on "Nộp" | tap Nộp twice quickly, confirm | one dialog, one result, history has 1 entry | e2e | pass |
| F02-E4 | | edge: back button mid-exam | start, system back | confirm exit dialog; "Thoát" → exam list, attempt abandoned | e2e | pass |
| F02-E5 | | edge: app killed mid-exam | start, answer Q1, restart app | home banner "làm dở (1/25)"; "Làm tiếp" shows the answer selected | e2e | pass |
| F02-E6 | | edge: reopened after deadline | start, restart after the deadline has passed | result opens straight away, "Hết giờ", status timed out | e2e | pass |
| F02-E7 | | edge: resume returns to the last question | start, go to Q5, restart, Làm tiếp | exam opens at Q5 | e2e | fail → BUG-001, fixed |
| F02-E8 | | edge: 320px wide, text 200% | exam screen at 320×640, textScaler 2.0 | no overflow, every option reachable | e2e | fail → BUG-002…008, fixed |
| F02-N1 | | negative: class larger than the bank | pick D, Thi thử ngay | "Chưa đủ câu hỏi" dialog, nothing written | e2e | pass |
| F02-N2 | | negative: unknown attempt id | open /exams/run/999 | error view, no crash | e2e | not run |
| F03-H1 | review a failed exam | happy | fail an exam → Xem lại câu sai | only wrong questions, correct answer marked, explanation open | e2e | pass |
| F03-E1 | | edge: perfect exam | pass 25/25 | no "Xem lại câu sai" button; wrong filter shows the empty state | e2e | pass |
| F04-H1 | study a topic | happy | home → Ôn theo chủ đề → topic 1 → wrong answer | answer revealed, "Giải thích" visible, question added to the wrong list | e2e | pass (after BUG-009 fix) |
| F04-E1 | | edge: resume topic | answer, go to Q3, leave, reopen the topic | opens at Q3 | e2e | pass |
| F04-E2 | | edge: last question | jump to the last question → Hoàn thành | summary dialog with counts | e2e | pass |
| F05-H1 | drill critical questions | happy | home → Câu điểm liệt | only critical questions (3 in the sample), with the "Điểm liệt" badge | e2e | pass |
| F06-H1 | clear my mistakes | happy | answer wrong → Câu sai → answer right → reopen | the question is gone from the list | e2e | pass |
| F06-E1 | | edge: empty | fresh install → Câu sai | empty state with "Thi thử ngay" | e2e | pass |
| F06-E2 | | edge: clear the list | wrong answers → Câu sai → delete → confirm | empty state; progress counts kept | e2e | pass |
| F07-H1 | look up a sign | happy | home → Biển báo | stub "Sắp có" (S12 not built) | e2e | pass |
| S15-H1 | reset progress | happy | answer some → settings → Xoá tiến độ → confirm | home shows 0% and 0 wrong | e2e | pass |
| A11Y-1 | all main screens | a11y | onboarding, home, exam, result, study | tap targets ≥ 48, tap targets labelled, text contrast AA | e2e | pass (light mode) |
| KB-1 | keyboard only | a11y | Tab/Enter through onboarding → home → exam | every control reachable and visibly focused | manual | not run |
| SR-1 | screen reader | a11y | VoiceOver on the exam screen | question, options with their state, and the timer are read | manual | not run |
| DEV-1 | real device | manual | iOS simulator: kill mid-exam and resume | as F02-E5 | manual | pass (earlier build); v1→v2 migration pass on device |

## Results

- **Automated:** 26 e2e and accessibility cases plus 41 unit, contract and migration tests, 67 in all. All pass on `3ccd5d0`.
- **Before the fixes:** 2 cases failed and found 9 bugs, all S3/S4; see [bugs.md](bugs.md).
- **Not run:**
  - F02-N2 (unknown attempt id). The error view exists, but no test opens a bad URL.
  - KB-1 and SR-1, which need a person or a device.

## Simulator check (iPhone 17, build `3ccd5d0`)

**Passed:**
- Installed the new build over the old one, which had a v1 `user.db`. The app opened with the class, history, progress and wrong list intact.
- Afterwards `PRAGMA user_version` is 2 and `exam_attempts.current_position` exists, so the migration ran on a real device.

**Not finished:**
- The on-device check of BUG-001 (resume at the last question) was stopped. During the run the database showed exams started and the class changed from screens the test was not on, so someone else was using the simulator at the same time.
- BUG-001 is covered by `F02-E7` and the repository contract test, both green.
- Repeat the device check when nobody else is using the simulator.
