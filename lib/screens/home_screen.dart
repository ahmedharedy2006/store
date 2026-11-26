// ============================================================================
// Screen 2: HomeScreen (Store Dashboard & Products Management)
// Purpose: Displays store statistics, category filter, and Products CRUD:
//   1. GET    - Displays list of products from Hive 'products_box'
//   2. ADD    - Dialog to add a new product into Hive
//   3. UPDATE - Dialog to modify existing product details
//   4. DELETE - Dialog to confirm and delete product from Hive
// State: Managed through ProductProvider, CategoryProvider, and AuthProvider
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/auth_provider.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import 'category_screen.dart';
import 'auth_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // --------------------------------------------------------------------------
  // Dialog to [CREATE] or [UPDATE] a Product
  // --------------------------------------------------------------------------
  void _showProductDialog(BuildContext context, {ProductModel? productToEdit}) {
    // Determine mode: edit or new product
    final isEditing = productToEdit != null;

    // Get current available categories
    final categories = context.read<CategoryProvider>().categories;

    // Controllers
    final nameController = TextEditingController(
      text: isEditing ? productToEdit.name : '',
    );
    final priceController = TextEditingController(
      text: isEditing ? productToEdit.price.toString() : '',
    );
    final quantityController = TextEditingController(
      text: isEditing ? productToEdit.quantity.toString() : '',
    );

    // Initial category selection
    String selectedCategory = isEditing
        ? productToEdit.categoryName
        : (categories.isNotEmpty ? categories.first.name : 'General');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                isEditing ? 'Edit Product' : 'Add New Product',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Product Name Input
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        hintText: 'e.g., iPhone 15',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 2. Category Dropdown Selector
                    DropdownButtonFormField<String>(
                      initialValue: categories.any((c) => c.name == selectedCategory)
                          ? selectedCategory
                          : (categories.isNotEmpty ? categories.first.name : null),
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat.name,
                          child: Text(cat.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedCategory = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // 3. Price Input
                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Price (\$)',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 4. Quantity / Stock Input
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock Quantity',
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
                    final priceText = priceController.text.trim();
                    final qtyText = quantityController.text.trim();

                    // Simple direct if checks
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter product name'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    final price = double.tryParse(priceText);
                    if (price == null || price < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid price'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    final quantity = int.tryParse(qtyText);
                    if (quantity == null || quantity < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid stock quantity'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    final productProvider = context.read<ProductProvider>();

                    if (isEditing) {
                      // [CRUD: UPDATE]
                      await productProvider.updateProduct(
                        id: productToEdit.id,
                        newName: name,
                        newCategoryName: selectedCategory,
                        newPrice: price,
                        newQuantity: quantity,
                      );
                    } else {
                      // [CRUD: CREATE]
                      await productProvider.addProduct(
                        name: name,
                        categoryName: selectedCategory,
                        price: price,
                        quantity: quantity,
                      );
                    }

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Product updated successfully!'
                                : 'Product saved successfully!',
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
      },
    );
  }

  // --------------------------------------------------------------------------
  // Confirmation Dialog for [DELETE] Operation
  // --------------------------------------------------------------------------
  void _confirmDeleteProduct(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Product'),
          content: Text(
            'Are you sure you want to delete "${product.name}"?',
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
                await context.read<ProductProvider>().deleteProduct(product.id);

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Product "${product.name}" deleted successfully.'),
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
    // Watch state from Providers
    final authProvider = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    final user = authProvider.currentUser;
    final products = productProvider.filteredProducts;
    final categories = categoryProvider.categories;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // App Bar with user info, Category screen navigation, and Logout
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shoppy',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            Text(
              user != null ? 'Welcome, ${user.name}' : 'Store Management',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          // Button to Navigate to Screen 3 (Category Management)
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: 'Manage Categories',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoryScreen()),
              );
            },
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              // Call AuthProvider logout
              context.read<AuthProvider>().logout();
              // Navigate back to AuthScreen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      // Floating Action Button to [ADD] new product
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        onPressed: () {
          // Check if there are any categories created first
          if (categories.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please add at least one category first!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          _showProductDialog(context);
        },
      ),

      body: Column(
        children: [
          // ------------------------------------------------------------------
          // 1. Dashboard Summary Cards
          // ------------------------------------------------------------------
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                // Total Products Card
                _buildStatCard(
                  title: 'Products',
                  value: '${productProvider.allProducts.length}',
                  icon: Icons.inventory_2_outlined,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 8),

                // Total Categories Card
                _buildStatCard(
                  title: 'Categories',
                  value: '${categories.length}',
                  icon: Icons.category_outlined,
                  color: Colors.orange.shade800,
                ),
                const SizedBox(width: 8),

                // Total Stock / Inventory Card
                _buildStatCard(
                  title: 'Stock Units',
                  value: '${productProvider.totalStockItems}',
                  icon: Icons.stacked_line_chart,
                  color: Colors.green.shade700,
                ),
              ],
            ),
          ),

          // ------------------------------------------------------------------
          // 2. Search Field
          // ------------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products by name...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (text) {
                // Update search query filter in ProductProvider
                productProvider.setSearchQuery(text);
              },
            ),
          ),

          // ------------------------------------------------------------------
          // 3. Category Filter Chips (All, Electronics, etc.)
          // ------------------------------------------------------------------
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                // 'All' Filter Chip
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: productProvider.selectedCategory == 'All',
                    selectedColor: Colors.indigo.shade100,
                    checkmarkColor: Colors.indigo,
                    onSelected: (selected) {
                      productProvider.setCategoryFilter('All');
                    },
                  ),
                ),
                // Chips for each category loaded from Hive
                ...categories.map((cat) {
                  final isSelected = productProvider.selectedCategory.toLowerCase() ==
                      cat.name.toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat.name),
                      selected: isSelected,
                      selectedColor: Colors.indigo.shade100,
                      checkmarkColor: Colors.indigo,
                      onSelected: (selected) {
                        productProvider.setCategoryFilter(selected ? cat.name : 'All');
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ------------------------------------------------------------------
          // 4. [CRUD: GET/READ] - Products List
          // ------------------------------------------------------------------
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            const Text(
                              'No products found!',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap "+ Add Product" below to add your first product.',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 85),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top Row: Avatar, Product Title, Category Badge, Edit & Delete buttons
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.indigo.shade50,
                                        foregroundColor: Colors.indigo,
                                        radius: 20,
                                        child: const Icon(Icons.shopping_bag_outlined, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
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
                                                product.categoryName,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.indigo.shade800,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Action Buttons: Edit and Delete
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.all(6),
                                            tooltip: 'Edit Product',
                                            onPressed: () => _showProductDialog(
                                              context,
                                              productToEdit: product,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.all(6),
                                            tooltip: 'Delete Product',
                                            onPressed: () => _confirmDeleteProduct(context, product),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Divider(height: 1, color: Colors.grey.shade200),
                                  const SizedBox(height: 10),
                                  // Bottom Row: Price tag and Stock counter
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.monetization_on_outlined,
                                            size: 16,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '\$${product.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: product.quantity > 5
                                              ? Colors.grey.shade100
                                              : Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: product.quantity > 5
                                                ? Colors.grey.shade300
                                                : Colors.red.shade200,
                                          ),
                                        ),
                                        child: Text(
                                          'Stock: ${product.quantity} units',
                                          style: TextStyle(
                                            color: product.quantity > 5
                                                ? Colors.grey.shade800
                                                : Colors.red.shade700,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // Helper Widget: Builds a compact statistical summary card
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
