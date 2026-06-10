import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flare_dns/l10n/app_localizations.dart';
import '../providers/pages_provider.dart';
import '../domain/page.dart';

class PagesListPage extends ConsumerStatefulWidget {
  const PagesListPage({super.key});

  @override
  ConsumerState<PagesListPage> createState() => _PagesListPageState();
}

class _PagesListPageState extends ConsumerState<PagesListPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final pagesAsync = ref.watch(pagesProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pagesTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => ref.invalidate(pagesProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l10n.pagesSearch,
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (val) =>
                      setState(() => _searchQuery = val.trim().toLowerCase()),
                ),
              ),
            ),
          ),
          Expanded(
            child: pagesAsync.when(
              data: (pages) {
                if (pages.isEmpty) {
                  return Center(child: Text(l10n.pagesEmpty));
                }
                final filtered = pages
                    .where((p) => p.name.toLowerCase().contains(_searchQuery))
                    .toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(l10n.pagesNoMatch),
                  );
                }
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) => _PageCard(page: filtered[i]),
                    ),
                  ),
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text(AppLocalizations.of(context).commonError(e.toString()))),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageCard extends StatelessWidget {
  final CloudflarePage page;
  const _PageCard({required this.page});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isGithub = page.source == 'github';
    final isGitlab = page.source == 'gitlab';
    final sourceColor = isGithub
        ? colorScheme.primary
        : isGitlab
        ? colorScheme.tertiary
        : colorScheme.secondary;
    final sourceIcon = isGithub
        ? Icons.code
        : isGitlab
        ? Icons.merge_type
        : Icons.web;
    final sourceLabel = isGithub
        ? 'GitHub'
        : isGitlab
        ? 'GitLab'
        : 'Direct';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/page/${page.name}', extra: page),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: sourceColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(sourceIcon, color: sourceColor, size: 22),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      page.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      page.subdomain,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        _InfoChip(
                          icon: sourceIcon,
                          label: sourceLabel,
                          color: sourceColor,
                        ),
                        _InfoChip(
                          icon: Icons.call_split,
                          label: page.productionBranch,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.outline, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
