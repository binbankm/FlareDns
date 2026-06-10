import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flare_dns/l10n/app_localizations.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/locale/locale_provider.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final accountAsync = ref.watch(authProvider);
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          // Account Section
          Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0, top: 8.0),
            child: Text(
              l10n.settingsSectionAccount,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 36,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: accountAsync.when(
                      data: (account) {
                        if (account == null) return Text(l10n.settingsNotLoggedIn);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.email,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              l10n.settingsCloudflareApiKey,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (err, stack) => Text(AppLocalizations.of(context).commonError(err.toString())),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Appearance Section
          Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              l10n.settingsSectionAppearance,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settingsTheme,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text(l10n.settingsThemeSystem),
                          icon: Icon(Icons.brightness_auto),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text(l10n.settingsThemeLight),
                          icon: Icon(Icons.light_mode),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text(l10n.settingsThemeDark),
                          icon: Icon(Icons.dark_mode),
                        ),
                      ],
                      selected: {themeMode},
                      onSelectionChanged: (Set<ThemeMode> newSelection) {
                        ref
                            .read(themeProvider.notifier)
                            .setThemeMode(newSelection.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Language Section
          Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              l10n.settingsSectionLanguage,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'system',
                      label: Text(l10n.settingsLanguageSystem),
                      icon: Icon(Icons.language),
                    ),
                    ButtonSegment(
                      value: 'zh',
                      label: Text(l10n.settingsLanguageChinese),
                      icon: Icon(Icons.translate),
                    ),
                    ButtonSegment(
                      value: 'en',
                      label: Text(l10n.settingsLanguageEnglish),
                      icon: Icon(Icons.abc),
                    ),
                  ],
                  selected: {
                    currentLocale == null
                        ? 'system'
                        : currentLocale.languageCode,
                  },
                  onSelectionChanged: (Set<String> newSelection) {
                    final code = newSelection.first;
                    ref.read(localeProvider.notifier).setLocale(
                      code == 'system' ? null : Locale(code),
                    );
                  },
                ),
              ),
            ),
          ),

          SizedBox(height: 24),

          // About Section
          Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              l10n.settingsSectionAbout,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text(l10n.settingsVersion),
                  trailing: Text(
                    '1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(Icons.code),
                  title: Text(l10n.settingsSourceCode),
                  trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.outline),
                  onTap: () {
                    // Open github link
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 32),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              ),
              icon: Icon(Icons.logout),
              label: Text(
                l10n.settingsLogout,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.settingsLogoutConfirmTitle),
                    content: Text(l10n.settingsLogoutConfirmContent),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.commonCancel),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          ref.read(authProvider.notifier).logout();
                        },
                        child: Text(l10n.settingsLogoutConfirm),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
