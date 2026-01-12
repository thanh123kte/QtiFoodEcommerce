import 'package:flutter/material.dart';

import '../customer_dashboard_view_model.dart';

class DashboardCategoryStrip extends StatelessWidget {
  final List<DashboardCategoryChip> categories;
  final bool isLoading;
  final String? error;
  final int? selectedCategoryId;
  final ValueChanged<int?> onSelected;

  const DashboardCategoryStrip({
    super.key,
    required this.categories,
    required this.isLoading,
    required this.error,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF7A45);
    if (isLoading && categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null && categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(error!, style: const TextStyle(color: Colors.orange)),
      );
    }

    if (categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text('Khong tim thay danh muc'),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final category = categories[index];
          final bool isSelected = category.id == selectedCategoryId;
          return GestureDetector(
            onTap: () => onSelected(category.id),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [primary, primary.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: category.imageUrl == null ? null : NetworkImage(category.imageUrl!),
                    backgroundColor: isSelected ? Colors.transparent : Colors.grey.shade100,
                    child: category.imageUrl == null
                        ? Icon(Icons.category_outlined, color: isSelected ? Colors.white : Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 80,
                  child: Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected ? primary : Colors.black87,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
