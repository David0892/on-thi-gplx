# Build log

## 2026-11-19: shell, vertical slice and must-have screens

**Applies to every screen below:**
- **Data:** the data layer is **in-memory** (`lib/data/memory_repositories.dart`). It uses the same repository interfaces as the planned drift layer, so swapping it changes no screen code. Progress, history and bookmarks are lost when the app restarts.
- **Content:** **32 hand-written sample questions** in `app/assets/seed/content.json`, flagged `is_sample`. The app shows a "bản thử nghiệm" notice on home. They are not from the official set and not from the original app.
- **Checks:** `flutter analyze` is clean and 15 unit tests pass (exam generator, grading, repository flow). Every screen was clicked through in Flutter web at 390×844 with no console errors.
- **Screenshots:** in `replica/clone-screens/`. They were taken in dark mode because the browser followed the system theme.
- **Not checked for any screen yet:** keyboard-only navigation, 200% text scale, and the 1440px layout (content is capped at 600px and centred by design).

| ID | status | missing | harder than expected |
| --- | --- | --- | --- |
| S01 class picker | done | — | — |
| S02 home | done | no "resume running exam" banner, because nothing survives a restart yet | — |
| S03 exam list | done | — | — |
| S04 exam run | partial | exam not persisted, so it is lost if the app is killed; resume needs drift | — |
| S05 result | done | — | — |
| S06 review | done | — | — |
| S07 topic list | done | — | — |
| S08 study | done | — | — |
| S09 critical | done (via S08) | — | — |
| S10 wrong answers | done (via S08) | — | — |
| S11 saved | done (via S08) | — | — |
| S12 signs | stub | the whole screen and the sign images (could-have) | — |
| S13 tips | stub | the whole screen and original tip articles | — |
| S14 FAQ | stub | the whole screen and original FAQ text | — |
| S15 settings | done | hosted privacy policy page | — |

**Notes on individual screens:**
- **S01:** all 15 classes, grouped by vehicle type.
- **S02:** progress ring and stats; the "Thi thử ngay" button reaches S04 in 1 tap.
- **S03:**
  - The rules card for the class, a random exam, 5 numbered sets with best score, and history.
  - Classes whose rules are unverified show a warning line.
- **S04:**
  - The timer counts down to `deadlineAt` and auto-submits at zero.
  - Also built: the question grid sheet, a confirm before submitting with the unanswered count, and a confirm before exiting (which abandons the exam).
  - Critical questions are not marked during the exam, as in the real test.
- **S05:** shows pass, fail by score or fail by critical, names the critical question that was missed, and the right/wrong/blank counts.
- **S06:** all/wrong filter, revealed answer states, explanations, and an empty state for a perfect exam.
- **S07:** progress per topic.
- **S08:**
  - Instant feedback with an explanation after each answer.
  - The topic resume point is kept; the grid shows right and wrong.
  - An end-of-list summary, and empty states for the wrong-answers and saved lists.
- **S15:** change class, reset progress with a confirm, about and disclaimer, privacy text, and a link to the design gallery.

**Bug found while clicking through, and fixed:**
- **What:** a cold-start deep link (e.g. `/#/study/topic`) skipped the class picker, because the router redirect ran while the class was still loading.
- **Fix:** the selected class is now read before the first frame.

**Deviation from architecture.md:**
- The plan was for the vertical slice to use 25 real questions entered by hand.
- I wrote sample questions instead. Transcribing official questions from memory risks a wrong answer key, and the official appendix (Công văn 2262) has not been obtained yet.

**Bigger than it looked:**
- The **content work**, not the screens. The official 600 questions, the class pools, the 60 critical flags, about 200 images and 600 original explanations are still entirely ahead.

## 2026-11-19: persistence (replica-backend)

- **What changed:**
  - `user.db` is now SQLite through drift on Android and iOS; the memory repos remain only for the web preview.
  - Screens did not change, apart from two additions:
    - home now has a "Bạn có bài thi đang làm dở" banner with a "Làm tiếp" button;
    - S04 grades an exam immediately if it is reopened after its deadline.
- **Checks:** 34 tests pass, including the shared repository contract against both implementations and a real-file test that closes and reopens the database. I also killed and relaunched the app on the iOS simulator; details are in backend.md.
- **S04** goes from partial to done. Remaining gap: a resumed exam opens at question 1 instead of the last question viewed (small; store the current position in `exam_attempts`).
