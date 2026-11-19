// S01: pick the licence class. Also reached from home/settings to change class.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/app_theme.dart';
import '../../design/tokens.g.dart';
import '../../design/widgets.dart';
import '../../providers.dart';
import '../common.dart';

const _groups = {
  'moto': 'Xe mô tô',
  'car': 'Ô tô con, xe tải nhỏ',
  'truck': 'Xe tải',
  'bus': 'Xe khách',
  'trailer': 'Xe kéo rơ moóc',
};

class ClassPickerPage extends ConsumerStatefulWidget {
  const ClassPickerPage({super.key, this.changing = false});
  final bool changing;

  @override
  ConsumerState<ClassPickerPage> createState() => _ClassPickerPageState();
}

class _ClassPickerPageState extends ConsumerState<ClassPickerPage> {
  String? _picked;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final classes = ref.watch(contentRepoProvider).classes();
    _picked ??= ref.watch(selectedClassProvider);

    return Scaffold(
      appBar: widget.changing ? AppBar(title: const Text('Đổi hạng bằng')) : null,
      body: SafeArea(
        child: PageBody(
          children: [
            if (!widget.changing) ...[
              const SizedBox(height: AppSpace.s24),
              Text('Bạn đang ôn thi bằng hạng nào?', style: AppType.xl.copyWith(color: c.text)),
              const SizedBox(height: AppSpace.s8),
              Text(
                'Mỗi hạng có số câu, thời gian và điểm đạt khác nhau. Bạn có thể đổi lại bất cứ lúc nào.',
                style: AppType.base.copyWith(color: c.textMuted),
              ),
            ],
            for (final MapEntry(key: group, value: label) in _groups.entries) ...[
              Padding(
                padding: const EdgeInsets.only(top: AppSpace.s24, bottom: AppSpace.s12),
                child: Semantics(
                  header: true,
                  child: Text(label, style: AppType.sm.copyWith(fontWeight: FontWeight.w600, color: c.textMuted)),
                ),
              ),
              LayoutBuilder(
                builder: (context, box) {
                  final cols = box.maxWidth >= 480 ? 3 : 2;
                  final w = (box.maxWidth - AppSpace.s12 * (cols - 1)) / cols;
                  return Wrap(
                    spacing: AppSpace.s12,
                    runSpacing: AppSpace.s12,
                    children: [
                      for (final cls in classes.where((x) => x.group == group))
                        SizedBox(
                          width: w,
                          child: ClassCard(
                            code: cls.code,
                            description: cls.description,
                            selected: _picked == cls.code,
                            onTap: () => setState(() => _picked = cls.code),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
            const SizedBox(height: 96),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppLayout.gutter),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
              child: AppButton(
                label: _picked == null ? 'Chọn một hạng để tiếp tục' : 'Ôn thi hạng $_picked',
                size: AppButtonSize.lg,
                expand: true,
                onPressed: _picked == null
                    ? null
                    : () async {
                        await ref.read(selectedClassProvider.notifier).set(_picked!);
                        ref.read(revisionProvider.notifier).bump();
                        if (context.mounted) context.go('/');
                      },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
