import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';
import '../services/cloudinary_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  /// Pick image from gallery
  Future<void> _pickImageFromGallery() async {
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
          _selectedImageBytes = bytes;
          _selectedImageName = pickedFile.name;
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

  /// Pick image from camera
  Future<void> _pickImageFromCamera() async {
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
          _selectedImageBytes = bytes;
          _selectedImageName = pickedFile.name;
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

  /// Remove selected image
  void _removeImage() {
    setState(() {
      _selectedImageBytes = null;
      _selectedImageName = null;
    });
  }

  /// Submit: upload to Cloudinary then save to Firebase
  Future<void> _submitProduct() async {
    final name = _nameController.text.trim();
    final price = _priceController.text.trim();
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;

    // Validate
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên sản phẩm')),
      );
      return;
    }
    if (price.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập giá sản phẩm')),
      );
      return;
    }
    if (_selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn hình ảnh sản phẩm')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Step 1: Upload image to Cloudinary
      final imageUrl = await CloudinaryService.uploadImage(
        imageBytes: _selectedImageBytes!,
        fileName: _selectedImageName ?? 'product_image.jpg',
      );

      // Step 2: Save product to Firebase with Cloudinary URL
      await FirebaseService.addProduct(
        name: name,
        price: Product.formatCurrency(price),
        soluong: stock,
        image: imageUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm sản phẩm thành công!'),
            backgroundColor: AppColors.primaryNavy,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _selectedImageBytes != null;

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
                'Thêm Sản Phẩm Mới',
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
                      // 1. Media Upload Section
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: hasImage
                                        ? AppColors.primaryNavy.withOpacity(0.1)
                                        : AppColors.borderLight,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    hasImage ? '1/5 ảnh' : '0/5 ảnh',
                                    style: TextStyle(
                                      fontFamily: 'Liberation Sans',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: hasImage
                                          ? AppColors.primaryNavy
                                          : AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Image Preview or Upload Placeholder
                            if (hasImage)
                              // Show selected image preview
                              Stack(
                                children: [
                                  Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.primaryNavy.withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.memory(
                                        _selectedImageBytes!,
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  // Remove button
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: _removeImage,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppColors.danger,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // File name badge
                                  if (_selectedImageName != null)
                                    Positioned(
                                      bottom: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          _selectedImageName!.length > 25
                                              ? '${_selectedImageName!.substring(0, 22)}...'
                                              : _selectedImageName!,
                                          style: const TextStyle(
                                            fontFamily: 'Liberation Sans',
                                            fontSize: 11,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            else
                              // Dashed Upload Container
                              GestureDetector(
                                onTap: _pickImageFromGallery,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 36,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.border,
                                      width: 2,
                                      strokeAlign: BorderSide.strokeAlignCenter,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: AppColors.lightBlue,
                                          shape: BoxShape.circle,
                                          boxShadow: const [AppColors.cardShadow],
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.cloud_upload_outlined,
                                            color: AppColors.primaryNavy,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Nhấn để chọn ảnh sản phẩm',
                                        style: TextStyle(
                                          fontFamily: 'Liberation Sans',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Định dạng JPG, PNG hoặc WEBP (tối đa 5MB)',
                                        style: TextStyle(
                                          fontFamily: 'Liberation Sans',
                                          fontSize: 13,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 14),

                            // Buttons for pick / camera
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _pickImageFromGallery,
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
                                  onPressed: _pickImageFromCamera,
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

                      // 2. Core Information Section
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
                            // Product Name
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontFamily: 'Liberation Sans',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                    children: [
                                      TextSpan(text: 'Tên sản phẩm '),
                                      TextSpan(
                                        text: '*',
                                        style: TextStyle(color: AppColors.danger),
                                      ),
                                    ],
                                  ),
                                ),
                                ValueListenableBuilder<TextEditingValue>(
                                  valueListenable: _nameController,
                                  builder: (_, value, _) => Text(
                                    '${value.text.length}/120',
                                    style: const TextStyle(
                                      fontFamily: 'Liberation Sans',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _nameController,
                              maxLength: 120,
                              style: const TextStyle(
                                fontFamily: 'Liberation Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Nhập tên sản phẩm',
                                hintStyle: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w400,
                                ),
                                counterText: '',
                                filled: true,
                                fillColor: AppColors.surfaceMuted,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
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

                            // Price
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Liberation Sans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                                children: [
                                  TextSpan(text: 'Giá bán (VNĐ) '),
                                  TextSpan(
                                    text: '*',
                                    style: TextStyle(color: AppColors.danger),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontFamily: 'Liberation Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Nhập giá',
                                hintStyle: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w400,
                                ),
                                filled: true,
                                fillColor: AppColors.surfaceMuted,
                                suffixIcon: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
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
                                  vertical: 12,
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

                            // Stock
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Liberation Sans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                                children: [
                                  TextSpan(text: 'Số lượng '),
                                  TextSpan(
                                    text: '*',
                                    style: TextStyle(color: AppColors.danger),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontFamily: 'Liberation Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Nhập số lượng',
                                hintStyle: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w400,
                                ),
                                filled: true,
                                fillColor: AppColors.surfaceMuted,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
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

              // Persistent Bottom Action Dock
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  boxShadow: const [AppColors.bottomBarShadow],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      // Cancel Button
                      SizedBox(
                        width: 112,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.borderLight,
                            side: const BorderSide(
                              color: AppColors.border,
                              width: 1,
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
                      ),
                      const SizedBox(width: 8),

                      // Add Product Button
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _isUploading ? null : _submitProduct,
                            icon: _isUploading
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
                              _isUploading ? 'Đang tải lên...' : 'Thêm sản phẩm',
                              style: const TextStyle(
                                fontFamily: 'Liberation Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isUploading
                                  ? AppColors.primaryNavy.withOpacity(0.7)
                                  : AppColors.primaryNavy,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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

          // Full-screen loading overlay
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.3),
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
                      'Đang upload ảnh lên Cloudinary...',
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
