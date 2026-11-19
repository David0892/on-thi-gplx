// S06: walk a finished exam, answers revealed, with an "only wrong" filter.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/tokens.g.dart';
import '../../design/widgets.dart';
import '../../domain/models.dart';
import '../../providers.dart';
import '../common.dart';

AnswerState revealedState({
  required int position,
  required int correct,
  int? chosen,
}) {
  if (position == correct) {
    return chosen == correct ? AnswerState.correct : AnswerState.missed;
  }
  if (position == chosen) return AnswerState.wrong;
  return AnswerState.idle;
}

class ExamReviewPage extends ConsumerStatefulWidget {
  const ExamReviewPage({
    super.key,
    required this.attemptId,
    this.onlyWrong = false,
  });
  final int attemptId;
  final bool onlyWrong;

  @override
  ConsumerState<ExamReviewPage> createState() => _ExamReviewPageState();
}

class _ExamReviewPageState extends ConsumerState<ExamReviewPage> {
  late bool _onlyWrong = widget.onlyWrong;

  @override
  Widget build(BuildContext context) {
    final attempt = ref.watch(attemptProvider(widget.attemptId));
    final content = ref.watch(contentRepoProvider);
    final saved = ref.watch(bookmarksProvider).value ?? const {};

    return Scaffold(
      appBar: AppBar(title: const Text('Xem lại bài thi')),
      body: switch (attempt) {
        AsyncData(:final value) => () {
          final items = value.answers
              .where((x) => !_onlyWrong || x.isCorrect == false)
              .toList();
          return PageBody(
            children: [
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text('Tất cả (${value.questionCount})'),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text(
                      'Câu sai (${value.answers.where((x) => x.isCorrect == false).length})',
                    ),
                  ),
                ],
                selected: {_onlyWrong},
                onSelectionChanged: (s) => setState(() => _onlyWrong = s.first),
              ),
              const SizedBox(height: AppSpace.s16),
              if (items.isEmpty)
                const EmptyState(
                  icon: Icons.task_alt,
                  title: 'Không sai câu nào',
                  body: 'Bạn đã trả lời đúng toàn bộ bài thi này.',
                ),
              for (final x in items) ...[
                _ReviewItem(
                  answer: x,
                  total: value.questionCount,
                  question: content.question(x.questionKey),
                  saved: saved.contains(x.questionKey),
                  onToggleSave: () async {
                    await ref.read(bookmarkRepoProvider).toggle(x.questionKey);
                    ref.read(revisionProvider.notifier).bump();
                  },
                ),
                const SizedBox(height: AppSpace.s24),
              ],
            ],
          );
        }(),
        AsyncError() => const ErrorView(message: 'Không tìm thấy bài thi.'),
        _ => const LoadingView(),
      },
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({
    required this.answer,
    required this.total,
    required this.question,
    required this.saved,
    required this.onToggleSave,
  });

  final AttemptAnswer answer;
  final int total;
  final Question question;
  final bool saved;
  final VoidCallback onToggleSave;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      QuestionCard(
        index: answer.position,
        total: total,
        text: question.text,
        critical: question.isCritical,
        trailing: BookmarkToggle(on: saved, onChanged: (_) => onToggleSave()),
      ),
      const SizedBox(height: AppSpace.s8),
      if (answer.chosen == null)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpace.s8),
          child: Text('Bạn đã bỏ trống câu này.', style: AppType.sm),
        ),
      for (final (i, opt) in question.options.indexed) ...[
        AnswerOption(
          position: i + 1,
          text: opt,
          state: revealedState(
            position: i + 1,
            correct: question.correctPosition,
            chosen: answer.chosen,
          ),
        ),
        const SizedBox(height: AppSpace.s8),
      ],
      ExplanationPanel(
        body: question.explanation,
        initiallyExpanded: answer.isCorrect == false,
      ),
    ],
  );
}
