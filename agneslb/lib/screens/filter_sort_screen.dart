import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/filter_options.dart';

class FilterSortScreen extends StatefulWidget {
  final FilterSortOptions? initialOptions;

  const FilterSortScreen({super.key, this.initialOptions});

  @override
  State<FilterSortScreen> createState() => _FilterSortScreenState();
}

class _FilterSortScreenState extends State<FilterSortScreen> {
  late double _minPrice;
  late double _maxPrice;
  String? _selectedQuickRange;
  late String _selectedPriceSort; // 'none' | 'low_to_high' | 'high_to_low'
  late String _selectedNameSort; // 'none' | 'a_to_z' | 'z_to_a'

  @override
  void initState() {
    super.initState();
    final opt = widget.initialOptions ?? const FilterSortOptions();
    _minPrice = opt.minPrice;
    _maxPrice = opt.maxPrice;
    _selectedQuickRange = opt.quickRange;
    _selectedPriceSort = opt.priceSort;
    _selectedNameSort = opt.nameSort;
  }

  void _resetFilters() {
    setState(() {
      _minPrice = 0;
      _maxPrice = 10000000;
      _selectedQuickRange = null;
      _selectedPriceSort = 'none';
      _selectedNameSort = 'none';
    });
  }

  void _onQuickChipSelected(String title) {
    setState(() {
      if (_selectedQuickRange == title) {
        // Deselect
        _selectedQuickRange = null;
        _minPrice = 0;
        _maxPrice = 10000000;
      } else {
        _selectedQuickRange = title;
        switch (title) {
          case 'Dưới 1 triệu':
            _minPrice = 0;
            _maxPrice = 1000000;
            break;
          case '1 - 5 triệu':
            _minPrice = 1000000;
            _maxPrice = 5000000;
            break;
          case '5 - 10 triệu':
            _minPrice = 5000000;
            _maxPrice = 10000000;
            break;
          case 'Trên 10 triệu':
            _minPrice = 10000000;
            _maxPrice = 100000000;
            break;
        }
      }
    });
  }

  String _formatCurrency(double amount) {
    final int val = amount.round();
    if (val >= 100000000) return '100tr+ đ';
    final s = val.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return '${s.replaceAllMapped(reg, (Match m) => '${m[1]}.')} đ';
  }

  void _applyFilters() {
    final options = FilterSortOptions(
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      quickRange: _selectedQuickRange,
      priceSort: _selectedPriceSort,
      nameSort: _selectedNameSort,
    );
    Navigator.of(context).pop(options);
  }

  @override
  Widget build(BuildContext context) {
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
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Title
              const Expanded(
                child: Text(
                  'Bộ Lọc & Sắp Xếp',
                  style: TextStyle(
                    fontFamily: 'Liberation Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),

              // Reset Button
              TextButton(
                onPressed: _resetFilters,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                child: const Text(
                  'Đặt lại',
                  style: TextStyle(
                    fontFamily: 'Liberation Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryNavy,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Section 1: Khoảng Giá (VNĐ)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [AppColors.cardShadow],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.monetization_on_outlined,
                                  size: 20,
                                  color: AppColors.secondaryNavy,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Khoảng giá (VNĐ)',
                                  style: TextStyle(
                                    fontFamily: 'Liberation Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightBlue,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${_formatCurrency(_minPrice)} - ${_formatCurrency(_maxPrice)}',
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
                        const SizedBox(height: 16),

                        // Slider Track
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.secondaryNavy,
                            inactiveTrackColor: AppColors.borderLight,
                            thumbColor: Colors.white,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 10,
                              elevation: 2,
                            ),
                            trackHeight: 6,
                          ),
                          child: Slider(
                            value: _maxPrice.clamp(500000, 15000000),
                            min: 500000,
                            max: 15000000,
                            divisions: 29,
                            onChanged: (val) {
                              setState(() {
                                _maxPrice = val;
                                _selectedQuickRange = null; // custom range
                              });
                            },
                          ),
                        ),

                        // Labels below slider
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '500.000 đ',
                              style: TextStyle(
                                fontFamily: 'Liberation Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightBlue,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Tối đa: ${_formatCurrency(_maxPrice)}',
                                style: const TextStyle(
                                  fontFamily: 'Liberation Sans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondaryNavy,
                                ),
                              ),
                            ),
                            const Text(
                              '15.000.000+ đ',
                              style: TextStyle(
                                fontFamily: 'Liberation Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // TỪ and ĐẾN boxes
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.borderLight,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'TỪ (VNĐ)',
                                      style: TextStyle(
                                        fontFamily: 'Liberation Sans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatCurrency(_minPrice),
                                      style: const TextStyle(
                                        fontFamily: 'Liberation Sans',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.borderLight,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'ĐẾN (VNĐ)',
                                      style: TextStyle(
                                        fontFamily: 'Liberation Sans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatCurrency(_maxPrice),
                                      style: const TextStyle(
                                        fontFamily: 'Liberation Sans',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Quick Select Chips 2x2 Grid
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 3.2,
                          children: [
                            _buildQuickChip('Dưới 1 triệu'),
                            _buildQuickChip('1 - 5 triệu'),
                            _buildQuickChip('5 - 10 triệu'),
                            _buildQuickChip('Trên 10 triệu'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Section 2: Sắp Xếp Theo Giá
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [AppColors.cardShadow],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sắp xếp theo giá',
                          style: TextStyle(
                            fontFamily: 'Liberation Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSortOption(
                                title: 'Giá: Thấp đến cao',
                                isSelected: _selectedPriceSort == 'low_to_high',
                                onTap: () {
                                  setState(() {
                                    _selectedPriceSort =
                                        _selectedPriceSort == 'low_to_high'
                                            ? 'none'
                                            : 'low_to_high';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildSortOption(
                                title: 'Giá: Cao đến thấp',
                                isSelected: _selectedPriceSort == 'high_to_low',
                                onTap: () {
                                  setState(() {
                                    _selectedPriceSort =
                                        _selectedPriceSort == 'high_to_low'
                                            ? 'none'
                                            : 'high_to_low';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Section 3: Sắp Xếp Theo Tên
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [AppColors.cardShadow],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sắp xếp theo tên',
                          style: TextStyle(
                            fontFamily: 'Liberation Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSortOption(
                                title: 'Tên A → Z',
                                isSelected: _selectedNameSort == 'a_to_z',
                                onTap: () {
                                  setState(() {
                                    _selectedNameSort =
                                        _selectedNameSort == 'a_to_z'
                                            ? 'none'
                                            : 'a_to_z';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildSortOption(
                                title: 'Tên Z → A',
                                isSelected: _selectedNameSort == 'z_to_a',
                                onTap: () {
                                  setState(() {
                                    _selectedNameSort =
                                        _selectedNameSort == 'z_to_a'
                                            ? 'none'
                                            : 'z_to_a';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Fixed Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.95),
              boxShadow: const [AppColors.bottomBarShadow],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _applyFilters,
                  icon: const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Áp dụng bộ lọc',
                    style: TextStyle(
                      fontFamily: 'Liberation Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryNavy,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String title) {
    final isSelected = _selectedQuickRange == title;
    return InkWell(
      onTap: () => _onQuickChipSelected(title),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondaryNavy : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.secondaryNavy : AppColors.border,
            width: 1.5,
          ),
          boxShadow: isSelected ? const [AppColors.cardShadow] : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Liberation Sans',
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightBlue : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.secondaryNavy : AppColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Liberation Sans',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.secondaryNavy : AppColors.textDark,
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 18,
              color: isSelected ? AppColors.secondaryNavy : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
