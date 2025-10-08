import 'package:equatable/equatable.dart';

enum AllowanceFrequency {
  weekly,
  monthly;

  String toJson() => name;
  static AllowanceFrequency fromJson(String json) => values.byName(json);
}

class Child extends Equatable {
  final String id;
  final String familyId;
  final String name;
  final int? age;
  final double allowanceAmount;
  final AllowanceFrequency? allowanceFrequency;
  final int? allowanceDay;
  final bool allowanceEnabled;
  final DateTime? nextAllowanceDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Child({
    required this.id,
    required this.familyId,
    required this.name,
    this.age,
    required this.allowanceAmount,
    this.allowanceFrequency,
    this.allowanceDay,
    required this.allowanceEnabled,
    this.nextAllowanceDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating from database JSON
  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'],
      familyId: json['family_id'],
      name: json['name'],
      age: json['age'],
      allowanceAmount: (json['allowance_amount'] as num).toDouble(),
      allowanceFrequency: json['allowance_frequency'] != null
          ? AllowanceFrequency.values.firstWhere(
              (e) =>
                  e.toString().split('.').last == json['allowance_frequency'],
            )
          : null,
      allowanceDay: json['allowance_day'],
      allowanceEnabled: json['allowance_enabled'],
      nextAllowanceDate: json['next_allowance_date'] != null
          ? DateTime.parse(json['next_allowance_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Convert to JSON for database insert/update
  // Note: Do not include 'id' for inserts - let Supabase generate it
  Map<String, dynamic> toJson({bool includeId = false}) {
    final json = {
      'family_id': familyId,
      'name': name,
      'age': age,
      'allowance_amount': allowanceAmount,
      'allowance_frequency': allowanceFrequency?.toString().split('.').last,
      'allowance_day': allowanceDay,
      'allowance_enabled': allowanceEnabled,
      'next_allowance_date': nextAllowanceDate?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    if (includeId) {
      json['id'] = id;
    }

    return json;
  }

  // Convert to JSON for insert (excludes id, created_at, updated_at - let DB handle these)
  Map<String, dynamic> toInsertJson() {
    return {
      'family_id': familyId,
      'name': name,
      'age': age,
      'allowance_amount': allowanceAmount,
      'allowance_frequency': allowanceFrequency?.toString().split('.').last,
      'allowance_day': allowanceDay,
      'allowance_enabled': allowanceEnabled,
      'next_allowance_date': nextAllowanceDate?.toIso8601String(),
      'is_deleted': false,
    };
  }

  // Convert to JSON for update (only include fields that should be updated)
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'age': age,
      'allowance_amount': allowanceAmount,
      'allowance_frequency': allowanceFrequency?.toString().split('.').last,
      'allowance_day': allowanceDay,
      'allowance_enabled': allowanceEnabled,
      'next_allowance_date': nextAllowanceDate?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Validation method
  bool isValid() {
    if (familyId.trim().isEmpty) return false;
    if (name.trim().isEmpty) return false;
    if (allowanceAmount < 0) return false;
    if (allowanceDay != null) {
      // See _getDayName in child_form.dart for reference
      if (allowanceFrequency == AllowanceFrequency.weekly &&
          (allowanceDay! < 0 || allowanceDay! > 7)) {
        return false;
      }
      if (allowanceFrequency == AllowanceFrequency.monthly &&
          (allowanceDay! < 1 || allowanceDay! > 31)) {
        return false;
      }
    }
    return true;
  }

  // Helper method to calculate next allowance date
  static DateTime? calculateNextAllowanceDate(
    AllowanceFrequency? frequency,
    int? day,
  ) {
    if (frequency == null || day == null) return null;

    final now = DateTime.now();
    DateTime nextDate;

    switch (frequency) {
      case AllowanceFrequency.weekly:
        final currentWeekday = now.weekday % 7; // 0-6 where 0 is Sunday
        final daysUntilNext = (day - currentWeekday + 7) % 7;
        nextDate = now.add(Duration(days: daysUntilNext));
        break;
      case AllowanceFrequency.monthly:
        if (now.day >= day) {
          // Move to next month
          nextDate = DateTime(now.year, now.month + 1, day);
        } else {
          nextDate = DateTime(now.year, now.month, day);
        }
        break;
    }

    return DateTime(nextDate.year, nextDate.month, nextDate.day);
  }

  // Copy with method for immutability
  Child copyWith({
    String? familyId,
    String? name,
    int? age,
    double? allowanceAmount,
    AllowanceFrequency? allowanceFrequency,
    int? allowanceDay,
    bool? allowanceEnabled,
    DateTime? nextAllowanceDate,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Child(
      id: id,
      familyId: familyId ?? this.familyId,
      name: name ?? this.name,
      age: age ?? this.age,
      allowanceAmount: allowanceAmount ?? this.allowanceAmount,
      allowanceFrequency: allowanceFrequency ?? this.allowanceFrequency,
      allowanceDay: allowanceDay ?? this.allowanceDay,
      allowanceEnabled: allowanceEnabled ?? this.allowanceEnabled,
      nextAllowanceDate: nextAllowanceDate ?? this.nextAllowanceDate,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Soft delete
  Child markAsDeleted() {
    return copyWith(isDeleted: true, updatedAt: DateTime.now());
  }

  // Update next allowance date (useful for recurring allowances)
  Child updateNextAllowanceDate() {
    if (!allowanceEnabled ||
        allowanceFrequency == null ||
        allowanceDay == null) {
      return this;
    }

    return copyWith(
      nextAllowanceDate: calculateNextAllowanceDate(
        allowanceFrequency,
        allowanceDay,
      ),
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    familyId,
    name,
    age,
    allowanceAmount,
    allowanceFrequency,
    allowanceDay,
    allowanceEnabled,
    nextAllowanceDate,
    createdAt,
    updatedAt,
  ];
}
