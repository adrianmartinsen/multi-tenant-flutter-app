import '../../auth/domain/user_model.dart';
import 'family_model.dart';

abstract class FamilyRepository {
  Future<void> createAndJoinFamily(String familyName);
  Future<void> joinExistingFamily(String familyId);
  Future<Family?> getCurrentFamily();
  Future<List<UserModel>> getFamilyMembers();
}
