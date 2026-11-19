// S04: an exam in progress. The clock reads deadlineAt, so it keeps running in
// the background like the real test, and auto-submits at zero.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/app_theme.dart';
import '../../design/tokens.g.dart';
import '../../design/widgets.dart';
import '../../domain/models.dart';
import '../../providers.dart';
import '../common.dart';

class ExamRunPage extends ConsumerStatefulWidget {
  const ExamRunPage({super.key, required this.attemptId});
  final int attemptId;

  @override
  ConsumerState<ExamRunPage> createState() => _ExamRunPageState();
}

class _ExamRunPageState extends ConsumerState<ExamRunPage> {
  ExamAttempt? _attempt;
  Object? _error;
  int _index = 0;
  Timer? _ticker;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final a = await ref.read(examRepoProvider).attempt(widget.attemptId);
      if (!mounted) return;
      if (a.isFinished) {
        context.go('/exams/result/${a.id}');
        return;
      }
      // Reopened after the deadline (app was killed mid-exam): grade what was answered.
      if (!DateTime.now().isBefore(a.deadlineAt)) {
        await ref.read(examRepoProvider).submit(a.id, timedOut: true);
        ref.read(revisionProvider.notifier).bump();
        if (mounted) context.go('/exams/result/${a.id}');
        return;
      }
      setState(() {
        _attempt = a;
        _index = (a.currentPosition - 1).clamp(0, a.questionCount - 1);
      });
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  /// Moves to question [i] and remembers it, so a resumed exam reopens here.
  void _goTo(int i) {
    setState(() => _index = i);
    ref.read(examRepoProvider).setPosition(_attempt!.id, i + 1);
  }

  void _tick() {
    final a = _attempt;
    if (a == null || !mounted) return;
    if (!DateTime.now().isBefore(a.deadlineAt)) {
      _submit(timedOut: true);
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _choose(int position, int choice) async {
    final a = _attempt!;
    setState(() {
      _attempt = a.copyWith(
        answers: [
          for (final x in a.answers)
            x.position == position ? x.copyWith(chosen: choice) : x,
        ],
      );
    });
    await ref.read(examRepoProvider).answer(a.id, position, choice);
  }

  Future<void> _submit({bool timedOut = false}) async {
    if (_submitting) return;
    final a = _attempt!;
    if (!timedOut) {
      final left = a.questionCount - a.answeredCount;
      final ok = await showConfirmDialog(
        context,
        title: 'Nộp bài?',
        body: left > 0
            ? 'Bạn còn $left câu chưa trả lời. Câu chưa trả lời được tính là sai.'
            : 'Bạn đã trả lời tất cả các câu. Sau khi nộp sẽ không sửa được nữa.',
        confirmLabel: 'Nộp bài',
      );
      if (!ok) return;
    }
    setState(() => _submitting = true);
    _ticker?.cancel();
    await ref.read(examRepoProvider).submit(a.id, timedOut: timedOut);
    ref.read(revisionProvider.notifier).bump();
    if (mounted) context.go('/exams/result/${a.id}');
  }

  Future<void> _confirmExit() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Thoát bài thi?',
      body: 'Bài làm dở sẽ bị huỷ và không được chấm điểm.',
      confirmLabel: 'Thoát',
      destructive: true,
    );
    if (!ok || !mounted) return;
    _ticker?.cancel();
    await ref.read(examRepoProvider).abandon(_attempt!.id);
    ref.read(revisionProvider.notifier).bump();
    if (mounted) context.go('/exams');
  }

  void _openGrid() {
    final a = _attempt!;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppLayout.gutter,
            0,
            AppLayout.gutter,
            AppLayout.gutter,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đã trả lời ${a.answeredCount}/${a.questionCount} câu',
                style: AppType.lg.copyWith(color: ctx.colors.text),
              ),
              const SizedBox(height: AppSpace.s16),
              Wrap(
                spacing: AppSpace.s8,
                runSpacing: AppSpace.s8,
                children: [
                  for (final (i, x) in a.answers.indexed)
                    QuestionGridCell(
                      number: i + 1,
                      state: x.chosen == null
                          ? GridCellState.unanswered
                          : GridCellState.answered,
                      current: i == _index,
                      critical: false, // not revealed during the exam, like the real test
                      onTap: () {
                        Navigator.pop(ctx);
                        _goTo(i);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorView(message: 'Không mở được bài thi này.'),
      );
    }
    final a = _attempt;
    if (a == null) return const Scaffold(body: LoadingView());

    final content = ref.watch(contentRepoProvider);
    final answer = a.answers[_index];
    final q = content.question(answer.questionKey);
    final saved = ref.watch(bookmarksProvider).value?.contains(q.key) ?? false;
    final isLast = _index == a.questionCount - 1;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Thoát bài thi',
            icon: const Icon(Icons.close),
            onPressed: _confirmExit,
          ),
          title: Text(
            a.examSetNumber == null ? 'Đề ngẫu nhiên' : 'Đề ${a.examSetNumber}',
          ),
          actions: [
            CountdownPill(remaining: a.deadlineAt.difference(DateTime.now())),
            const SizedBox(width: AppSpace.s8),
          ],
        ),
        // Keyed by question so each question opens scrolled to its top.
        body: QuestionTextScale(
          child: PageBody(
            key: ValueKey(_index),
            children: [
              QuestionCard(
                index: _index + 1,
                total: a.questionCount,
                text: q.text,
                image: QuestionImage.of(q),
                // Critical questions are not marked during the exam (as in the real test).
                trailing: BookmarkToggle(
                  on: saved,
                  onChanged: (_) async {
                    await ref.read(bookmarkRepoProvider).toggle(q.key);
                    ref.read(revisionProvider.notifier).bump();
                  },
                ),
              ),
              const SizedBox(height: AppSpace.s12),
              for (final (i, opt) in q.options.indexed) ...[
                AnswerOption(
                  position: i + 1,
                  text: opt,
                  state: answer.chosen == i + 1
                      ? AnswerState.selected
                      : AnswerState.idle,
                  onTap: () => _choose(answer.position, i + 1),
                ),
                const SizedBox(height: AppSpace.s8),
              ],
            ],
          ),
        ),
        // Toolbar text is capped at 1.3x so four controls still fit on a 320px screen.
        bottomNavigationBar: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.bg,
                border: Border(top: BorderSide(color: context.colors.border)),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.s8,
                vertical: AppSpace.s8,
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Câu trước',
                    onPressed: _index == 0 ? null : () => _goTo(_index - 1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: AppButton(
                      label: 'Câu ${_index + 1}/${a.questionCount}',
                      icon: Icons.grid_view,
                      variant: AppButtonVariant.secondary,
                      onPressed: _openGrid,
                    ),
                  ),
                  const SizedBox(width: AppSpace.s8),
                  // Flexible, so the loading spinner cannot squeeze the grid button to nothing.
                  if (isLast)
                    Flexible(
                      child: AppButton(
                        label: 'Nộp bài',
                        loading: _submitting,
                        onPressed: () => _submit(),
                      ),
                    )
                  else ...[
                    Flexible(
                      child: AppButton(
                        label: 'Nộp',
                        variant: AppButtonVariant.ghost,
                        loading: _submitting,
                        onPressed: () => _submit(),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Câu tiếp theo',
                      onPressed: () => _goTo(_index + 1),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
