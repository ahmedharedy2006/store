// ============================================================================
// Provider: CategoryProvider
// Purpose: Handles all CRUD operations for Categories using Hive & Provider.
// 4 CRUD Operations:
//   1. CREATE (Add new category)
//   2. READ   (Get/load categories from Hive)
//   3. UPDATE (Edit existing category in Hive)
//   4. DELETE (Remove category from Hive)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/category_model.dart';
import '../services/hive_service.dart';

class CategoryProvider extends ChangeNotifier {
  // In-memory list of categories for the UI
  List<CategoryModel> _categories = [];

  // Loading state indicator
  bool _isLoading = false;

  // Constructor: Automatically load categories from Hive when provider is created
  CategoryProvider() {
    loadCategories();
  }

  // --------------------------------------------------------------------------
  // Getters for UI access
  // --------------------------------------------------------------------------
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  // --------------------------------------------------------------------------
  // [CRUD - READ]: Load all categories from Hive Box
  // --------------------------------------------------------------------------
  void loadCategories() {
    _isLoading = true;
    notifyListeners();

    try {
      // Access the categories Hive box
      final Box box = HiveService.getCategoriesBox();

      // Read all values stored in the Hive box
      final List<CategoryModel> loadedList = [];
      for (var value in box.values) {
        if (value is Map) {
          loadedList.add(CategoryModel.fromMap(value));
        }
      }

      // Update in-memory list
      _categories = loadedList;
    } catch (e) {
      debugPrint('Error loading categories from Hive: $e');
    } finally {
      _isLoading = false;
      // Notify listening UI widgets that the list has changed
      notifyListeners();
    }
  }

  // --------------------------------------------------------------------------
  // [CRUD - CREATE]: Add a new category to Hive Box
  // --------------------------------------------------------------------------
  Future<void> addCategory({
    required String name,
    required String description,
  }) async {
    // Access Hive box
    final Box box = HiveService.getCategoriesBox();

    // Generate unique category ID using current timestamp
    final String id = 'cat_${DateTime.now().millisecondsSinceEpoch}';

    // Create CategoryModel instance
    final newCategory = CategoryModel(
      id: id,
      name: name.trim(),
      description: description.trim(),
    );

    // Save into Hive box: Key = id, Value = Map representation
    await box.put(id, newCategory.toMap());

    // Add to in-memory list and notify UI immediately
    _categories.add(newCategory);
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // [CRUD - UPDATE]: Modify an existing category in Hive Box
  // --------------------------------------------------------------------------
  Future<void> updateCategory({
    required String id,
    required String newName,
    required String newDescription,
  }) async {
    // Access Hive box
    final Box box = HiveService.getCategoriesBox();

    // Create updated CategoryModel object with same ID
    final updatedCategory = CategoryModel(
      id: id,
      name: newName.trim(),
      description: newDescription.trim(),
    );

    // Overwrite the record in Hive box using its key (id)
    await box.put(id, updatedCategory.toMap());

    // Update the item in the in-memory list
    final index = _categories.indexWhere((cat) => cat.id == id);
    if (index != -1) {
      _categories[index] = updatedCategory;
      // Notify UI widgets of the update
      notifyListeners();
    }
  }

  // --------------------------------------------------------------------------
  // [CRUD - DELETE]: Remove a category from Hive Box
  // --------------------------------------------------------------------------
  Future<void> deleteCategory(String id) async {
    // Access Hive box
    final Box box = HiveService.getCategoriesBox();

    // Delete record from Hive box by key
    await box.delete(id);

    // Remove from in-memory list
    _categories.removeWhere((cat) => cat.id == id);

    // Notify UI widgets to rebuild without the deleted category
    notifyListeners();
  }
}
