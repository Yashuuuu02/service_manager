class Customer {
  final String id; // UUID
  final String name;
  final String phone;
  final String lastVisitDate; // ISO8601

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.lastVisitDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'lastVisitDate': lastVisitDate,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      lastVisitDate: map['lastVisitDate'],
    );
  }
}

class Vehicle {
  final String id;
  final String customerId;
  final String model; // e.g., 'Maruti Swift'
  final String registrationNumber; // e.g., 'MH12AB1234'
  final String type; // Sedan, SUV, etc.

  Vehicle({
    required this.id,
    required this.customerId,
    required this.model,
    required this.registrationNumber,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'model': model,
      'registrationNumber': registrationNumber,
      'type': type,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      customerId: map['customerId'],
      model: map['model'],
      registrationNumber: map['registrationNumber'],
      type: map['type'],
    );
  }
}
