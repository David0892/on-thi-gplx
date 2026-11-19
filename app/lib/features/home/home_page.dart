// S02: the hub. One tap on "Thi thử ngay" starts a random exam.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/app_theme.dart';
import '../../design/tokens.g.dart';
import '../../design/widgets.dart';
import '../../providers.dart';
import '../common.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final cls = ref.watch(currentClassProvider);
    final stats = ref.watch(homeStatsProvider).value;

    final tiles = [
      (Icons.assignment_outlined, 'Đề thi thử', null, '/exams'),
      (Icons.menu_book_outlined, 'Ôn theo chủ đề', null, '/topics'),
      (Icons.priority_high, 'Câu điểm liệt', null, '/study/critical'),
      (Icons.error_outline, 'Câu sai', stats?.wrong, '/study/wrong'),
      (Icons.bookmark_border, 'Câu đã lưu', stats?.saved, '/study/saved'),
      (Icons.signpost_outlined, 'Biển báo', null, '/signs'),
      (Icons.lightbulb_outline, 'Mẹo ghi nhớ', null, '/tips'),
      (Icons.help_outline, 'Hỏi đáp', null, '/faq'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ôn thi GPLX'),
        actions: [
          ClassChip(
            code: cls.code,
            onTap: () => context.push('/onboarding?change=1'),
          ),
          IconButton(
            tooltip: 'Cài đặt',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: PageBody(
        children: [
          const SampleNotice(),
          // In the body, not the app bar: at 320px and 200% text the bar has no room.
          Semantics(
            button: true,
            label: 'Tìm câu hỏi',
            excludeSemantics: true,
            child: Material(
              color: c.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: () => context.push('/search'),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AppLayout.tapTargetMin,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.s12,
                      vertical: AppSpace.s8,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: c.textMuted),
                        const SizedBox(width: AppSpace.s8),
                        Expanded(
                          child: Text(
                            'Tìm câu hỏi theo từ khóa hoặc số câu',
                            style: AppType.base.copyWith(color: c.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.s16),
          if (ref.watch(runningExamProvider).value case final running?) ...[
            Container(
              padding: const EdgeInsets.all(AppSpace.s12),
              decoration: BoxDecoration(
                color: c.accentSoft,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: c.accent),
              ),
              // Text and button stacked, so neither is squeezed at large text sizes.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pending_actions, color: c.accent),
                      const SizedBox(width: AppSpace.s12),
                      Expanded(
                        child: Text(
                          'Bạn có bài thi đang làm dở '
                          '(${running.answeredCount}/${running.questionCount} câu).',
                          style: AppType.sm.copyWith(color: c.text),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppButton(
                      label: 'Làm tiếp',
                      variant: AppButtonVariant.ghost,
                      onPressed: () => context.go('/exams/run/${running.id}'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.s16),
          ],
          Container(
            padding: const EdgeInsets.all(AppSpace.s16),
            decoration: BoxDecoration(
              color: c.bg,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                ProgressRing(value: stats?.masteredShare ?? 0),
                const SizedBox(width: AppSpace.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cls.name, style: AppType.lg.copyWith(color: c.text)),
                      Text(
                        '${cls.examQuestionCount} câu · ${cls.examMinutes} phút · đạt từ ${cls.passMark} câu',
                        style: AppType.sm.copyWith(color: c.textMuted),
                      ),
                      const SizedBox(height: AppSpace.s8),
                      Text(
                        stats == null || stats.examsTaken == 0
                            ? 'Chưa làm đề thi thử nào'
                            : 'Đã đạt ${stats.examsPassed}/${stats.examsTaken} đề thi thử',
                        style: AppType.sm.copyWith(color: c.text),
                      ),
                      Text(
                        '${stats?.mastered ?? 0}/${stats?.total ?? 0} câu đã trả lời đúng',
                        style: AppType.sm.copyWith(color: c.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.s16),
          AppButton(
            label: 'Thi thử ngay',
            icon: Icons.play_arrow_rounded,
            size: AppButtonSize.lg,
            expand: true,
            onPressed: () => startExam(context, ref),
          ),
          const SizedBox(height: AppSpace.s24),
          LayoutBuilder(
            builder: (context, box) {
              final cols = box.maxWidth >= 480 ? 4 : 2;
              final w = (box.maxWidth - AppSpace.s12 * (cols - 1)) / cols;
              return Wrap(
                spacing: AppSpace.s12,
                runSpacing: AppSpace.s12,
                children: [
                  for (final (icon, label, count, path) in tiles)
                    SizedBox(
                      width: w,
                      child: MenuTile(
                        icon: icon,
                        label: label,
                        count: count,
                        onTap: () => context.push(path),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
