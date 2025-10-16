import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/child_model.dart';
import '../domain/child_repo.dart';

class SupabaseChildRepository implements ChildRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<Child>> getChildrenForFamily(String familyId) async {
    try {
      final response = await _supabase
          .from('children')
          .select()
          .eq('family_id', familyId)
          .order('created_at', ascending: true);

      final childrenList = response as List;
      return childrenList.map((json) => Child.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch children: ${e.toString()}');
    }
  }

  @override
  Future<Child> getChildById(String childId) async {
    try {
      final response = await _supabase
          .from('children')
          .select()
          .eq('id', childId)
          .single();

      return Child.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw Exception('Child not found');
      }
      throw Exception('Failed to fetch child: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch child: ${e.toString()}');
    }
  }

  @override
  Future<Child> createChild({
    required String name,
    required String familyId,
    double balance = 0.0,
  }) async {
    try {
      final response = await _supabase
          .from('children')
          .insert({'name': name, 'family_id': familyId, 'balance': balance})
          .select()
          .single();

      return Child.fromJson(response);
    } on PostgrestException catch (e) {
      // Handle specific database errors
      if (e.code == '23503') {
        throw Exception('Invalid family_id - family does not exist');
      }
      throw Exception('Failed to create child: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create child: ${e.toString()}');
    }
  }

  @override
  Future<Child> updateChild(Child child) async {
    try {
      // Validate the child before updating
      if (!child.isValid()) {
        throw Exception('Invalid child data');
      }

      final response = await _supabase
          .from('children')
          .update(child.toJson())
          .eq('id', child.id)
          .select()
          .single();

      return Child.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw Exception('Child not found');
      }
      throw Exception('Failed to update child: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update child: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteChild(String childId) async {
    try {
      await _supabase.from('children').delete().eq('id', childId);
    } on PostgrestException catch (e) {
      throw Exception('Failed to delete child: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete child: ${e.toString()}');
    }
  }

  @override
  Future<double> getChildBalance(String childId) async {
    try {
      // Fetch all transactions for the child
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('child_id', childId);

      final transactionsList = response as List;

      // Calculate balance by summing credits and subtracting debits
      double balance = 0.0;

      for (var transactionJson in transactionsList) {
        final amount = (transactionJson['amount'] as num).toDouble();
        final type = transactionJson['transaction_type'] as String;

        if (type == 'credit' || type == 'allowance') {
          balance += amount.abs();
        } else if (type == 'debit') {
          balance -= amount.abs();
        }
      }

      return balance;
    } catch (e) {
      throw Exception('Failed to calculate balance: ${e.toString()}');
    }
  }
}
