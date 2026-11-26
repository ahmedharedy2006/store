// ============================================================================
// Model: ProductModel
// Purpose: Represents an item/product in the store.
// Storage: Saved inside Hive 'products_box' using CRUD operations.
// ============================================================================

class ProductModel {
  // Unique ID for the product (generated using timestamp)
  final String id;

  // Name/Title of the product (e.g., "Apple iPhone 15", "T-Shirt")
  final String name;

  // The category this product belongs to (e.g., "Electronics")
  final String categoryName;

  // Unit selling price of the product
  final double price;

  // Available stock count / quantity in the store
  final int quantity;

  // Constructor to initialize all required product properties
  ProductModel({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.price,
    required this.quantity,
  });

  // Convert ProductModel to a Map for Hive box storage (Create & Update)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'categoryName': categoryName,
      'price': price,
      'quantity': quantity,
    };
  }

  // Create ProductModel instance from a Map stored in Hive (Read)
  factory ProductModel.fromMap(Map<dynamic, dynamic> map) {
    return ProductModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      categoryName: map['categoryName']?.toString() ?? 'General',
      price: (map['price'] is num) ? (map['price'] as num).toDouble() : 0.0,
      quantity: (map['quantity'] is num) ? (map['quantity'] as num).toInt() : 0,
    );
  }
}
