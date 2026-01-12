import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'customer_dashboard_view_model.dart';
import 'dashboard_filter_view_model.dart';
import '../../seller/products/widgets/product_theme.dart';

class DashboardFilterScreen extends StatelessWidget {
  final List<DashboardCategoryChip> categories;
  final int? initialCategoryId;
  final ProductSortOption initialSort;
  final double? minPrice;
  final double? maxPrice;
  final double priceBound;

  const DashboardFilterScreen({
    super.key,
    required this.categories,
    required this.initialCategoryId,
    required this.initialSort,
    required this.minPrice,
    required this.maxPrice,
    required this.priceBound,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardFilterViewModel(
        initialCategoryId: initialCategoryId,
        initialSort: initialSort,
        minPrice: minPrice,
        maxPrice: maxPrice,
        priceBound: priceBound,
      ),
      child: Consumer<DashboardFilterViewModel>(
        builder: (context, vm, _) {
          final state = vm.state;
          return Scaffold(
            backgroundColor: const Color(0xFFFDF7F1),
            appBar: AppBar(
              backgroundColor: sellerAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              title: const Text('Bộ lọc'),
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: vm.resetFilters,
                            icon: const Icon(Icons.refresh, color: sellerAccent),
                            label: const Text(
                              'Xóa bộ lọc',
                              style: TextStyle(color: sellerAccent, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const Text('Danh mục', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 8),
                        _CategoryGrid(
                          categories: categories,
                          selectedId: state.selectedCategoryId,
                          onSelect: vm.selectCategory,
                        ),
                        const SizedBox(height: 16),
                        const Text('Sắp xếp', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 8),
                        _SortList(
                          sortOption: state.sortOption,
                          onChanged: vm.setSort,
                        ),
                        const SizedBox(height: 16),
                        const Text('Giá', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        _PriceSection(
                          state: state,
                          onRangeChanged: vm.setRange,
                          onTierSelected: vm.selectTier,
                        ),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sellerAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(
                          DashboardFilterResult(
                            categoryId: state.selectedCategoryId,
                            sortOption: state.sortOption,
                            minPrice: state.range.start <= 0 ? null : state.range.start,
                            maxPrice: state.range.end >= state.maxPriceBound ? null : state.range.end,
                          ),
                        );
                      },
                      child: const Text('Áp dụng bộ lọc'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<DashboardCategoryChip> categories;
  final int? selectedId;
  final ValueChanged<int?> onSelect;

  const _CategoryGrid({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = <_CategoryTile>[
      _CategoryTile(
        title: 'Tất cả',
        imageUrl: null,
        selected: selectedId == null,
        onTap: () => onSelect(null),
      ),
      ...categories.map(
        (c) => _CategoryTile(
          title: c.name,
          imageUrl: c.imageUrl,
          selected: selectedId == c.id,
          onTap: () => onSelect(c.id),
        ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (_, index) => tiles[index],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.title,
    required this.imageUrl,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? sellerAccentSoft : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? sellerAccent : sellerBorder),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: sellerBorder,
              backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty) ? NetworkImage(imageUrl!) : null,
              child: (imageUrl == null || imageUrl!.isEmpty)
                  ? const Icon(Icons.category, size: 18, color: sellerAccent)
                  : null,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? sellerAccent : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortList extends StatelessWidget {
  final ProductSortOption sortOption;
  final ValueChanged<ProductSortOption> onChanged;

  const _SortList({
    required this.sortOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (ProductSortOption.none, 'Đề xuất'),
      (ProductSortOption.priceAsc, 'Giá tăng dần'),
      (ProductSortOption.priceDesc, 'Giá giảm dần'),
    ];
    return Column(
      children: items.map((item) {
        final option = item.$1;
        final label = item.$2;
        final selected = sortOption == option;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: selected ? sellerAccentSoft : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? sellerAccent : sellerBorder),
          ),
          child: ListTile(
            onTap: () => onChanged(option),
            title: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? sellerAccent : Colors.black87,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PriceSection extends StatelessWidget {
  final DashboardFilterUiState state;
  final ValueChanged<RangeValues> onRangeChanged;
  final ValueChanged<PriceTier?> onTierSelected;

  const _PriceSection({
    required this.state,
    required this.onRangeChanged,
    required this.onTierSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tiers = state.tiers;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            children: tiers.map((tier) {
              final selected = state.selectedTier == tier;
              return ChoiceChip(
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(tier.label),
                    Text(
                      tier.display,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
                selected: selected,
                selectedColor: sellerAccentSoft,
                showCheckmark: false,
                onSelected: (_) => onTierSelected(selected ? null : tier),
                labelStyle: TextStyle(
                  color: selected ? sellerAccent : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: selected ? sellerAccent : sellerBorder,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          const Text('Khoảng giá', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatCurrency(state.range.start)),
              Text(state.range.end >= state.maxPriceBound ? 'Không giới hạn' : _formatCurrency(state.range.end)),
            ],
          ),
          RangeSlider(
            values: state.range,
            min: 0,
            max: state.maxPriceBound,
            divisions: 20,
            activeColor: sellerAccent,
            inactiveColor: sellerAccentSoft,
            labels: RangeLabels(
              _formatCurrency(state.range.start),
              state.range.end >= state.maxPriceBound ? '∞' : _formatCurrency(state.range.end),
            ),
            onChanged: onRangeChanged,
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return '${value.toStringAsFixed(0)}đ';
  }
}
