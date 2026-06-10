class Account {
  final String email;
  final String apiKey;

  const Account({
    required this.email,
    required this.apiKey,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      email: json['email'] as String,
      apiKey: json['apiKey'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'apiKey': apiKey,
    };
  }
}
