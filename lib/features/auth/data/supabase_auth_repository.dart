import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/auth_repo.dart';
import '../domain/family_model.dart';
import '../domain/user_model.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<void> signUp(String email, String password) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Failed to create user');
    }
  }

  @override
  Future<void> signIn(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Failed to sign in');
    }
  }

  @override
  Future<void> createAndJoinFamily(String familyName) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    await _supabase.rpc(
      'create_family_for_user',
      params: {'family_name': familyName},
    );

    // // Create family
    // final familyResponse = await _supabase
    //     .from('families')
    //     .insert({'name': familyName})
    //     .select()
    //     .single();

    // // Link user to family
    // await _supabase
    //     .from('users')
    //     .update({'family_id': familyResponse['id']})
    //     .eq('id', user.id);
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
  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final response = await _supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    return UserModel.fromJson(response);
  }

  @override
  Future<FamilyModel?> getCurrentFamily() async {
    final currentUser = await getCurrentUser();
    if (currentUser?.familyId == null) return null;

    final response = await _supabase
        .from('families')
        .select()
        .eq('id', currentUser!.familyId!)
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

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
