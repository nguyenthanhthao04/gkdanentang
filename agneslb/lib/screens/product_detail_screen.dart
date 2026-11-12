import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/product.dart';
import '../widgets/product_image_view.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product? product;

  const ProductDetailScreen({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    final currentProduct = product ?? Product.dummyProducts.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          color: AppColors.background,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            bottom: 8,
          ),
          child: Row(
            children: [
              // Back Button
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [AppColors.cardShadow],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title Icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [AppColors.cardShadow],
                ),
                child: const Center(
                  child: Icon(
                    Icons.inventory_2_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Title
              const Text(
                'Chi Tiết Sản Phẩm',
                style: TextStyle(
                  fontFamily: 'Liberation Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandDark,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Image Showcase (Firebase field: image)
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [AppColors.cardShadow],
              ),
              child: AspectRatio(
                aspectRatio: 1.1,
                child: ProductImageView(
                  image: currentProduct.image,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Product Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [AppColors.cardShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product ID Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'MÃ: #${currentProduct.id}',
                      style: const TextStyle(
                        fontFamily: 'Liberation Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryNavy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Product Title (Firebase field: name)
                  Text(
                    currentProduct.name,
                    style: const TextStyle(
                      fontFamily: 'Liberation Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Divider(color: AppColors.borderLight, height: 1),
                  const SizedBox(height: 14),

                  // Metrics Row: Price (price) and Stock (soluong)
                  Row(
                    children: [
                      // Price
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.sell_outlined,
                                    size: 16,
                                    color: AppColors.primaryNavy,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Giá Niêm Yết:',
                                    style: TextStyle(
                                      fontFamily: 'Liberation Sans',
                                      fontSize: 12.5,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                currentProduct.price,
                                style: const TextStyle(
                                  fontFamily: 'Liberation Sans',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondaryNavy,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Stock
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 16,
                                    color: AppColors.success,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Kho Hiện Tại:',
                                    style: TextStyle(
                                      fontFamily: 'Liberation Sans',
                                      fontSize: 12.5,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${currentProduct.soluong}',
                                style: const TextStyle(
                                  fontFamily: 'Liberation Sans',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.brandDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
