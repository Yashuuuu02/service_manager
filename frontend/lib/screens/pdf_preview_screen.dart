import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../backend/providers/service_provider.dart';
import '../backend/models/service_record.dart';

class PdfPreviewScreen extends StatelessWidget {
  final String? serviceRecordId; // Optional, if accessing specific

  const PdfPreviewScreen({super.key, this.serviceRecordId});

  @override
  Widget build(BuildContext context) {
    // For demo, if no ID passed, take the last one or show list
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Preview')),
      body: PdfPreview(
        build: (format) async {
             final provider = context.read<ServiceProvider>();
             if (provider.todaysRecords.isNotEmpty) {
                 return await provider.generatePdfForRecord(provider.todaysRecords.first.id);
             } else {
                 return await provider.generatePdfForRecord("mock_id"); // Fallback
             }
        },
      ),
    );
  }
}
