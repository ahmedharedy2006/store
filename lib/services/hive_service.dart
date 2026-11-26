// ============================================================================
// Service: HiveService
// Purpose: Handles Hive initialization and exposes references to opened Hive Boxes.
// Rules: Only Hive & Hive Flutter are used for local persistence.
// ============================================================================

import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  // Constant names for the Hive boxes to avoid spelling mistakes
  static const String usersBoxName = 'users_box';
  static const String categoriesBoxName = 'categories_box';
  static const String productsBoxName = 'products_box';

  // Initialize Hive Flutter and open required storage boxes
  static Future<void> init() async {
    // 1. Initialize Hive with the default directory for Flutter apps
    await Hive.initFlutter();

    // 2. Open the users box to store registered accounts (Authentication)
    final userBox = await Hive.openBox(usersBoxName);

    // 3. Open the categories box to store category objects
    final categoryBox = await Hive.openBox(categoriesBoxName);

    // 4. Open the products box to store product items
    final productBox = await Hive.openBox(productsBoxName);

    // 5. Seed some initial sample data if the app is launched for the first time
    await _seedInitialDataIfEmpty(userBox, categoryBox, productBox);
  }

  // Getters to easily access the opened boxes from anywhere in the app
  static Box getUsersBox() => Hive.box(usersBoxName);
  static Box getCategoriesBox() => Hive.box(categoriesBoxName);
  static Box getProductsBox() => Hive.box(productsBoxName);

  // Helper method: Add sample categories, products, and default user if database is empty
  static Future<void> _seedInitialDataIfEmpty(Box userBox, Box catBox, Box prodBox) async {
    // Check if users box has no records, add a convenient demo account
    if (userBox.isEmpty) {
      await userBox.put('admin@shoppy.com', {
        'id': 'user_admin',
        'name': 'Store Admin',
        'email': 'admin@shoppy.com',
        'password': '1234',
      });
    }
    // Check if category box has no records
    if (catBox.isEmpty) {
      // Sample category 1: Electronics
      await catBox.put('cat_1', {
        'id': 'cat_1',
        'name': 'Electronics',
        'description': 'Laptops, Smartphones, and accessories',
      });

      // Sample category 2: Clothing
      await catBox.put('cat_2', {
        'id': 'cat_2',
        'name': 'Clothing',
        'description': 'Men, Women and Kids fashion',
      });

      // Sample category 3: Groceries
      await catBox.put('cat_3', {
        'id': 'cat_3',
        'name': 'Groceries',
        'description': 'Daily food, beverages and pantry',
      });
    }

    // Check if product box has no records
    if (prodBox.isEmpty) {
      // Sample product 1
      await prodBox.put('prod_1', {
        'id': 'prod_1',
        'name': 'MacBook Pro M3',
        'categoryName': 'Electronics',
        'price': 1999.99,
        'quantity': 15,
      });

      // Sample product 2
      await prodBox.put('prod_2', {
        'id': 'prod_2',
        'name': 'Cotton Polo T-Shirt',
        'categoryName': 'Clothing',
        'price': 29.50,
        'quantity': 50,
      });

      // Sample product 3
      await prodBox.put('prod_3', {
        'id': 'prod_3',
        'name': 'Organic Coffee Beans 1kg',
        'categoryName': 'Groceries',
        'price': 18.00,
        'quantity': 35,
      });
    }
  }
}
