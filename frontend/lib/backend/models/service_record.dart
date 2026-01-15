import 'dart:convert';
import 'customer_vehicle.dart';
import 'inspection_item.dart';
import 'part_used.dart';

class ServiceRecord {
  final String id;
  final String vehicleId;
  final String customerName; // Denormalized for query speed
  final String vehicleModel; // Denormalized
  final String date; // ISO8601
  final double totalAmount;
  final String status;
  final String? approvalAt;
  final String? completedAt;

  // Job Status Constants
  static const String statusInspectionPending = 'Inspection Pending';
  static const String statusApprovalPending = 'Approval Pending';
  static const String statusInProgress = 'In Progress';
  static const String statusReady = 'Ready for Delivery';
  static const String statusDelivered = 'Delivered';

  static const List<String> allStatuses = [
    statusInspectionPending,
    statusApprovalPending,
    statusInProgress,
    statusReady,
    statusDelivered,
  ];

  bool get isTerminal => status == statusDelivered;
  bool get isEditable => status == statusInspectionPending || status == statusInProgress; // Rough logic, refined in UI

  
  // JSON Encoded lists for simplicity in SQLite v1
  final List<InspectionItem> inspectionItems;
  final List<PartUsed> partsUsed;

  ServiceRecord({
    required this.id,
    required this.vehicleId,
    required this.customerName,
    required this.vehicleModel,
    required this.date,
    required this.totalAmount,
    required this.status,
    required this.inspectionItems,
    required this.partsUsed,
    this.approvalAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'customerName': customerName,
      'vehicleModel': vehicleModel,
      'date': date,
      'totalAmount': totalAmount,
      'status': status,
      'inspectionItems': jsonEncode(inspectionItems.map((e) => e.toMap()).toList()),
      'partsUsed': jsonEncode(partsUsed.map((e) => e.toMap()).toList()),
    };
  }

  factory ServiceRecord.fromMap(Map<String, dynamic> map) {
    return ServiceRecord(
      id: map['id'],
      vehicleId: map['vehicleId'],
      customerName: map['customerName'],
      vehicleModel: map['vehicleModel'],
      date: map['date'],
      totalAmount: (map['totalAmount'] as num).toDouble(),
      status: map['status'],
      inspectionItems: (jsonDecode(map['inspectionItems']) as List)
          .map((e) => InspectionItem.fromMap(e))
          .toList(),
      partsUsed: (jsonDecode(map['partsUsed']) as List)
          .map((e) => PartUsed.fromMap(e))
          .toList(),
      approvalAt: map['approvalAt'],
      completedAt: map['completedAt'],
    );
  }

  ServiceRecord copyWith({
    String? id,
    String? vehicleId,
    String? customerName,
    String? vehicleModel,
    String? date,
    double? totalAmount,
    String? status,
    List<InspectionItem>? inspectionItems,
    List<PartUsed>? partsUsed,
    String? approvalAt,
    String? completedAt,
  }) {
    return ServiceRecord(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      customerName: customerName ?? this.customerName,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      inspectionItems: inspectionItems ?? this.inspectionItems,
      partsUsed: partsUsed ?? this.partsUsed,
      approvalAt: approvalAt ?? this.approvalAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
