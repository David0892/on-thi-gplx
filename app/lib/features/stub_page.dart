import 'package:flutter/material.dart';

import '../design/widgets.dart';

/// Placeholder for screens not built yet (should/could-haves).
class StubPage extends StatelessWidget {
  const StubPage({super.key, required this.title, required this.screenId});
  final String title;
  final String screenId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(
      child: EmptyState(
        icon: Icons.construction_outlined,
        title: 'Sắp có',
        body: 'Mục này đang được xây dựng ($screenId).',
      ),
    ),
  );
}
