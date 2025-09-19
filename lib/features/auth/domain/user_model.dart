import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.familyId,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? familyId;
  final DateTime createdAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json[kId],
      email: json[kEmail],
      displayName: json[kDisplayName],
      familyId: json[kFamilyId],
      createdAt: DateTime.parse(json[kCreatedAt]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      kId: id,
      kEmail: email,
      kDisplayName: displayName,
      kFamilyId: familyId,
      kCreatedAt: createdAt.toIso8601String(),
    };
  }

  bool get hasFamily => familyId != null;

  @override
  List<Object?> get props => [id, email, displayName, familyId, createdAt];
}

const String kId = 'id';
const String kEmail = 'email';
const String kDisplayName = 'display_name';
const String kFamilyId = 'family_id';
const String kCreatedAt = 'created_at';