class UserModel {
  final String id;
  final String name;
  final String email;

  UserModel({required this.id, required this.name, required this.email});

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'S';
  }

  factory UserModel.fromJson(Map<String, dynamic> j) =>
      UserModel(id: j['id'] ?? '', name: j['name'] ?? '', email: j['email'] ?? '');
}
