import 'package:flutter/material.dart';
import '../backend/models/service_record.dart';

class JobStatusPill extends StatelessWidget {
  final String status;

  const JobStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case ServiceRecord.statusInspectionPending:
        color = Colors.orange;
        break;
      case ServiceRecord.statusApprovalPending:
        color = Colors.purple;
        break;
      case ServiceRecord.statusInProgress:
        color = Colors.blue;
        break;
      case ServiceRecord.statusReady:
        color = Colors.teal;
        break;
      case ServiceRecord.statusDelivered:
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
