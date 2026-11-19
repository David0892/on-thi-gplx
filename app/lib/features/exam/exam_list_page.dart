// S03: the rules for this class, a random exam, numbered sets and history.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/app_theme.dart';
import '../../design/tokens.g.dart';
import '../../design/widgets.dart';
import '../../providers.dart';
import '../common.dart';

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

    return Scaffold(
      appBar: AppBar(title: Text('Thi thử ${cls.name}')),
      body: PageBody(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpace.s16),
            decoration: BoxDecoration(
              color: c.bg,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (icon, text) in [
                  (
                    Icons.quiz_outlined,
                    '${cls.examQuestionCount} câu hỏi, chọn một đáp án đúng',
                  ),
                  (
                    Icons.timer_outlined,
                    '${cls.examMinutes} phút, đồng hồ vẫn chạy khi bạn thoát ra ngoài app',
                  ),
                  (
                    Icons.verified_outlined,
                    'Đạt khi đúng từ ${cls.passMark}/${cls.examQuestionCount} câu',
                  ),
                  (
                    Icons.priority_high,
                    'Có ${cls.criticalPerExam} câu điểm liệt: trả lời sai là trượt',
                  ),
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpace.s4),
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
                if (!cls.rulesVerified) ...[
                  const SizedBox(height: AppSpace.s8),
                  Text(
                    'Quy định của hạng này đang được đối chiếu với văn bản chính thức.',
                    style: AppType.xs.copyWith(color: c.warning),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpace.s16),
          AppButton(
            label: 'Làm đề ngẫu nhiên',
            icon: Icons.shuffle,
            size: AppButtonSize.lg,
            expand: true,
            onPressed: () => startExam(context, ref),
          ),
          section('Bộ đề cố định'),
          switch (sets) {
            AsyncData(:final value) => _Card(
              children: [
                for (final s in value)
                  ListRow(
                    title: 'Đề ${s.number}',
                    subtitle: s.bestScore == null
                        ? 'Chưa làm'
                        : 'Điểm cao nhất ${s.bestScore}/${cls.examQuestionCount}',
                    trailing: s.passed == null
                        ? null
                        : _Badge(passed: s.passed!),
                    onTap: () => startExam(context, ref, setNumber: s.number),
                  ),
              ],
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
                        : 'Đề ${a.examSetNumber}',
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
