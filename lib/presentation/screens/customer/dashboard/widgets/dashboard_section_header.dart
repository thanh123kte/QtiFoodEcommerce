import 'package:flutter/material.dart';

class DashboardSectionHeader extends StatelessWidget {
  final VoidCallback onSort;
  final VoidCallback onFilter;

  const DashboardSectionHeader({
    super.key,
    required this.onSort,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF7A45);
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        children: [
          Text(
            'Khám phá',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
          ),
          const Spacer(),
          _DashboardFilterButton(
            icon: Icons.sort,
            label: 'Sắp xếp',
            onTap: onSort,
            color: primary,
          ),
          const SizedBox(width: 8),
          _DashboardFilterButton(
            icon: Icons.filter_alt_outlined,
            label: 'Lọc',
            onTap: onFilter,
            color: primary,
          ),
        ],
      ),
    );
  }
}

class _DashboardFilterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _DashboardFilterButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(color: color.withOpacity(0.4)),
        foregroundColor: color,
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
