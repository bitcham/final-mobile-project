import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/router/app_router_provider.dart';
import 'src/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Missing .env is non-fatal: search surfaces a friendly message until
    // TheMovieDB keys are provided.
  }
  runApp(const ProviderScope(child: CinerateApp()));
}

class CinerateApp extends ConsumerWidget {
  const CinerateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return CupertinoApp.router(
      title: 'CINERATE',
      debugShowCheckedModeBanner: false,
      theme: cinerateCupertinoTheme,
      routerConfig: router,
    );
  }
}
