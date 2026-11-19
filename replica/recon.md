# Recon map: Ôn Thi GPLX 600 Câu Chuẩn 2026 (Android)

Package: `com.vns.onthigplx`. Developer: MobiSoft Studio (Vietnam). Free, ads only, no in-app purchases.
About 539K installs (+51K/month), first released 2024-05-05, last updated 2026-11-14 (AppGoblin).

Scope: the theory-test prep loop. Pick a licence class, study the question bank by topic, take timed mock exams, and review mistakes and critical questions. The simulation test (mô phỏng 120 tình huống) and the practical test (sa hình) are out of this slice.
For: the user's own product, for Vietnamese learner drivers (confirmed 2026-11-19). Business model still open: free + ads, or freemium with a remove-ads purchase.
Date: 2026-11-19

> Evidence level: built from the public listing (via AppGoblin), the official exam rules, and how this app category works. No screenshots were captured, because the Play page would not render through a fetch. Screen rows marked **(inferred)** need checking against the real app. Install it on your own phone and fill `replica/screens/`.

## Sources

| # | source | URL | notes |
| --- | --- | --- | --- |
| 1 | Play Store listing | https://play.google.com/store/apps/details?id=com.vns.onthigplx | title only came through; body is JS-rendered |
| 2 | AppGoblin listing mirror | https://appgoblin.info/apps/com.vns.onthigplx | description, feature list, installs, ads/IAP, dates |
| 3 | Developer site | https://shinichikudodeveloper.github.io | portfolio of 4 other apps (news, music); no privacy policy |
| 4 | Official rules: Công văn 2262/CSGT-P5 (600-question set, in force 2025-06-01) | https://cdn.thuvienphapluat.vn/phap-luat/2022-2/LVPD/nam-2025/cong-van-2262.pdf | **the real source of the question bank**. Use this, not the app |
| 5 | Govt news: new 600-question set from 1/6 | https://hatinh.gov.vn/vi/bai-viet/tu-16-thi-sat-hach-ly-thuyet-lai-xe-se-dung-bo-de-600-cau-hoi-moi | effective date, 60 critical questions |
| 6 | Exam structure per class | https://quantrimang.com/cong-nghe/cau-truc-de-thi-bang-lai-xe-cac-loai-moi-nhat-209406 | questions / minutes / pass mark per class (secondary source) |
| 7 | A1 exam rules | https://luatvietnam.vn/giao-thong/thi-bang-lai-xe-a1-863-104039-article.html | A1/A: 25 questions, 21 to pass, 250-question pool |
| 8 | Notes on the new set | https://lsvn.vn/mot-so-noi-dung-can-luu-y-trong-bo-de-ly-thuyet-thi-sat-hach-gplx-moi-a158433 | content changes vs the old set |
| 9 | Category roundup (competitors) | https://fptshop.com.vn/tin-tuc/for-gamers/app-hoc-bang-lai-xe-may-205673 | what users expect from this category |
| 10 | Competitor listings (App Store) | https://apps.apple.com/app/id6740868842 , https://apps.apple.com/us/app/id6444957942 | same category; the second bundles the 120 simulation videos |

## Core loop

Choose your licence class → take a randomly generated, timed mock exam that follows the official rules → see pass/fail with the critical-question rule applied → review wrong answers with explanations → repeat until you pass consistently.

## Exam rules the clone must encode

Rules from sources 4–7. Classes marked ? are unconfirmed; check them against the official appendix before seeding.

| class | questions | minutes | pass mark | critical per exam | pool |
| --- | --- | --- | --- | --- | --- |
| A1, A, B1 | 25 | 19 | 21 | 1 | 250 (motorbike subset) |
| B | 30 | 20 | 27 | 1 | ? (300 cited) |
| C1 | 35 | 22 | 32 | 1 | ? |
| C | 40 | 24 | 36 | 1 | ? |
| D1, D2, D, BE, C1E, CE, D1E, D2E, DE | 45 ? | 26 ? | 41 ? | 1 | 600 |

Any wrong answer on a critical question (câu điểm liệt, 60 in the bank) fails the exam whatever the score. Topics named in the listing: rules (quy định chung & quy tắc), traffic culture (văn hoá giao thông), driving technique (kỹ thuật lái xe), signs (biển báo), situations (sa hình). The official set probably also has a vehicle mechanics chapter (cấu tạo & sửa chữa). Exact chapter ranges are **not yet verified**; take them from source 4.

## Screens

