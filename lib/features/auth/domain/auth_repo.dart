import 'family_model.dart';
import 'user_model.dart';

abstract class AuthRepository {
  Future<void> signUp(String email, String password);
  Future<void> signIn(String email, String password);
  Future<void> createAndJoinFamily(String familyName);
  Future<void> joinExistingFamily(String familyId);
  Future<List<UserModel>> getFamilyMembers();
  Future<UserModel?> getCurrentUser();
  Future<FamilyModel?> getCurrentFamily();
  Future<void> signOut();
}
