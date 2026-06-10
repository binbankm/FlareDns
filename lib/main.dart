import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/locale/locale_provider.dart';
import 'package:flare_dns/l10n/app_localizations.dart';

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
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'FlareDns',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
      ],
    );
  }
}
