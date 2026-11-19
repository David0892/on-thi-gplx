# Bugs

**Build:** `91c9e76`, tested on 2026-11-19.

**Where the tests ran:** Flutter widget tests (headless), on a 390×844 screen and on a 320×640 screen at 200% text.

**What is listed:** only bugs reproduced by a failing test. Every one has a regression test that now passes.

**Summary:**

| severity | found | fixed |
| --- | --- | --- |
| S1 | 0 | — |
| S2 | 0 | — |
| S3 | 6 | 6 |
| S4 | 3 | 3 |

All fixes are in `3ccd5d0`.

---

### BUG-001: a resumed exam reopens at question 1, not where the learner was

- **Severity:** S3
- **Flow / case:** F02 / F02-E7
- **Screen:** S04
- **Device:** widget test 390×844; first seen on the iOS simulator

**Steps:**
1. Start an exam.
2. Go to question 5.
3. Kill the app and reopen it.
4. Tap "Làm tiếp".

**Expected:** the exam opens at "Câu 5/25".
**Actual:** it opens at "Câu 1/25".
**Evidence:** the `F02-E7` test failed: `Found 0 widgets with text "Câu 5/25"`.
**Cause:** the screen position lived only in widget state.
**Fix:**
- Added `exam_attempts.current_position` in user.db **schema v2**, written on every question change.
- Added a migration from v1. `migration_test.dart` opens a real v1 file and checks that the running exam survives the upgrade.

**Status:** fixed in `3ccd5d0`.

### BUG-002: the next question opens scrolled down, with its question text hidden

- **Severity:** S3
- **Flow / case:** F02, F04 / F02-E8
- **Screens:** S04, S08
- **Device:** widget test 320×640 and 390×844, text 200%

**Steps:**
1. Use large text, or a question with long answers.
2. Scroll down to tap an answer.
3. Tap "next".

**Expected:** the next question opens at the top, with the question text visible.
**Actual:** the list keeps the previous scroll offset, so the new question's text is above the screen. The learner reads the answers before the question.
**Evidence:** `F02-E8` failed: `QuestionCard` was not found after "Câu tiếp theo", because it had been scrolled out of the lazy list.
**Fix:** each question's page is keyed by question, so its scroll position starts fresh.

**Status:** fixed in `3ccd5d0`.

### BUG-003: the QuestionCard header overflows at large text, pushing the bookmark button off the card

- **Severity:** S3
- **Flow / case:** F02, F04 / F02-E8
- **Screens:** S04, S06, S08
- **Device:** 320×640, text 200%

**Steps:** at 200% text, open a critical question.

**Expected:** "Câu 1/25", the "Điểm liệt" badge and the bookmark button all fit on the card.
**Actual:** the header row overflowed by 12px, and the bookmark button was clipped.
**Evidence:** a `RenderFlex overflowed by 12 pixels` error from the `Row ← QuestionCard` header.
**Fix:** the number and the badge are in a `Wrap` inside an `Expanded`.

**Status:** fixed in `3ccd5d0`.

### BUG-004: the exam bottom bar overflows on narrow screens, and while submitting

- **Severity:** S3
- **Flow / case:** F02 / F02-E8
- **Screens:** S04, S08
- **Device:** 320×640, text 200%

**Steps:**
1. At 200% text on a 320px screen, go to the last question.
2. Tap "Nộp bài".

**Expected:** the controls fit.
**Actual:**
- the bar overflowed by 23px;
- while submitting, the loading spinner squeezed the "Câu 25/25" button down to 3.7px wide.

**Evidence:** `RenderFlex overflowed by 23/24 pixels` errors on the bottom bar `Row`.
**Fix:**
- The bottom bars cap text scaling at 1.3× (`MediaQuery.withClampedTextScaling`), the usual treatment for fixed toolbars.
- The submit button is `Flexible`.

**Status:** fixed in `3ccd5d0`.

