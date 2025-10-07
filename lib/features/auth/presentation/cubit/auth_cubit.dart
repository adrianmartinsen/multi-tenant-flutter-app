import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../family/domain/family_repo.dart';
import '../../domain/auth_repo.dart';
import 'auth_cubit_state.dart';

class AuthCubit extends Cubit<AuthCubitState> {
  final AuthRepository _authRepository;
  final FamilyRepository _familyRepository;

  AuthCubit({
    required AuthRepository authRepository,
    required FamilyRepository familyRepository,
  }) : _authRepository = authRepository,
       _familyRepository = familyRepository,
       super(AuthInitial());

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authRepository.signIn(email, password);
      await _checkUserState();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Step 1: Create user only
  Future<void> signUp(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUp(email, password);
      await _checkUserState();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Step 2: Create and join family
  Future<void> createAndJoinFamily(String familyName) async {
    emit(AuthLoading());
    try {
      await _familyRepository.createAndJoinFamily(familyName);
      await _checkUserState();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Step 2 alternative: Join existing family
  Future<void> joinExistingFamily(String familyId) async {
    emit(AuthLoading());
    try {
      await _familyRepository.joinExistingFamily(familyId);
      await _checkUserState();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // REMOVE THIS ONCE FAMILY DASHBOARD IS UP AND RUNNING (AND HOMEPAGE IS GONE)

  Future<void> getFamilyMembers() async {
    if (state is AuthAuthenticated) {
      final currentState = state as AuthAuthenticated;
      try {
        final members = await _familyRepository.getFamilyMembers();
        emit(currentState.copyWith(familyMembers: members));
      } catch (e) {
        emit(currentState.copyWith(error: e.toString()));
      }
    }
  }

  // Check what state the user is in
  Future<void> checkAuthState() async {
    emit(AuthLoading());
    await _checkUserState();
  }

  Future<void> deleteAccount() async {
    emit(AuthDeleting());

    try {
      await _authRepository.deleteAccount();

      // Account deleted successfully - user is automatically signed out
      emit(AuthAccountDeleted());

      // Transition to initial state after a brief moment
      await Future.delayed(const Duration(milliseconds: 500));
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError('An unexpected error occurred'));
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _checkUserState() async {
    try {
      final user = await _authRepository.getCurrentUser();

      if (user == null) {
        emit(AuthInitial());
        return;
      }

      if (user.hasFamily) {
        final family = await _familyRepository.getCurrentFamily();
        if (family != null) {
          emit(AuthAuthenticated(user: user, family: family));
        } else {
          emit(AuthError('Family not found'));
        }
      } else {
        emit(AuthUserWithoutFamily(user: user));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
