class FilterSortOptions {
  final double minPrice;
  final double maxPrice;
  final String? quickRange; // 'Dưới 1 triệu', '1 - 5 triệu', '5 - 10 triệu', 'Trên 10 triệu', or null
  final String priceSort; // 'none', 'low_to_high', 'high_to_low'
  final String nameSort; // 'none', 'a_to_z', 'z_to_a'

  const FilterSortOptions({
    this.minPrice = 0,
    this.maxPrice = 10000000,
    this.quickRange,
    this.priceSort = 'none',
    this.nameSort = 'none',
  });

  bool get isActive {
    return quickRange != null ||
        maxPrice < 10000000 ||
        minPrice > 0 ||
        priceSort != 'none' ||
        nameSort != 'none';
  }

  FilterSortOptions copyWith({
    double? minPrice,
    double? maxPrice,
    String? quickRange,
    String? priceSort,
    String? nameSort,
  }) {
    return FilterSortOptions(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      quickRange: quickRange ?? this.quickRange,
      priceSort: priceSort ?? this.priceSort,
      nameSort: nameSort ?? this.nameSort,
    );
  }
}

