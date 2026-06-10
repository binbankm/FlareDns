class Zone {
  final String id;
  final String name;
  final String status;
  final String? planName;
  final List<String> nameServers;

  const Zone({
    required this.id,
    required this.name,
    required this.status,
    this.planName,
    this.nameServers = const [],
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      planName: json['plan']?['name'] as String?,
      nameServers: (json['name_servers'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}
