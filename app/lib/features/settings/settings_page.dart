// S15: class, reset, about + disclaimer, privacy.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/tokens.g.dart';
import '../../design/widgets.dart';
import '../../providers.dart';
import '../common.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cls = ref.watch(currentClassProvider);

    void info(String title, String body) => showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(child: Text(body)),
            actions: [AppButton(label: 'Đóng', onPressed: () => Navigator.pop(ctx))],
          ),
        );

    final rows = <Widget>[
      ListRow(
        leading: Icons.directions_car_outlined,
        title: 'Hạng đang ôn',
        subtitle: '${cls.name} · ${cls.description}',
        onTap: () => context.push('/onboarding?change=1'),
      ),
      ListRow(
        leading: Icons.restart_alt,
        title: 'Xoá tiến độ ${cls.name}',
        subtitle: 'Câu đã làm, câu sai và lịch sử ôn của hạng này',
        onTap: () async {
          final ok = await showConfirmDialog(
            context,
            title: 'Xoá tiến độ ${cls.name}?',
            body: 'Toàn bộ kết quả ôn tập của hạng này sẽ bị xoá và không khôi phục được. '
                'Câu đã lưu vẫn được giữ.',
            confirmLabel: 'Xoá tiến độ',
            destructive: true,
          );
          if (!ok) return;
          await ref.read(studyRepoProvider).reset(cls.code);
          ref.read(revisionProvider.notifier).bump();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xoá tiến độ')));
          }
        },
      ),
      ListRow(
        leading: Icons.info_outline,
        title: 'Giới thiệu',
        onTap: () => info(
          'Giới thiệu',
          'Ứng dụng hỗ trợ ôn tập lý thuyết sát hạch giấy phép lái xe. '
              'Đây KHÔNG phải sản phẩm của cơ quan nhà nước. Nội dung câu hỏi dựa trên bộ câu hỏi '
              'do Cục Cảnh sát giao thông công bố; phần giải thích do chúng tôi biên soạn.\n\n'
              'Kết quả trong app chỉ để tham khảo, không thay thế kỳ sát hạch chính thức.',
        ),
      ),
      ListRow(
        leading: Icons.privacy_tip_outlined,
        title: 'Quyền riêng tư',
        onTap: () => info(
          'Quyền riêng tư',
          'App không yêu cầu tài khoản và không thu thập dữ liệu cá nhân. '
              'Tiến độ ôn tập chỉ được lưu trên máy của bạn và bị xoá khi bạn gỡ app.',
        ),
      ),
      if (kDebugMode || kIsWeb)
        ListRow(
          leading: Icons.palette_outlined,
          title: 'Thư viện giao diện (dành cho nhà phát triển)',
          onTap: () => context.push('/design'),
        ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: PageBody(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Column(
              children: [
                for (final (i, r) in rows.indexed) ...[if (i > 0) const Divider(), r],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
