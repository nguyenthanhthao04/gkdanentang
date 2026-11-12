import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirebaseService {
  static final CollectionReference _productsRef =
      FirebaseFirestore.instance.collection('products');

  /// Stream of products listening in real-time from Firestore
  static Stream<List<Product>> getProductsStream() {
    return _productsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  /// Add a new product to Firestore with fields: image, name, price, soluong
  static Future<void> addProduct({
    required String name,
    required String price,
    required int soluong,
    String image = 'assets/images/sony_wh1000xm5-4a0be7.png',
  }) async {
    await _productsRef.add({
      'name': name,
      'price': price,
      'soluong': soluong,
      'image': image,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update an existing product in Firestore with fields: name, price, soluong, image
  static Future<void> updateProduct({
    required String id,
    required String name,
    required String price,
    required int soluong,
    String? image,
  }) async {
    final Map<String, dynamic> updateData = {
      'name': name,
      'price': price,
      'soluong': soluong,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (image != null && image.isNotEmpty) {
      updateData['image'] = image;
    }
    await _productsRef.doc(id).update(updateData);
  }

  /// Delete product by ID from Firestore
  static Future<void> deleteProduct(String id) async {
    await _productsRef.doc(id).delete();
  }

  /// Seed initial products from Figma into Firestore if empty
  static Future<void> seedInitialProductsIfEmpty() async {
    try {
      final snapshot = await _productsRef.limit(1).get();
      if (snapshot.docs.isEmpty) {
        for (final product in Product.dummyProducts) {
          await _productsRef.add({
            'name': product.name,
            'price': product.price,
            'soluong': product.soluong,
            'image': product.image,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      // ignore
    }
  }
}
