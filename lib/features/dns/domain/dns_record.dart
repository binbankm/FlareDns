class DnsRecord {
  final String id;
  final String type;
  final String name;
  final String content;
  final bool proxied;
  final int ttl;
  final int? priority;

  const DnsRecord({
    required this.id,
    required this.type,
    required this.name,
    required this.content,
    required this.proxied,
    required this.ttl,
    this.priority,
  });

  factory DnsRecord.fromJson(Map<String, dynamic> json) {
    return DnsRecord(
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      content: json['content'] as String,
      proxied: json['proxied'] as bool? ?? false,
      ttl: json['ttl'] as int? ?? 1,
      priority: json['priority'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'type': type,
      'name': name,
      'content': content,
      'proxied': proxied,
      'ttl': ttl,
    };
    if (priority != null) {
      map['priority'] = priority;
    }
    return map;
  }
}
