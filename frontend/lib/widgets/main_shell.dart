import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Mock state for Sync Status 
  bool _isOffline = true; // Default to offline for "Offline Ready" look
  
  void _toggleOffline() {
      // Just a mock toggle for demo
      setState(() {
          _isOffline = !_isOffline;
      });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // Use a clean white app bar with specific styling
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.onBackground),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
            children: [
                Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.handyman_outlined, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                    'GarageFlow Pro', 
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold, 
                        color: AppColors.onBackground
                    )
                ),
            ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
                'Offline Ready',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                ),
            ),
          ),
        ],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
             // Drawer Header
             Container(
                 padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                 child: Row(
                     children: [
                         Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.handyman_outlined, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                            'GarageFlow Pro', 
                            style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold, 
                                color: AppColors.onBackground
                            )
                        ),
                        const Spacer(),
                        IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                        )
                     ],
                 ),
             ),
             const Divider(height: 1),
             
             // Drawer Items
             Expanded(
                 child: ListView(
                     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                     children: [
                         _buildDrawerItem(context, icon: Icons.dashboard_outlined, label: 'Dashboard', path: '/', isSelected: GoRouterState.of(context).uri.toString() == '/'),
                         _buildDrawerItem(context, icon: Icons.people_outline, label: 'Customers', path: '/customers', isSelected: false), // Placeholder
                         _buildDrawerItem(context, icon: Icons.directions_car_outlined, label: 'Vehicles', path: '/vehicles', isSelected: false), // Placeholder
                         _buildDrawerItem(context, icon: Icons.assignment_outlined, label: 'Job Cards', path: '/jobs', isSelected: GoRouterState.of(context).uri.toString().startsWith('/jobs')),
                         _buildDrawerItem(context, icon: Icons.fact_check_outlined, label: 'Inspections', path: '/inspections', isSelected: false),
                         _buildDrawerItem(context, icon: Icons.engineering_outlined, label: 'Technicians', path: '/technicians', isSelected: false),
                         _buildDrawerItem(context, icon: Icons.inventory_2_outlined, label: 'Parts & Inventory', path: '/inventory', isSelected: GoRouterState.of(context).uri.toString().startsWith('/inventory')),
                         _buildDrawerItem(context, icon: Icons.receipt_long_outlined, label: 'Invoices', path: '/reports', isSelected: GoRouterState.of(context).uri.toString().startsWith('/reports')),
                         _buildDrawerItem(context, icon: Icons.settings_outlined, label: 'Settings', path: '/settings', isSelected: GoRouterState.of(context).uri.toString().startsWith('/settings')),
                     ],
                 ),
             ),
             
             // Drawer Footer
             Padding(
                 padding: const EdgeInsets.all(16),
                 child: Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(
                         color: AppColors.background,
                         borderRadius: BorderRadius.circular(8),
                         border: Border.all(color: Colors.grey.shade200),
                     ),
                     child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                             Text('Offline Mode Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.onBackground)),
                             const SizedBox(height: 4),
                             Text('All data stored locally on device', style: TextStyle(fontSize: 12, color: AppColors.tertiary)),
                         ],
                     ),
                 ),
             ),
          ],
        ),
      ),
      body: widget.child,
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String label, required String path, required bool isSelected}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: ListTile(
            leading: Icon(icon, color: isSelected ? Colors.white : AppColors.onBackground.withOpacity(0.7)),
            title: Text(label, style: TextStyle(
                color: isSelected ? Colors.white : AppColors.onBackground,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            )),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            tileColor: isSelected ? AppColors.primary : Colors.transparent,
            onTap: () {
                Navigator.pop(context); // Close drawer
                context.go(path);
            },
        ),
      );
  }
}
