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

## 2026-11-19: official 600-question bank

**Sources:**
- *600 câu hỏi* (Cục CSGT, 2025)
- Công văn 2262/CSGT-P5, with Phụ lục 1–3
- Thông tư 12/2025 (pass marks)

Details are in [content/README.md](../content/README.md).

**Pipeline:** `tool/content/build_content.py` parses the PDF:
- the answer key comes from the underlines;
- 318 images are cropped (about 7.4 MB as WebP);
- the build refuses to write unless every check passes (600 questions, one underlined answer each, appendix counts).

**What changed in the app:**
- `assets/content/` replaces the sample seed;
- the 32-question sample now lives on as a test fixture;
- chapter quotas are groups (motorbike classes draw "kỹ thuật **or** cấu tạo");
- pools and critical questions are per class (A1/A: 250 questions, 20 critical; B1: 300, 30; others: 600, 60);
- images in the question card, with tap to zoom;
- explanations are optional;
- user data recorded against the old sample bank is removed on first launch with the new bank.

**Corrections found on the way:**
- **Pass marks:** A and B1 pass at **23/25**, not 21 (Thông tư 12/2025 Phụ lục II, III).
- **Topic quotas:** these were "unknown" before; they are now exact from CV 2262.
- **Chapter IV:** "Cấu tạo và sửa chữa" was missing from the sample topics.

**Checks:**
- 73 tests pass, including new real-content tests: chapter ranges, pools, critical counts, 30 generated exams per class, every image file present, pass marks;
- `flutter analyze` is clean;
- the web build showed an official sign question with its image, with no console errors.

**Not done:** 600 original explanations, which the official set does not provide. The iOS simulator was not rerun, in case someone else is using it.

## 2026-11-19: explanations, batch 1 (60 critical questions)

- **What was written:** explanations for all 60 critical questions in `content/explanations.json`, in our own words. Each one checks against the underlined official answer and says why the tempting wrong options are wrong (e.g. Câu 19: "Cả hai ý trên" is wrong because bicycles may use quốc lộ).
- **Pipeline:** the build merges the explanations and fails if a key is not a real question, an explanation is empty, or a critical question has none.
- **Reproducibility:** the build was re-run in a fresh venv from `requirements.txt`. The output was byte-identical apart from the 60 explanation lines (all 318 images unchanged).
- **Checks:** 74 tests pass, including a new one that every critical question has an explanation. In the web build, A1's critical drill shows 20 questions, and answering one wrong shows the explanation.
- **Remaining:** 540 explanations, for the non-critical questions.

## 2026-11-19: explanations for all 600 questions

- **What was written:** 540 more explanations in our own words, in `content/explanations/` (one file per chapter range), for **600/600** in total.
  - Chapters I–IV: written from the question text and the official answer.
  - Chapters V–VI (signs and traffic scenarios): written after viewing every picture in 9-image contact sheets.
- **Mistakes caught by checking the pictures:**
  - Câu 227 is the "BRAKE (!)" icon, not a "P".
  - Câu 36 and 37 now describe the officer's arm signals.
  - Câu 493 and 487 were checked at full size before writing.
- **Checks:**
  - an automated cross-check that each explanation names the correct option (Biển N, Vạch N, Hướng N, numbers and units). It found 4 false positives, which were made explicit.
  - the build now has `--require-all`, and `content_test.dart` asserts all 600 have an explanation;
  - 75 tests pass;
  - the images are byte-identical across rebuilds.
- **For human review:** Câu 440, 493, 515, 523, 569 and 593 give a reason the picture does not make fully explicit. A driving instructor should look at them before release.
- **Parity:** 88.9, with 14/14 must-haves.
