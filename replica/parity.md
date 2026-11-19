# Parity: GPLX prep app vs Ôn Thi GPLX 600 Câu Chuẩn 2026

> **Update 2026-11-19, after all 600 explanations:**
> - Feature score is **88.9 / 100**, with must-haves at **14 of 14**.
> - There are no open S1 or S2 bugs, so the app is **shippable** by the replica-diff rule.
> - Layout parity is still unmeasured, because there are no screenshots of the original.
> - Remaining should-haves: tips (S13), FAQ (S14), and a hosted privacy policy. Remaining could-haves: the sign library and search.
> - The sections below describe earlier runs and are kept for history.

**Build:** `1dfdf9c`. **Date:** 2026-11-19.

**Tools:** `parity.py` on [features.csv](features.csv). `imgdiff.py` was **not run**; see the layout section below.

## Verdict: **not shippable yet**

| check | result |
| --- | --- |
| must-haves done | **10 of 14**; all 4 missing are content, none is code |
| feature score | **77.0 / 100** |
| layout score | **not measured**: no screenshots of the original |
| open S1 / S2 bugs | **0 / 0** (9 S3/S4 found and fixed; see [bugs.md](bugs.md)) |

**What is done:** every must-have that is *code* works and is tested. That covers class choice, exams by the class rules, the critical-question rule, the timer and resume, review, study by topic, the wrong-answer and saved lists, and the critical-question drill.

**What blocks shipping:** the **question bank**. The app runs on 32 sample questions written for development; the original has the official 600. Until the real bank, pools, critical flags and explanations are in, a learner cannot prepare for a real exam with it.

## Feature parity: 77.0

26 features counted. Weights: must 3, should 2, could 1; `partial` counts as half.

| area | score | features |
| --- | --- | --- |
| content | **21.4** | 6 |
| study | 77.3 | 5 |
| settings | 85.7 | 4 |
| onboarding | 100 | 1 |
| exam | 100 | 7 |
| review | 100 | 3 |

### Missing, in build order

| priority | area | feature | state | note |
| --- | --- | --- | --- | --- |
| must | content | Full official 600-question bank bundled offline | no | 32 sample questions; needs the content pipeline |
| must | content | Critical questions flagged (60) | partial | 3 in the sample |
| must | content | Question pools per class (e.g. 250 for A1/A) | partial | all classes share the sample pool |
| must | study | Answer explanations | partial | written for the 32 sample questions only |
| should | content | FAQ on the exam procedure | no | needs original writing |
| should | content | Memorization tips per topic | no | needs original writing |
| should | settings | Not-official disclaimer + privacy policy | partial | in-app text done; a hosted page is needed for the stores |
| could | content | Traffic sign library by group | no | may not exist in the original |
| could | study | Search questions by text or number | no | FTS5 is ready in the schema |

### Left out on purpose (not scored)

- **Banner and interstitial ads:** the app is free, with no ads (decided 2026-11-19).
- **The original's explanations, tips, images, name and listing copy:** these belong to its developer.
- **The 120 simulation videos and the practical test:** outside this slice.

## Layout parity: not measured

`replica/screens/` is empty, so there is nothing to compare against:
- the Play listing did not render through a fetch during recon;
- the original's store screenshots are marketing frames, with captions and device bezels, which would not be a fair layout comparison anyway.

The clone's screens are ready in `replica/clone-screens/` (S01–S08, S11, S15, at 390×844).

**To measure it:**
1. Install the original on your own Android phone.
2. Take screenshots at the same states: class picker, home, exam on Q1, result, review, topic list, study with an answer revealed, settings.
3. Save them as `replica/screens/S01.png` …, then run:

```bash
python3 ~/.claude/skills/replica-diff/imgdiff.py replica/screens/S04.png replica/clone-screens/S04.jpg --out replica/diffs/S04.png --json > replica/diffs/S04.json
```

```bash
python3 ~/.claude/skills/replica-diff/parity.py replica/features.csv --visual replica/diffs/*.json --markdown > replica/parity.md
```

**Two caveats on the clone's screenshots:**
- They were taken in **dark mode**, which `imgdiff` handles because it compares edges, not colour.
- They show the sample content. Retake them once the real bank is in.

## Behaviour diff

The original was never used in this project. The "original does" column comes from its listing and from the recon map's inferred screens, marked *(inferred)*. Confirm it on your phone.

| flow | original does | clone does | fix or keep |
| --- | --- | --- | --- |
| F02 start a mock exam | home → mock exam list → pick or random → Q1 *(inferred)*: 2–3 taps | home → "Thi thử ngay" → Q1: **1 tap**; the list is still there for numbered sets | keep, it is faster |
| F02 result | interstitial ad before the result *(listing: 100% ad-funded)* | result straight away, no ads | keep, it is the positioning |
| F02 app killed mid-exam | unknown | resumes on the same question, with answers kept and the clock still running; after the deadline it auto-grades as "Hết giờ" | keep; check whether the original resumes |
| F02 critical questions during the exam | unknown | not marked during the exam (as in the real test), marked in review and study | keep; check the original |
| F02 submit with blanks | unknown | the dialog states how many are blank; blanks count as wrong | keep |
| F02 a class bigger than the bank | n/a (the original has the full bank) | a "Chưa đủ câu hỏi" dialog | goes away with the real bank |
| F04 study | instant feedback and explanation *(listing)* | the same, plus resume per topic and a summary at the end of a topic | keep |
| F06 wrong answers | review incorrectly answered questions *(listing)* | auto-collected; a question leaves the list once answered right; clearing asks to confirm | keep |
| F01 class | pick a class *(listing)* | 15 classes; progress kept per class; switch from the home chip | keep; for D1–DE, check the rules against the official text |
| large text (200%) | unknown | tested at 320px with no overflow; the toolbar text is capped at 1.3× | keep |
| data and account | no account; ads SDK *(listing)* | no account, no ads, no analytics, data on the device only | keep, a privacy advantage |

## Top five to build next

1. **Content pipeline plus the official 600 questions** (`tool/build_content.dart` → `content.db`). Transcribe from Công văn 2262/CSGT-P5, enter it twice, and diff the two entries in CI. This alone unblocks 2 must-haves.
2. **Class pools and the 60 critical flags** from the official appendix, plus the topic quota per class. Confirm the D1–DE rules and set `rules_verified`.
3. **600 original explanations.** This is the largest writing job; start with the 60 critical questions.
4. **Tips (S13) and FAQ (S14)**, written fresh.
5. **Hosted privacy policy and store disclaimer** (needed by `/replica-launch` anyway). Decide on Android `allowBackup` at the same time.

**Next step:** items 1–3 are content work, not app screens. After them, run `/replica-diff` again; must-haves should reach 14/14 and the score should rise above 90. If you want to sharpen the angle before the content work, run `/replica-entrepreneur` now; it reads the original's real reviews to find what to beat.
