import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'service_manager.db');
    return await openDatabase(
      path,
      version: 2, // Incremented version
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Customers Table
    await db.execute('''
      CREATE TABLE customers(
        id TEXT PRIMARY KEY,
        name TEXT,
        phone TEXT
      )
    ''');

    // Vehicles Table
    await db.execute('''
      CREATE TABLE vehicles(
        id TEXT PRIMARY KEY,
        customerId TEXT,
        make TEXT,
        model TEXT,
        year INTEGER,
        licensePlate TEXT,
        mileage INTEGER,
        FOREIGN KEY (customerId) REFERENCES customers(id)
      )
    ''');

    // Service Records Table
    await db.execute('''
      CREATE TABLE service_records(
        id TEXT PRIMARY KEY,
        customerId TEXT,
        vehicleId TEXT,
        customerName TEXT, -- Denormalized for query speed
        vehicleModel TEXT, -- Denormalized
        date TEXT,
        totalAmount REAL,
        status TEXT,
        approvalAt TEXT, 
        completedAt TEXT,
        FOREIGN KEY (customerId) REFERENCES customers(id),
        FOREIGN KEY (vehicleId) REFERENCES vehicles(id)
      )
    ''');

    // Inspection Items Table
    await db.execute('''
      CREATE TABLE inspection_items(
        id TEXT PRIMARY KEY,
        serviceRecordId TEXT,
        name TEXT,
        status TEXT,
        notes TEXT,
        photoPath TEXT,
        FOREIGN KEY (serviceRecordId) REFERENCES service_records(id)
      )
    ''');

    // Parts Used Table
    await db.execute('''
      CREATE TABLE parts_used(
        id TEXT PRIMARY KEY,
        serviceRecordId TEXT,
        partName TEXT,
        quantity INTEGER,
        price REAL,
        FOREIGN KEY (serviceRecordId) REFERENCES service_records(id)
      )
    ''');
    
    await _createInventoryTable(db);
    
    // Seed Data
    await _seedData(db);
  }
  
  Future<void> _createInventoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE inventory(
        id TEXT PRIMARY KEY,
        name TEXT,
        partNumber TEXT,
        price REAL,
        quantity INTEGER,
        minStockLevel INTEGER,
        trackStock INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add inventory table
      await _createInventoryTable(db);
      
      // Add new columns to service_records
      // SQLite doesn't support adding multiple columns in one statement easily or IF NOT EXISTS heavily
      try {
        await db.execute('ALTER TABLE service_records ADD COLUMN approvalAt TEXT');
      } catch (e) {
        // Ignore if exists (simplistic migration)
      }
      try {
        await db.execute('ALTER TABLE service_records ADD COLUMN completedAt TEXT');
      } catch (e) {
        // Ignore
      }
    }
  }  
  
  Future<void> _seedData(Database db) async {
      // Basic Seed
      await db.insert('customers', {
          'id': 'cust_1',
          'name': 'Raj Kumar',
          'phone': '9876543210',
          'lastVisitDate': DateTime.now().toIso8601String(),
      });
      await db.insert('vehicles', {
          'id': 'veh_1',
          'customerId': 'cust_1',
          'model': 'Maruti Swift',
          'registrationNumber': 'MH12AB1234',
          'type': 'Hatchback',
      });
  }
}
