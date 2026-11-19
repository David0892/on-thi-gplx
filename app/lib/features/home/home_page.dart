// S02 Tổng quan: readiness, what to fix next, and shortcuts.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/app_theme.dart';
import '../../design/tokens.g.dart';
import '../../design/widgets.dart';
import '../../domain/readiness.dart';
import '../../providers.dart';
import '../common.dart';
import '../shell/app_shell.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final readiness = ref.watch(readinessProvider).value;
    final fixes = ref.watch(improvementsProvider).value ?? const [];
    final stats = ref.watch(homeStatsProvider).value;

    return Scaffold(
      appBar: const TabAppBar(title: 'Tổng quan'),
      body: PageBody(
        children: [
          const SampleNotice(),
          const _SearchBar(),
          const SizedBox(height: AppSpace.s16),
          if (ref.watch(runningExamProvider).value case final running?) ...[
            _ResumeBanner(
              text:
                  'Bạn có bài thi đang làm dở '
                  '(${running.answeredCount}/${running.questionCount} câu).',
              onResume: () => context.go('/exams/run/${running.id}'),
            ),
            const SizedBox(height: AppSpace.s16),
          ],
          _ReadinessCard(readiness: readiness, stats: stats),
          const SizedBox(height: AppSpace.s16),
          _Section(
            icon: Icons.checklist,
            title: 'Cần cải thiện',
            trailing: fixes.isEmpty ? null : '${fixes.length} việc',
            child: fixes.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppSpace.s16),
                    child: Text(
                      'Chưa có gì cần sửa. Hãy làm thêm câu mới hoặc thi thử.',
                      style: AppType.sm.copyWith(color: c.textMuted),
                    ),
                  )
                : Column(
                    children: [
                      for (final f in fixes)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpace.s12),
                          child: _FixCard(fix: f),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: AppSpace.s16),
          _Section(
            icon: Icons.apps,
            title: 'Truy cập nhanh',
            child: _QuickGrid(stats: stats),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: 'Tìm câu hỏi',
      excludeSemantics: true,
      child: Material(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => context.push('/search'),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppLayout.tapTargetMin,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.s12,
                vertical: AppSpace.s8,
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: c.textMuted),
                  const SizedBox(width: AppSpace.s8),
                  Expanded(
                    child: Text(
                      'Tìm câu hỏi theo từ khóa hoặc số câu',
                      style: AppType.base.copyWith(color: c.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResumeBanner extends StatelessWidget {
  const _ResumeBanner({required this.text, required this.onResume});
  final String text;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpace.s12),
      decoration: BoxDecoration(
        color: c.accentSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.accent),
      ),
      // Text and button stacked, so neither is squeezed at large text sizes.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.pending_actions, color: c.accent),
              const SizedBox(width: AppSpace.s12),
              Expanded(
                child: Text(text, style: AppType.sm.copyWith(color: c.text)),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              label: 'Làm tiếp',
              variant: AppButtonVariant.ghost,
              onPressed: onResume,
            ),
          ),
        ],
      ),
    );
  }
}

