# Components: GPLX prep app (Flutter)

## Sources and conventions

**Sources:**
- `tokens.json` (light) and `tokens.dark.json` (dark), which share the same 17 colour roles.
- `gen_dart.py`, which generates `app/lib/design/tokens.g.dart` from them.
- The widgets themselves live in `app/lib/design/widgets.dart`.
- The gallery is the `/design` route (`app/lib/design/gallery_page.dart`).

**Why no measurements:** there are no screenshots of the original in `replica/screens/`. This is a system designed for the category (exam-prep quiz apps), not a copy of measured values. Only the patterns are shared with the original: question card, answer list, jump grid, pass/fail result. Nothing else is taken from it.

**Rules every widget follows:**
- Colours come only from `context.colors` (the `AppColors` ThemeExtension). A raw `Color(0x…)` outside `tokens.g.dart` is a bug.
- Text styles come from `AppType`, and spacing from `AppSpace`.
- Tap targets are at least 48×48 (`AppLayout.tapTargetMin`).
- Answer states never rely on colour alone. Each one has an icon and a `Semantics` label.
- Text scales to 200% (`MediaQuery.textScaler`) without clipping. Cards grow, they never fix their height.
- Icons are Material Symbols (Apache 2.0, bundled with Flutter). No icons, illustrations or sounds come from the original.
- The font is Be Vietnam Pro (SIL OFL), bundled under `assets/fonts/`. It is built for Vietnamese diacritics. Until the files are added, the theme falls back to Roboto or SF.
- All copy is written fresh, in Vietnamese.

---

```
AppButton
  variants  primary (accent), secondary (outline, border-input), ghost (text accent), danger
  sizes     md 48px (default, a full tap target), lg 56px (exam start, submit)
  states    default, pressed (overlay 12%), focus-visible (2px accent ring, 2px offset),
            disabled (38% opacity, no ripple), loading (spinner replaces icon, label kept)
  tokens    bg accent / text on-accent, radius md, type base w600, padding x16
  a11y      Semantics(button: true, enabled), loading announces "Đang xử lý"; label stays
            in the tree while loading, so screen readers do not lose it
  used on   S01 (Tiếp tục), S03 (Thi ngẫu nhiên), S04 (Nộp bài), S05 (Thi lại / Xem lại),
            S10 S15 (danger: Xoá)
```

```
MenuTile
  variants  default, with count badge (e.g. wrong-answers count)
  states    default, pressed, focus-visible, disabled (no class selected)
  tokens    bg bg on a surface page, border border, radius lg, icon accent 28px,
            label sm w600 text, badge pill danger/on-danger xs
  a11y      one Semantics node: "Câu sai, 12 câu"; whole tile is the button
  used on   S02 (2-column grid)
```

```
ClassCard / ClassChip
  variants  card (S01 grid: code xl + short description sm muted), chip (S02 app bar)
  states    unselected (border border), selected (border accent 2px, bg accent-soft,
            check icon), pressed, focus-visible
  tokens    radius lg (card) / pill (chip), code type xl w700
  a11y      radio group semantics: Semantics(inMutuallyExclusiveGroup, checked)
  used on   S01, S02, S15
```

```
ProgressRing / ProgressBar
  variants  ring 96px (home, % mastered) with center label, linear 6px (topic rows)
  states    0 (track only), partial, complete (success colour + check)
  tokens    track border, fill accent, complete success, label lg w700
  a11y      Semantics(value: "45%"), not announced as a live region
  used on   S02, S07
```

```
QuestionCard
  variants  text-only, text + image (image max 240px tall, fit contain, tap to zoom)
  states    default; critical (adds CriticalBadge in the header)
  tokens    header xs muted "Câu 12/25", text question style (18/26 w500),
            bg bg, radius lg, padding 16
  a11y      header + text read as one heading-level node; image gets the
            question number as label ("Hình câu 12"), not a description we invent
  used on   S04, S06, S08
```

