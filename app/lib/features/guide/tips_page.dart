// S13: memorization tips. A list of short articles, each a set of points.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/app_theme.dart';
import '../../design/tokens.g.dart';
import '../../design/widgets.dart';
import '../../providers.dart';
import '../common.dart';

class TipsPage extends ConsumerWidget {
  const TipsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tips = ref.watch(articlesProvider).tips;
    return Scaffold(
      appBar: AppBar(title: const Text('Mẹo ghi nhớ')),
      body: tips.isEmpty
          ? const Center(
              child: EmptyState(
                icon: Icons.lightbulb_outline,
                title: 'Chưa có mẹo nào',
                body: 'Nội dung mẹo chưa được tải. Hãy mở lại ứng dụng.',
              ),
            )
          : PageBody(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Column(
                    children: [
                      for (final (i, t) in tips.indexed) ...[
                        if (i > 0) const Divider(),
                        ListRow(
                          title: t.title,
                          subtitle: t.summary,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/tips/${t.id}'),
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

class TipDetailPage extends ConsumerWidget {
  const TipDetailPage({super.key, required this.tipId});
  final String tipId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tip = ref.watch(articlesProvider).tip(tipId);
    if (tip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mẹo ghi nhớ')),
        body: const Center(
          child: EmptyState(
            icon: Icons.search_off,
            title: 'Không tìm thấy mẹo này',
            body: 'Có thể mẹo đã được đổi tên trong bản cập nhật.',
          ),
        ),
      );
    }
    final c = context.colors;
    final topics = ref.watch(contentRepoProvider).topics();
    final topic = topics.where((t) => t.id == tip.topicId).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(tip.title)),
      body: PageBody(
        children: [
          if (topic != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.s8),
              child: Text(
                'Chương: ${topic.name}',
                style: AppType.sm.copyWith(color: c.textMuted),
              ),
            ),
          Text(tip.summary, style: AppType.lg.copyWith(color: c.text)),
          const SizedBox(height: AppSpace.s16),
          for (final (i, p) in tip.points.indexed)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpace.s12),
              padding: const EdgeInsets.all(AppSpace.s16),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: c.accentSoft,
                      child: Text(
                        '${i + 1}',
                        style: AppType.sm.copyWith(color: c.accent),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpace.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.text,
                          style: AppType.base.copyWith(color: c.text),
                        ),
                        if (p.refs.isNotEmpty) ...[
                          const SizedBox(height: AppSpace.s8),
                          Text(
                            'Câu liên quan: ${p.refs.join(', ')}',
                            style: AppType.sm.copyWith(color: c.textMuted),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
