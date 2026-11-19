// Small pieces shared by several screens.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../design/app_theme.dart';
import '../design/tokens.g.dart';
import '../design/widgets.dart';
import '../domain/exam_rules.dart';
import '../providers.dart';

/// Centers content and caps its width, so tablets and web do not stretch it.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children, this.padding});
  final List<Widget> children;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
      child: ListView(
        padding: padding ?? const EdgeInsets.all(AppLayout.gutter),
        children: children,
      ),
    ),
  );
}

/// Applies the learner's question text size (Cài đặt) on top of the system
/// text size, to a question and its answers and explanation.
class QuestionTextScale extends ConsumerWidget {
  const QuestionTextScale({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = ref.watch(questionScaleProvider);
    if (scale == 1) return child;
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        textScaler: TextScaler.linear(mq.textScaler.scale(1) * scale),
      ),
      child: child,
    );
  }
}

/// Shown while the bank is the hand-written sample, so nobody mistakes it for the official set.
class SampleNotice extends ConsumerWidget {
  const SampleNotice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(contentRepoProvider).isSample) {
      return const SizedBox.shrink();
    }
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.s16),
      padding: const EdgeInsets.all(AppSpace.s12),
      decoration: BoxDecoration(
        color: c.warningSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.science_outlined, color: c.warning, size: 20),
          const SizedBox(width: AppSpace.s8),
          Expanded(
            child: Text(
              'Bản thử nghiệm: đang dùng câu hỏi mẫu, chưa phải bộ đề chính thức.',
              style: AppType.sm.copyWith(color: c.text),
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(AppSpace.s32),
      child: CircularProgressIndicator(),
    ),
  );
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: EmptyState(
      icon: Icons.error_outline,
      title: 'Có lỗi xảy ra',
      body: message,
      action: onRetry == null
          ? null
          : AppButton(label: 'Thử lại', onPressed: onRetry),
    ),
  );
}

/// Starts an exam and opens it. Shows a dialog when the bank cannot fill the
/// class rules (e.g. the sample bank for a 45-question class).
Future<void> startExam(
  BuildContext context,
  WidgetRef ref, {
  int? setNumber,
}) async {
  final code = ref.read(currentClassProvider).code;
  try {
    final id = await ref
        .read(examRepoProvider)
        .start(code, setNumber: setNumber);
    ref.read(revisionProvider.notifier).bump();
    if (context.mounted) context.go('/exams/run/$id');
  } on NotEnoughQuestions catch (e) {
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chưa đủ câu hỏi'),
        content: Text(
          '${e.message}\n\nHãy chọn hạng khác hoặc chờ bản cập nhật bộ đề đầy đủ.',
        ),
        actions: [
          AppButton(label: 'Đã hiểu', onPressed: () => Navigator.pop(ctx)),
        ],
      ),
    );
  }
}

String formatDuration(Duration d) {
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
