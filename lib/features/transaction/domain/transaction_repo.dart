import 'transaction_model.dart';

abstract class TransactionsRepository {
  /// Get all transactions for a specific child
  /// Returns transactions sorted by created_at descending (newest first)
  Future<List<Transaction>> getTransactionsForChild(String childId);

  /// Get a specific transaction by ID
  /// Throws an exception if the transaction doesn't exist or doesn't belong to the user's family
  Future<Transaction> getTransactionById(String transactionId);

  /// Create a new transaction for a child
  /// Returns the created transaction with the generated ID from Supabase
  Future<Transaction> createTransaction(Transaction transaction);

  /// Update an existing transaction
  /// Typically used for editing description or correcting amounts
  /// Returns the updated transaction
  Future<Transaction> updateTransaction(Transaction transaction);

  /// Delete a transaction permanently
  /// This will affect the child's balance calculation
  Future<void> deleteTransaction(String transactionId);

  /// Get recent transactions for a child with a limit
  /// Useful for displaying a summary or recent activity
  Future<List<Transaction>> getRecentTransactions(
    String childId, {
    int limit = 10,
  });

  /// Get transactions for a child within a date range
  /// Useful for generating reports or filtering by period
  Future<List<Transaction>> getTransactionsByDateRange(
    String childId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get transactions for a child filtered by type
  /// Returns only transactions of the specified type (credit, debit, or allowance)
  Future<List<Transaction>> getTransactionsByType(
    String childId,
    TransactionType type,
  );

  /// Get transactions for the current month for a child
  /// Useful for monthly summaries and reports
  Future<List<Transaction>> getCurrentMonthTransactions(String childId);

  /// Calculate the current balance for a child
  /// This sums all transactions (credits + allowances - debits)
  Future<double> calculateBalance(String childId);

  /// Get total credits for a child (optionally within a date range)
  Future<double> getTotalCredits(
    String childId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get total debits for a child (optionally within a date range)
  Future<double> getTotalDebits(
    String childId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Batch create multiple transactions at once
  /// Useful for processing allowances for multiple children or bulk operations
  /// Returns the list of created transactions
  Future<List<Transaction>> createTransactionsBatch(
    List<Transaction> transactions,
  );
}
