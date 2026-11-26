// ============================================================================
// File: main.dart
// Project: Simple College Store Management System
// Requirements Met:
//   - Storage: Hive & Hive Flutter (Local database with Boxes)
//   - State Management: Provider (ChangeNotifier, MultiProvider, Consumer)
//   - 4 CRUD Operations: Get, Add, Update, Delete for Categories & Products
//   - Features: Login, Register, Categories Management, Products Management
//   - Screen Count: 3 Screens (AuthScreen, HomeScreen, CategoryScreen)
//   - Strictly NO unauthorized packages (only hive, hive_flutter, provider)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Services
import 'services/hive_service.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/category_provider.dart';
import 'providers/product_provider.dart';

// Screens
import 'screens/splash_screen.dart';

// Main entry point of the Flutter application
void main() async {
  // 1. Ensure Flutter engine and widget bindings are initialized before async calls
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Hive and open all local storage boxes
  await HiveService.init();

  // 3. Launch the Flutter App wrapped inside MultiProvider
  runApp(
    MultiProvider(
      providers: [
        // AuthProvider: Handles Login, Register, and Current User session
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // CategoryProvider: Handles Category CRUD operations with Hive
        ChangeNotifierProvider(create: (_) => CategoryProvider()),

        // ProductProvider: Handles Product CRUD operations with Hive
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: const StoreApp(),
    ),
  );
}

// Root Application Widget
class StoreApp extends StatelessWidget {
  const StoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Application title
      title: 'Shoppy',

      // Remove the debug banner from top right corner
      debugShowCheckedModeBanner: false,

      // App Theme
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 2,
          centerTitle: false,
        ),
      ),

      // Initial landing screen: SplashScreen with smooth animation
      home: const SplashScreen(),
    );
  }
}
