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
  final String? createdAt;

  const CloudflareD1Database({
    required this.uuid,
    required this.name,
    this.createdAt,
  });

  factory CloudflareD1Database.fromJson(Map<String, dynamic> json) {
    return CloudflareD1Database(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      createdAt: json['created_at'] as String?,
    );
  }
}

class CloudflareR2Bucket {
  final String name;
  final String? creationDate;

  const CloudflareR2Bucket({required this.name, this.creationDate});

  factory CloudflareR2Bucket.fromJson(Map<String, dynamic> json) {
    return CloudflareR2Bucket(
      name: json['name'] as String,
      creationDate: json['creation_date'] as String?,
    );
  }
}
