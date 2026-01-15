import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../backend/providers/service_provider.dart';
import '../theme/app_colors.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch stats
    final provider = context.watch<ServiceProvider>();
    final now = DateTime.now();
    final dateString = DateFormat('EEEE, d MMMM y').format(now);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onBackground,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              dateString,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.tertiary,
                  ),
            ),
            const SizedBox(height: 24),

            // Stats Grid
            LayoutBuilder(
              builder: (context, constraints) {
                // simple responsive check
                final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  childAspectRatio: 1.5,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStatCard(
                      context,
                      title: "Today's Jobs",
                      value: "${provider.todaysCount}",
                      icon: Icons.assignment_outlined,
                      iconBg: AppColors.primaryContainer,
                      iconColor: AppColors.primary,
                    ),
                    _buildStatCard(
                      context,
                      title: "Pending Jobs",
                      value: "${provider.pendingCount}",
                      icon: Icons.warning_amber_rounded,
                      iconBg: const Color(0xFFFEF3F2), // Light Red/Orange
                      iconColor: AppColors.statusCritical, // Or Warning
                    ),
                    _buildStatCard(
                      context,
                      title: "Completed Today",
                      value: "${provider.completedCount}",
                      icon: Icons.check_circle_outline,
                      iconBg: Colors.white, // Transparent or specific? Design shows Check icon alone sometimes.
                      // Let's stick to design: Simple card, tick icon on right? 
                      // Actually design shows: "Completed Today" 0, tick icon.
                      // Let's use standard layout but maybe customize icon.
                      iconColor: AppColors.onBackground,
                      isSimple: true, 
                    ),
                     _buildStatCard(
                      context,
                      title: "Total Customers",
                      value: "0", // Placeholder for now, provider doesn't seem to have it exposed yet
                      icon: Icons.people_outline,
                      iconBg: AppColors.primaryContainer,
                      iconColor: AppColors.primary,
                    ),
                    _buildStatCard(
                      context,
                      title: "Low Stock Items",
                      value: "0", // Placeholder
                      icon: Icons.directions_car_outlined, // Design shows Car icon? Or box? Design shows Car in Low Stock item??
                      // Actually design for "Low Stock Items" shows a Car icon in a purple box. Maybe it's "Low Stock" -> "Parts" -> Box? 
                      // Wait, "Low Stock Items" card has a car icon on the uploaded image? No, "Low Stock Items" has a Car icon in the 1st image... wait.
                      // Row 3 left: "Low Stock Items", Icon: Car. 
                      // Row 2 right: "Total Customers", Icon: People.
                      // Let's follow image 1 exactly.
                      iconBg: AppColors.primaryContainer,
                      iconColor: AppColors.primary,
                    ),
                     _buildStatCard(
                      context,
                      title: "Today's Revenue",
                      value: "₹${provider.todaysRevenue.toStringAsFixed(0)}",
                      icon: Icons.currency_rupee,
                      iconBg: Colors.transparent,
                      iconColor: AppColors.onBackground,
                      isSimple: true,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Recent Job Cards Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Job Cards',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () => context.go('/jobs'),
                  child: Row(
                    children: [
                      Text('View All', style: TextStyle(color: AppColors.primary)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 1),
            
            // Recent Job Cards Content (Empty State)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              color: Colors.white, // Or consistent with card
              // The design shows this section as a card itself or just a region. 
              // The design puts "Recent Job Cards" inside a white container with "View All". 
              // Then the content is inside.
              child: Column(
                children: [
                   Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       border: Border.all(color: AppColors.onBackground, width: 2), // Thick black outline clock
                     ),
                     child: const Icon(Icons.access_time, size: 32),
                   ),
                   const SizedBox(height: 16),
                   Text(
                     "No job cards yet",
                     style: Theme.of(context).textTheme.bodyMedium,
                   ),
                   const SizedBox(height: 24),
                   ElevatedButton(
                     onPressed: () => context.push('/new-service'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: AppColors.primary,
                       foregroundColor: Colors.white,
                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                     ),
                     child: const Text("Create First Job Card"),
                   )
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // 2x2 grid
                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.0, // Wide buttons
                        children: [
                          _buildQuickActionButton(
                            context,
                            label: "New Job Card",
                            icon: Icons.assignment_add,
                            isPrimary: true,
                            onTap: () => context.push('/new-service'),
                          ),
                          _buildQuickActionButton(
                            context,
                            label: "Add Customer",
                            icon: Icons.person_add_outlined,
                            isPrimary: false,
                            onTap: () => context.push('/add-customer'),
                          ),
                          _buildQuickActionButton(
                            context,
                            label: "Add Vehicle",
                            icon: Icons.directions_car_outlined,
                            isPrimary: false,
                            onTap: () => context.push('/add-vehicle'),
                          ),
                          _buildQuickActionButton(
                            context,
                            label: "Quick Search",
                            icon: Icons.search,
                            isPrimary: false,
                            onTap: () => context.go('/jobs'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    bool isSimple = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onBackground,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isSimple)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                )
              else 
                 Icon(icon, color: iconColor, size: 24),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(BuildContext context, {
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : AppColors.onBackground,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : AppColors.onBackground,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
