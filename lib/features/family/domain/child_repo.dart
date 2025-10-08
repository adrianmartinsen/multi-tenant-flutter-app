import 'child_model.dart';

abstract class ChildRepository {
  /// Get all children for the current user's family
  Future<List<Child>> getChildrenForFamily(String familyId);

  /// Get a specific child by ID
  /// Throws an exception if the child doesn't exist or doesn't belong to the user's family
  Future<Child> getChildById(String childId);

  /// Create a new child for the current user's family
  /// The family_id will be automatically set based on the authenticated user
  /// Returns the created child with the generated ID from Supabase
  Future<Child> createChild(Child child);

  /// Update an existing child
  /// Only the child's own data is updated, not the family_id
  /// Returns the updated child
  Future<Child> updateChild(Child child);

  /// This will cascade delete all associated transactions
  /// Use with caution - this action cannot be undone
  Future<void> deleteChild(String childId);

  /// Get the current balance for a child
  /// This calculates the balance from all transactions
  Future<double> getChildBalance(String childId);
}
