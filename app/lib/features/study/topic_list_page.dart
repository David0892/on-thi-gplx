// S07: study by chapter, with progress per topic.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/tokens.g.dart';
import '../../design/widgets.dart';
import '../../providers.dart';
import '../common.dart';

class TopicListPage extends ConsumerWidget {
  const TopicListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentRepoProvider);
    final cls = ref.watch(currentClassProvider);
    final pool = content.pool(cls.code);
    final progress = ref.watch(progressProvider).value ?? const {};

    return Scaffold(
      appBar: AppBar(title: const Text('Ôn theo chủ đề')),
      body: PageBody(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Column(
              children: [
                for (final (i, t) in content.topics().indexed) ...[
                  if (i > 0) const Divider(),
                  () {
                    final inTopic = pool
                        .where((q) => q.topicId == t.id)
                        .toList();
                    final right = inTopic
                        .where((q) => progress[q.key]?.lastCorrect == true)
                        .length;
                    return ListRow(
                      title: t.name,
                      subtitle: '$right/${inTopic.length} câu đã trả lời đúng',
                      progress: inTopic.isEmpty ? 0 : right / inTopic.length,
                      onTap: inTopic.isEmpty
                          ? null
                          : () => context.push('/study/topic?topic=${t.id}'),
                    );
                  }(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
