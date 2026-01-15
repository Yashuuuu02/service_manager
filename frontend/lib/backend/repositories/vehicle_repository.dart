import 'package:uuid/uuid.dart';
import 'base_repository.dart';
import '../models/customer_vehicle.dart';

class VehicleRepository extends BaseRepository {
  final _uuid = const Uuid();

  Future<List<Customer>> getAllCustomers() async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query('customers');
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  Future<List<Vehicle>> getVehiclesForCustomer(String customerId) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      'vehicles',
      where: 'customerId = ?',
      whereArgs: [customerId],
    );
    return List.generate(maps.length, (i) => Vehicle.fromMap(maps[i]));
  }

  Future<String> createCustomer(String name, String phone) async {
    final database = await db;
    final id = _uuid.v4();
    await database.insert('customers', {
      'id': id,
      'name': name,
      'phone': phone,
      'lastVisitDate': DateTime.now().toIso8601String(),
    });
    return id;
  }

  Future<String> createVehicle(String customerId, String model, String regNum, String type) async {
    final database = await db;
    final id = _uuid.v4();
    await database.insert('vehicles', {
      'id': id,
      'customerId': customerId,
      'model': model,
      'registrationNumber': regNum,
      'type': type,
    });
    return id;
  }
}
