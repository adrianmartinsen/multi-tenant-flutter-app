import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/auth_repo.dart';
import 'auth_cubit_state.dart';

class AuthCubit extends Cubit<AuthCubitState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
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
      await _authRepository.createAndJoinFamily(familyName);
      await _checkUserState();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Step 2 alternative: Join existing family
  Future<void> joinExistingFamily(String familyId) async {
    emit(AuthLoading());
    try {
      await _authRepository.joinExistingFamily(familyId);
      await _checkUserState();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> getFamilyMembers() async {
    if (state is AuthAuthenticated) {
      final currentState = state as AuthAuthenticated;
      try {
        final members = await _authRepository.getFamilyMembers();
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
        final family = await _authRepository.getCurrentFamily();
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
