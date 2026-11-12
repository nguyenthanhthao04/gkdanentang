import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String price;
  final int soluong;
  final String image;
  final String category;

  // Backward-compatibility getters
  int get stock => soluong;
  String get imageAsset => image;

  /// Numeric price for sorting & filtering
  int get numericPrice {
    final clean = price.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 0;
  }

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.soluong,
    required this.image,
    this.category = 'Tất cả',
  });

  /// Format any number or string into Vietnamese currency display (e.g. 10.000 đ, 1.000.000 đ)
  static String formatCurrency(dynamic raw) {
    if (raw == null) return '0 đ';
    final digits = raw.toString().replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '0 đ';
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return '${digits.replaceAllMapped(reg, (Match m) => '${m[1]}.')} đ';
  }

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};

    // 1. name
    final nameVal = data['name']?.toString() ?? 'Chưa có tên';

    // 2. price - format with dot thousand separators (e.g. 10.000 đ, 1.000.000 đ)
    final formattedPrice = formatCurrency(data['price']);

    // 3. soluong (fallback to stock if field is named stock)
    int soluongVal = 0;
    final rawSoluong = data['soluong'] ?? data['stock'];
    if (rawSoluong is num) {
      soluongVal = rawSoluong.toInt();
    } else if (rawSoluong != null) {
      soluongVal = int.tryParse(rawSoluong.toString()) ?? 0;
    }

    // 4. image (fallback to imageAsset if field is named imageAsset)
    final imageVal = data['image']?.toString() ??
        data['imageAsset']?.toString() ??
        'assets/images/sony_wh1000xm5-4a0be7.png';

    // 5. category
    final categoryVal = data['category']?.toString() ?? 'Tất cả';

    return Product(
      id: doc.id,
      name: nameVal,
      price: formattedPrice,
      soluong: soluongVal,
      image: imageVal,
      category: categoryVal,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'soluong': soluong,
      'image': image,
      'category': category,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static List<Product> dummyProducts = const [
    Product(
      id: '1',
      name: 'Tai nghe Bluetooth Sony WH-1000XM5',
      price: '6.490.000 đ',
      soluong: 45,
      image: 'assets/images/sony_wh1000xm5-4a0be7.png',
      category: 'Tai nghe',
    ),
    Product(
      id: '2',
      name: 'Đồng hồ thông minh Garmin Forerunner 265',
      price: '10.990.000 đ',
      soluong: 12,
      image: 'assets/images/garmin_forerunner_265-4a0be7.png',
      category: 'Đồng hồ',
    ),
    Product(
      id: '3',
      name: 'Bàn phím cơ không dây NuPhy Air75 V2',
      price: '2.850.000 đ',
      soluong: 8,
      image: 'assets/images/nuphy_air75_v2-4a0be7.png',
      category: 'Bàn phím',
    ),
    Product(
      id: '4',
      name: 'Áo khoác gió thể thao nam ProShield',
      price: '450.000 đ',
      soluong: 120,
      image: 'assets/images/jacket_proshield-4a0be7.png',
      category: 'Thời trang',
    ),
    Product(
      id: '5',
      name: 'Chuột công thái học Logitech MX Master 3S',
      price: '2.390.000 đ',
      soluong: 50,
      image: 'assets/images/logitech_mx_master_3s-56586a.png',
      category: 'Chuột máy tính',
    ),
  ];
}
