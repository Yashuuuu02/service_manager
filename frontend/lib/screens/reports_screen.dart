import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../backend/providers/service_provider.dart';
import '../theme/app_colors.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceProvider>();
    final totalRevenue = provider.todaysRevenue; // Just a placeholder, ideally week/month
    final count = provider.todaysCount;

    return Scaffold(
        appBar: AppBar(title: const Text('Reports & Analytics')),
        body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
                _buildStatCard(
                    context, 
                    'Total Revenue (Today)', 
                    '₹ ${totalRevenue.toStringAsFixed(0)}', 
                    Icons.attach_money, 
                    AppColors.primary
                ),
                _buildStatCard(
                    context, 
                    'Services Completed', 
                    '$count', 
                    Icons.done_all, 
                    AppColors.statusOk
                ),
                 _buildStatCard(
                    context, 
                    'Pending Estimates', 
                    '${provider.pendingCount}', 
                    Icons.pending_actions, 
                    AppColors.statusWarning
                ),
                const Divider(height: 32),
                const Center(child: Text('Detailed charts coming in v2.0', style: TextStyle(color: Colors.grey))),
            ],
        ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
      return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                  children: [
                      Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: color, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Text(title, style: Theme.of(context).textTheme.bodyMedium),
                              Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                      ),
                  ],
              ),
          ),
      );
  }
}
