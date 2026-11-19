import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/articles.dart';
import 'data/db/open_db.dart';
import 'data/memory_repositories.dart';
import 'data/sql_repositories.dart';
import 'design/app_theme.dart';
import 'providers.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final content = await SeedContentRepo.load();
  final articles = await Articles.load();
  final userDb = await openUserDb();
  if (userDb != null) await reconcileWithContent(userDb, content);
  final container = ProviderContainer(
    overrides: [
      contentRepoProvider.overrideWithValue(content),
      userDbProvider.overrideWithValue(userDb),
    ],
  );
  // Read before the first frame so the router redirect never sees a loading state.
  final initialClass = await container
      .read(settingsRepoProvider)
      .selectedClass();
  container.dispose();
  runApp(
    ProviderScope(
      overrides: [
        contentRepoProvider.overrideWithValue(content),
        userDbProvider.overrideWithValue(userDb),
        initialClassProvider.overrideWithValue(initialClass),
        articlesProvider.overrideWithValue(articles),
      ],
      child: const App(),
    ),
  );
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
