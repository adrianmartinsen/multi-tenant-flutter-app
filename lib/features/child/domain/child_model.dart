import 'package:equatable/equatable.dart';

class Child extends Equatable {
  final String id;
  final String familyId;
  final String name;
  final double balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Child({
    required this.id,
    required this.familyId,
    required this.name,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating from database JSON
  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'],
      familyId: json['family_id'],
      name: json['name'],
      balance: json['balance'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Convert to JSON for database insert/update
  // Note: Do not include 'id' for inserts - let Supabase generate it
  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'family_id': familyId,
      'name': name,
      'balance': balance,
      'updated_at': updatedAt.toIso8601String(),
    };
    return json;
  }

  // Validation method
  bool isValid() {
    if (id.isEmpty) return false;
    if (familyId.trim().isEmpty) return false;
    if (name.trim().isEmpty) return false;
    return true;
  }

  // Copy with method for immutability
  Child copyWith({
    String? familyId,
    String? name,
    double? balance,
    DateTime? updatedAt,
  }) {
    return Child(
      id: id,
      familyId: familyId ?? this.familyId,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    familyId,
    name,
    balance,
    createdAt,
    updatedAt,
  ];
}
