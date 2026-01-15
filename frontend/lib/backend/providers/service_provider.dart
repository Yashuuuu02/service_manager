import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../repositories/service_repository.dart';
import '../repositories/vehicle_repository.dart';
import '../services/pdf_service.dart';
import '../models/service_record.dart';
import '../models/inventory_item.dart'; // New import
import '../repositories/inventory_repository.dart'; // New import

class ServiceProvider extends ChangeNotifier {
  final ServiceRepository _serviceRepo = ServiceRepository();
  final VehicleRepository _vehicleRepo = VehicleRepository();
  final PdfService _pdfService = PdfService();
  final InventoryRepository _inventoryRepo = InventoryRepository(); // New instance

  List<ServiceRecord> _todaysRecords = [];
  List<ServiceRecord> _allRecords = []; // Added for Jobs Screen
  List<InventoryItem> _inventory = []; // New list
  bool _isLoading = false;

  List<ServiceRecord> get todaysRecords => _todaysRecords;
  List<ServiceRecord> get allRecords => _allRecords;
  
  // Updated Filters using ServiceRecord constants
  List<ServiceRecord> get pendingRecords => _allRecords.where((r) => r.status == ServiceRecord.statusInspectionPending || r.status == ServiceRecord.statusApprovalPending).toList();
  List<ServiceRecord> get completedRecords => _allRecords.where((r) => r.status == ServiceRecord.statusDelivered).toList();
  
  bool get isLoading => _isLoading;
  List<InventoryItem> get inventory => _inventory;

  // Dashboard Stats
  int get todaysCount => _todaysRecords.length;
  double get todaysRevenue => _todaysRecords
      .where((r) => r.status == ServiceRecord.statusDelivered) // Only delivered revenue
      .fold(0, (sum, item) => sum + item.totalAmount);
  int get completedCount => _todaysRecords.where((r) => r.status == ServiceRecord.statusDelivered).length;
  int get pendingCount => _todaysRecords.where((r) => r.status == ServiceRecord.statusInspectionPending || r.status == ServiceRecord.statusApprovalPending).length;

  Future<void> loadInventory() async {
    _isLoading = true;
    notifyListeners();
    try {
      _inventory = await _inventoryRepo.getAllItems();
    } catch (e) {
      debugPrint("Error loading inventory: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateJobStatus(String recordId, String newStatus) async {
    final index = _allRecords.indexWhere((r) => r.id == recordId);
    if (index != -1) {
      final oldRecord = _allRecords[index];
      
      // Auto-deduct inventory if moving to In Progress from a pre-work state
      if (newStatus == ServiceRecord.statusInProgress && oldRecord.status != ServiceRecord.statusInProgress) {
         await _deductInventoryForRecord(oldRecord);
      }
      
      // Additional Logic: Set timestamps
      String? approvalAt = oldRecord.approvalAt;
      String? completedAt = oldRecord.completedAt;

      if (newStatus == ServiceRecord.statusApprovalPending && oldRecord.status != ServiceRecord.statusApprovalPending) {
        // Just finished inspection
      }
      if (newStatus == ServiceRecord.statusInProgress && oldRecord.status == ServiceRecord.statusApprovalPending) {
        approvalAt = DateTime.now().toIso8601String();
      }
      if (newStatus == ServiceRecord.statusDelivered && oldRecord.status != ServiceRecord.statusDelivered) {
        completedAt = DateTime.now().toIso8601String();
      }

      final updatedRecord = oldRecord.copyWith(
        status: newStatus,
        approvalAt: approvalAt,
        completedAt: completedAt,
      );

      // Update in List
      _allRecords[index] = updatedRecord;
      
      // Update Todays List if present
      final todayIndex = _todaysRecords.indexWhere((r) => r.id == recordId);
      if (todayIndex != -1) {
        _todaysRecords[todayIndex] = updatedRecord;
      }

      notifyListeners();

      // Persist to DB
      await _serviceRepo.saveServiceRecord(updatedRecord);
    }
  }

  Future<void> _deductInventoryForRecord(ServiceRecord record) async {
    for (var part in record.partsUsed) {
       try {
         // Find generic match by name
         final invItem = _inventory.firstWhere((i) => i.name == part.name, orElse: () => InventoryItem(id: '', name: '', price: 0, quantity: 0, trackStock: false));
         if (invItem.id.isNotEmpty && invItem.trackStock) {
           await _inventoryRepo.updateStock(invItem.id, -part.quantity);
         }
       } catch (e) {
         debugPrint("Error deducting stock: $e");
       }
    }
    await loadInventory(); // Refresh stock
  }



  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _todaysRecords = await _serviceRepo.getTodaysServices();
      // Also load all for stats consistency if needed, but for now we separate
    } catch (e) {
      debugPrint("Error loading dashboard: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllRecords() async {
      _isLoading = true;
      notifyListeners();
      try {
          _allRecords = await _serviceRepo.getAllServices();
      } catch(e) {
          debugPrint("Error loading all records: $e");
      } finally {
          _isLoading = false;
          notifyListeners();
      }
  }

  Future<void> saveNewService(ServiceRecord record) async {
      await _serviceRepo.saveServiceRecord(record);
      
      // Auto-deduct inventory if the new record is already in a state that implies parts usage
      if (record.status == ServiceRecord.statusInProgress || 
          record.status == ServiceRecord.statusReady || 
          record.status == ServiceRecord.statusDelivered) {
           await _deductInventoryForRecord(record);
      }
      
      await loadDashboardData(); // Refresh UI
  }
  
  Future<Uint8List> generatePdfForRecord(String recordId) async {
      // For simplicity, we find from loaded records or fetch custom
      // In a real app we might fetchByID
      final record = (await _serviceRepo.getAllServices()).firstWhere((r) => r.id == recordId);
      return await _pdfService.generateInvoice(record);
  }
  Future<void> addInventoryItem(InventoryItem item) async {
    await _inventoryRepo.addItem(item);
    await loadInventory();
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    await _inventoryRepo.updateItem(item);
    await loadInventory();
  }

  Future<void> deleteInventoryItem(String id) async {
    await _inventoryRepo.deleteItem(id);
    await loadInventory();
  }
}
