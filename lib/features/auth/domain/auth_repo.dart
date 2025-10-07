import 'user_model.dart';

abstract class AuthRepository {
  Future<void> signUp(String email, String password);
  Future<void> signIn(String email, String password);
  Future<UserModel?> getCurrentUser();
  Future<void> deleteAccount();
  Future<void> signOut();
}
