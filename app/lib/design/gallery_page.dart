// The /design route: every primitive in every state, for visual review.
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'tokens.g.dart';
import 'widgets.dart';

/// Self-contained: owns its light/dark toggle so it works as a plain route.
class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  bool _dark = false;

  @override
  Widget build(BuildContext context) => Theme(
    data: _dark ? AppTheme.dark() : AppTheme.light(),
    child: _GalleryBody(
      dark: _dark,
      onToggleDark: () => setState(() => _dark = !_dark),
    ),
  );
}

class _GalleryBody extends StatefulWidget {
  const _GalleryBody({required this.dark, required this.onToggleDark});
  final bool dark;
  final VoidCallback onToggleDark;

  @override
  State<_GalleryBody> createState() => _GalleryBodyState();
}

class _GalleryBodyState extends State<_GalleryBody> {
  String _class = 'A1';
  int? _picked;
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design system'),
        actions: [
          const CountdownPill(remaining: Duration(minutes: 12, seconds: 30)),
          IconButton(
            tooltip: widget.dark ? 'Giao diện sáng' : 'Giao diện tối',
            onPressed: widget.onToggleDark,
            icon: Icon(widget.dark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppLayout.maxContentWidth,
          ),
          child: ListView(
            padding: const EdgeInsets.all(AppLayout.gutter),
            children: [
              _section('Colour roles'),
              Wrap(
                spacing: AppSpace.s8,
                runSpacing: AppSpace.s8,
                children: [
                  for (final (name, col) in [
                    ('bg', c.bg),
                    ('surface', c.surface),
                    ('border', c.border),
                    ('border-input', c.borderInput),
                    ('text', c.text),
                    ('text-muted', c.textMuted),
                    ('accent', c.accent),
                    ('accent-soft', c.accentSoft),
                    ('danger', c.danger),
                    ('danger-soft', c.dangerSoft),
                    ('success', c.success),
                    ('success-soft', c.successSoft),
                    ('warning', c.warning),
                    ('warning-soft', c.warningSoft),
                  ])
                    _swatch(name, col),
                ],
              ),
              _section('Type'),
              Text(
                'Display 23/25',
                style: AppType.display.copyWith(color: c.text),
              ),
              Text(
                'XL Ôn thi bằng lái',
                style: AppType.xl.copyWith(color: c.text),
              ),
              Text(
                'LG Kết quả bài thi',
                style: AppType.lg.copyWith(color: c.text),
              ),
              Text(
                'Question: Người điều khiển xe mô tô phải làm gì khi gặp biển báo này?',
                style: AppType.question.copyWith(color: c.text),
              ),
              Text(
                'Base: Giải thích chi tiết từng đáp án.',
                style: AppType.base.copyWith(color: c.text),
              ),
              Text(
                'SM muted: 250 câu · 19 phút',
                style: AppType.sm.copyWith(color: c.textMuted),
              ),
              Text(
                'XS Câu 12/25',
                style: AppType.xs.copyWith(color: c.textMuted),
              ),

              _section('AppButton'),
              Wrap(
                spacing: AppSpace.s8,
                runSpacing: AppSpace.s8,
                children: [
                  AppButton(
                    label: 'Thi ngẫu nhiên',
                    icon: Icons.shuffle,
                    onPressed: () {},
                  ),
                  AppButton(
                    label: 'Xem lại',
                    variant: AppButtonVariant.secondary,
                    onPressed: () {},
                  ),
                  AppButton(
                    label: 'Bỏ qua',
                    variant: AppButtonVariant.ghost,
                    onPressed: () {},
                  ),
                  AppButton(
                    label: 'Xoá tiến độ',
                    variant: AppButtonVariant.danger,
                    onPressed: () {},
                  ),
                  const AppButton(label: 'Đã khoá', onPressed: null),
                  AppButton(label: 'Đang nộp', loading: true, onPressed: () {}),
                ],
              ),
              const SizedBox(height: AppSpace.s8),
              AppButton(
                label: 'Nộp bài',
                size: AppButtonSize.lg,
                expand: true,
                onPressed: () => showConfirmDialog(
                  context,
                  title: 'Nộp bài?',
                  body: 'Bạn còn 3 câu chưa trả lời. Câu chưa trả lời tính là sai.',
                  confirmLabel: 'Nộp bài',
                ),
              ),

              _section('ClassCard / ClassChip'),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpace.s12,
                crossAxisSpacing: AppSpace.s12,
                childAspectRatio: 1.6,
                children: [
                  for (final (code, d) in [
                    ('A1', 'Xe máy đến 125 cm³'),
                    ('B', 'Ô tô đến 8 chỗ'),
                  ])
                    ClassCard(
                      code: code,
                      description: d,
                      selected: _class == code,
                      onTap: () => setState(() => _class = code),
                    ),
                ],
              ),
              const SizedBox(height: AppSpace.s8),
              Align(
                alignment: Alignment.centerLeft,
                child: ClassChip(code: _class, onTap: () {}),
              ),

              _section('MenuTile + ProgressRing'),
              Row(
                children: [
                  const ProgressRing(value: 0.45),
                  const SizedBox(width: AppSpace.s16),
                  const ProgressRing(value: 1),
                  const SizedBox(width: AppSpace.s16),
                  Expanded(
                    child: MenuTile(
                      icon: Icons.error_outline,
                      label: 'Câu sai',
                      count: 12,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.s12),
              Row(
                children: [
                  Expanded(
                    child: MenuTile(
                      icon: Icons.assignment_outlined,
                      label: 'Thi thử',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpace.s12),
                  const Expanded(
                    child: MenuTile(
                      icon: Icons.bookmark_border,
                      label: 'Câu đã lưu',
                    ),
                  ),
                ],
              ),

              _section('QuestionCard + AnswerOption (exam, tap to select)'),
              QuestionCard(
                index: 12,
                total: 25,
                critical: true,
                text: 'Khi điều khiển xe chạy trên đường, người lái xe có được sử dụng rượu bia không?',
                trailing: BookmarkToggle(
                  on: _saved,
                  onChanged: (v) => setState(() => _saved = v),
                ),
              ),
              const SizedBox(height: AppSpace.s12),
              for (final (i, t) in [
                (1, 'Được, nếu nồng độ thấp.'),
                (2, 'Không được.'),
                (3, 'Chỉ được khi đi đường ngắn.'),
              ]) ...[
                AnswerOption(
                  position: i,
                  text: t,
                  state: _picked == i ? AnswerState.selected : AnswerState.idle,
                  onTap: () => setState(() => _picked = i),
                ),
                const SizedBox(height: AppSpace.s8),
              ],

              _section('AnswerOption (revealed states)'),
              const AnswerOption(
                position: 1,
                text: 'Đáp án người học chọn, sai',
                state: AnswerState.wrong,
              ),
              const SizedBox(height: AppSpace.s8),
              const AnswerOption(
                position: 2,
                text: 'Đáp án đúng nhưng không được chọn',
                state: AnswerState.missed,
              ),
              const SizedBox(height: AppSpace.s8),
              const AnswerOption(
                position: 3,
                text: 'Đáp án đúng và được chọn',
                state: AnswerState.correct,
              ),
              const SizedBox(height: AppSpace.s12),
              const ExplanationPanel(
                body:
                    'Người điều khiển phương tiện không được có nồng độ cồn trong máu hoặc hơi thở. '
                    'Đây là câu điểm liệt: trả lời sai là trượt cả bài.',
              ),

              _section('QuestionGrid'),
              Wrap(
                spacing: AppSpace.s8,
                runSpacing: AppSpace.s8,
                children: [
                  for (var n = 1; n <= 10; n++)
                    QuestionGridCell(
                      number: n,
                      current: n == 4,
                      critical: n == 7,
                      state: switch (n % 4) {
                        0 => GridCellState.unanswered,
                        1 => GridCellState.answered,
                        2 => GridCellState.correct,
                        _ => GridCellState.wrong,
                      },
                      onTap: () {},
                    ),
                ],
              ),

              _section('CountdownPill'),
              const Wrap(
                spacing: AppSpace.s8,
                children: [
                  CountdownPill(remaining: Duration(minutes: 18, seconds: 5)),
                  CountdownPill(remaining: Duration(seconds: 42)),
                  CountdownPill(remaining: Duration.zero),
                ],
              ),

              _section('ResultBanner'),
              const ResultBanner(
                kind: ResultKind.pass,
                score: 23,
                total: 25,
                passMark: 21,
                timeUsed: '11:42',
              ),
              const SizedBox(height: AppSpace.s12),
              const ResultBanner(
                kind: ResultKind.failScore,
                score: 19,
                total: 25,
                passMark: 21,
                timeUsed: '19:00',
              ),
              const SizedBox(height: AppSpace.s12),
              const ResultBanner(
                kind: ResultKind.failCritical,
                score: 24,
                total: 25,
                passMark: 21,
                timeUsed: '09:15',
                criticalNumber: 34,
              ),

              _section('ListRow'),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Column(
                  children: [
                    ListRow(
                      title: 'Quy định chung và quy tắc giao thông',
                      subtitle: '90 câu',
                      progress: 0.6,
                      onTap: () {},
                    ),
                    const Divider(),
                    ListRow(
                      title: 'Biển báo đường bộ',
                      subtitle: '65 câu',
                      progress: 1,
                      onTap: () {},
                    ),
                    const Divider(),
                    ListRow(
                      title: 'Xoá tiến độ',
                      leading: Icons.delete_outline,
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              _section('EmptyState'),
              Container(
                decoration: BoxDecoration(
                  color: c.bg,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: EmptyState(
                  icon: Icons.task_alt,
                  title: 'Chưa có câu sai nào',
                  body: 'Làm một đề thi thử để bắt đầu. Câu nào bạn trả lời sai sẽ hiện ở đây.',
                  action: AppButton(label: 'Thi thử ngay', onPressed: () {}),
                ),
              ),
              const SizedBox(height: AppSpace.s48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: AppSpace.s32, bottom: AppSpace.s12),
    child: Text(title, style: AppType.lg.copyWith(color: context.colors.text)),
  );

  Widget _swatch(String name, Color col) {
    final c = context.colors;
    return SizedBox(
      width: 84,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: col,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: c.border),
            ),
          ),
          Text(name, style: AppType.xs.copyWith(color: c.textMuted)),
        ],
      ),
    );
  }
}
