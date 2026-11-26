// ============================================================================
// Screen 3: CategoryScreen
// Purpose: Dedicated screen for Category Management implementing all 4 CRUD:
//   1. GET    - Displays all categories loaded from Hive
//   2. ADD    - Dialog to add new category into Hive
//   3. UPDATE - Dialog to edit existing category in Hive
//   4. DELETE - Dialog to confirm and delete category from Hive
// State: Managed through CategoryProvider (ChangeNotifier)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  // --------------------------------------------------------------------------
  // Dialog to [CREATE] or [UPDATE] a Category
  // --------------------------------------------------------------------------
  void _showCategoryDialog(BuildContext context, {CategoryModel? categoryToEdit}) {
    // If categoryToEdit != null, we are in UPDATE mode; otherwise in ADD mode
    final isEditing = categoryToEdit != null;

    // Controllers initialized with existing values if editing
    final nameController = TextEditingController(
      text: isEditing ? categoryToEdit.name : '',
    );
    final descController = TextEditingController(
      text: isEditing ? categoryToEdit.description : '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEditing ? 'Edit Category' : 'Add New Category',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category Name Input
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'e.g., Electronics, Food',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Category Description Input
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Brief summary of items',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),

            // Save / Update Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                final description = descController.text.trim();

                // Simple direct if check
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter category name'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                final catProvider = context.read<CategoryProvider>();

                if (isEditing) {
                  // [CRUD: UPDATE]
                  await catProvider.updateCategory(
                    id: categoryToEdit.id,
                    newName: name,
                    newDescription: description,
                  );
                } else {
                  // [CRUD: CREATE]
                  await catProvider.addCategory(
                    name: name,
                    description: description,
                  );
                }

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEditing
                            ? 'Category updated successfully!'
                            : 'Category added successfully!',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Text(isEditing ? 'Update' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // Confirmation Dialog for [DELETE] Operation
  // --------------------------------------------------------------------------
  void _confirmDeleteCategory(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Category'),
          content: Text(
            'Are you sure you want to delete "${category.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                // [CRUD: DELETE]
                await context.read<CategoryProvider>().deleteCategory(category.id);

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Category "${category.name}" deleted successfully.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch CategoryProvider to reactively rebuild list when categories change
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = categoryProvider.categories;

    // Read ProductProvider to count products per category
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categories Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      // Floating Action Button to [ADD] new category
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
        onPressed: () => _showCategoryDialog(context),
      ),

      // [CRUD: GET/READ] - Display list of categories
      body: categoryProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category_outlined, size: 72, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'No categories found!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the "+ Add Category" button to create one.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];

                    // Count how many products belong to this category
                    final productCount = productProvider.allProducts
                        .where((p) => p.categoryName.toLowerCase() == category.name.toLowerCase())
                        .length;

                    return Card(
                      elevation: 2.5,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        // Category Icon with badge
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.shade50,
                          foregroundColor: Colors.indigo.shade700,
                          radius: 24,
                          child: const Icon(Icons.label_important_outline),
                        ),
                        // Category Name & Product Count
                        title: Text(
                          category.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        // Category Description and Product Count badge
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (category.description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  category.description,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$productCount product(s) linked',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.indigo.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Actions: Edit and Delete Buttons
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // [CRUD: UPDATE] Button
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(6),
                              tooltip: 'Edit Category',
                              onPressed: () => _showCategoryDialog(
                                context,
                                categoryToEdit: category,
                              ),
                            ),
                            const SizedBox(width: 4),
                            // [CRUD: DELETE] Button
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(6),
                              tooltip: 'Delete Category',
                              onPressed: () => _confirmDeleteCategory(context, category),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
