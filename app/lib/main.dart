import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/memory_repositories.dart';
import 'design/app_theme.dart';
import 'providers.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final content = await SeedContentRepo.load();
  final settings = MemorySettingsRepo();
  final initialClass = await settings.selectedClass();
  runApp(ProviderScope(
    overrides: [
      contentRepoProvider.overrideWithValue(content),
      settingsRepoProvider.overrideWithValue(settings),
      initialClassProvider.overrideWithValue(initialClass),
    ],
    child: const App(),
  ));
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Ôn thi GPLX', // placeholder until /replica-brand
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
