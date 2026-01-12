import '../../domain/entities/wallet_transaction.dart';

class WalletTransactionModel {
  final String id;
  final String transactionType;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final DateTime? createdAt;
  final String description;
  final String referenceId;
  final String referenceType;
  final String? status;

  WalletTransactionModel({
    required this.id,
    required this.transactionType,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.createdAt,
    required this.description,
    required this.referenceId,
    required this.referenceType,
    this.status,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    double parseAmount(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return WalletTransactionModel(
      id: json['id']?.toString() ?? '',
      transactionType: json['transactionType']?.toString() ?? json['type']?.toString() ?? '',
      amount: parseAmount(json['amount']),
      balanceBefore: parseAmount(json['balanceBefore']),
      balanceAfter: parseAmount(json['balanceAfter']),
      createdAt: parseDate(json['createdAt']),
      description: json['description']!.toString(),
      referenceId: json['referenceId']!.toString(),
      referenceType: json['referenceType']!.toString(),
      status: json['status']?.toString(),
    );
  }

  WalletTransaction toEntity() {
    return WalletTransaction(
      id: id,
      transactionType: transactionType,
      amount: amount,
      balanceBefore: balanceBefore,
      balanceAfter: balanceAfter,
      createdAt: createdAt,
      description: description,
      referenceId: referenceId,
      referenceType: referenceType,
      status: status,
    );
  }
}
