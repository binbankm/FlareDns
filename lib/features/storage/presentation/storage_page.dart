import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flare_dns/l10n/app_localizations.dart';
import 'views/kv_list_view.dart';
import 'views/d1_list_view.dart';
import 'views/r2_list_view.dart';
import '../providers/storage_providers.dart';
import '../data/storage_repository.dart';

class StoragePage extends ConsumerStatefulWidget {
  const StoragePage({super.key});

  @override
  ConsumerState<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends ConsumerState<StoragePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateDialog() {
    final index = _tabController.index;
    final l10n = AppLocalizations.of(context);
    final title = index == 0
        ? l10n.storageCreateKV
        : (index == 1 ? l10n.storageCreateD1 : l10n.storageCreateR2);
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: l10n.storageCreateHint),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;

                final scaffoldMessenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);

                try {
                  final repo = ref.read(storageRepositoryProvider);
                  if (index == 0) {
                    await repo.createKVNamespace(name);
                    ref.invalidate(kvNamespacesProvider);
                  } else if (index == 1) {
                    await repo.createD1Database(name);
                    ref.invalidate(d1DatabasesProvider);
                  } else if (index == 2) {
                    await repo.createR2Bucket(name);
                    ref.invalidate(r2BucketsProvider);
                  }
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(l10n.storageCreateSuccess(title))),
                  );
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(l10n.commonError(e.toString()))),
                  );
                }
              },
              child: Text(l10n.commonCreate),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.storageTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'KV'),
            Tab(text: 'D1'),
            Tab(text: 'R2'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [KVListView(), D1ListView(), R2ListView()],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: _showCreateDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
