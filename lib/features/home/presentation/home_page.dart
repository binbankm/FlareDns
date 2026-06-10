import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flare_dns/l10n/app_localizations.dart';
import '../../zones/presentation/zones_list_page.dart';
import '../../workers/presentation/workers_list_page.dart';
import '../../pages/presentation/pages_list_page.dart';
import '../../storage/presentation/storage_page.dart';
import '../../settings/presentation/settings_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ZonesListPage(),
    const WorkersListPage(),
    const PagesListPage(),
    const StoragePage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.public_outlined),
            selectedIcon: Icon(Icons.public),
            label: l10n.navDomains,
          ),
          NavigationDestination(
            icon: Icon(Icons.bolt_outlined),
            selectedIcon: Icon(Icons.bolt),
            label: l10n.navWorkers,
          ),
          NavigationDestination(
            icon: Icon(Icons.web_outlined),
            selectedIcon: Icon(Icons.web),
            label: l10n.navPages,
          ),
          NavigationDestination(
            icon: Icon(Icons.storage_outlined),
            selectedIcon: Icon(Icons.storage),
            label: l10n.navStorage,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
