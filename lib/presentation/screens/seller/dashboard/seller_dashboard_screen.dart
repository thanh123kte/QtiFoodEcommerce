import 'package:datn_foodecommerce_flutter_app/presentation/screens/seller/categories/store_categories_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../utils/currency_formatter.dart';
import '../../customer/profile/profile_screen.dart';
import '../orders/seller_orders_screen.dart';
import '../products/seller_products_screen.dart';
import '../vouchers/seller_vouchers_screen.dart';
import '../profile/seller_profile_overview_screen.dart';
import '../analytics/seller_statistics_screen.dart';
import 'seller_dashboard_view_model.dart';

class SellerDashboardScreen extends StatefulWidget {
  final String ownerId;

  const SellerDashboardScreen({super.key, required this.ownerId});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  late final SellerDashboardViewModel _viewModel = GetIt.I<SellerDashboardViewModel>();

  @override
  void initState() {
    super.initState();
    _viewModel.load(widget.ownerId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _handleBack(context),
      child: ChangeNotifierProvider.value(
        value: _viewModel,
        child: Consumer<SellerDashboardViewModel>(
          builder: (context, vm, _) {
            final state = vm.state;
            final stats = state.stats;
            final revenue = stats?.totalRevenue ?? 0;
            final orders = stats?.totalOrders ?? 0;
            final totalOrders = stats?.totalOrders ?? 0;

            return Scaffold(
              backgroundColor: const Color(0xFFF6F7FB),
              body: RefreshIndicator(
                  onRefresh: vm.refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _DashboardHeader(
                          storeName: state.storeName ?? 'Trang Người bán',
                          statusLabel: state.error != null ? 'Đang cập nhật' : 'Đang mở cửa',
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (state.isLoadingStore || state.isLoadingStats) ...[
                                const _LoadingCard(),
                                const SizedBox(height: 16),
                              ] else if (state.error != null && stats == null) ...[
                                _ErrorCard(message: state.error!),
                                const SizedBox(height: 16),
                              ] else ...[
                                _StatCard(
                                        title: 'Doanh thu hôm nay',
                                        value: formatCurrency(revenue, suffix: '₫'),
                                        subtitle: _periodLabel(state.period),
                                        accent: const Color(0xFFFEF1E7),
                                        icon: Icons.payments_rounded,
                                        iconColor: const Color(0xFFFF8A00),
                                      ),
                                const SizedBox(height: 12),
                                _StatCard(
                                        title: 'Đơn hàng mới',
                                        value: orders.toString(),
                                        subtitle: 'Trong ${_periodLabel(state.period)}',
                                        accent: const Color(0xFFF0F6FF),
                                        icon: Icons.shopping_bag_outlined,
                                        iconColor: const Color(0xFF2F80ED),
                                      ),
                                const SizedBox(height: 12),
                                _StatCard(
                                  title: 'Tổng đơn hàng',
                                  value: totalOrders.toString(),
                                  subtitle: 'Cập nhật ${_periodLabel(state.period)}',
                                  accent: Colors.white,
                                  icon: Icons.receipt_long_outlined,
                                  iconColor: const Color(0xFF27AE60),
                                  isFullWidth: true,
                                ),
                                const SizedBox(height: 12),
                              ],
                              Text(
                                'Quản lý',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1F2A44)),
                              ),
                              const SizedBox(height: 12),
                              _ActionGrid(
                                ownerId: widget.ownerId,
                                storeId: state.storeId,
                                storeName: state.storeName,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              );
          },
        ),
      ),
    );
  }
}

Future<bool> _handleBack(BuildContext context) async {
  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.pop();
    return false;
  }
  navigator.pushReplacement(
    MaterialPageRoute(builder: (_) => const ProfileScreen()),
  );
  return false;
}

String _periodLabel(String value) {
  switch (value.toLowerCase()) {
    case 'weekly':
      return 'tuần này';
    case 'monthly':
      return 'tháng này';
    default:
      return 'hôm nay';
  }
}

class _DashboardHeader extends StatelessWidget {
  final String storeName;
  final String statusLabel;

