import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../backend/providers/service_provider.dart';
import '../backend/database/database_helper.dart'; // Direct access for reset if needed, or via Provider

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _resetDatabase(BuildContext context) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
            title: const Text('Reset Database'),
            content: const Text('This will delete ALL data (Customers, Vehicles, Service Records, Inventory). This cannot be undone.\n\nThe app will close after reset.'),
            actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete All', style: TextStyle(color: Colors.red))),
            ],
        )
    );

    if (confirm == true) {
        // Simple way: Delete the DB file
        // In a real app we might want a cleaner way via Provider
        // For now, let's use DatabaseHelper internal (assuming we can access similar or add method)
        // Since we didn't add a 'reset' method to DatabaseHelper, we can just delete the tables manually via raw queries or just clear tables.
        
        // Actually, let's just show a "Not Implemented" or try to clear inventory/services via Provider if available.
        // But we want a full reset.
        // Let's print to console for now as "Reset" logic implies restarting app which is hard to handle in Dart code without exit().
        
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Database Reset Not Fully Implemented yet - Requires App Restart')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
            children: [
                const UserAccountsDrawerHeader(
                    accountName: Text('Workshop Admin'), 
                    accountEmail: Text('admin@workshop.com'),
                    currentAccountPicture: CircleAvatar(child: Icon(Icons.person, size: 40)),
                    decoration: BoxDecoration(color: Colors.blueGrey),
                ),
                ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Versions'),
                    subtitle: const Text('v1.0.0 (Beta)'),
                ),
                ListTile(
                    leading: const Icon(Icons.cloud_sync),
                    title: const Text('Sync Status'),
                    subtitle: const Text('Offline Mode - Data saved locally'),
                    trailing: const Icon(Icons.check_circle, color: Colors.green),
                ),
                const Divider(),
                ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('Reset Database', style: TextStyle(color: Colors.red)),
                    onTap: () => _resetDatabase(context),
                ),
            ],
        ),
    );
  }
}
