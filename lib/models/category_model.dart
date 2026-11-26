// ============================================================================
// Model: CategoryModel
// Purpose: Represents a product category (e.g., Electronics, Clothes, Food).
// Storage: Saved inside Hive 'categories_box' using CRUD operations.
// ============================================================================

class CategoryModel {
  // Unique ID for the category (generated using timestamp)
  final String id;

  // Name of the category (e.g., "Beverages", "Shoes")
  final String name;

  // Optional description providing more details about the category
  final String description;

  // Constructor with required id, name, and optional description
  CategoryModel({
    required this.id,
    required this.name,
    this.description = '',
  });

  // Convert CategoryModel to a Map to save it into Hive Box
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  // Create CategoryModel instance from a Map retrieved from Hive Box
  factory CategoryModel.fromMap(Map<dynamic, dynamic> map) {
    return CategoryModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
    );
  }
}
