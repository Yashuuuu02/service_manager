import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../backend/providers/service_provider.dart';
import '../../backend/models/service_record.dart';
import '../../widgets/job_status_stepper.dart';
import '../../widgets/job_status_pill.dart';
import '../../theme/app_colors.dart';

class JobDetailsScreen extends StatefulWidget {
  final String serviceId;

  const JobDetailsScreen({super.key, required this.serviceId});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  ServiceRecord? _record;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  Future<void> _loadRecord() async {
    // In a real app, we might fetch from DB by ID if not in provider.
    // Provider.allRecords should have it if loaded.
    final provider = context.read<ServiceProvider>();
    // Ensure records are loaded
    if (provider.allRecords.isEmpty) {
      await provider.loadAllRecords();
    }
    
    try {
      final record = provider.allRecords.firstWhere((r) => r.id == widget.serviceId);
      setState(() {
        _record = record;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateStatus(String newStatus) async {
    if (_record == null) return;
    
    // Optimistic Update
    final oldStatus = _record!.status;
    
    // Check constraints if needed (e.g. can't go back from Delivered)
    // For now, allow flexible movement as per V1 requirements
    
    await context.read<ServiceProvider>().updateJobStatus(_record!.id, newStatus);
    
    // Reload local record to get updated timestamps
    _loadRecord();
    
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to $newStatus')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Not Found')),
        body: const Center(child: Text('Service Record not found or deleted.')),
      );
    }
    
    final record = _record!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${record.vehicleModel} - ${record.customerName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
                 final bytes = await context.read<ServiceProvider>().generatePdfForRecord(record.id);
                 if (context.mounted) {
                     GoRouter.of(context).push('/pdf-preview', extra: bytes);
                 }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Stepper Section
            Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: JobStatusStepper(
                  currentStatus: record.status, 
                  onStepTap: (status) {
                      // Confirm dialog before changing status?
                      // For now, direct update for speed
                      _updateStatus(status);
                  }
              ),
            ),
            
            const Divider(height: 1),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildDetailRow('Date', DateFormat.yMMMd().format(DateTime.parse(record.date))),
                          const Divider(),
                          _buildDetailRow('Customer', record.customerName),
                          const Divider(),
                          _buildDetailRow('Vehicle', record.vehicleModel),
                          const Divider(),
                          _buildDetailRow('Total Amount', '₹ ${record.totalAmount.toStringAsFixed(0)}', isBold: true),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text('Parts & Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  
                  // Parts List
                  ...record.partsUsed.map((part) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(part.isLabor ? Icons.engineering : Icons.settings, size: 20),
                    title: Text(part.name),
                    trailing: Text('₹ ${part.total.toStringAsFixed(0)}'),
                    subtitle: Text('${part.quantity} x ₹ ${part.price}'),
                  )),
                  
                   if (record.partsUsed.isEmpty)
                    const Text('No parts or labor recorded.', style: TextStyle(color: Colors.grey)),

                  const SizedBox(height: 24),
                  const Text('Timestamps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (record.approvalAt != null)
                    Text('Approved: ${DateFormat.yMMMd().add_jm().format(DateTime.parse(record.approvalAt!))}'),
                  if (record.completedAt != null)
                    Text('Completed: ${DateFormat.yMMMd().add_jm().format(DateTime.parse(record.completedAt!))}'),
                  if (record.approvalAt == null && record.completedAt == null)
                    const Text('No timestamps available yet.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
            // Edit functionality placeholder
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit functionality coming soon')));
        },
        icon: const Icon(Icons.edit),
        label: const Text('Edit Job'),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(
              fontSize: 16, 
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal
          )),
        ],
      ),
    );
  }
}
