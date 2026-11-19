// Design-system primitives. Specs: replica/design/components.md.
// Colours only from context.colors, text only from AppType, spacing only from AppSpace.
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'app_theme.dart';
import 'tokens.g.dart';

// ---------------------------------------------------------------- AppButton

enum AppButtonVariant { primary, secondary, ghost, danger }

enum AppButtonSize { md, lg }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final height = size == AppButtonSize.lg ? 56.0 : 48.0;
    // Loading keeps the enabled colours (spinner stays visible); taps are blocked below.
    final onPress = loading && onPressed != null ? () {} : onPressed;
    final fg = switch (variant) {
      AppButtonVariant.primary => c.onAccent,
      AppButtonVariant.danger => c.onDanger,
      AppButtonVariant.secondary => c.text,
      AppButtonVariant.ghost => c.accent,
    };
    final leading = loading
        ? SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : (icon != null ? Icon(icon, size: 20) : null);
    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[leading, const SizedBox(width: AppSpace.s8)],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );
    final min = Size(expand ? double.infinity : AppLayout.tapTargetMin, height);
    final Widget button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: onPress,
        style: FilledButton.styleFrom(minimumSize: min),
        child: child,
      ),
      AppButtonVariant.danger => FilledButton(
        onPressed: onPress,
        style: FilledButton.styleFrom(
          minimumSize: min,
          backgroundColor: c.danger,
          foregroundColor: c.onDanger,
        ),
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: onPress,
        style: OutlinedButton.styleFrom(minimumSize: min),
        child: child,
      ),
      AppButtonVariant.ghost => TextButton(
        onPressed: onPress,
        style: TextButton.styleFrom(minimumSize: min),
        child: child,
      ),
    };
    return Semantics(
      hint: loading ? 'Đang xử lý' : null,
      child: IgnorePointer(ignoring: loading, child: button),
    );
  }
}

// ---------------------------------------------------------------- MenuTile

class MenuTile extends StatelessWidget {
  const MenuTile({
    super.key,
    required this.icon,
    required this.label,
    this.count,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final int? count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final semantic = count == null ? label : '$label, $count câu';
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: semantic,
      excludeSemantics: true,
      child: Material(
        color: c.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: c.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 28, color: c.accent),
                    const Spacer(),
                    if (count != null && count! > 0) _CountBadge(count: count!),
                  ],
                ),
                const SizedBox(height: AppSpace.s12),
                Text(
                  label,
                  style: AppType.sm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: c.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s8, vertical: 2),
      decoration: BoxDecoration(
        color: c.danger,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text('$count', style: AppType.xs.copyWith(color: c.onDanger)),
    );
  }
}

// ---------------------------------------------------------------- ClassCard / ClassChip

