import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../models/product.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/product_image_view.dart';
import '../services/firebase_service.dart';
import '../services/cloudinary_service.dart';

class EditProductScreen extends StatefulWidget {
  final Product? product;

  const EditProductScreen({super.key, this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  Uint8List? _newImageBytes;
  String? _newImageName;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product ?? Product.dummyProducts.first;
    _nameController = TextEditingController(text: p.name);
    _priceController = TextEditingController(
      text: p.price.replaceAll(' đ', '').replaceAll('.', ''),
    );
    _stockController = TextEditingController(text: '${p.stock}');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  /// Pick a new image from gallery
  Future<void> _pickNewImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _newImageBytes = bytes;
          _newImageName = pickedFile.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn ảnh: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  /// Pick a new image from camera
  Future<void> _pickNewImageFromCamera() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _newImageBytes = bytes;
          _newImageName = pickedFile.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chụp ảnh: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  /// Remove the newly picked image (revert to existing)
  void _removeNewImage() {
    setState(() {
      _newImageBytes = null;
      _newImageName = null;
    });
  }

  /// Save changes: optionally upload new image to Cloudinary, then update Firebase
  Future<void> _saveChanges() async {
    final currentProduct = widget.product ?? Product.dummyProducts.first;
    final name = _nameController.text.trim();
    final price = _priceController.text.trim();
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên sản phẩm')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? newImageUrl;

      // If user picked a new image, upload to Cloudinary first
      if (_newImageBytes != null) {
        newImageUrl = await CloudinaryService.uploadImage(
          imageBytes: _newImageBytes!,
          fileName: _newImageName ?? 'product_image.jpg',
        );
      }

      // Update product in Firebase
      await FirebaseService.updateProduct(
        id: currentProduct.id,
        name: name,
        price: Product.formatCurrency(price),
        soluong: stock,
        image: newImageUrl, // null if no new image → keeps existing
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật sản phẩm thành công!'),
            backgroundColor: AppColors.secondaryNavy,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentProduct = widget.product ?? Product.dummyProducts.first;
    final hasNewImage = _newImageBytes != null;

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
              const Expanded(
                child: Text(
                  'Chỉnh Sửa Sản Phẩm',
                  style: TextStyle(
                    fontFamily: 'Liberation Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),

              // Delete button in header
              IconButton(
                onPressed: () {
                  ConfirmDeleteDialog.show(
                    context,
                    product: currentProduct,
                    onConfirmDelete: () async {
                      try {
                        await FirebaseService.deleteProduct(currentProduct.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã xóa sản phẩm khỏi Firebase!'),
                              backgroundColor: AppColors.danger,
                            ),
                          );
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi khi xóa: $e')),
                          );
                        }
                      }
                    },
                  );
                },
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                  size: 22,
                ),
                tooltip: 'Xóa sản phẩm',
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Main Product Image Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border, width: 1),
                          boxShadow: const [AppColors.cardShadow],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Hình ảnh sản phẩm',
                                  style: TextStyle(
                                    fontFamily: 'Liberation Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                if (hasNewImage)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryNavy,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'Đã chọn ảnh mới',
                                      style: TextStyle(
                                        fontFamily: 'Liberation Sans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Image display
                            Center(
                              child: Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 240,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceMuted,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: hasNewImage
                                            ? AppColors.primaryNavy
                                            : AppColors.borderLight,
                                        width: hasNewImage ? 2 : 1,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: hasNewImage
                                          ? Image.memory(
                                              _newImageBytes!,
                                              fit: BoxFit.contain,
                                              width: double.infinity,
                                              height: 240,
                                            )
                                          : ProductImageView(
                                              image: currentProduct.image,
                                              fit: BoxFit.contain,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                    ),
                                  ),
                                  // Revert button if new image is selected
                                  if (hasNewImage)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: InkWell(
                                        onTap: _removeNewImage,
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.danger.withValues(alpha: 0.9),
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: const [AppColors.cardShadow],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(
                                                Icons.undo_rounded,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Hoàn tác',
                                                style: TextStyle(
                                                  fontFamily: 'Liberation Sans',
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // 2 Buttons: "Chọn từ thư viện" & "Chụp ảnh" (disabled on web)
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _pickNewImageFromGallery,
                                    icon: const Icon(
                                      Icons.photo_library_outlined,
                                      size: 18,
                                      color: AppColors.primaryNavy,
                                    ),
                                    label: const Text(
                                      'Chọn từ thư viện',
                                      style: TextStyle(
                                        fontFamily: 'Liberation Sans',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: AppColors.surfaceMuted,
                                      side: const BorderSide(
                                        color: AppColors.border,
                                        width: 1.5,
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                OutlinedButton.icon(
                                  onPressed: _pickNewImageFromCamera,
                                  icon: const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 18,
                                    color: AppColors.primaryNavy,
                                  ),
                                  label: const Text(
                                    'Chụp ảnh',
                                    style: TextStyle(
                                      fontFamily: 'Liberation Sans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: AppColors.surfaceMuted,
                                    side: const BorderSide(
                                      color: AppColors.border,
                                      width: 1.5,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. Form Fields Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight, width: 1),
                          boxShadow: const [AppColors.cardShadow],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Field 1: Tên sản phẩm
                            const Text(
                              'Tên sản phẩm',
                              style: TextStyle(
                                fontFamily: 'Liberation Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _nameController,
                              style: const TextStyle(
                                fontFamily: 'Liberation Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.surface,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryNavy,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Field 2: Giá bán (VNĐ)
                            const Text(
                              'Giá bán (VNĐ)',
                              style: TextStyle(
                                fontFamily: 'Liberation Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontFamily: 'Liberation Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.surface,
                                suffixIcon: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  child: Text(
                                    'VNĐ',
                                    style: TextStyle(
                                      fontFamily: 'Liberation Sans',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryNavy,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Field 3: Số lượng
                            const Text(
                              'Số lượng',
                              style: TextStyle(
                                fontFamily: 'Liberation Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontFamily: 'Liberation Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.surface,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryNavy,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Sticky Bottom Actions Bar: Hủy & Lưu thay đổi
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.95),
                  boxShadow: const [AppColors.bottomBarShadow],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      // Hủy Button
                      OutlinedButton(
                        onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.lightBlue,
                          side: const BorderSide(
                            color: AppColors.border,
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
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
                      const SizedBox(width: 8),

                      // Lưu thay đổi Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveChanges,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                          label: Text(
                            _isSaving ? 'Đang lưu...' : 'Lưu thay đổi',
                            style: const TextStyle(
                              fontFamily: 'Liberation Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSaving
                                ? AppColors.secondaryNavy.withValues(alpha: 0.7)
                                : AppColors.secondaryNavy,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Full-screen loading overlay when uploading new image
          if (_isSaving && _newImageBytes != null)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.primaryNavy,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Đang upload ảnh mới lên Cloudinary...',
                      style: TextStyle(
                        fontFamily: 'Liberation Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
