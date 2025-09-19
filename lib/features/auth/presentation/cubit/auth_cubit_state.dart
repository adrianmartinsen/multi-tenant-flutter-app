import '../../domain/family_model.dart';
import '../../domain/user_model.dart';

abstract class AuthCubitState {}

class AuthInitial extends AuthCubitState {}

class AuthLoading extends AuthCubitState {}

class AuthUserCreated extends AuthCubitState {}

class AuthUserWithoutFamily extends AuthCubitState {
  final UserModel user;

  AuthUserWithoutFamily({required this.user});
}

class AuthAuthenticated extends AuthCubitState {
  final UserModel user;
  final FamilyModel family;
  final List<UserModel> familyMembers;
  final String? error;

  AuthAuthenticated({
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
}

class AuthError extends AuthCubitState {
  final String message;

  AuthError(this.message);
}