class ClassCard extends StatelessWidget {
  const ClassCard({
    super.key,
    required this.code,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: 'Hạng $code, $description',
      excludeSemantics: true,
      child: Material(
        color: selected ? c.accentSoft : c.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: selected ? c.accent : c.border,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Scales down instead of overflowing at large text sizes ("D1E" at 200%).
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          code,
                          style: AppType.xl.copyWith(color: c.text),
                        ),
                      ),
                    ),
                    if (selected) Icon(Icons.check_circle, color: c.accent),
                  ],
                ),
                const SizedBox(height: AppSpace.s4),
                Text(
                  description,
                  style: AppType.sm.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ClassChip extends StatelessWidget {
  const ClassChip({super.key, required this.code, this.onTap});
  final String code;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: 'Đang ôn hạng $code, đổi hạng',
      excludeSemantics: true,
      child: Material(
        color: c.accentSoft,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppLayout.tapTargetMin,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.s16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hạng $code',
                    style: AppType.sm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: c.accent,
                    ),
                  ),
                  Icon(Icons.expand_more, size: 20, color: c.accent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Progress

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.caption = 'đã thuộc',
  });
  final double value; // 0..1
  final String caption;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final done = value >= 1;
    final pct = (value * 100).round();
    return Semantics(
      label: 'Tiến độ',
      value: '$pct%',
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: 96,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: value.clamp(0, 1),
              strokeWidth: 8,
              backgroundColor: c.border,
              color: done ? c.success : c.accent,
              strokeCap: StrokeCap.round,
            ),
            Padding(
              // Keep the label inside the ring; shrink it rather than overflow at large text sizes.
              padding: const EdgeInsets.all(AppSpace.s12),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (done)
                      Icon(Icons.check, color: c.success)
                    else
                      Text(
                        '$pct%',
                        style: AppType.lg.copyWith(
                          fontWeight: FontWeight.w700,
                          color: c.text,
                        ),
                      ),
                    Text(
                      caption,
                      style: AppType.xs.copyWith(color: c.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      value: '${(value * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: LinearProgressIndicator(
          value: value.clamp(0, 1),
          minHeight: 6,
          backgroundColor: c.border,
          color: value >= 1 ? c.success : c.accent,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Question

class CriticalBadge extends StatelessWidget {
  const CriticalBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s8, vertical: 2),
      decoration: BoxDecoration(
        color: c.warningSoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.priority_high, size: 14, color: c.warning),
          Flexible(
            child: Text(
              'Điểm liệt',
              style: AppType.xs.copyWith(
                fontWeight: FontWeight.w600,
                color: c.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.index,
    required this.total,
    required this.text,
    this.critical = false,
    this.image,
    this.trailing,
  });

  final int index;
  final int total;
  final String text;
  final bool critical;
  final Widget? image;
  final Widget? trailing; // e.g. BookmarkToggle

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpace.s16),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Number and badge wrap onto two lines at large text sizes instead of overflowing.
              Expanded(
                child: Wrap(
                  spacing: AppSpace.s8,
                  runSpacing: AppSpace.s4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Câu $index/$total',
                      style: AppType.xs.copyWith(color: c.textMuted),
                    ),
                    if (critical) const CriticalBadge(),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: AppSpace.s8),
          Semantics(
            header: true,
            label: critical
                ? 'Câu $index, câu điểm liệt. $text'
                : 'Câu $index. $text',
            excludeSemantics: true,
            child: Text(text, style: AppType.question.copyWith(color: c.text)),
          ),
          if (image != null) ...[
            const SizedBox(height: AppSpace.s12),
            Semantics(
              image: true,
              label: 'Hình câu $index',
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: Center(child: image),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum AnswerState { idle, selected, correct, wrong, missed }

class AnswerOption extends StatelessWidget {
  const AnswerOption({
    super.key,
    required this.position,
    required this.text,
    this.state = AnswerState.idle,
    this.onTap,
  });

  final int position; // 1..4
  final String text;
  final AnswerState state;
  final VoidCallback? onTap; // null = disabled (revealed)

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (
      Color bg,
      Color border,
      double width,
      Color bubbleBg,
      Color bubbleFg,
      IconData? icon,
      Color? iconColor,
      String stateWord,
    ) = switch (state) {
      AnswerState.idle => (
        c.bg,
        c.border,
        1.0,
        c.surface,
        c.text,
        null,
        null,
        '',
      ),
      AnswerState.selected => (
        c.accentSoft,
        c.accent,
        2.0,
        c.accent,
        c.onAccent,
        null,
        null,
        ', đã chọn',
      ),
      AnswerState.correct => (
        c.successSoft,
        c.success,
        2.0,
        c.success,
        c.onSuccess,
        Icons.check_circle,
        c.success,
        ', đúng',
      ),
      AnswerState.wrong => (
        c.dangerSoft,
        c.danger,
        2.0,
        c.danger,
        c.onDanger,
        Icons.cancel,
        c.danger,
        ', sai',
      ),
      AnswerState.missed => (
        c.bg,
        c.success,
        2.0,
        c.surface,
        c.success,
        Icons.check,
        c.success,
        ', đáp án đúng',
      ),
    };
    return Semantics(
      button: onTap != null,
      selected: state == AnswerState.selected,
      label: 'Đáp án $position: $text$stateWord',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.ease,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: border, width: width),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.s16,
                  vertical: AppSpace.s12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: bubbleBg,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$position',
                        style: AppType.sm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: bubbleFg,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpace.s12),
                    Expanded(
                      child: Text(
                        text,
                        style: AppType.base.copyWith(color: c.text),
                      ),
                    ),
                    if (icon != null) ...[
                      const SizedBox(width: AppSpace.s8),
                      Icon(icon, color: iconColor),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum GridCellState { unanswered, answered, correct, wrong }

class QuestionGridCell extends StatelessWidget {
  const QuestionGridCell({
    super.key,
    required this.number,
    required this.state,
    this.current = false,
    this.critical = false,
    this.onTap,
  });

  final int number;
  final GridCellState state;
  final bool current;
  final bool critical;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (Color bg, Color fg, String word) = switch (state) {
      GridCellState.unanswered => (c.bg, c.textMuted, 'chưa trả lời'),
      GridCellState.answered => (c.accentSoft, c.accent, 'đã trả lời'),
      GridCellState.correct => (c.successSoft, c.success, 'đúng'),
      GridCellState.wrong => (c.dangerSoft, c.danger, 'sai'),
    };
    return Semantics(
      button: true,
      selected: current,
      label: 'Câu $number, $word${critical ? ', điểm liệt' : ''}',
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: AppLayout.gridCell,
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            side: BorderSide(
              color: current
                  ? c.accent
                  : (state == GridCellState.unanswered ? c.border : bg),
              width: current ? 2 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            onTap: onTap,
            child: Stack(
              children: [
                Center(
                  child: Text(
                    '$number',
                    style: AppType.sm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                ),
                if (critical)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: c.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Timer

class CountdownPill extends StatefulWidget {
  const CountdownPill({super.key, required this.remaining});
  final Duration remaining; // computed by the caller from deadline_at

  @override
  State<CountdownPill> createState() => _CountdownPillState();
}

class _CountdownPillState extends State<CountdownPill> {
  @override
  void didUpdateWidget(CountdownPill old) {
    super.didUpdateWidget(old);
    for (final mark in const [Duration(minutes: 5), Duration(minutes: 1)]) {
      if (old.remaining > mark && widget.remaining <= mark) {
        SemanticsService.sendAnnouncement(
          View.of(context),
          'Còn ${mark.inMinutes} phút',
          Directionality.of(context),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final r = widget.remaining.isNegative ? Duration.zero : widget.remaining;
    final warn = r < const Duration(minutes: 1);
    final mm = r.inMinutes.toString().padLeft(2, '0');
    final ss = (r.inSeconds % 60).toString().padLeft(2, '0');
    return Semantics(
      label: 'Còn ${r.inMinutes} phút ${r.inSeconds % 60} giây',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.s12,
          vertical: AppSpace.s4,
        ),
        decoration: BoxDecoration(
          color: warn ? c.warningSoft : c.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              size: 18,
              color: warn ? c.warning : c.text,
            ),
            const SizedBox(width: AppSpace.s4),
            Text(
              '$mm:$ss',
              style: AppType.base.copyWith(
                fontWeight: FontWeight.w700,
                color: warn ? c.warning : c.text,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Result

enum ResultKind { pass, failScore, failCritical }

class ResultBanner extends StatelessWidget {
  const ResultBanner({
    super.key,
    required this.kind,
    required this.score,
    required this.total,
    required this.passMark,
    required this.timeUsed,
    this.criticalNumber,
  });

  final ResultKind kind;
  final int score;
  final int total;
  final int passMark;
  final String timeUsed;
  final int? criticalNumber;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pass = kind == ResultKind.pass;
    final bg = pass ? c.success : c.danger;
    final fg = pass ? c.onSuccess : c.onDanger;
    final (IconData icon, String verdict, String detail) = switch (kind) {
      ResultKind.pass => (
        Icons.verified,
        'Đạt',
        'Cần $passMark/$total câu để đạt',
      ),
      ResultKind.failScore => (
        Icons.cancel,
        'Chưa đạt',
        'Cần $passMark/$total câu để đạt',
      ),
      ResultKind.failCritical => (
        Icons.priority_high,
        'Chưa đạt',
        'Sai câu điểm liệt số ${criticalNumber ?? '?'}',
      ),
    };
    return Semantics(
      liveRegion: true,
      label: '$verdict, $score trên $total câu. $detail',
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpace.s24),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          children: [
            Icon(icon, color: fg, size: 32),
            const SizedBox(height: AppSpace.s8),
            Text('$score/$total', style: AppType.display.copyWith(color: fg)),
            Text(verdict, style: AppType.lg.copyWith(color: fg)),
            const SizedBox(height: AppSpace.s4),
            Text(
              detail,
              style: AppType.sm.copyWith(color: fg),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpace.s8),
            Text('Thời gian: $timeUsed', style: AppType.xs.copyWith(color: fg)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Explanation, bookmark

class ExplanationPanel extends StatelessWidget {
  const ExplanationPanel({
    super.key,
    required this.body,
    this.initiallyExpanded = true,
  });
  final String body;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // A Material (not a coloured Container) so the ExpansionTile's ink shows.
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: c.accent, width: 4)),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            tilePadding: const EdgeInsets.symmetric(horizontal: AppSpace.s16),
            childrenPadding: const EdgeInsets.fromLTRB(
              AppSpace.s16,
              0,
              AppSpace.s16,
              AppSpace.s16,
            ),
            leading: Icon(Icons.lightbulb_outline, color: c.accent),
            title: Text(
              'Giải thích',
              style: AppType.sm.copyWith(
                fontWeight: FontWeight.w600,
                color: c.text,
              ),
            ),
            expandedAlignment: Alignment.centerLeft,
            children: [Text(body, style: AppType.base.copyWith(color: c.text))],
          ),
        ),
      ),
    );
  }
}

class BookmarkToggle extends StatelessWidget {
  const BookmarkToggle({super.key, required this.on, required this.onChanged});
  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      toggled: on,
      label: 'Lưu câu hỏi',
      excludeSemantics: true,
      child: IconButton(
        onPressed: () {
          onChanged(!on);
          ScaffoldMessenger.maybeOf(context)
            ?..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(on ? 'Đã bỏ lưu' : 'Đã lưu')),
            );
        },
        icon: Icon(
          on ? Icons.bookmark : Icons.bookmark_border,
          color: on ? c.accent : c.textMuted,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Empty, dialog, rows

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.all(AppSpace.s32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: c.textMuted),
          const SizedBox(height: AppSpace.s16),
          Text(
            title,
            style: AppType.lg.copyWith(color: c.text),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpace.s8),
          Text(
            body,
            style: AppType.sm.copyWith(color: c.textMuted),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpace.s24),
            action!,
          ],
        ],
      ),
    );
  }
}

/// Returns true when the user confirms. The confirm button carries the verb.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        AppButton(
          label: 'Huỷ',
          variant: AppButtonVariant.ghost,
          onPressed: () => Navigator.pop(ctx, false),
        ),
        AppButton(
          label: confirmLabel,
          variant: destructive
              ? AppButtonVariant.danger
              : AppButtonVariant.primary,
          onPressed: () => Navigator.pop(ctx, true),
        ),
      ],
    ),
  );
  return ok ?? false;
}

class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.progress,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData? leading;
  final Widget? trailing;
  final double? progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.bg,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.s16,
              vertical: AppSpace.s12,
            ),
            child: Row(
              children: [
                if (leading != null) ...[
                  Icon(leading, color: c.textMuted),
                  const SizedBox(width: AppSpace.s16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppType.base.copyWith(color: c.text)),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: AppType.sm.copyWith(color: c.textMuted),
                        ),
                      if (progress != null) ...[
                        const SizedBox(height: AppSpace.s8),
                        ProgressBar(value: progress!),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSpace.s12),
                  trailing!,
                ] else if (onTap != null)
                  Icon(Icons.chevron_right, color: c.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
