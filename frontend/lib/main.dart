import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'router.dart';

import 'package:provider/provider.dart';
import 'backend/providers/service_provider.dart';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  runApp(const ServiceManagerApp());
}

class ServiceManagerApp extends StatelessWidget {
  const ServiceManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ServiceProvider()..loadDashboardData()),
      ],
      child: MaterialApp.router(
        title: 'Service Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Or user preference
        routerConfig: appRouter,
      ),
    );
  }
}
