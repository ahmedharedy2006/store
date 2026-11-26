// ============================================================================
// Provider: ProductProvider
// Purpose: Handles all CRUD operations for Products using Hive & Provider.
// 4 CRUD Operations:
//   1. CREATE (Add new product)
//   2. READ   (Get/load products from Hive)
//   3. UPDATE (Edit existing product in Hive)
//   4. DELETE (Remove product from Hive)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/product_model.dart';
import '../services/hive_service.dart';

class ProductProvider extends ChangeNotifier {
  // In-memory list of all products
  List<ProductModel> _products = [];

  // Currently selected category filter ('All' means no filter)
  String _selectedCategory = 'All';

  // Search query text for live filtering
  String _searchQuery = '';

  // Loading state flag
  bool _isLoading = false;

  // Constructor: Load existing products from Hive automatically upon initialization
  ProductProvider() {
    loadProducts();
  }

  // --------------------------------------------------------------------------
  // Getters
  // --------------------------------------------------------------------------
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  // Returns all products without filters (for raw statistics)
  List<ProductModel> get allProducts => _products;

  // Returns filtered products based on selected category and search query
  List<ProductModel> get filteredProducts {
    return _products.where((product) {
      // 1. Check category filter
      final matchesCategory = _selectedCategory == 'All' ||
          product.categoryName.toLowerCase() == _selectedCategory.toLowerCase();

      // 2. Check search text filter
      final matchesSearch = product.name
          .toLowerCase()
          .contains(_searchQuery.toLowerCase().trim());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Total inventory calculation (price * quantity across all products)
  double get totalInventoryValue {
    return _products.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  // Total quantity count of all items in stock
  int get totalStockItems {
    return _products.fold(0, (sum, item) => sum + item.quantity);
  }

  // --------------------------------------------------------------------------
  // Category Filter and Search Methods
  // --------------------------------------------------------------------------
  void setCategoryFilter(String categoryName) {
    _selectedCategory = categoryName;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // [CRUD - READ]: Load all products from Hive Box
  // --------------------------------------------------------------------------
  void loadProducts() {
    _isLoading = true;
    notifyListeners();

    try {
      // Access the products Hive box
      final Box box = HiveService.getProductsBox();

      // Iterate through box values and convert them into ProductModel
      final List<ProductModel> loadedList = [];
      for (var value in box.values) {
        if (value is Map) {
          loadedList.add(ProductModel.fromMap(value));
        }
      }

      // Update local state list
      _products = loadedList;
    } catch (e) {
      debugPrint('Error loading products from Hive: $e');
    } finally {
      _isLoading = false;
      // Notify listening UI widgets
      notifyListeners();
    }
  }

  // --------------------------------------------------------------------------
  // [CRUD - CREATE]: Add a new product to Hive Box
  // --------------------------------------------------------------------------
  Future<void> addProduct({
    required String name,
    required String categoryName,
    required double price,
    required int quantity,
  }) async {
    // Access Hive box
    final Box box = HiveService.getProductsBox();

    // Generate unique product ID
    final String id = 'prod_${DateTime.now().millisecondsSinceEpoch}';

    // Create ProductModel instance
    final newProduct = ProductModel(
      id: id,
      name: name.trim(),
      categoryName: categoryName.trim(),
      price: price,
      quantity: quantity,
    );

    // Save into Hive Box: Key = id, Value = Map representation
    await box.put(id, newProduct.toMap());

    // Add to in-memory list and notify UI immediately
    _products.add(newProduct);
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // [CRUD - UPDATE]: Modify an existing product in Hive Box
  // --------------------------------------------------------------------------
  Future<void> updateProduct({
    required String id,
    required String newName,
    required String newCategoryName,
    required double newPrice,
    required int newQuantity,
  }) async {
    // Access Hive box
    final Box box = HiveService.getProductsBox();

    // Create updated ProductModel instance
    final updatedProduct = ProductModel(
      id: id,
      name: newName.trim(),
      categoryName: newCategoryName.trim(),
      price: newPrice,
      quantity: newQuantity,
    );

    // Overwrite the existing entry in Hive Box using its key (id)
    await box.put(id, updatedProduct.toMap());

    // Update the item in the in-memory list
    final index = _products.indexWhere((prod) => prod.id == id);
    if (index != -1) {
      _products[index] = updatedProduct;
      // Notify UI widgets to refresh
      notifyListeners();
    }
  }

  // --------------------------------------------------------------------------
  // [CRUD - DELETE]: Remove a product from Hive Box
  // --------------------------------------------------------------------------
  Future<void> deleteProduct(String id) async {
    // Access Hive box
    final Box box = HiveService.getProductsBox();

    // Delete record from Hive box by key
    await box.delete(id);

    // Remove from in-memory list
    _products.removeWhere((prod) => prod.id == id);

    // Notify UI widgets to rebuild
    notifyListeners();
  }
}
