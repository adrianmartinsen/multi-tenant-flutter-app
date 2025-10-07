import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class FamilyModel extends Equatable {
  const FamilyModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String name;
  final DateTime createdAt;

  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    return FamilyModel(
      id: json[kId],
      name: json[kName],
      createdAt: DateTime.parse(json[kCreatedAt]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      kId: id,
      kName: name,
      kCreatedAt: createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, name, createdAt];
}

const String kId = 'id';
const String kName = 'name';
const String kCreatedAt = 'created_at';