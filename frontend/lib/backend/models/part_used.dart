class PartUsed {
  final String name;
  final double price;
  final int quantity;
  final bool isLabor; // true if labor charge

  PartUsed({
    required this.name,
    required this.price,
    required this.quantity,
    this.isLabor = false,
  });

  double get total => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'isLabor': isLabor ? 1 : 0,
    };
  }

  factory PartUsed.fromMap(Map<String, dynamic> map) {
    return PartUsed(
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      isLabor: map['isLabor'] == 1,
    );
  }
}
