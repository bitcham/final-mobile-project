import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/router/app_router_provider.dart';
import 'src/core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
