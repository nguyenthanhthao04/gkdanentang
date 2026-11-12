import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/product.dart';
import '../models/filter_options.dart';
import '../services/firebase_service.dart';
import '../widgets/product_image_view.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/logout_dialog.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import 'filter_sort_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  FilterSortOptions _filterOptions = const FilterSortOptions();

  @override
  void initState() {
    super.initState();
    // Auto seed initial products into Firebase if collection is empty
    FirebaseService.seedInitialProductsIfEmpty();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showLogoutDialog() {
    LogoutDialog.show(
      context,
      onConfirmLogout: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
    );
  }

  void _showDeleteDialog(Product product) {
    ConfirmDeleteDialog.show(
      context,
      product: product,
      onConfirmDelete: () async {
        try {
          await FirebaseService.deleteProduct(product.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã xóa "${product.name}" khỏi Firebase!'),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi khi xóa: $e'),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        }
      },
    );
  }

  Future<void> _openFilterScreen() async {
    final result = await Navigator.of(context).push<FilterSortOptions>(
      MaterialPageRoute(
        builder: (_) => FilterSortScreen(initialOptions: _filterOptions),
      ),
    );
    if (result != null) {
      setState(() {
        _filterOptions = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Header
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          color: AppColors.background,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            bottom: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo + Title
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [AppColors.cardShadow],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.inventory_2_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'AgnesLB',
                        style: TextStyle(
                          fontFamily: 'Liberation Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryNavy,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Quản Lý Sản Phẩm',
                        style: TextStyle(
                          fontFamily: 'Liberation Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Đăng xuất Button
              InkWell(
                onTap: _showLogoutDialog,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.logout_rounded,
                        size: 16,
                        color: AppColors.danger,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Đăng xuất',
                        style: TextStyle(
                          fontFamily: 'Liberation Sans',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<List<Product>>(
        stream: FirebaseService.getProductsStream(),
        builder: (context, snapshot) {
          // If error or stream has not connected, fallback gracefully
          final List<Product> rawProducts = snapshot.hasData && snapshot.data!.isNotEmpty
              ? snapshot.data!
              : (snapshot.connectionState == ConnectionState.waiting
                  ? []
                  : Product.dummyProducts);

          // Apply local filter & search
          final query = _searchController.text.trim().toLowerCase();
          List<Product> filteredProducts = rawProducts.where((p) {
            // Search query filter
            final matchesSearch = query.isEmpty ||
                p.name.toLowerCase().contains(query);

            // Price range filter
            final pPrice = p.numericPrice;
            final matchesPrice = pPrice >= _filterOptions.minPrice &&
                pPrice <= _filterOptions.maxPrice;

            return matchesSearch && matchesPrice;
          }).toList();

          // Apply sort by price
          if (_filterOptions.priceSort == 'low_to_high') {
            filteredProducts.sort((a, b) => a.numericPrice.compareTo(b.numericPrice));
          } else if (_filterOptions.priceSort == 'high_to_low') {
            filteredProducts.sort((a, b) => b.numericPrice.compareTo(a.numericPrice));
          }

          // Apply sort by name
          if (_filterOptions.nameSort == 'a_to_z') {
            filteredProducts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          } else if (_filterOptions.nameSort == 'z_to_a') {
            filteredProducts.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
          }

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: 96,
                ),
                children: [
                  // Operational Micro-Status & Metric Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Tổng cộng: ',
                            style: TextStyle(
                              fontFamily: 'Liberation Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandDark,
                            ),
                          ),
                          Text(
                            '${filteredProducts.length}',
                            style: const TextStyle(
                              fontFamily: 'Liberation Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                          const Text(
                            ' sản phẩm',
                            style: TextStyle(
                              fontFamily: 'Liberation Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandDark,
                            ),
                          ),
                        ],
                      ),
                      if (snapshot.hasData)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.cloud_done_rounded, size: 14, color: AppColors.primaryNavy),
                              SizedBox(width: 4),
                              Text(
                                'Firebase Live',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search bar + Filter button
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [AppColors.cardShadow],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              fontFamily: 'Liberation Sans',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brandDark,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm theo tên sản phẩm...',
                              hintStyle: const TextStyle(
                                fontFamily: 'Liberation Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppColors.brandDark,
                                size: 20,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Filter Icon Button with active badge
                      InkWell(
                        onTap: _openFilterScreen,
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _filterOptions.isActive
                                    ? AppColors.primaryNavy
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [AppColors.cardShadow],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.tune_rounded,
                                  color: _filterOptions.isActive
                                      ? Colors.white
                                      : AppColors.primaryNavy,
                                  size: 22,
                                ),
                              ),
                            ),
                            if (_filterOptions.isActive)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.danger,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Active Filter Badges Bar
                  if (_filterOptions.isActive) ...[
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_filterOptions.quickRange != null)
                            _buildFilterBadge(
                              label: 'Giá: ${_filterOptions.quickRange}',
                              onRemove: () {
                                setState(() {
                                  _filterOptions = _filterOptions.copyWith(
                                    quickRange: null,
                                    minPrice: 0,
                                    maxPrice: 10000000,
                                  );
                                });
                              },
                            )
                          else if (_filterOptions.maxPrice < 10000000 || _filterOptions.minPrice > 0)
                            _buildFilterBadge(
                              label: 'Giá: <= ${( _filterOptions.maxPrice / 1000000).toStringAsFixed(1)}tr',
                              onRemove: () {
                                setState(() {
                                  _filterOptions = _filterOptions.copyWith(
                                    minPrice: 0,
                                    maxPrice: 10000000,
                                  );
                                });
                              },
                            ),
                          if (_filterOptions.priceSort != 'none')
                            _buildFilterBadge(
                              label: _filterOptions.priceSort == 'low_to_high'
                                  ? 'Giá: Thấp → Cao'
                                  : 'Giá: Cao → Thấp',
                              onRemove: () {
                                setState(() {
                                  _filterOptions = _filterOptions.copyWith(priceSort: 'none');
                                });
                              },
                            ),
                          if (_filterOptions.nameSort != 'none')
                            _buildFilterBadge(
                              label: _filterOptions.nameSort == 'a_to_z'
                                  ? 'Tên: A → Z'
                                  : 'Tên: Z → A',
                              onRemove: () {
                                setState(() {
                                  _filterOptions = _filterOptions.copyWith(nameSort: 'none');
                                });
                              },
                            ),
                          // Reset all chip
                          InkWell(
                            onTap: () {
                              setState(() {
                                _filterOptions = const FilterSortOptions();
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.dangerLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Xóa tất cả',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.danger,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Loading State
                  if (snapshot.connectionState == ConnectionState.waiting && rawProducts.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(color: AppColors.primaryNavy),
                      ),
                    )
                  else if (filteredProducts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.border),
                          const SizedBox(height: 12),
                          const Text(
                            'Không tìm thấy sản phẩm phù hợp',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_filterOptions.isActive || _searchController.text.isNotEmpty)
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _filterOptions = const FilterSortOptions();
                                  _searchController.clear();
                                });
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Xóa bộ lọc & tìm kiếm'),
                            )
                          else
                            ElevatedButton.icon(
                              onPressed: () async {
                                await FirebaseService.seedInitialProductsIfEmpty();
                                setState(() {});
                              },
                              icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                              label: const Text('Thêm 5 sản phẩm mẫu vào Firebase'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryNavy,
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    )
                  else
                    // Product Items List
                    ...filteredProducts.map((product) => _buildProductCard(product)),
                ],
              ),

              // Floating Add New Product Button (FAB)
              Positioned(
                right: 16,
                bottom: 24,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddProductScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x59021064),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add_rounded, color: Colors.white, size: 22),
                        SizedBox(width: 6),
                        Text(
                          'Thêm sản phẩm',
                          style: TextStyle(
                            fontFamily: 'Liberation Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      drawer: _buildQuickNavigatorDrawer(context),
    );
  }

  Widget _buildFilterBadge({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.secondaryNavy.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryNavy,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.secondaryNavy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: product),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Product Image (Firebase field: image)
                ProductImageView(
                  image: product.image,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(width: 12),

                // Info: Title (name), Price (formatted as e.g. 10.000 đ, 1.000.000 đ), Stock (soluong)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Liberation Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.price,
                        style: const TextStyle(
                          fontFamily: 'Liberation Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Số lượng: ${product.soluong}',
                        style: const TextStyle(
                          fontFamily: 'Liberation Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandDark,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons: Edit & Delete
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit button
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EditProductScreen(product: product),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: AppColors.brandDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Delete button
                    InkWell(
                      onTap: () => _showDeleteDialog(product),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.dangerLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickNavigatorDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primaryNavy),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  'AgnesLB Navigation',
                  style: TextStyle(
                    fontFamily: 'Liberation Sans',
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Danh sách tất cả màn hình Figma',
                  style: TextStyle(
                    fontFamily: 'Liberation Sans',
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.login, color: AppColors.primaryNavy),
            title: const Text('1. Đăng Nhập Quản Trị'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2, color: AppColors.primaryNavy),
            title: const Text('2. Quản Lý Danh Sách Sản Phẩm'),
            selected: true,
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            leading: const Icon(Icons.add_box, color: AppColors.primaryNavy),
            title: const Text('3. Thêm Mới Sản Phẩm'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddProductScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_note, color: AppColors.primaryNavy),
            title: const Text('4. Chỉnh Sửa Sản Phẩm'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProductScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.tune, color: AppColors.primaryNavy),
            title: const Text('5. Bộ Lọc & Sắp Xếp Sản Phẩm'),
            onTap: () {
              Navigator.of(context).pop();
              _openFilterScreen();
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.primaryNavy),
            title: const Text('7. Chi Tiết Sản Phẩm'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProductDetailScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppColors.danger),
            title: const Text('Dialog: Xác Nhận Xóa Sản Phẩm'),
            onTap: () {
              Navigator.of(context).pop();
              ConfirmDeleteDialog.show(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.danger),
            title: const Text('Dialog: Đăng Xuất'),
            onTap: () {
              Navigator.of(context).pop();
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }
}
