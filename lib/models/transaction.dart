
enum TransactionType { income, expense }
enum TransactionCat {travelling, shopping, others, finance, income, pets, transport, home, health, family, foodDrink }

class Transaction {
  final String id;
  final String name;
  final String time;
  final DateTime date;
  final String imgUrl;
  final TransactionType type;
  final TransactionCat category;
  final int amount;

  Transaction( {
    required this.id,
    required this.name,
    required this.time,
    required this.date,
    required this.imgUrl,
    required this.type,
    required this.category,
    required this.amount,
  });

  factory Transaction.fromJson(Map<String, dynamic> json, String id) {
  final TransactionType type = TransactionType.values.firstWhere(
    (value) => value.toString() == json['type'],
    orElse: () => TransactionType.expense,
  );

  final TransactionCat category = TransactionCat.values.firstWhere(
    (value) => value.toString() == json['category'],
    orElse: () => TransactionCat.others,
  );

  return Transaction(
    id: id,
    name: json['name'],
    time: json['time'],
    date: json['date'].toDate(),
    imgUrl: json['imgUrl'],
    type: type,
    category: category,
    amount: json['amount'],
  );
}

}
