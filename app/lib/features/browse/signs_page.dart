// S12: the sign library. Chapter V questions grouped by subject, each opening
// the question with its picture, answer and explanation.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/app_theme.dart';
import '../../design/tokens.g.dart';
import '../../design/widgets.dart';
import '../../domain/models.dart';
import '../../providers.dart';
import '../common.dart';
import 'question_page.dart';

/// The group's questions that are in the current class's pool, in bank order.
List<Question> _inPool(WidgetRef ref, List<int> numbers) {
  final cls = ref.watch(currentClassProvider);
  final wanted = numbers.toSet();
  return [
    for (final q in ref.watch(contentRepoProvider).pool(cls.code))
      if (wanted.contains(q.number)) q,
  ];
}

class SignsPage extends ConsumerWidget {
  const SignsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(articlesProvider).signGroups;
    final cls = ref.watch(currentClassProvider);
    final c = context.colors;
    final rows = [
      for (final g in groups) (g, _inPool(ref, g.questionNumbers).length),
    ].where((r) => r.$2 > 0).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Biển báo')),
      body: rows.isEmpty
          ? const Center(
              child: EmptyState(
                icon: Icons.signpost_outlined,
                title: 'Chưa có biển báo nào',
                body: 'Bộ câu của hạng này không có câu biển báo.',
              ),
            )
          : PageBody(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.s12),
                  child: Text(
                    'Các câu biển báo và vạch kẻ đường trong bộ câu của '
                    '${cls.name}, xếp theo chủ đề.',
                    style: AppType.sm.copyWith(color: c.textMuted),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Column(
                    children: [
                      for (final (i, (g, count)) in rows.indexed) ...[
                        if (i > 0) const Divider(),
                        ListRow(
                          title: g.title,
                          subtitle: '$count câu · ${g.summary}',
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/signs/${g.id}'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class SignGroupPage extends ConsumerWidget {
  const SignGroupPage({super.key, required this.groupId});
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = ref.watch(articlesProvider).signGroup(groupId);
    final qs = g == null ? const <Question>[] : _inPool(ref, g.questionNumbers);
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(title: Text(g?.title ?? 'Biển báo')),
      body: qs.isEmpty
          ? const Center(
              child: EmptyState(
                icon: Icons.search_off,
                title: 'Không có câu nào',
                body:
                    'Nhóm này không có câu nào trong bộ câu của hạng bạn chọn.',
              ),
            )
          : PageBody(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.s12),
                  child: Text(
                    g!.summary,
                    style: AppType.sm.copyWith(color: c.textMuted),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Column(
                    children: [
                      for (final (i, q) in qs.indexed) ...[
                        if (i > 0) const Divider(),
                        QuestionRow(question: q),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
