import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';

import 'core/theme/theme_provider.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(
    // ProviderScope is required for Riverpod
    const ProviderScope(child: FlareDnsApp()),
  );
}

class FlareDnsApp extends ConsumerWidget {
  const FlareDnsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'FlareDns',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