  const _DashboardHeader({required this.storeName, required this.statusLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF7A30), Color(0xFFFFA852)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            storeName,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.greenAccent),
              ),
              const SizedBox(width: 8),
              Text(
                statusLabel,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final Color iconColor;
  final bool isFullWidth;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accent,
    required this.icon,
    required this.iconColor,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: isFullWidth ? 18 : 16,
            backgroundColor: Colors.white,
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1F2A44)),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: const Color(0xFF6B7280), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  final String ownerId;
  final int? storeId;
  final String? storeName;

  const _ActionGrid({required this.ownerId, required this.storeId, required this.storeName});

  @override
  Widget build(BuildContext context) {
    final items = [
      _ActionItem(
        label: 'Hồ sơ cửa hàng',
        color: const Color(0xFF8A5DFF),
        icon: Icons.storefront_rounded,
        onTap: () => _open(context, SellerProfileOverviewScreen(ownerId: ownerId)),
      ),
      _ActionItem(
        label: 'Quản lý sản phẩm',
        color: const Color(0xFF2F80ED),
        icon: Icons.inventory_2_rounded,
        onTap: () => _open(context, SellerProductsScreen(ownerId: ownerId)),
      ),
      _ActionItem(
        label: 'Quản lý đơn hàng',
        color: const Color(0xFF27AE60),
        icon: Icons.receipt_long_rounded,
        onTap: () => _open(context, SellerOrdersScreen(ownerId: ownerId)),
      ),
      _ActionItem(
        label: 'Danh mục cửa hàng',
        color: const Color(0xFF9B51E0),
        icon: Icons.category_rounded,
        onTap: storeId == null
            ? () => _showMissingStore(context)
            : () => _open(
                  context,
                  StoreCategoriesScreen(storeId: storeId!),
                ),
      ),
      _ActionItem(
        label: 'Quản lý Voucher',
        color: const Color(0xFFF2C94C),
        icon: Icons.local_offer_outlined,
        onTap: storeId == null
            ? null
            : () => _open(
                  context,
                  SellerVouchersScreen(storeId: storeId!, storeName: storeName),
                ),
      ),
      _ActionItem(
        label: 'Ví của tôi',
        color: const Color(0xFF27AE60),
        icon: Icons.account_balance_wallet_outlined,
        onTap: () => context.push('/seller/wallet'),
      ),
      _ActionItem(
        label: 'Thống kê',
        color: const Color(0xFF4AC1C0),
        icon: Icons.bar_chart_rounded,
        onTap: storeId == null
            ? () => _showMissingStore(context)
            : () => _open(
                  context,
                  SellerStatisticsScreen(storeId: storeId!, storeName: storeName),
                ),
      ),
      _ActionItem(
        label: 'Người dùng',
        color: const Color(0xFF6B7280),
        icon: Icons.arrow_back,
        onTap: () => context.go('/mainscreen'),
      ),
      _ActionItem(
        label: 'Đăng xuất',
        color: Colors.redAccent,
        icon: Icons.logout,
        isDestructive: true,
        onTap: () => _confirmLogout(context),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (_, index) => _ActionCard(item: items[index]),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _showMissingStore(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vui lòng tạo cửa hàng trước.')),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Huỷ')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Đăng xuất')),
        ],
      ),
    );
    if (confirm != true) return;
    final auth = GetIt.I<FirebaseAuth>();
    await auth.signOut();
    if (!context.mounted) return;
    context.go('/login');
  }
}

class _ActionItem {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;
   final bool isDestructive;

  const _ActionItem({required this.label, required this.color, required this.icon, this.onTap, this.isDestructive = false});
}

class _ActionCard extends StatelessWidget {
  final _ActionItem item;

  const _ActionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final disabled = item.onTap == null;
    final accent = disabled ? Colors.grey : (item.isDestructive ? Colors.redAccent : item.color);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: disabled ? null : item.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: disabled ? Colors.grey.shade200 : accent.withOpacity(0.35)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: accent.withOpacity(0.15),
              child: Icon(item.icon, color: accent, size: 26),
            ),
            const SizedBox(height: 12),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1F2A44)),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}


