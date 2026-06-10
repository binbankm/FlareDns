class CloudflarePage {
  final String id;
  final String name;
  final String subdomain;
  final String source;
  final String createdOn;
  final String productionBranch;
  final Map<String, dynamic> productionEnvVars;
  final Map<String, dynamic> kvNamespaces;
  final Map<String, dynamic> d1Databases;
  final Map<String, dynamic> r2Buckets;
  final Map<String, dynamic> serviceBindings;

  const CloudflarePage({
    required this.id,
    required this.name,
    required this.subdomain,
    required this.source,
    required this.createdOn,
    required this.productionBranch,
    this.productionEnvVars = const {},
    this.kvNamespaces = const {},
    this.d1Databases = const {},
    this.r2Buckets = const {},
    this.serviceBindings = const {},
  });

  factory CloudflarePage.fromJson(Map<String, dynamic> json) {
    final prod =
        (json['deployment_configs'] as Map<String, dynamic>?)?['production']
            as Map<String, dynamic>? ??
        {};
    return CloudflarePage(
      id: json['id'] as String,
      name: json['name'] as String,
      subdomain: json['subdomain'] as String? ?? '',
      source: (json['source'] != null && json['source']['type'] != null)
          ? json['source']['type'] as String
          : 'direct',
      createdOn: json['created_on'] as String,
      productionBranch: json['production_branch'] as String? ?? 'main',
      productionEnvVars: prod['env_vars'] as Map<String, dynamic>? ?? {},
      kvNamespaces: prod['kv_namespaces'] as Map<String, dynamic>? ?? {},
      d1Databases: prod['d1_databases'] as Map<String, dynamic>? ?? {},
      r2Buckets: prod['r2_buckets'] as Map<String, dynamic>? ?? {},
      serviceBindings: prod['services'] as Map<String, dynamic>? ?? {},
    );
  }
}

class PageDeployment {
  final String id;
  final String shortId;
  final String environment;
  final String url;
  final String createdOn;
  final String status;
  final String commitHash;
  final String commitMessage;
  final String branch;

  const PageDeployment({
    required this.id,
    required this.shortId,
    required this.environment,
    required this.url,
    required this.createdOn,
    required this.status,
    required this.commitHash,
    required this.commitMessage,
    required this.branch,
  });

  factory PageDeployment.fromJson(Map<String, dynamic> json) {
    String status = 'unknown';
    if (json['latest_stage'] != null &&
        json['latest_stage']['status'] != null) {
      status = json['latest_stage']['status'] as String;
    }

    String commitHash = '';
    String commitMessage = '';
    String branch = '';
    final trigger = json['deployment_trigger'] as Map<String, dynamic>?;
    if (trigger != null) {
      final meta = trigger['metadata'] as Map<String, dynamic>?;
      if (meta != null) {
        commitHash = (meta['commit_hash'] as String? ?? '').length > 7
            ? (meta['commit_hash'] as String).substring(0, 7)
            : (meta['commit_hash'] as String? ?? '');
        commitMessage = (meta['commit_message'] as String? ?? '')
            .split('\n')
            .first;
        branch = meta['branch'] as String? ?? '';
      }
    }

    return PageDeployment(
      id: json['id'] as String,
      shortId:
          json['short_id'] as String? ?? json['id'].toString().substring(0, 8),
      environment: json['environment'] as String? ?? 'unknown',
      url: json['url'] as String? ?? '',
      createdOn: json['created_on'] as String,
      status: status,
      commitHash: commitHash,
      commitMessage: commitMessage,
      branch: branch,
    );
  }
}

class PageDomain {
  final String id;
  final String name;
  final String status;

  const PageDomain({
    required this.id,
    required this.name,
    required this.status,
  });

  factory PageDomain.fromJson(Map<String, dynamic> json) {
    return PageDomain(
      id: json['id'] as String? ?? json['name'] as String,
      name: json['name'] as String,
      status: json['status'] as String? ?? 'unknown',
    );
  }
}
