// S14: questions about the exam and the app, as an accordion.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/articles.dart';
import '../../design/app_theme.dart';
import '../../design/tokens.g.dart';
import '../../design/widgets.dart';
import '../../providers.dart';
import '../common.dart';

class FaqPage extends ConsumerWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(articlesProvider).faq;
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(title: const Text('Hỏi đáp về kỳ thi')),
      body: groups.isEmpty
          ? const Center(
              child: EmptyState(
                icon: Icons.help_outline,
                title: 'Chưa có câu hỏi nào',
                body: 'Nội dung hỏi đáp chưa được tải. Hãy mở lại ứng dụng.',
              ),
            )
          : PageBody(
              children: [
                for (final g in groups) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpace.s8,
                      bottom: AppSpace.s8,
                    ),
                    child: Semantics(
                      header: true,
                      child: Text(
                        g.title,
                        style: AppType.sm.copyWith(color: c.textMuted),
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: Material(
                      color: c.bg,
                      child: Column(
                        children: [
                          for (final (i, item) in g.items.indexed) ...[
                            if (i > 0) const Divider(),
                            _FaqTile(item: item),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.s16),
                ],
              ],
            ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.item});
  final FaqItem item;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ExpansionTile(
      key: PageStorageKey(item.id),
      shape: const Border(),
      collapsedShape: const Border(),
      tilePadding: const EdgeInsets.symmetric(horizontal: AppSpace.s16),
      childrenPadding: const EdgeInsets.fromLTRB(
        AppSpace.s16,
        0,
        AppSpace.s16,
        AppSpace.s16,
      ),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      title: Text(item.question, style: AppType.base.copyWith(color: c.text)),
      children: [
        Text(item.answer, style: AppType.base.copyWith(color: c.textMuted)),
        if (item.widget == 'class_table') ...[
          const SizedBox(height: AppSpace.s12),
          const ClassRulesTable(),
        ],
      ],
    );
  }
}

/// Count, minutes and pass mark per class, straight from the bank's rules, so
/// the FAQ can never disagree with the exam the app generates.
class ClassRulesTable extends ConsumerWidget {
  const ClassRulesTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final classes = ref.watch(contentRepoProvider).classes();
    final anyUnverified = classes.any((k) => !k.rulesVerified);
    TextStyle head = AppType.sm.copyWith(
      color: c.textMuted,
      fontWeight: FontWeight.w600,
    );
    TextStyle cell = AppType.sm.copyWith(color: c.text);
    Widget pad(Widget w) => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.s8),
      child: w,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Table(
          columnWidths: const {0: FlexColumnWidth(1.2)},
          border: TableBorder(horizontalInside: BorderSide(color: c.border)),
          children: [
            TableRow(
              children: [
                for (final h in ['Hạng', 'Số câu', 'Thời gian', 'Đạt'])
                  pad(Text(h, style: head)),
              ],
            ),
            for (final k in classes)
              TableRow(
                children: [
                  pad(
                    Text(k.rulesVerified ? k.code : '${k.code}*', style: cell),
                  ),
                  pad(Text('${k.examQuestionCount}', style: cell)),
                  pad(Text('${k.examMinutes} phút', style: cell)),
                  pad(
                    Text('${k.passMark}/${k.examQuestionCount}', style: cell),
                  ),
                ],
              ),
          ],
        ),
        if (anyUnverified) ...[
          const SizedBox(height: AppSpace.s8),
          Text(
            '* Chưa tìm thấy văn bản xác nhận thời gian và điểm đạt; tạm lấy theo hạng D.',
            style: AppType.xs.copyWith(color: c.textMuted),
          ),
        ],
      ],
    );
  }
}
