import 'package:equatable/equatable.dart';

enum TransactionType {
  credit,
  debit,
  allowance;

  String toJson() => name;
  static TransactionType fromJson(String json) => values.byName(json);
}

class Transaction extends Equatable {
  final String id;
  final String childId;
  final double amount;
  final String? description;
  final TransactionType transactionType;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.childId,
    required this.amount,
    required this.description,
    required this.transactionType,
    required this.createdAt,
  });

  // Factory constructor for creating from database JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      childId: json['child_id'],
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
      transactionType: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['transaction_type'],
      ),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Convert to JSON for database insert/update
  // Note: Do not include 'id' for inserts - let Supabase generate it
  Map<String, dynamic> toJson({bool includeId = false}) {
    final json = {
      'child_id': childId,
      'amount': amount,
      'description': description,
      'transaction_type': transactionType.toString().split('.').last,
    };

    if (includeId) {
      json['id'] = id;
    }

    return json;
  }

  // Convert to JSON for insert (excludes id and created_at - let DB handle these)
  Map<String, dynamic> toInsertJson() {
    return {
      'child_id': childId,
      'amount': amount,
      'description': description,
      'transaction_type': transactionType.toString().split('.').last,
    };
  }

  // Validation method
  bool isValid() {
    if (amount == 0) return false;
    if (transactionType != TransactionType.allowance &&
        description?.trim().isEmpty == true) {
      return false;
    }
    // Ensure credits are positive and debits are negative
    switch (transactionType) {
      case TransactionType.credit:
      case TransactionType.allowance:
        if (amount < 0) return false;
        break;
      case TransactionType.debit:
        if (amount > 0) return false;
        break;
    }
    return true;
  }

  // Calculate balance from a list of transactions
  static double calculateBalance(List<Transaction> transactions) {
    return transactions.fold<double>(0.0, (balance, transaction) {
      switch (transaction.transactionType) {
        case TransactionType.credit:
        case TransactionType.allowance:
          return balance + transaction.amount.abs();
        case TransactionType.debit:
          return balance - transaction.amount.abs();
      }
    });
  }

  // Get total credits from a list of transactions
  static double getTotalCredits(List<Transaction> transactions) {
    return transactions
        .where(
          (t) =>
              t.transactionType == TransactionType.credit ||
              t.transactionType == TransactionType.allowance,
        )
        .fold<double>(0.0, (sum, t) => sum + t.amount.abs());
  }

  // Get total debits from a list of transactions
  static double getTotalDebits(List<Transaction> transactions) {
    return transactions
        .where((t) => t.transactionType == TransactionType.debit)
        .fold<double>(0.0, (sum, t) => sum + t.amount.abs());
  }

  // Filter transactions by type
  static List<Transaction> filterByType(
    List<Transaction> transactions,
    TransactionType type,
  ) {
    return transactions.where((t) => t.transactionType == type).toList();
  }

  // Filter transactions by date range
  static List<Transaction> filterByDateRange(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    return transactions
        .where(
          (t) =>
              t.createdAt.isAfter(
                startDate.subtract(const Duration(days: 1)),
              ) &&
              t.createdAt.isBefore(endDate.add(const Duration(days: 1))),
        )
        .toList();
  }

  // Get recent transactions (sorted by date descending)
  static List<Transaction> getRecent(
    List<Transaction> transactions, {
    int limit = 10,
  }) {
    final sorted = List<Transaction>.from(transactions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(limit).toList();
  }

  // Get transactions for current month
  static List<Transaction> getCurrentMonthTransactions(
    List<Transaction> transactions,
  ) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return filterByDateRange(transactions, startOfMonth, endOfMonth);
  }

  // Check if transaction is a credit (positive amount)
  bool isCredit() {
    return transactionType == TransactionType.credit ||
        transactionType == TransactionType.allowance;
  }

  // Check if transaction is a debit (negative amount)
  bool isDebit() {
    return transactionType == TransactionType.debit;
  }

  // Get formatted amount with sign
  String getFormattedAmount() {
    final sign = isCredit() ? '+' : '-';
    return '$sign\$${amount.abs().toStringAsFixed(2)}';
  }

  // Get display description (with default for allowance)
  String getDisplayDescription() {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }
    return transactionType == TransactionType.allowance
        ? 'Weekly allowance'
        : 'No description';
  }

  // Copy with method for immutability
  Transaction copyWith({
    String? childId,
    double? amount,
    String? description,
    TransactionType? transactionType,
  }) {
    return Transaction(
      id: id,
      childId: childId ?? this.childId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      transactionType: transactionType ?? this.transactionType,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    childId,
    amount,
    description,
    transactionType,
    createdAt,
  ];
}
