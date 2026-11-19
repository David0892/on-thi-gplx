// S08 study mode: one question at a time, instant feedback and explanation.
// Serves S09 (critical), S10 (wrong answers) and S11 (saved) with a filter.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/app_theme.dart';
import '../../design/tokens.g.dart';
import '../../design/widgets.dart';
import '../../domain/models.dart';
import '../../providers.dart';
import '../common.dart';
import '../exam/exam_review_page.dart' show revealedState;

class StudyPage extends ConsumerStatefulWidget {
  const StudyPage({super.key, required this.source, this.topicId});
  final StudySource source;
  final int? topicId;

  @override
  ConsumerState<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends ConsumerState<StudyPage> {
  int _index = 0;
  bool _cursorLoaded = false;
  final _answers =
      <String, int>{}; // this session: questionKey -> chosen position

  StudyKey get _key => (source: widget.source, topicId: widget.topicId);

  String _title() => switch (widget.source) {
    StudySource.topic =>
      ref.read(contentRepoProvider).topic(widget.topicId!).shortName,
    StudySource.critical => 'Câu điểm liệt',
    StudySource.wrong => 'Câu đã làm sai',
    StudySource.saved => 'Câu đã lưu',
  };

  @override
  void initState() {
    super.initState();
    _restoreCursor();
  }

  Future<void> _restoreCursor() async {
    if (widget.source == StudySource.topic) {
      final pos = await ref
          .read(studyRepoProvider)
          .cursor(ref.read(currentClassProvider).code, widget.topicId!);
      if (mounted) setState(() => _index = pos);
    }
    if (mounted) setState(() => _cursorLoaded = true);
  }

  void _go(int i, int length) {
    setState(() => _index = i.clamp(0, length - 1));
    if (widget.source == StudySource.topic) {
      ref
          .read(studyRepoProvider)
          .saveCursor(
            ref.read(currentClassProvider).code,
            widget.topicId!,
            _index,
          );
    }
  }

  Future<void> _choose(Question q, int choice) async {
    if (_answers.containsKey(q.key)) return;
    setState(() => _answers[q.key] = choice);
    await ref
        .read(studyRepoProvider)
        .record(
          ref.read(currentClassProvider).code,
          q.key,
          correct: choice == q.correctPosition,
        );
    ref.read(revisionProvider.notifier).bump();
  }

  Future<void> _finish(List<Question> qs) async {
    final right = qs.where((q) => _answers[q.key] == q.correctPosition).length;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hết câu hỏi'),
        content: Text(
          'Bạn đã trả lời ${_answers.length}/${qs.length} câu, đúng $right câu.',
        ),
        actions: [
          AppButton(
            label: 'Ở lại',
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.pop(ctx),
          ),
          AppButton(
            label: 'Xong',
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _clearWrong() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Xoá danh sách câu sai?',
      body: 'Các câu sẽ được bỏ khỏi danh sách. Lịch sử làm bài vẫn được giữ.',
      confirmLabel: 'Xoá',
      destructive: true,
    );
    if (!ok) return;
    await ref
        .read(studyRepoProvider)
        .clearWrong(ref.read(currentClassProvider).code);
    ref.read(revisionProvider.notifier).bump();
    ref.invalidate(studyQuestionsProvider(_key));
  }

  void _openGrid(List<Question> qs) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppLayout.gutter,
            0,
            AppLayout.gutter,
            AppLayout.gutter,
          ),
          child: Wrap(
            spacing: AppSpace.s8,
            runSpacing: AppSpace.s8,
            children: [
              for (final (i, q) in qs.indexed)
                QuestionGridCell(
                  number: i + 1,
                  current: i == _index,
                  critical: q.isCritical,
                  state: switch (_answers[q.key]) {
                    null => GridCellState.unanswered,
                    final c when c == q.correctPosition =>
                      GridCellState.correct,
                    _ => GridCellState.wrong,
                  },
                  onTap: () {
                    Navigator.pop(ctx);
                    _go(i, qs.length);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(studyQuestionsProvider(_key));
    final saved = ref.watch(bookmarksProvider).value ?? const {};

    return Scaffold(
      appBar: AppBar(
        title: Text(_title()),
        actions: [
          if (widget.source == StudySource.wrong &&
              (questions.value?.isNotEmpty ?? false))
            IconButton(
              tooltip: 'Xoá danh sách',
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearWrong,
            ),
        ],
      ),
      body: switch (questions) {
        AsyncData(:final value) when value.isEmpty => Center(child: _empty()),
        AsyncData(:final value) when _cursorLoaded => _question(value, saved),
        AsyncError() => const ErrorView(message: 'Không tải được câu hỏi.'),
        _ => const LoadingView(),
      },
      bottomNavigationBar: switch (questions) {
        AsyncData(:final value) when value.isNotEmpty && _cursorLoaded =>
          _bottomBar(value),
        _ => null,
      },
    );
  }

  Widget _empty() => switch (widget.source) {
    StudySource.wrong => EmptyState(
      icon: Icons.task_alt,
      title: 'Chưa có câu sai nào',
      body: 'Câu nào bạn trả lời sai khi ôn hoặc khi thi thử sẽ được gom vào đây.',
      action: AppButton(
        label: 'Thi thử ngay',
        onPressed: () => startExam(context, ref),
      ),
    ),
    StudySource.saved => const EmptyState(
      icon: Icons.bookmark_border,
      title: 'Chưa lưu câu nào',
      body: 'Bấm biểu tượng dấu trang ở góc câu hỏi để lưu lại những câu khó.',
    ),
    _ => const EmptyState(
      icon: Icons.inbox_outlined,
      title: 'Chưa có câu hỏi',
      body: 'Mục này chưa có câu hỏi cho hạng bạn đang ôn.',
    ),
  };

  Widget _question(List<Question> qs, Set<String> saved) {
    final i = _index.clamp(0, qs.length - 1);
    final q = qs[i];
    final chosen = _answers[q.key];
    // Keyed by question so each question opens scrolled to its top.
    return PageBody(
      key: ValueKey(q.key),
      children: [
        QuestionCard(
          index: i + 1,
          total: qs.length,
          text: q.text,
          critical: q.isCritical,
          trailing: BookmarkToggle(
            on: saved.contains(q.key),
            onChanged: (_) async {
              await ref.read(bookmarkRepoProvider).toggle(q.key);
              ref.read(revisionProvider.notifier).bump();
            },
          ),
        ),
        const SizedBox(height: AppSpace.s12),
        for (final (j, opt) in q.options.indexed) ...[
          AnswerOption(
            position: j + 1,
            text: opt,
            state: chosen == null
                ? AnswerState.idle
                : revealedState(
                    position: j + 1,
                    correct: q.correctPosition,
                    chosen: chosen,
                  ),
            onTap: chosen == null ? () => _choose(q, j + 1) : null,
          ),
          const SizedBox(height: AppSpace.s8),
        ],
        if (chosen != null) ...[
          const SizedBox(height: AppSpace.s8),
          ExplanationPanel(body: q.explanation),
        ],
      ],
    );
  }

  Widget _bottomBar(List<Question> qs) {
    final i = _index.clamp(0, qs.length - 1);
    final isLast = i == qs.length - 1;
    // Toolbar text is capped at 1.3x so the controls still fit on a 320px screen.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.bg,
            border: Border(top: BorderSide(color: context.colors.border)),
          ),
          padding: const EdgeInsets.all(AppSpace.s8),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Câu trước',
                onPressed: i == 0 ? null : () => _go(i - 1, qs.length),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: AppButton(
                  label: 'Câu ${i + 1}/${qs.length}',
                  icon: Icons.grid_view,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => _openGrid(qs),
                ),
              ),
              const SizedBox(width: AppSpace.s8),
              AppButton(
                label: isLast ? 'Hoàn thành' : 'Tiếp',
                onPressed: isLast
                    ? () => _finish(qs)
                    : () => _go(i + 1, qs.length),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
