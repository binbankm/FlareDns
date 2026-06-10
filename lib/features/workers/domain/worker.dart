class CloudflareWorker {
  final String id;
  final String createdOn;
  final String modifiedOn;
  final String usageModel;
  final String? compatibilityDate;
  final List<String> handlers;

  const CloudflareWorker({
    required this.id,
    required this.createdOn,
    required this.modifiedOn,
    required this.usageModel,
    this.compatibilityDate,
    required this.handlers,
  });

  factory CloudflareWorker.fromJson(Map<String, dynamic> json) {
    return CloudflareWorker(
      id: json['id'] as String,
      createdOn: json['created_on'] as String,
      modifiedOn: json['modified_on'] as String,
      usageModel: json['usage_model'] as String? ?? 'standard',
      compatibilityDate: json['compatibility_date'] as String?,
      handlers:
          (json['handlers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

class WorkerBinding {
  final String name;
  final String type;
  final String? detail;

  const WorkerBinding({required this.name, required this.type, this.detail});

  factory WorkerBinding.fromJson(Map<String, dynamic> json) {
    String? detail;
    if (json['type'] == 'd1') {
      detail = json['database_id']?.toString();
    } else if (json['type'] == 'kv_namespace') {
      detail = json['namespace_id']?.toString();
    } else if (json['type'] == 'plain_text') {
      detail = json['text']?.toString();
    } else if (json['type'] == 'r2_bucket') {
      detail = json['bucket_name']?.toString();
    } else if (json['type'] == 'analytics_engine') {
      detail = json['dataset']?.toString();
    } else if (json['type'] == 'queue') {
      detail = json['queue_name']?.toString();
    } else if (json['type'] == 'service') {
      detail = json['service']?.toString();
    } else {
      // Fallback for any other binding types
      final extraKeys = json.keys
          .where((k) => k != 'name' && k != 'type')
          .toList();
      if (extraKeys.isNotEmpty) {
        detail = extraKeys.map((k) => '$k: ${json[k]}').join(', ');
      }
    }

    return WorkerBinding(
      name: json['name'] as String,
      type: json['type'] as String,
      detail: detail,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'name': name, 'type': type};
    if (detail != null) {
      if (type == 'd1') {
        data['database_id'] = detail;
      } else if (type == 'kv_namespace') {
        data['namespace_id'] = detail;
      } else if (type == 'plain_text') {
        data['text'] = detail;
      } else if (type == 'r2_bucket') {
        data['bucket_name'] = detail;
      } else if (type == 'analytics_engine') {
        data['dataset'] = detail;
      } else if (type == 'queue') {
        data['queue_name'] = detail;
      } else if (type == 'service') {
        data['service'] = detail;
      } else {
        // Fallback: try to parse comma separated key: value string back
        try {
          final parts = detail!.split(', ');
          for (final p in parts) {
            final kv = p.split(': ');
            if (kv.length == 2) {
              data[kv[0]] = kv[1];
            }
          }
        } catch (_) {}
      }
    }
    return data;
  }
}

class WorkerSchedule {
  final String cron;
  final String createdOn;

  const WorkerSchedule({required this.cron, required this.createdOn});

  factory WorkerSchedule.fromJson(Map<String, dynamic> json) {
    return WorkerSchedule(
      cron: json['cron'] as String,
      createdOn: json['created_on'] as String,
    );
  }
}

class WorkerDeployment {
  final String id;
  final String versionId;
  final String source;
  final String authorEmail;
  final String createdOn;

  const WorkerDeployment({
    required this.id,
    required this.versionId,
    required this.source,
    required this.authorEmail,
    required this.createdOn,
  });

  factory WorkerDeployment.fromJson(Map<String, dynamic> json) {
    String vId = json['id'] as String;
    if (json['versions'] != null && (json['versions'] as List).isNotEmpty) {
      vId = json['versions'][0]['version_id'] as String? ?? vId;
    }

    return WorkerDeployment(
      id: json['id'] as String,
      versionId: vId,
      source: json['source'] as String? ?? 'unknown',
      authorEmail: json['author_email'] as String? ?? 'Unknown',
      createdOn: json['created_on'] as String,
    );
  }
}

class WorkerDomain {
  final String id;
  final String hostname;
  final String environment;
  final String service;

  const WorkerDomain({
    required this.id,
    required this.hostname,
    required this.environment,
    required this.service,
  });

  factory WorkerDomain.fromJson(Map<String, dynamic> json) {
    return WorkerDomain(
      id: json['id'] as String? ?? '',
      hostname: json['hostname'] as String,
      environment: json['environment'] as String? ?? 'production',
      service: json['service'] as String? ?? '',
    );
  }
}

class WorkerSecret {
  final String name;
  final String type;

  const WorkerSecret({required this.name, required this.type});

  factory WorkerSecret.fromJson(Map<String, dynamic> json) {
    return WorkerSecret(
      name: json['name'] as String,
      type: json['type'] as String? ?? 'secret_text',
    );
  }
}

class CloudflareKVNamespace {
  final String id;
  final String title;

  const CloudflareKVNamespace({required this.id, required this.title});

  factory CloudflareKVNamespace.fromJson(Map<String, dynamic> json) {
    return CloudflareKVNamespace(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }
}

class CloudflareD1Database {
  final String uuid;
  final String name;

  const CloudflareD1Database({required this.uuid, required this.name});

  factory CloudflareD1Database.fromJson(Map<String, dynamic> json) {
    return CloudflareD1Database(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
    );
  }
}
