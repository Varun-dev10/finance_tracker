class TransactionModel {
  final String id;
  final String categoryId;
  final String categoryName; // filled in on the Flutter side after matching category_id
  final double amount;
  final String type;
  final String? description;
  final DateTime transactionDate;

  TransactionModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.type,
    this.description,
    required this.transactionDate,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json, String categoryName) {
    return TransactionModel(
      id: json['id'],
      categoryId: json['category_id'],
      categoryName: categoryName,
      amount: double.parse(json['amount'].toString()),
      type: json['type'],
      description: json['description'],
      transactionDate: DateTime.parse(json['transaction_date']),
    );
  }
}