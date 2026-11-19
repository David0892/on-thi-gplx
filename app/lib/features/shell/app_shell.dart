// The four main tabs: Tổng quan, Ôn tập, Luyện thi, Cài đặt. Everything else
// (a study session, an exam, a question) opens full screen above the tabs.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/app_theme.dart';
import '../../design/tokens.g.dart';
import '../../design/widgets.dart';
import '../../providers.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  static const tabs = [
    (Icons.home_outlined, Icons.home, 'Tổng quan'),
    (Icons.menu_book_outlined, Icons.menu_book, 'Ôn tập'),
    (Icons.assignment_outlined, Icons.assignment, 'Luyện thi'),
    (Icons.settings_outlined, Icons.settings, 'Cài đặt'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: shell,
    bottomNavigationBar: MediaQuery.withClampedTextScaling(
      // Four labels must fit side by side on a 320px phone.
      maxScaleFactor: 1.3,
      child: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          for (final (icon, selected, label) in tabs)
            NavigationDestination(
              icon: Icon(icon),
              selectedIcon: Icon(selected),
              label: label,
            ),
        ],
      ),
    ),
  );
}

/// The app bar every tab uses: the tab's name and, except on settings, the
/// class chip to switch class.
class TabAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const TabAppBar({super.key, required this.title, this.showClass = true});
  final String title;
  final bool showClass;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cls = ref.watch(currentClassProvider);
    final c = context.colors;
    // The tabs get a filled bar in the accent colour; screens opened above
    // them keep the plain bar, so it is clear which level you are on.
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: false,
      backgroundColor: c.accent,
      foregroundColor: c.onAccent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppType.lg.copyWith(
        color: c.onAccent,
        fontWeight: FontWeight.w700,
      ),
      actions: [
        if (showClass)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClassChip(
              code: cls.code,
              onTap: () => context.push('/onboarding?change=1'),
            ),
          ),
      ],
    );
  }
}
