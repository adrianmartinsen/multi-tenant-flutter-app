import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/domain/user_model.dart';
import '../domain/family_model.dart';
import '../domain/family_repo.dart';

class SupabaseFamilyRepository implements FamilyRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<void> createAndJoinFamily(String familyName) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    await _supabase.rpc(
      'create_family_for_user',
      params: {'family_name': familyName},
    );
  }

  @override
  Future<void> joinExistingFamily(String familyId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    // Call the database function using RPC
    await _supabase.rpc(
      'join_existing_family',
      params: {'join_family_id': familyId},
    );
  }

  @override
  Future<FamilyModel?> getCurrentFamily() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final userData = await _supabase
        .from('users')
        .select('family_id')
        .eq('id', user.id)
        .single();

    final familyId = userData['family_id'];
    if (familyId == null) return null;

    final response = await _supabase
        .from('families')
        .select()
        .eq('id', familyId)
        .single();

    return FamilyModel.fromJson(response);
  }

  @override
  Future<List<UserModel>> getFamilyMembers() async {
    final response = await _supabase.rpc('get_family_members');
    final memberList = response as List;
    return memberList.map((member) {
      final memberMap = Map<String, dynamic>.from(member as Map);
      // The database function returns 'user_id', but the model expects 'id'.
      if (memberMap.containsKey('user_id')) {
        memberMap['id'] = memberMap.remove('user_id');
      }
      return UserModel.fromJson(memberMap);
    }).toList();
  }
}
