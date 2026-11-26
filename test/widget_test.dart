import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/models/category_model.dart';
import 'package:store_app/models/product_model.dart';
import 'package:store_app/models/user_model.dart';

void main() {
  test('Models toMap and fromMap test', () {
    // 1. Test UserModel
    final user = UserModel(
      id: '1',
      name: 'Ahmed',
      email: 'ahmed@test.com',
      password: '123',
    );
    final userMap = user.toMap();
    final restoredUser = UserModel.fromMap(userMap);
    expect(restoredUser.email, 'ahmed@test.com');
    expect(restoredUser.name, 'Ahmed');

    // 2. Test CategoryModel
    final category = CategoryModel(
      id: 'cat_1',
      name: 'Electronics',
      description: 'Laptops and phones',
    );
    final catMap = category.toMap();
    final restoredCat = CategoryModel.fromMap(catMap);
    expect(restoredCat.name, 'Electronics');

    // 3. Test ProductModel
    final product = ProductModel(
      id: 'prod_1',
      name: 'MacBook',
      categoryName: 'Electronics',
      price: 1500.0,
      quantity: 5,
    );
    final prodMap = product.toMap();
    final restoredProd = ProductModel.fromMap(prodMap);
    expect(restoredProd.name, 'MacBook');
    expect(restoredProd.price, 1500.0);
    expect(restoredProd.quantity, 5);
  });
}
