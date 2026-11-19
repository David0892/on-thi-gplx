// One question, read-only: answer shown, explanation open. Opened from search
// (S16) and the sign library (S12).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories.dart';
import '../../design/app_theme.dart';
import '../../design/tokens.g.dart';
import '../../design/widgets.dart';
import '../../domain/models.dart';
import '../../providers.dart';
import '../common.dart';

/// The question with this official number, as the given class sees it
/// (critical flag per class). Falls back to any class's pool, so a link to a
/// question outside the class still opens; [inClass] says which case it was.
({Question question, bool inClass})? findQuestion(
  ContentRepo content,
  String classCode,
  int number,
) {
  for (final q in content.pool(classCode)) {
    if (q.number == number) return (question: q, inClass: true);
  }
  for (final k in content.classes()) {
    for (final q in content.pool(k.code)) {
      if (q.number == number) {
        return (question: q.withCritical(false), inClass: false);
      }
    }
  }
  return null;
}

/// A compact row for a question in a list: number, picture, text.
class QuestionRow extends StatelessWidget {
  const QuestionRow({super.key, required this.question});
  final Question question;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final q = question;
    return Material(
      color: c.bg,
      child: InkWell(
        onTap: () => context.push('/question/${q.number}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.s12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (q.image != null) ...[
                ExcludeSemantics(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Image.asset(
                      q.image!,
                      width: 72,
                      height: 56,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) =>
                          const SizedBox(width: 72, height: 56),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpace.s12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpace.s8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Câu ${q.number}',
                          style: AppType.sm.copyWith(
                            color: c.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (q.isCritical) const CriticalBadge(),
                      ],
                    ),
                    const SizedBox(height: AppSpace.s4),
                    Text(
                      q.text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.sm.copyWith(color: c.textMuted),
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

class QuestionPage extends ConsumerWidget {
  const QuestionPage({super.key, required this.number});
  final int number;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentRepoProvider);
    final cls = ref.watch(currentClassProvider);
    final found = findQuestion(content, cls.code, number);
    if (found == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Câu $number')),
        body: const Center(
          child: EmptyState(
            icon: Icons.search_off,
            title: 'Không có câu này',
            body: 'Bộ đề có các câu từ 1 đến 600.',
          ),
        ),
      );
    }
    final q = found.question;
    final saved = ref.watch(bookmarksProvider).value ?? const <String>{};
    final c = context.colors;

    return Scaffold(
      appBar: AppBar(title: Text('Câu ${q.number}')),
      body: PageBody(
        children: [
          if (!found.inClass)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.s12),
              child: Text(
                'Câu này không có trong bộ câu của ${cls.name}.',
                style: AppType.sm.copyWith(color: c.textMuted),
              ),
            ),
          QuestionCard(
            index: q.number,
            total: 600,
            text: q.text,
            critical: q.isCritical,
            image: QuestionImage.of(q),
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
              state: j + 1 == q.correctPosition
                  ? AnswerState.correct
                  : AnswerState.idle,
            ),
            const SizedBox(height: AppSpace.s8),
          ],
          if (q.explanation != null) ...[
            const SizedBox(height: AppSpace.s8),
            ExplanationPanel(body: q.explanation!, initiallyExpanded: true),
          ],
        ],
      ),
    );
  }
}
