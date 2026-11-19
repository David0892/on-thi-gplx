// S07 Ôn tập: overall progress, study material, and one card per chapter.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/app_theme.dart';
import '../../design/tokens.g.dart';
import '../../design/widgets.dart';
import '../../domain/models.dart';
import '../../domain/readiness.dart';
import '../../providers.dart';
import '../common.dart';
import '../shell/app_shell.dart';

class LearnPage extends ConsumerWidget {
  const LearnPage({super.key});

  static const _topicIcons = {
    1: Icons.balance,
    2: Icons.volunteer_activism_outlined,
    3: Icons.sports_motorsports_outlined,
    4: Icons.build_outlined,
    5: Icons.signpost_outlined,
    6: Icons.alt_route,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final content = ref.watch(contentRepoProvider);
    final cls = ref.watch(currentClassProvider);
    final pool = content.pool(cls.code);
    final progress = ref.watch(progressProvider).value ?? const {};
    final all = Tally.of(pool, progress);
    final critical = pool.where((q) => q.isCritical).toList();

    Widget heading(String t) => Padding(
      padding: const EdgeInsets.only(top: AppSpace.s24, bottom: AppSpace.s8),
      child: Semantics(
        header: true,
        child: Text(
          t,
          style: AppType.lg.copyWith(
            color: c.text,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: const TabAppBar(title: 'Ôn tập'),
      body: PageBody(
        children: [
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Tiến độ ôn tập',
                  style: AppType.base.copyWith(
                    color: c.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpace.s8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${all.answered}',
                              style: AppType.xl.copyWith(
                                color: c.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: ' / ${all.total} câu đã làm',
                              style: AppType.sm.copyWith(color: c.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      '${all.total == 0 ? 0 : (all.answered * 100 / all.total).round()}%',
                      style: AppType.lg.copyWith(
                        color: c.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.s8),
                SegmentedProgress(
                  right: all.right,
                  wrong: all.wrong,
                  total: all.total,
                ),
                const SizedBox(height: AppSpace.s12),
                Row(
                  children: [
                    _Count(value: all.right, label: 'Đúng', color: c.success),
                    _Count(value: all.wrong, label: 'Sai', color: c.danger),
                    _Count(
                      value: all.unseen,
                      label: 'Chưa làm',
                      color: c.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.s12),
                AppButton(
                  label: 'Ôn tất cả câu hỏi',
                  icon: Icons.play_arrow_rounded,
                  expand: true,
                  onPressed: () => context.push('/study/all'),
                ),
              ],
            ),
          ),
          heading('Tài liệu học'),
          LayoutBuilder(
            builder: (context, box) {
              final w = (box.maxWidth - AppSpace.s8) / 2;
              return Wrap(
                spacing: AppSpace.s8,
                runSpacing: AppSpace.s8,
                children: [
                  for (final (icon, title, sub, path) in [
                    (
                      Icons.lightbulb_outline,
                      'Mẹo ghi nhớ',
                      'Con số và quy tắc hay gặp',
                      '/tips',
                    ),
                    (
                      Icons.signpost_outlined,
                      'Biển báo',
                      'Tra cứu theo chủ đề',
                      '/signs',
                    ),
                    (
                      Icons.help_outline,
                      'Hỏi đáp',
                      'Về kỳ thi và ứng dụng',
                      '/faq',
                    ),
                    (
                      Icons.search,
                      'Tìm câu hỏi',
                      'Theo từ khóa hoặc số câu',
                      '/search',
                    ),
                  ])
                    SizedBox(
                      width: w,
                      child: _MaterialTile(
                        icon: icon,
                        title: title,
                        subtitle: sub,
                        onTap: () => context.push(path),
                      ),
                    ),
                ],
              );
            },
          ),
          heading('Nội dung ôn tập'),
          _TopicCard(
            icon: Icons.priority_high,
            iconColor: c.danger,
            title: 'Câu điểm liệt',
            subtitle: '${critical.length} câu · sai một câu là trượt',
            tally: Tally.of(critical, progress),
            highlight: true,
            onTap: critical.isEmpty
                ? null
                : () => context.push('/study/critical'),
          ),
          for (final t in content.topics())
            () {
              final qs = pool.where((q) => q.topicId == t.id).toList();
              return _TopicCard(
                icon: _topicIcons[t.id] ?? Icons.menu_book_outlined,
                iconColor: c.accent,
                title: t.name,
                subtitle: qs.isEmpty
                    ? 'Không có câu nào trong bộ câu của ${cls.name}'
                    : '${qs.length} câu · ${_range(qs)}',
                tally: Tally.of(qs, progress),
                onTap: qs.isEmpty
                    ? null
                    : () => context.push('/study/topic?topic=${t.id}'),
              );
            }(),
        ],
      ),
    );
  }

  static String _range(List<Question> qs) {
    final first = qs.first.number, last = qs.last.number;
    return last - first + 1 == qs.length
        ? 'Câu $first đến $last'
        : 'trong khoảng câu $first đến $last';
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
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
      child: child,
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.value, required this.label, required this.color});
  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.circle, size: 8, color: color),
              const SizedBox(width: AppSpace.s4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$value',
                    style: AppType.lg.copyWith(
                      color: c.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppType.xs.copyWith(color: c.textMuted),
          ),
        ],
      ),
    );
  }
}

class _MaterialTile extends StatelessWidget {
  const _MaterialTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.bg,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 96),
          padding: const EdgeInsets.all(AppSpace.s12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpace.s8),
                decoration: BoxDecoration(
                  color: c.accentSoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: c.accent, size: 20),
              ),
              const SizedBox(height: AppSpace.s8),
              Text(
                title,
                style: AppType.sm.copyWith(
                  color: c.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(subtitle, style: AppType.xs.copyWith(color: c.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.tally,
    required this.onTap,
    this.highlight = false,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Tally tally;
  final VoidCallback? onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pct = tally.total == 0
        ? 0
        : (tally.right * 100 / tally.total).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.s12),
      child: Material(
        color: highlight ? c.dangerSoft : c.bg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSpace.s16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: c.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(icon, color: iconColor),
                    const SizedBox(width: AppSpace.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppType.base.copyWith(
                              color: c.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: AppType.xs.copyWith(color: c.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: AppType.sm.copyWith(
                        color: c.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (onTap != null)
                      Icon(Icons.chevron_right, color: c.textMuted),
                  ],
                ),
                const SizedBox(height: AppSpace.s12),
                SegmentedProgress(
                  right: tally.right,
                  wrong: tally.wrong,
                  total: tally.total,
                ),
                const SizedBox(height: AppSpace.s8),
                Text(
                  '${tally.right} đúng · ${tally.wrong} sai · còn ${tally.unseen} câu',
                  style: AppType.xs.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
