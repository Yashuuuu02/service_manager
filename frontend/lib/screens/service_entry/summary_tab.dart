import 'package:flutter/material.dart';

class SummaryTab extends StatelessWidget {
  final VoidCallback onPrev;
  final String customerName;
  final String vehicleModel;
  final double totalAmount;
  final VoidCallback onSave;

  const SummaryTab({
      super.key, 
      required this.onPrev,
      required this.customerName,
      required this.vehicleModel,
      required this.totalAmount,
      required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
               Text('Customer: $customerName', style: const TextStyle(fontWeight: FontWeight.bold)),
               Text('Vehicle: $vehicleModel'),
               const Divider(),
               Center(child: Text('Total: ₹ ${totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save),
            label: const Text('SAVE SERVICE'),
             style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
          ),
        ),
      ],
    );
  }
}
