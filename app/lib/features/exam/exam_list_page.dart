// S03: the rules for this class, a random exam, numbered sets and history.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/app_theme.dart';
import '../../design/tokens.g.dart';
import '../../design/widgets.dart';
import '../../providers.dart';
import '../../domain/models.dart';
import '../common.dart';
import '../shell/app_shell.dart';

class ExamListPage extends ConsumerWidget {
  const ExamListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final cls = ref.watch(currentClassProvider);
    final sets = ref.watch(examSetsProvider);
    final history = ref.watch(historyProvider).value ?? const [];

    Widget section(String t) => Padding(
      padding: const EdgeInsets.only(top: AppSpace.s24, bottom: AppSpace.s8),
      child: Semantics(
        header: true,
        child: Text(t, style: AppType.lg.copyWith(color: c.text)),
      ),
    );

    final setList = sets.value ?? const <ExamSetSummary>[];
    final done = setList.where((s) => s.bestScore != null).length;
    final passed = setList.where((s) => s.passed == true).length;
    final failed = setList.where((s) => s.passed == false).length;

    return Scaffold(
      appBar: const TabAppBar(title: 'Luyện thi'),
      body: PageBody(
        children: [
          Container(
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
                    Icon(Icons.flag_outlined, color: c.accent),
                    const SizedBox(width: AppSpace.s8),
                    Expanded(
                      child: Text(
                        '$done / ${setList.length} đề đã làm',
                        style: AppType.base.copyWith(
                          color: c.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(Icons.check_circle, size: 18, color: c.success),
                    Text(
                      ' $passed  ',
                      style: AppType.sm.copyWith(color: c.text),
                    ),
                    Icon(Icons.cancel, size: 18, color: c.danger),
                    Text(' $failed', style: AppType.sm.copyWith(color: c.text)),
                  ],
                ),
                const SizedBox(height: AppSpace.s8),
                ProgressBar(value: setList.isEmpty ? 0 : done / setList.length),
                const SizedBox(height: AppSpace.s12),
                Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  // Its own Material, so the tile's ink is not hidden by the card colour.
                  child: Material(
                    type: MaterialType.transparency,
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      title: Text(
                        '${cls.name}: ${cls.examQuestionCount} câu · ${cls.examMinutes} phút · đạt từ ${cls.passMark} câu',
                        style: AppType.sm.copyWith(color: c.text),
                      ),
                      children: [
                        for (final (icon, text) in [
                          (
                            Icons.timer_outlined,
                            'Đồng hồ vẫn chạy khi bạn thoát ra ngoài app',
                          ),
                          (
                            Icons.priority_high,
                            'Có ${cls.criticalPerExam} câu điểm liệt: trả lời sai là trượt',
                          ),
                        ])
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpace.s4,
                            ),
                            child: Row(
                              children: [
                                Icon(icon, size: 20, color: c.accent),
                                const SizedBox(width: AppSpace.s12),
                                Expanded(
                                  child: Text(
                                    text,
                                    style: AppType.sm.copyWith(color: c.text),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (!cls.rulesVerified)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpace.s4),
                            child: Text(
                              'Quy định của hạng này đang được đối chiếu với văn bản chính thức.',
                              style: AppType.xs.copyWith(color: c.warning),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.s8),
                AppButton(
                  label: 'Làm đề ngẫu nhiên',
                  icon: Icons.shuffle,
                  expand: true,
                  onPressed: () => startExam(context, ref),
                ),
              ],
            ),
          ),
          section('Bộ đề cố định'),
          switch (sets) {
            AsyncData(:final value) => LayoutBuilder(
              builder: (context, box) {
                final cols = box.maxWidth >= 480 ? 4 : 3;
                final w = (box.maxWidth - AppSpace.s8 * (cols - 1)) / cols;
                return Wrap(
                  spacing: AppSpace.s8,
                  runSpacing: AppSpace.s8,
                  children: [
                    for (final s in value)
                      SizedBox(
                        width: w,
                        child: _SetCard(
                          set: s,
                          total: cls.examQuestionCount,
                          onTap: () =>
                              startExam(context, ref, setNumber: s.number),
                        ),
                      ),
                  ],
                );
              },
            ),
            AsyncError() => const ErrorView(
              message: 'Không tải được danh sách đề.',
            ),
            _ => const LoadingView(),
          },
          section('Lịch sử làm bài'),
          if (history.isEmpty)
            Text(
              'Bạn chưa nộp bài thi nào.',
              style: AppType.sm.copyWith(color: c.textMuted),
            )
          else
            _Card(
              children: [
                for (final a in history.take(10))
                  ListRow(
                    title: a.examSetNumber == null
                        ? 'Đề ngẫu nhiên'
                        : 'Đề số ${a.examSetNumber}',
                    subtitle:
                        '${a.score}/${a.questionCount} câu · ${_time(a.startedAt)}',
                    trailing: _Badge(passed: a.passed!),
                    onTap: () => context.push('/exams/result/${a.id}'),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  static String _time(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} '
      '${t.day}/${t.month}';
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(AppRadius.lg),
    child: Column(
      children: [
        for (final (i, w) in children.indexed) ...[
          if (i > 0) const Divider(),
          w,
        ],
      ],
    ),
  );
}

class _Badge extends StatelessWidget {
  const _Badge({required this.passed});
  final bool passed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s8, vertical: 2),
      decoration: BoxDecoration(
        color: passed ? c.successSoft : c.dangerSoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        passed ? 'Đạt' : 'Chưa đạt',
        style: AppType.xs.copyWith(
          fontWeight: FontWeight.w600,
          color: passed ? c.success : c.danger,
        ),
      ),
    );
  }
}

class _SetCard extends StatelessWidget {
  const _SetCard({required this.set, required this.total, required this.onTap});
  final ExamSetSummary set;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (status, color, soft) = switch (set.passed) {
      null => ('Chưa làm', c.textMuted, c.surface),
      true => ('Đạt', c.success, c.successSoft),
      false => ('Chưa đạt', c.danger, c.dangerSoft),
    };
    return Semantics(
      button: true,
      label:
          'Đề số ${set.number}, $status'
          '${set.bestScore == null ? '' : ', ${set.bestScore}/$total câu'}',
      excludeSemantics: true,
      child: Material(
        color: c.bg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpace.s12,
              horizontal: AppSpace.s4,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: c.border),
            ),
            child: Column(
              children: [
                Text(
                  'Đề số ${set.number}',
                  style: AppType.sm.copyWith(
                    color: c.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpace.s4),
                Icon(
                  set.passed == null
                      ? Icons.schedule
                      : set.passed!
                      ? Icons.check_circle_outline
                      : Icons.highlight_off,
                  color: color,
                ),
                const SizedBox(height: AppSpace.s4),
                Text(
                  '${set.bestScore?.toString() ?? '--'}/$total',
                  style: AppType.base.copyWith(
                    color: c.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpace.s4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.s8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: soft,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(status, style: AppType.xs.copyWith(color: color)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