/// A titled white card, the building block of the tab pages.
class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
    this.action,
  });
  final IconData icon;
  final String title;
  final String? trailing;
  final Widget? action;
  final Widget child;

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: c.accent),
              const SizedBox(width: AppSpace.s8),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: AppType.lg.copyWith(
                      color: c.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (trailing != null)
                Text(trailing!, style: AppType.sm.copyWith(color: c.textMuted)),
              ?action,
            ],
          ),
          const SizedBox(height: AppSpace.s12),
          child,
        ],
      ),
    );
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({required this.readiness, required this.stats});
  final Readiness? readiness;
  final HomeStats? stats;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final r = readiness;
    final pool = r?.pool ?? const Tally();
    final critical = r?.critical ?? const Tally();
    final tiles = [
      (
        Icons.verified_outlined,
        'Đã thuộc',
        '${pool.mastered}/${pool.total} câu',
        c.success,
        '/study/all',
      ),
      (Icons.sync, 'Chưa chắc', '${pool.shaky} câu', c.accent, '/learn'),
      (
        Icons.priority_high,
        'Điểm liệt',
        '${critical.mastered}/${critical.total} đã thuộc',
        c.danger,
        '/study/critical',
      ),
      (
        Icons.assignment_turned_in_outlined,
        'Thi thử',
        stats == null || stats!.examsTaken == 0
            ? 'Chưa thi'
            : 'Đạt ${stats!.examsPassed}/${stats!.examsTaken} đề',
        c.warning,
        '/exams',
      ),
    ];

    return _Section(
      icon: Icons.insights,
      title: 'Mức sẵn sàng',
      // An icon, not a text button: the header must fit at 200% text on 320px.
      action: IconButton(
        tooltip: 'Xem chi tiết mức sẵn sàng',
        icon: const Icon(Icons.info_outline),
        onPressed: r == null ? null : () => showReadinessSheet(context, r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ProgressRing(value: r?.score ?? 0, caption: 'sẵn sàng'),
              const SizedBox(width: AppSpace.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Pill(
                      text: r?.label ?? 'Cần ôn thêm',
                      color: r?.ready == true ? c.success : c.warning,
                      soft: r?.ready == true ? c.successSoft : c.warningSoft,
                    ),
                    const SizedBox(height: AppSpace.s8),
                    Text(
                      'Mục tiêu ${(readinessTarget * 100).round()}%',
                      style: AppType.sm.copyWith(color: c.textMuted),
                    ),
                    Text(
                      'Đạt ${r?.conditionsMet ?? 0}/3 điều kiện đi thi',
                      style: AppType.sm.copyWith(color: c.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.s16),
          LayoutBuilder(
            builder: (context, box) {
              final w = (box.maxWidth - AppSpace.s8) / 2;
              return Wrap(
                spacing: AppSpace.s8,
                runSpacing: AppSpace.s8,
                children: [
                  for (final (icon, label, value, color, path) in tiles)
                    SizedBox(
                      width: w,
                      child: _StatTile(
                        icon: icon,
                        label: label,
                        value: value,
                        color: color,
                        onTap: () => path == '/learn' || path == '/exams'
                            ? context.go(path)
                            : context.push(path),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color, required this.soft});
  final String text;
  final Color color;
  final Color soft;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpace.s8,
      vertical: AppSpace.s4,
    ),
    decoration: BoxDecoration(
      color: soft,
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
    child: Text(
      text,
      style: AppType.sm.copyWith(color: color, fontWeight: FontWeight.w600),
    ),
  );
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.s12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: AppSpace.s8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppType.xs.copyWith(color: c.textMuted)),
                    Text(
                      value,
                      style: AppType.sm.copyWith(
                        color: c.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FixCard extends StatelessWidget {
  const _FixCard({required this.fix});
  final Improvement fix;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (tag, color, soft, icon) = switch (fix.kind) {
      ImprovementKind.criticalWrong => (
        'ĐIỂM LIỆT · ƯU TIÊN',
        c.danger,
        c.dangerSoft,
        Icons.error_outline,
      ),
      ImprovementKind.oftenWrong => (
        'HAY SAI',
        c.warning,
        c.warningSoft,
        Icons.replay,
      ),
      ImprovementKind.topicWrong => (
        'CHƯƠNG NHIỀU CÂU SAI',
        c.warning,
        c.warningSoft,
        Icons.menu_book_outlined,
      ),
      ImprovementKind.unseen => (
        'CÂU MỚI',
        c.accent,
        c.accentSoft,
        Icons.fiber_new_outlined,
      ),
    };
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(color: color, child: const SizedBox(width: 4)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpace.s12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpace.s8),
                      decoration: BoxDecoration(
                        color: soft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: AppSpace.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tag,
                            style: AppType.xs.copyWith(
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            fix.title,
                            style: AppType.base.copyWith(
                              color: c.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpace.s4),
                          Text(
                            fix.detail,
                            style: AppType.sm.copyWith(color: c.textMuted),
                          ),
                          const SizedBox(height: AppSpace.s8),
                          // Not AppButton: at 200% text on a 320px phone the
                          // label must be allowed to wrap.
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => context.push(fix.path),
                              style: TextButton.styleFrom(
                                foregroundColor: color,
                                backgroundColor: soft,
                                minimumSize: const Size(
                                  0,
                                  AppLayout.tapTargetMin,
                                ),
                              ),
                              icon: const Icon(Icons.arrow_forward, size: 18),
                              iconAlignment: IconAlignment.end,
                              label: Text(
                                fix.action,
                                style: AppType.sm.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

class _QuickGrid extends ConsumerWidget {
  const _QuickGrid({required this.stats});
  final HomeStats? stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final tiles = [
      (
        Icons.assignment_outlined,
        'Làm đề thi',
        null,
        c.accent,
        c.accentSoft,
        null,
      ),
      (
        Icons.error_outline,
        'Câu đang sai',
        stats?.wrong,
        c.danger,
        c.dangerSoft,
        '/study/wrong',
      ),
      (
        Icons.replay,
        'Câu hay sai',
        null,
        c.warning,
        c.warningSoft,
        '/study/often',
      ),
      (
        Icons.priority_high,
        'Câu điểm liệt',
        null,
        c.danger,
        c.dangerSoft,
        '/study/critical',
      ),
      (
        Icons.signpost_outlined,
        'Biển báo',
        null,
        c.success,
        c.successSoft,
        '/signs',
      ),
      (
        Icons.bookmark_border,
        'Câu đã lưu',
        stats?.saved,
        c.accent,
        c.accentSoft,
        '/study/saved',
      ),
    ];
    return LayoutBuilder(
      builder: (context, box) {
        final cols = box.maxWidth >= 480 ? 3 : 2;
        final w = (box.maxWidth - AppSpace.s8 * (cols - 1)) / cols;
        return Wrap(
          spacing: AppSpace.s8,
          runSpacing: AppSpace.s8,
          children: [
            for (final (icon, label, count, color, soft, path) in tiles)
              SizedBox(
                width: w,
                child: _QuickTile(
                  icon: icon,
                  label: label,
                  count: count,
                  color: color,
                  soft: soft,
                  onTap: path == null
                      ? () => startExam(context, ref)
                      : () => context.push(path),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.soft,
    required this.onTap,
    this.count,
  });
  final IconData icon;
  final String label;
  final int? count;
  final Color color;
  final Color soft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: count == null ? label : '$label, $count câu',
      excludeSemantics: true,
      child: Material(
        color: soft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 88),
            child: Padding(
              padding: const EdgeInsets.all(AppSpace.s12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: color, size: 28),
                      const SizedBox(width: AppSpace.s4),
                      Expanded(
                        child: count == null
                            ? const SizedBox.shrink()
                            : Text(
                                '$count câu',
                                textAlign: TextAlign.end,
                                overflow: TextOverflow.ellipsis,
                                style: AppType.xs.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.s8),
                  Text(
                    label,
                    style: AppType.sm.copyWith(
                      color: c.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// What the readiness score means and the three conditions to book the exam.
Future<void> showReadinessSheet(BuildContext context, Readiness r) {
  final c = context.colors;
  final pct = (r.score * 100).round();
  final conditions = [
    (
      r.scoreReached,
      'Mức sẵn sàng từ ${(readinessTarget * 100).round()}%',
      'Hiện tại $pct%.',
    ),
    (
      r.criticalReady,
      'Thuộc hết câu điểm liệt',
      '${r.critical.mastered}/${r.critical.total} câu đã thuộc, '
          '${r.critical.wrong} câu đang sai.',
    ),
    (
      r.examsSteady,
      'Đạt $recentExamsNeeded đề thi thử gần nhất',
      r.recentExams == 0
          ? 'Chưa thi đề nào.'
          : 'Đạt ${r.recentPasses}/${r.recentExams} đề gần nhất.',
    ),
  ];
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.s16,
          0,
          AppSpace.s16,
          AppSpace.s16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mức sẵn sàng $pct%',
              style: AppType.xl.copyWith(color: c.text),
            ),
            const SizedBox(height: AppSpace.s8),
            ProgressBar(value: r.score),
            const SizedBox(height: AppSpace.s12),
            Text(
              'Câu trả lời đúng từ hai lần trở lên được tính là đã thuộc và tính trọn. '
              'Câu mới đúng một lần chỉ tính một nửa. Câu đang sai và câu chưa làm không được tính.\n\n'
              'Đề thi thật được rút ngẫu nhiên từ cả bộ câu, nên mục tiêu được đặt cao hơn điểm đạt.',
              style: AppType.sm.copyWith(color: c.text),
            ),
            const SizedBox(height: AppSpace.s16),
            Text(
              'Điều kiện đi thi (${r.conditionsMet}/3)',
              style: AppType.base.copyWith(
                color: c.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpace.s8),
            for (final (ok, title, detail) in conditions)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.s8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      ok ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: ok ? c.success : c.textMuted,
                    ),
                    const SizedBox(width: AppSpace.s8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppType.sm.copyWith(color: c.text),
                          ),
                          Text(
                            detail,
                            style: AppType.xs.copyWith(color: c.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpace.s8),
            AppButton(
              label: 'Đã hiểu',
              expand: true,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    ),
  );
}
