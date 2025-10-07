import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/auth_repo.dart';
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
  Future<void> deleteAccount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const AuthException('No user logged in');
      }

      // Delete the user account - this will trigger the database cascade
      // which removes the user from public.users and potentially the family
      await _supabase.auth.admin.deleteUser(user.id);
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw const AuthException('Failed to delete account. Please try again.');
    }
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
