import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/main_shell.dart';

import 'screens/dashboard_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/service_entry/service_entry_screen.dart';
import 'screens/pdf_preview_screen.dart';
import 'screens/jobs_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/customers_screen.dart';
import 'screens/vehicles_screen.dart';
import 'screens/add_vehicle_screen.dart';
import 'screens/add_customer_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/customers',
          builder: (context, state) => const CustomersScreen(),
        ),
        GoRoute(
          path: '/vehicles',
          builder: (context, state) => const VehiclesScreen(),
        ),
        GoRoute(
          path: '/jobs',
          builder: (context, state) => const JobsScreen(),
        ),
        GoRoute(
          path: '/inventory', 
          builder: (context, state) => const InventoryScreen(), 
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const ReportsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/new-service',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ServiceEntryScreen(),
    ),
    GoRoute(
      path: '/add-vehicle',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddVehicleScreen(),
    ),
    GoRoute(
      path: '/add-customer',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddCustomerScreen(),
    ),
    GoRoute(
      path: '/pdf-preview',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PdfPreviewScreen(),
    ),
  ],
);