| ID | screen | route / how to reach | purpose | key components | states seen |
| --- | --- | --- | --- | --- | --- |
| S01 | Splash / first-run class picker | app launch | pick licence class once, stored | class card grid (A1…DE), short class description | first run, returning (skipped) |
| S02 | Home | tab 1 | hub: progress + entry points | class switcher chip, progress ring, menu tiles (Thi thử, Ôn theo chủ đề, Câu điểm liệt, Câu sai, Câu đã lưu, Biển báo, Mẹo, FAQ), banner ad | fresh (0%), in progress, ad loaded/failed |
| S03 | Mock exam list | Home → Thi thử | list of exam sets + "random exam" | exam row with best score / pass badge, "Đề ngẫu nhiên" button | none taken, some passed, some failed |
| S04 | Exam in progress | S03 → start | answer N questions against a timer | countdown timer, question number grid / pager, question text, optional image, 2–4 answer options, prev/next, submit | unanswered, answered, time almost up, time out (auto-submit), exit confirm (inferred) |
| S05 | Exam result | submit or time out | verdict | pass/fail banner, score x/N, critical-question failure reason, wrong count, time used, "Xem lại", "Thi lại", interstitial ad | pass, fail by score, fail by critical question |
| S06 | Exam review | S05 → Xem lại | walk the answered exam | per-question correct/incorrect colouring, user answer vs correct, explanation, filter (all / wrong) | all correct, has wrong |
| S07 | Topic list | Home → Ôn theo chủ đề | study by chapter | topic rows with count + progress bar | 0%, partial, complete |
| S08 | Study (practice) mode | S07 → topic, or S09/S10/S11 | answer one question at a time with instant feedback | question card, options, immediate right/wrong reveal, explanation, bookmark toggle, critical badge, question jump grid | unanswered, correct, wrong, last question |
| S09 | Critical questions list | Home → Câu điểm liệt | drill the 60 fail-on-sight questions | same as S08, filtered | — |
| S10 | Wrong answers | Home → Câu sai | re-drill everything ever answered wrong | S08 filtered, "clear" action | **empty** ("no wrong answers yet"), filled |
| S11 | Saved questions | Home → Câu đã lưu | bookmarks | S08 filtered | **empty**, filled |
| S12 | Traffic signs library | Home → Biển báo (inferred) | browse signs by group | tabs (cấm, nguy hiểm, hiệu lệnh, chỉ dẫn, phụ), sign tile, detail sheet | — |
| S13 | Tips (Mẹo) | Home → Mẹo | memorization tips per topic | article list → article | — |
| S14 | FAQ | Home → FAQ | exam procedure Q&A | accordion | — |
| S15 | Settings | Home → gear (inferred) | class, reset progress, rate app, privacy policy, disclaimer | list rows, confirm dialog for reset | — |

## Flows

```
F01 First run: pick a class and land on home
    S01 -> S02
    happy path taps: 2
    edge: user changes class later (progress per class or shared?), offline first launch (bank must be bundled)

F02 Take a mock exam and pass   (core loop)
    S02 -> S03 -> S04 (answer 25..45) -> S05
    happy path taps: 3 + N answers + 1 submit (+ confirm)  -> A1: ~30 taps
    edge: timer runs out (auto-submit), app backgrounded mid-exam (pause or keep counting?),
          wrong critical question with otherwise passing score, unanswered questions at submit,
          interstitial ad shown before result

F03 Review a failed exam
    S05 -> S06 (filter wrong) -> bookmark from S06
    happy path taps: 2
    edge: exam contained images that fail to load (must be bundled)

F04 Study a topic
    S02 -> S07 -> S08 (answer, see explanation, next...)
    happy path taps: 2 + 2 per question
    edge: resume where you left off, finish topic, wrong answer gets added to S10

F05 Drill critical questions
    S02 -> S09 -> S08 mode
    happy path taps: 1 + 2 per question

F06 Clear my mistakes
    S02 -> S10 -> answer correctly -> (removed from list? inferred)
    edge: empty state, "reset" confirm

F07 Look up a sign
    S02 -> S12 -> group tab -> sign detail
    happy path taps: 3
```

Number to beat: **start a mock exam in 2 taps from home** (F02 to the first question).

## Components

