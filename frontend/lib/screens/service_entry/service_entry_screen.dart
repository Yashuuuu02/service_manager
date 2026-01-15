import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../backend/models/service_record.dart';
import '../../backend/models/inspection_item.dart';
import '../../backend/models/part_used.dart';
import '../../backend/providers/service_provider.dart';
import '../../theme/app_colors.dart';
import 'vehicle_details_tab.dart';
import 'inspection_tab.dart';
import 'parts_labor_tab.dart';
import 'summary_tab.dart';

class ServiceEntryScreen extends StatefulWidget {
  const ServiceEntryScreen({super.key});

  @override
  State<ServiceEntryScreen> createState() => _ServiceEntryScreenState();
}

class _ServiceEntryScreenState extends State<ServiceEntryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Local Form State (Transient)
  String _customerName = "";
  String _phone = "";
  String _vehicleModel = "";
  String _regNum = "";
  String _vehicleType = "Sedan";
  
  // Inspection Data
  final List<InspectionItem> _inspectionItems = [
     InspectionItem(name: 'Engine Oil Level', status: 'OK'),
     InspectionItem(name: 'Air Filter', status: 'Attention'),
     InspectionItem(name: 'Brake Pads', status: 'Critical'),
  ];
  
  // Parts Data
  final List<PartUsed> _partsUsed = [
      PartUsed(name: 'Labor Charge', price: 500, quantity: 1, isLabor: true),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _nextTab() {
    if (_tabController.index < _tabController.length - 1) {
      _tabController.animateTo(_tabController.index + 1);
    }
  }

  void _prevTab() {
    if (_tabController.index > 0) {
      _tabController.animateTo(_tabController.index - 1);
    }
  }
  
  Future<void> _saveService() async {
      final total = _partsUsed.fold(0.0, (sum, p) => sum + p.total);
      
      final record = ServiceRecord(
          id: const Uuid().v4(),
          vehicleId: const Uuid().v4(), // Mock Vehicle ID
          customerName: _customerName.isEmpty ? "Unknown" : _customerName,
          vehicleModel: _vehicleModel.isEmpty ? "Standard" : _vehicleModel,
          date: DateTime.now().toIso8601String(),
          totalAmount: total,
          status: ServiceRecord.statusInspectionPending, // Default start state
          inspectionItems: _inspectionItems,
          partsUsed: _partsUsed,
      );
      
      await context.read<ServiceProvider>().saveNewService(record);
      
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Service Saved Successfully!')));
          context.pop(); 
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Service Entry'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, 
          tabs: const [
            Tab(text: "1. Vehicle Details"),
            Tab(text: "2. Inspection"),
            Tab(text: "3. Parts & Labor"),
            Tab(text: "4. Summary & Save"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          VehicleDetailsTab(
              onNext: _nextTab, 
              // Pass current state as initials
              initialName: _customerName,
              initialPhone: _phone,
              initialModel: _vehicleModel,
              initialReg: _regNum,
              initialType: _vehicleType,
              onDataChanged: (name, phone, model, reg, type) {
                  setState(() {
                      _customerName = name;
                      _phone = phone;
                      _vehicleModel = model;
                      _regNum = reg;
                      _vehicleType = type;
                  });
              }
          ),
          InspectionTab(
              onNext: _nextTab, 
              onPrev: _prevTab,
              items: _inspectionItems,
              onUpdateItem: (updatedItem) {
                  setState(() {
                      final index = _inspectionItems.indexWhere((i) => i.name == updatedItem.name);
                      if (index != -1) {
                          _inspectionItems[index] = updatedItem;
                      }
                  });
              },
          ),
          PartsLaborTab(
            onNext: _nextTab, 
            onPrev: _prevTab,
            parts: _partsUsed,
            onAdd: (newItem) {
                setState(() {
                    _partsUsed.add(newItem);
                });
            },
            onRemove: (item) {
                setState(() {
                    _partsUsed.remove(item);
                });
            },
            onUpdateQty: (item, newQty) {
                setState(() {
                    final index = _partsUsed.indexOf(item);
                    if (index != -1) {
                        _partsUsed[index] = PartUsed(
                            name: item.name,
                            price: item.price,
                            quantity: newQty,
                            isLabor: item.isLabor,
                        );
                    }
                });
            },
          ),
          SummaryTab(
              onPrev: _prevTab, 
              customerName: _customerName,
              vehicleModel: _vehicleModel,
              totalAmount: _partsUsed.fold(0.0, (sum, p) => sum + p.total),
              onSave: _saveService,
          ),
        ],
      ),
    );
  }
}
