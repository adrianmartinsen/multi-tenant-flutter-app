import 'package:equatable/equatable.dart';
import 'package:multi_tenant_app_v2/features/auth/domain/user_model.dart';
import 'package:multi_tenant_app_v2/features/family/domain/family_model.dart';

abstract class FamilyDashboardState extends Equatable {
  const FamilyDashboardState();

  @override
  List<Object?> get props => [];
}

class FamilyDashboardInitial extends FamilyDashboardState {}

class FamilyDashboardLoading extends FamilyDashboardState {}

class FamilyDashboardLoaded extends FamilyDashboardState {
  final FamilyModel family;
  final List<UserModel> members;

  const FamilyDashboardLoaded({required this.family, required this.members});

  @override
  List<Object?> get props => [family, members];
}

class FamilyDashboardError extends FamilyDashboardState {
  final String message;

  const FamilyDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
