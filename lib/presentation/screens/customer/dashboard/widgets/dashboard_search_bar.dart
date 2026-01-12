import 'package:flutter/material.dart';

class DashboardSearchBar extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onFilterTap;

  const DashboardSearchBar({super.key, required this.onTap, required this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF7A45);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: primary),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Tìm món ngon hôm nay...',
                  style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
                ),
              ),
              GestureDetector(
                onTap: onFilterTap,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.tune_rounded, color: primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