```
AnswerOption
  variants  exam (no reveal), study (reveal on tap), review (always revealed)
  states    idle         bg bg, border border, number bubble surface
            selected     bg accent-soft, border accent 2px, bubble accent / on-accent
            correct      bg success-soft, border success 2px, check_circle icon success
            wrong        bg danger-soft, border danger 2px, cancel icon danger
            missed       (correct answer the user did not pick) border success 2px dashed-look,
                         check icon success, bg bg
            disabled     after reveal in study/review, not tappable, keeps its colour state
            focus-visible 2px accent ring
  tokens    radius md, min height 56, padding 12/16, number bubble 28px circle,
            text base, gap 12
  a11y      Semantics(button, selected, label "Đáp án 2: …, đúng"/"…, sai");
            state words always in the label, never colour-only
  used on   S04, S06, S08
```

```
CriticalBadge
  variants  one
  states    -
  tokens    bg warning-soft, text warning, xs w600, radius pill, icon priority_high 14px
  copy      "Điểm liệt"
  a11y      read as part of the question header: "Câu điểm liệt"
  used on   S04, S06, S08, S09
```

```
QuestionGrid (jump palette)
  variants  exam (answered / unanswered), review and study (correct / wrong)
  cell      44px square, radius sm, label sm w600
  states    unanswered (border border, text muted), answered (bg accent-soft, text accent),
            correct (bg success-soft, text success), wrong (bg danger-soft, text danger),
            current (border accent 2px), critical (small warning dot top-right)
  layout    Wrap, 5 to 8 per row depending on width, in a bottom sheet on S04
  a11y      each cell "Câu 7, đã trả lời" / "Câu 7, sai, điểm liệt"; current marked selected
  used on   S04, S06, S08
```

```
CountdownTimer
  variants  app-bar pill
  states    normal (text text, bg surface), warning (< 60 s: text warning, bg warning-soft,
            no blinking), expired (00:00, triggers auto-submit)
  tokens    type base w700 tabular figures, radius pill, icon timer 18px
  behaviour reads deadline_at; ticks every second; no animation that moves the layout
  a11y      label "Còn 12 phút 30 giây"; announces once at 5 min and once at 1 min
            (SemanticsService.announce), not every second
  used on   S04
```

```
ResultBanner
  variants  pass (success / on-success, icon verified), fail-score (danger / on-danger,
            icon cancel), fail-critical (danger / on-danger, icon priority_high,
            plus line "Sai câu điểm liệt số 34")
  content   score display "23/25", verdict lg, detail sm, time used xs
  tokens    radius lg, padding 24, display type for the score
  a11y      live region on first show: "Đạt, 23 trên 25 câu"
  used on   S05
```

```
ExplanationPanel
  variants  study (shown after answering), review (collapsed, tap to expand)
  states    collapsed, expanded
  tokens    bg surface, border-left 4px accent, radius md, title sm w600, body base
  a11y      ExpansionTile semantics (expanded/collapsed)
  used on   S06, S08
```

```
BookmarkToggle
  variants  icon button in the question header
  states    off (bookmark_border, text-muted), on (bookmark, accent), pressed, focus-visible
  a11y      toggle semantics "Lưu câu hỏi" with checked state; SnackBar "Đã lưu" / "Đã bỏ lưu"
  used on   S04 (exam: allowed), S06, S08
```

```
EmptyState
  variants  wrong-list empty, saved empty, no exams yet, no search results
  content   Material icon 48px muted, title lg, body sm muted, optional AppButton
  copy      "Chưa có câu sai nào", "Làm một đề thi thử để bắt đầu."; written fresh
  used on   S03, S10, S11, search
```

```
ConfirmDialog
  variants  exit exam, submit with unanswered (shows count), reset progress (danger)
  tokens    Material AlertDialog themed: radius lg, title lg, body base muted
  behaviour destructive action on the right, labelled with the verb ("Nộp bài", "Xoá"),
            never "OK"; back button = cancel
  used on   S04, S10, S15
```

```
ListRow
  variants  topic row (title + count + ProgressBar), settings row (icon + title + trailing),
            article row (title + chevron)
  states    default, pressed, focus-visible, disabled
  tokens    min height 56, padding 16, divider border
  used on   S03, S07, S13, S14, S15
```

```
SignTile
  variants  grid tile (image 64px + code xs muted + name sm)
  states    default, pressed
  note      sign images are redrawn from the QCVN 41 specification as our own SVGs
  used on   S12
```

App bar, bottom sheet, snackbar and the switch use themed Material widgets. The theme is set once in `app_theme.dart`, so these have no specs of their own.

Removed from the recon list: **Ad slot**. The app is free, with no ads.
