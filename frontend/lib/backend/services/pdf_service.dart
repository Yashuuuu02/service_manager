import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/service_record.dart';

class PdfService {
  Future<Uint8List> generateInvoice(ServiceRecord record) async {
    final pdf = pw.Document();
    
    // Currency format
    final currency = NumberFormat.simpleCurrency(name: 'INR');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            _buildHeader(record),
            pw.Divider(),
            _buildCustomerDetails(record),
             pw.SizedBox(height: 20),
            _buildInspectionSummary(record),
            pw.SizedBox(height: 20),
            _buildPartsAndLaborTable(record, currency),
            pw.Divider(),
            _buildTotal(record, currency),
            pw.SizedBox(height: 40),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(ServiceRecord record) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('SERVICE MANAGER', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20)),
            pw.Text('Authorized Service Center'),
            pw.Text('Pune, Maharashtra'),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('INVOICE / ESTIMATE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
            pw.Text('Date: ${DateFormat('dd MMM yyyy').format(DateTime.parse(record.date))}'),
            pw.Text('ID: #${record.id.substring(0, 8).toUpperCase()}'),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildCustomerDetails(ServiceRecord record) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Customer: ${record.customerName}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Vehicle: ${record.vehicleModel}'),
            ],
          ),
           pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Status: ${record.status.toUpperCase()}', style: pw.TextStyle(color: PdfColors.blue)),
            ],
          ),
        ],
      ),
    );
  }
  
  pw.Widget _buildInspectionSummary(ServiceRecord record) {
      // Filter issues
      final issues = record.inspectionItems.where((i) => i.status == 'Attention' || i.status == 'Critical').toList();
      
      if (issues.isEmpty) {
          return pw.Row(children: [pw.Text('Inspection: All checked items seem OK.', style: const pw.TextStyle(color: PdfColors.green))]);
      }
      
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
            pw.Text('INSPECTION ALERTS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ...issues.map((item) => pw.Row(
                children: [
                    pw.Text(item.status == 'Critical' ? '[CRITICAL] ' : '[ATTENTION] ', style: pw.TextStyle(color: item.status == 'Critical' ? PdfColors.red : PdfColors.orange)),
                    pw.Text('${item.name}'),
                    if (item.notes != null) pw.Text(' - ${item.notes}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                ]
            )),
        ]
      );
  }

  pw.Widget _buildPartsAndLaborTable(ServiceRecord record, NumberFormat currency) {
    return pw.Table.fromTextArray(
      headers: ['Description', 'Type', 'Qty', 'Unit Price', 'Total'],
      data: record.partsUsed.map((part) => [
        part.name,
        part.isLabor ? 'Labor' : 'Part',
        part.quantity.toString(),
        part.price.toStringAsFixed(0),
        part.total.toStringAsFixed(0),
      ]).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
    );
  }

  pw.Widget _buildTotal(ServiceRecord record, NumberFormat currency) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text('GRAND TOTAL:  ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text('INR ${record.totalAmount.toStringAsFixed(0)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
      ],
    );
  }
  
  pw.Widget _buildFooter() {
      return pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
              pw.Column(children: [
                   pw.Container(width: 100, height: 1, color: PdfColors.black),
                   pw.SizedBox(height: 5),
                   pw.Text('Customer Signature'),
              ]),
              pw.Column(children: [
                   pw.Container(width: 100, height: 1, color: PdfColors.black),
                   pw.SizedBox(height: 5),
                   pw.Text('Workshop Signature'),
              ]),
          ]
      );
  }
}