| component | variants | states | used on |
| --- | --- | --- | --- |
| Menu tile | icon + label + count badge | default, pressed | S02 |
| Class card / chip | grid card, compact chip | selected, unselected | S01, S02, S15 |
| Progress ring / bar | ring, linear | 0, partial, 100 | S02, S07 |
| Question card | text-only, text + image | — | S04, S06, S08 |
| Answer option | — | idle, selected, correct, wrong, correct-not-chosen, disabled | S04, S06, S08 |
| Critical badge | — | — | S04, S06, S08, S09 |
| Question grid (jump palette) | exam, study | unanswered, answered, correct, wrong, current | S04, S06, S08 |
| Countdown timer | — | normal, warning (<1 min), expired | S04 |
| Result banner | pass, fail-score, fail-critical | — | S05 |
| Explanation panel | — | collapsed, expanded | S06, S08 |
| Bookmark toggle | — | on, off | S06, S08 |
| Empty state | — | — | S10, S11, S03 |
| Confirm dialog | exit exam, submit with unanswered, reset progress | — | S04, S10, S15 |
| Ad slot | banner, interstitial | loading, loaded, failed (collapse) | S02, S05, others |
| Top app bar | back, title, action | — | all |

## Inferred data model

```
LicenseClass   code (A1|A|B1|B|C1|C|D1|D2|D|BE|C1E|CE|D1E|D2E|DE), name, description,
               exam_question_count, exam_minutes, pass_mark, critical_per_exam
               evidence: listing (classes covered), sources 6–7 (rules)
               confidence: high for A1/A/B1/B/C1/C, guess for the rest

Topic          id, name, order
               evidence: listing topic names
               confidence: medium (exact chapters unverified)

Question       id (1..600, official number), topic_id, text, image (nullable),
               options [2..4], correct_index, is_critical, explanation (own writing),
               tip (own writing, nullable)
               evidence: listing ("detailed explanations", "failing questions"), official set
               confidence: high

QuestionClass  question_id, class_code   (which pool a question belongs to: 250 for motorbike, etc.)
               evidence: source 7 (A1/A pool = 250 of 600)
               confidence: high that pools exist, mapping from official appendix

ExamSet        id, class_code, question_ids[] (fixed numbered sets, e.g. "Đề 1..N") or generated
               evidence: listing ("random question selection"); fixed sets are a category norm
               confidence: medium

ExamAttempt    id, class_code, exam_set_id (nullable for random), started_at, finished_at,
               answers {question_id: chosen_index|null}, score, passed, failed_on_critical
               evidence: listing ("automatic timer and scoring, pass/fail")
               confidence: high

QuestionProgress  question_id, class_code?, last_answer_correct, times_wrong, bookmarked, seen_at
               evidence: listing ("save questions", "review incorrect")
               confidence: high (whether it is per class is a guess)

Sign           id, code (e.g. P.102), group, name, meaning, image
               evidence: category norm; listing mentions road signs as a topic
               confidence: guess (a separate library may not exist in this app)

Article        id, kind (tip|faq), topic_id?, title, body
               evidence: listing ("FAQ section and study tips")
               confidence: high
```

Relationships: LicenseClass n-n Question (via QuestionClass); Topic 1-n Question; LicenseClass 1-n ExamSet; ExamSet 1-n ExamAttempt; Question 1-1 QuestionProgress (per device user). All local: no account, no server, apart from ads.

## Feature matrix

See `features.csv`. Must: 14, should: 9, could: 5, skip: 6 (ads rows dropped: the app is free).

## Out of scope (cannot or should not be cloned)

- **The app's own explanations, tips, FAQ text and images.** These are its copy. Write your own explanations. Take question text and sign images from the official government publication (source 4), never from the app's bundle.
- **The question bank itself.** It is state-issued material, but check its reuse status. Vietnamese IP law excludes legal and administrative documents from copyright, and the set was issued by công văn. Confirm this before shipping, and attribute the source.
- **Branding:** the "Ôn Thi GPLX 600 Câu Chuẩn" name and listing copy. The term "ôn thi GPLX" is generic, but the exact title and look belong to the developer. See /replica-brand.
- **Its install base, ratings and ad network revenue.**
- **Officialness.** The original states that it is not a government product. The clone must say the same.
- 120-situation simulation videos (mô phỏng) and the sa hình practical test are separate products, outside this slice. Competitors bundle them (source 10).

## Size

Screens 15, flows 7, entities 9. Hard parts:

1. **Content, not code.** Turning the official 600 questions into clean data (text, options, answer, critical flag, class pools, topic, ~200 images) and writing 600 original explanations. This is most of the work and needs care, since a wrong answer key costs users their exam.
2. **Exam generator that matches the real rules.** Per-class counts and timers, exactly one critical question per exam, topic distribution like the real test, and keeping up when the rules change (draft amendments to Thông tư 12/2025 are already in progress).
3. **Offline-first local state.** Exam timer survives backgrounding and process death, progress per class, and ads that never block the exam.

No realtime, no payments, no sync, no accounts. Size: **M**. About a week of app code, plus two to three weeks for the content pipeline and explanations.
