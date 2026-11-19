// S05: the verdict, with the critical-question rule spelled out.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/app_theme.dart';
import '../../design/tokens.g.dart';
import '../../design/widgets.dart';
import '../../domain/models.dart';
import '../../providers.dart';
import '../common.dart';

class ExamResultPage extends ConsumerWidget {
  const ExamResultPage({super.key, required this.attemptId});
  final int attemptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final attempt = ref.watch(attemptProvider(attemptId));
    final content = ref.watch(contentRepoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả'),
        leading: IconButton(
          tooltip: 'Về trang chủ',
          icon: const Icon(Icons.home_outlined),
          onPressed: () => context.go('/'),
        ),
      ),
      body: switch (attempt) {
        AsyncData(:final value) when value.score != null => () {
          final a = value;
          final wrong = a.answers
              .where((x) => x.chosen != null && x.isCorrect == false)
              .length;
          final blank = a.answers.where((x) => x.chosen == null).length;
          final criticalMiss = a.answers
              .where((x) => x.isCritical && x.isCorrect == false)
              .firstOrNull;
          final kind = a.passed!
              ? ResultKind.pass
              : (a.failedOnCritical!
                    ? ResultKind.failCritical
                    : ResultKind.failScore);
          return PageBody(
            children: [
              ResultBanner(
                kind: kind,
                score: a.score!,
                total: a.questionCount,
                passMark: a.passMark,
                timeUsed: formatDuration(a.timeUsed),
                criticalNumber: criticalMiss?.position,
              ),
              if (a.status == AttemptStatus.timedOut) ...[
                const SizedBox(height: AppSpace.s12),
                Text(
                  'Hết giờ: bài đã được nộp tự động.',
                  style: AppType.sm.copyWith(color: c.textMuted),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: AppSpace.s16),
              Row(
                children: [
                  _Stat(label: 'Đúng', value: a.score!, color: c.success),
                  _Stat(label: 'Sai', value: wrong, color: c.danger),
                  _Stat(label: 'Bỏ trống', value: blank, color: c.textMuted),
                ],
              ),
              if (criticalMiss != null) ...[
                const SizedBox(height: AppSpace.s16),
                Text(
                  'Câu ${criticalMiss.position} là câu điểm liệt: '
                  '"${content.question(criticalMiss.questionKey).text}"',
                  style: AppType.sm.copyWith(color: c.text),
                ),
              ],
              const SizedBox(height: AppSpace.s24),
              if (a.score! < a.questionCount)
                AppButton(
                  label: 'Xem lại câu sai',
                  icon: Icons.error_outline,
                  expand: true,
                  onPressed: () =>
                      context.push('/exams/review/${a.id}?filter=wrong'),
                ),
              const SizedBox(height: AppSpace.s8),
              AppButton(
                label: 'Xem lại cả bài',
                variant: AppButtonVariant.secondary,
                expand: true,
                onPressed: () => context.push('/exams/review/${a.id}'),
              ),
              const SizedBox(height: AppSpace.s8),
              AppButton(
                label: 'Làm đề khác',
                variant: AppButtonVariant.ghost,
                expand: true,
                onPressed: () => context.go('/exams'),
              ),
            ],
          );
        }(),
        AsyncData() => const ErrorView(message: 'Bài thi này chưa được chấm.'),
        AsyncError() => const ErrorView(message: 'Không tìm thấy bài thi.'),
        _ => const LoadingView(),
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text('$value', style: AppType.xl.copyWith(color: color)),
        Text(
          label,
          style: AppType.sm.copyWith(color: context.colors.textMuted),
        ),
      ],
    ),
  );
}
