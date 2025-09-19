class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? familyId;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.familyId,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      displayName: json['display_name'],
      familyId: json['family_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'family_id': familyId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper method to check if user has a family
  bool get hasFamily => familyId != null;
}
