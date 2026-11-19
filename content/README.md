# Question bank sources

The app's questions, answers, images, class pools, critical questions and exam structure come **only** from the two official documents below. Nothing is taken from any other app.

| file | what it is | downloaded from | SHA-256 |
| --- | --- | --- | --- |
| `source/bo-600-cau-hoi-2025.pdf` | *600 câu hỏi dùng cho sát hạch lái xe cơ giới đường bộ*, Bộ Công an – Cục Cảnh sát giao thông, Hà Nội 2025 (186 pages; correct answers underlined) | LuatVietnam copy: `https://cms.luatvietnam.vn/uploaded/Others/2025/05/13/Bo_600_cau_hoi_danh_cho_sat_hach_lai_xe_co_gioi_duong_bo_-_LVN_1305094143.pdf` | `d473be679b53458a33acc52057f3a4fe532ea489e91d88fb86789073cd98a9c5` |
| `source/cong-van-2262-csgt-p5.pdf` | Công văn 2262/CSGT-P5, 07/05/2025: usage guide, exam structure per class, Phụ lục 1 (250 câu A1/A), 2 (300 câu B1), 3 (60 câu điểm liệt) | Thư viện Pháp luật copy: `https://cdn.thuvienphapluat.vn/phap-luat/2022-2/LVPD/nam-2025/cong-van-2262.pdf`; Phụ lục 1–3 also checked against `https://cdn.thuvienphapluat.vn/uploads/tintuc/2025/05/12/CV-2262-trang-2.pdf` (identical lists) | `dcb0b42473a23af3b006ed07cfd3a728254eb3d5263f6a26d0536c576d69e634` |

**About the copies:**
- Both are copies hosted by legal-document sites. Neither file carries the host's branding; the text is the government document only.
- Replace them with copies from csgt.vn or another official portal if one is found. The hashes above show whether the content changed.

**Pass marks and exam times:** these come from Thông tư 12/2025/TT-BCA, Phụ lục II–IV, as read on LuatVietnam:

| classes | pass mark |
| --- | --- |
| A1 | 21/25 |
| A, B1 | 23/25 |
| B | 27/30 |
| C1 | 32/35 |
| C | 36/40 |
| D1, D2, D | 41/45 |

The trailer classes BE, C1E, CE, D1E, D2E and DE have 45 questions according to CV 2262, but their time and pass mark were not found in the readable text. They are set equal to D and flagged `verified: false`, and the app shows "đang được đối chiếu" for them.

## Rebuild

```bash
python3 -m venv .venv && .venv/bin/pip install -r tool/content/requirements.txt
```

```bash
.venv/bin/python tool/content/build_content.py --check
```

```bash
.venv/bin/python tool/content/build_content.py
```

The build writes `app/assets/content/content.json` and `app/assets/content/img/qNNN.webp`. It writes nothing unless every check passes:
- questions numbered 1–600 with none missing;
- 2–4 options each, numbered 1..n;
- **exactly one underlined option** per question;
- no question label swallowed into another question;
- Phụ lục 3 has 60 critical questions, and Phụ lục 1/2 have 250/300 questions with 20/30 critical;
- each appendix group's count matches its own heading;
- per-class quotas add up to the exam size.

`app/test/content_test.dart` checks the shipped JSON again: chapter ranges, pools, critical counts, that every class can build exams, that every image file exists, and the pass marks.

## Things the parser handles explicitly

| question | layout | handling |
| --- | --- | --- |
| Câu 204 | underline is dark grey, not black | any fill darker than 0.35 counts as an underline |
| Câu 301–302 | options in two columns ("1. … 3. …" on one line) | split into options by number |
| Câu 352 | three options on one line | split into options by number |
| Câu 362 | two images with typed labels "1  2" under them | cropped as one picture |
| Câu 507 | printed as "Câu 507:" | colon accepted after the number |
| any | a word broken across lines ("đường b" / "ộ") | glued back together |

## Critical questions are per class

Every exam has exactly one critical question:
- **A1 and A** draw it from Phụ lục 1's group 6 (20 questions);
- **B1** draws it from Phụ lục 2's group 6 (30 questions);
- **every other class** draws it from the full 60 in Phụ lục 3.

A question on the 60-list that an appendix files under another group (for example Câu 32 in A1/A) is a normal question for that class.

## Legal note

The question bank and the công văn are administrative documents issued by Cục Cảnh sát giao thông. Under Article 15 of the Luật Sở hữu trí tuệ, legal and administrative documents are not protected by copyright. Have a lawyer confirm this before publishing, including for the images in the book.

**Explanations:** the app shows explanations only where we wrote them ourselves. The official set has none, so `explanation` is `null` for all 600 questions for now.
