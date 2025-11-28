import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum TransactionStatus { pending, completed, cancelled, refunded }

class Transaction {
  final String id;
  final DateTime date;
  final String itemName;
  final String customer;
  final int quantity;
  final int pricePerItem;
  final int total;
  final TransactionStatus status;
  final String? category;
  final String? notes;
  final String? paymentMethod;

  const Transaction({
    required this.id,
    required this.date,
    required this.itemName,
    required this.customer,
    required this.quantity,
    required this.pricePerItem,
    required this.total,
    this.status = TransactionStatus.completed,
    this.category,
    this.notes,
    this.paymentMethod,
  });

  // Business Logic Methods
  bool get isHighValue => total > 1000000;
  bool get isPending => status == TransactionStatus.pending;
  bool get isRefunded => status == TransactionStatus.refunded;

  String get formattedDate => DateFormat('dd MMM yyyy, HH:mm').format(date);
  String get formattedDateShort => DateFormat('dd/MM/yy').format(date);

  String get formattedTotal => _formatCurrency(total);
  String get formattedPricePerItem => _formatCurrency(pricePerItem);

  String get statusLabel {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
      case TransactionStatus.refunded:
        return 'Refunded';
    }
  }

  Color get statusColor {
    switch (status) {
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.cancelled:
        return Colors.red;
      case TransactionStatus.refunded:
        return Colors.purple;
    }
  }

  // Validation
  bool isValid() {
    return id.isNotEmpty &&
        itemName.isNotEmpty &&
        customer.isNotEmpty &&
        quantity > 0 &&
        pricePerItem > 0 &&
        total > 0;
  }

  // JSON Serialization - From API/Database
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      itemName: json['itemName'] ?? '',
      customer: json['customer'] ?? '',
      quantity: json['quantity'] ?? 0,
      pricePerItem: json['pricePerItem'] ?? 0,
      total: json['total'] ?? 0,
      status: _parseStatus(json['status']),
      category: json['category'],
      notes: json['notes'],
      paymentMethod: json['paymentMethod'],
    );
  }

  static TransactionStatus _parseStatus(String status) {
    switch (status) {
      case 'pending':
        return TransactionStatus.pending;
      case 'cancelled':
        return TransactionStatus.cancelled;
      case 'refunded':
        return TransactionStatus.refunded;
      case 'completed':
      default:
        return TransactionStatus.completed;
    }
  }

  // JSON Serialization - To API/Database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'itemName': itemName,
      'customer': customer,
      'quantity': quantity,
      'pricePerItem': pricePerItem,
      'total': total,
      'status': status.name,
      'category': category,
      'notes': notes,
      'paymentMethod': paymentMethod,
    };
  }

  // For immediate UI use (from local data)
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      date: map['date'] is DateTime
          ? map['date']
          : DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      itemName: map['itemName'] ?? '',
      customer: map['customer'] ?? '',
      quantity: map['quantity'] ?? 0,
      pricePerItem: map['pricePerItem'] ?? 0,
      total: map['total'] ?? 0,
      status: map['status'] is TransactionStatus
          ? map['status']
          : _parseStatus(map['status'] ?? 'completed'),
      category: map['category'],
      notes: map['notes'],
      paymentMethod: map['paymentMethod'],
    );
  }

  // Copy with method for state management
  Transaction copyWith({
    String? id,
    DateTime? date,
    String? itemName,
    String? customer,
    int? quantity,
    int? pricePerItem,
    int? total,
    TransactionStatus? status,
    String? category,
    String? notes,
    String? paymentMethod,
  }) {
    return Transaction(
      id: id ?? this.id,
      date: date ?? this.date,
      itemName: itemName ?? this.itemName,
      customer: customer ?? this.customer,
      quantity: quantity ?? this.quantity,
      pricePerItem: pricePerItem ?? this.pricePerItem,
      total: total ?? this.total,
      status: status ?? this.status,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  // Equatable implementation (optional but recommended)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper method for currency formatting
  String _formatCurrency(int amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  @override
  String toString() {
    return 'Transaction(id: $id, item: $itemName, customer: $customer, total: $total, status: $status)';
  }
}

// Extension untuk List of Transactions
extension TransactionListExtensions on List<Transaction> {
  int get totalRevenue {
    return fold(0, (sum, transaction) => sum + transaction.total);
  }

  int get todayRevenue {
    final today = DateTime.now();
    return where(
      (transaction) =>
          transaction.date.year == today.year &&
          transaction.date.month == today.month &&
          transaction.date.day == today.day,
    ).fold(0, (sum, transaction) => sum + transaction.total);
  }

  List<Transaction> get completedTransactions {
    return where(
      (transaction) => transaction.status == TransactionStatus.completed,
    ).toList();
  }

  List<Transaction> get sortedByDateDesc {
    return [...this]..sort((a, b) => b.date.compareTo(a.date));
  }
}
