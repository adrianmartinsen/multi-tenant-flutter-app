import 'package:equatable/equatable.dart';

import '../../../family/domain/family_model.dart';
import '../../domain/user_model.dart';

abstract class AuthCubitState extends Equatable {
  const AuthCubitState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthCubitState {}

class AuthLoading extends AuthCubitState {}

class AuthUserCreated extends AuthCubitState {}

class AuthUserWithoutFamily extends AuthCubitState {
  final UserModel user;

  const AuthUserWithoutFamily({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthAuthenticated extends AuthCubitState {
  final UserModel user;
  final FamilyModel family;
  final List<UserModel> familyMembers;
  final String? error;

  const AuthAuthenticated({
    required this.user,
    required this.family,
    this.familyMembers = const [],
    this.error,
  });

  AuthAuthenticated copyWith({
    UserModel? user,
    FamilyModel? family,
    List<UserModel>? familyMembers,
    String? error,
  }) {
    return AuthAuthenticated(
      user: user ?? this.user,
      family: family ?? this.family,
      familyMembers: familyMembers ?? this.familyMembers,
      error: error,
    );
  }

  @override
  List<Object?> get props => [user, family, familyMembers, error];
}

class AuthDeleting extends AuthCubitState {}

class AuthAccountDeleted extends AuthCubitState {
  final String message;

  const AuthAccountDeleted({this.message = 'Account successfully deleted'});

  @override
  List<Object> get props => [message];
}

class AuthError extends AuthCubitState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}
