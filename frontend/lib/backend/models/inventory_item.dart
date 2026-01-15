class InventoryItem {
  final String id;
  final String name;
  final String partNumber; // Optional SKU
  final double price;
  final int quantity;
  final int minStockLevel;
  final bool trackStock; // If false, quantity ignored (e.g. Labor)

  const InventoryItem({
    required this.id,
    required this.name,
    this.partNumber = '',
    required this.price,
    required this.quantity,
    this.minStockLevel = 0,
    this.trackStock = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'partNumber': partNumber,
      'price': price,
      'quantity': quantity,
      'minStockLevel': minStockLevel,
      'trackStock': trackStock ? 1 : 0,
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'],
      name: map['name'],
      partNumber: map['partNumber'] ?? '',
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      minStockLevel: map['minStockLevel'] as int? ?? 0,
      trackStock: (map['trackStock'] as int? ?? 1) == 1,
    );
  }

  InventoryItem copyWith({
    String? id,
    String? name,
    String? partNumber,
    double? price,
    int? quantity,
    int? minStockLevel,
    bool? trackStock,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      partNumber: partNumber ?? this.partNumber,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      trackStock: trackStock ?? this.trackStock,
    );
  }
}
