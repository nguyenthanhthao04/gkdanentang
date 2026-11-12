import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/product.dart';
import 'product_image_view.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final Product? product;
  final VoidCallback? onConfirmDelete;

  const ConfirmDeleteDialog({
    super.key,
    this.product,
    this.onConfirmDelete,
  });

  static Future<void> show(BuildContext context, {Product? product, VoidCallback? onConfirmDelete}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ConfirmDeleteDialog(
        product: product,
        onConfirmDelete: onConfirmDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetProduct = product ?? Product.dummyProducts.first;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Danger Icon in light-red container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Heading & Subtitle
            const Text(
              'Xác nhận xóa sản phẩm',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Liberation Sans',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'Liberation Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  height: 1.5,
                ),
                children: [
                  TextSpan(text: 'Hành động này '),
                  TextSpan(
                    text: 'không thể hoàn tác',
                    style: TextStyle(color: AppColors.danger),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Mini Product Preview Card
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
                boxShadow: const [AppColors.cardShadow],
              ),
              child: Row(
                children: [
                  ProductImageView(
                    image: targetProduct.image,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          targetProduct.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Liberation Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              targetProduct.price,
                              style: const TextStyle(
                                fontFamily: 'Liberation Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Kho: ${targetProduct.soluong} cái',
                              style: const TextStyle(
                                fontFamily: 'Liberation Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
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
            const SizedBox(height: 20),

            // Destructive Primary Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirmDelete?.call();
                },
                icon: const Icon(Icons.delete_rounded, size: 18, color: Colors.white),
                label: const Text(
                  'Xóa sản phẩm',
                  style: TextStyle(
                    fontFamily: 'Liberation Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Secondary Cancel Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.softBlue,
                  side: const BorderSide(color: AppColors.border, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Hủy',
                  style: TextStyle(
                    fontFamily: 'Liberation Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Bottom security note
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.shield_outlined, size: 14, color: AppColors.textDark),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Dữ liệu hóa đơn cũ vẫn được lưu an toàn',
                    style: TextStyle(
                      fontFamily: 'Liberation Sans',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

