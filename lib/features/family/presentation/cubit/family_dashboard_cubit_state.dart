import 'package:equatable/equatable.dart';

import '../../../auth/domain/user_model.dart';
import '../../../child/domain/child_model.dart';
import '../../domain/family_model.dart';

abstract class FamilyDashboardState extends Equatable {
  const FamilyDashboardState();

  @override
  List<Object?> get props => [];
}

class FamilyDashboardInitial extends FamilyDashboardState {}

class FamilyDashboardLoading extends FamilyDashboardState {}

class FamilyDashboardLoaded extends FamilyDashboardState {
  final Family family;
  final List<UserModel> members;
  final List<Child> children;

  const FamilyDashboardLoaded({
    required this.family,
    required this.members,
    required this.children,
  });

  @override
  List<Object?> get props => [family, members];
}

class FamilyDashboardError extends FamilyDashboardState {
  final String message;

  const FamilyDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