### BUG-005: the "bài thi đang làm dở" banner overflows on narrow screens at large text

- **Severity:** S3
- **Flow / case:** F02 / F02-E5, F02-E8
- **Screen:** S02
- **Device:** 320×640, text 200%

**Steps:** at 200% text, start an exam, then return to home.

**Expected:** the banner text and the "Làm tiếp" button both show.
**Actual:** the row overflowed by 44px, and the text column was squeezed to a 1200px-tall sliver.
**Evidence:** `RenderFlex overflowed by 44 pixels`, with a `Size(262, 1200)` flex inside the banner.
**Fix:** the text and the button are stacked in a column.

**Status:** fixed in `3ccd5d0`.

### BUG-006: class codes overflow their cards at large text

- **Severity:** S3
- **Flow / case:** F01 / F02-E8
- **Screen:** S01
- **Device:** 320×640, text 200%

**Steps:** at 200% text, open the class picker.

**Expected:** every card shows its code.
**Actual:** the header row of cards like "D1E" and "C1E" overflowed by 6.5px.
**Evidence:** `RenderFlex overflowed by 6.5 pixels`, from the `Row ← Column ← Padding ← InkWell` inside `ClassCard`.
**Fix:** the code text scales down (`FittedBox`) instead of overflowing.

**Status:** fixed in `3ccd5d0`.

### BUG-007: the ProgressRing label overflows the ring at large text

- **Severity:** S4
- **Screen:** S02
- **Device:** 390×844, text 200%

**Steps:** at 200% text, open home.

**Expected:** "0%" and "đã thuộc" fit inside the ring.
**Actual:** the label overflowed the 96px ring by 56px.
**Evidence:** `RenderFlex overflowed by 56 pixels on the bottom`, from `Column ← Center ← Stack ← SizedBox ← Semantics` in `ProgressRing`.
**Fix:** the label sits in a padded `FittedBox` that scales it down.

**Status:** fixed in `3ccd5d0`.

### BUG-008: the "Điểm liệt" badge overflows when space is tight

- **Severity:** S4
- **Screens:** S04, S06, S08
- **Device:** 320×640, text 200%

**Expected:** the badge fits.
**Actual:** the badge row overflowed by 42px.
**Evidence:** `RenderFlex overflowed by 42 pixels`, from `Row ← CriticalBadge`.
**Fix:** the badge text is `Flexible`, so it can wrap.

**Status:** fixed in `3ccd5d0`.

### BUG-009: the ExplanationPanel's tap ripple is hidden behind its background

- **Severity:** S4
- **Screens:** S06, S08
- **Device:** any

**Steps:** in debug mode, open a question's explanation.

**Expected:** no framework warnings, and a visible ripple when tapping "Giải thích".
**Actual:** Flutter asserted "ListTile background color or ink splashes may be invisible", because the panel was a coloured `Container` around an `ExpansionTile`.
**Evidence:** the assertion text in `F01-E3` and `F04-H1`.
**Fix:** the panel background is now a `Material`.

**Status:** fixed in `3ccd5d0`.

---

## To check (not reproduced, or not covered by automation)

- **KB-1, keyboard only:** not run. Flutter widget tests can send key events, but no keyboard traversal test was written. Check by hand on iPad with a keyboard, or on desktop.
- **SR-1, VoiceOver:** not run. The semantics labels are asserted indirectly: the tests find buttons by label, and `labeledTapTargetGuideline` passes. No real screen reader was used.
- **Android device:** never run on Android; only on the iOS simulator.
- **Dark mode contrast:** the accessibility tests ran in light mode only. Dark tokens passed `contrast.py`, but not the in-app `textContrastGuideline`.
- **Simulator, class changed to B and exams started unexpectedly:** not a bug. The database timestamps show the simulator was being used by someone else at the same time as the test. No code path changes the class except the class picker's confirm button.
- **F02-N2:** opening `/exams/run/<unknown id>` should show the error view; no test covers this yet.
