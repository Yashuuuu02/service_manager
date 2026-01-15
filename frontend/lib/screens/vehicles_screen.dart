import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Vehicles',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onBackground,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage registered vehicles',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.tertiary,
                  ),
            ),
            const SizedBox(height: 24),
            
            // Action Button
            SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                    onPressed: () => context.push('/add-vehicle'), 
                    icon: const Icon(Icons.add),
                    label: const Text("Add Vehicle"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                ),
            ),
            const SizedBox(height: 16),
            
            // Search
            TextField(
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: "Search by registration, model, or owner",
                    fillColor: AppColors.surface, 
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
            ),
            const SizedBox(height: 24),

            // Empty State
            Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 60),
                decoration: BoxDecoration(
                    color: AppColors.background, 
                    border: Border.all(color: Colors.grey.shade300), 
                    borderRadius: BorderRadius.circular(16)
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        const Icon(Icons.directions_car_outlined, size: 48, color: AppColors.onBackground),
                        const SizedBox(height: 16),
                        Text(
                            "No vehicles registered",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.onBackground
                            ),
                        ),
                        const SizedBox(height: 16),
                         ElevatedButton(
                            onPressed: () => context.push('/add-vehicle'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                            ),
                            child: const Text("Add First Vehicle"),
                        )
                    ],
                ),
            )
          ],
        ),
      ),
    );
  }
}
