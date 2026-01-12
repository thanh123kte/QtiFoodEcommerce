import 'package:datn_foodecommerce_flutter_app/data/datasources/local/session_local.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/seller/products/widgets/product_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../dashboard/seller_dashboard_screen.dart';
import '../orders/seller_orders_screen.dart';
import '../products/seller_products_screen.dart';
import '../profile/seller_profile_overview_screen.dart';
import '../../messenger/seller_messenger_screen.dart';

class SellerMainScreen extends StatefulWidget {
  final String ownerId;
  const SellerMainScreen({super.key, required this.ownerId});

  @override
  State<SellerMainScreen> createState() => _SellerMainScreenState();
}

class _SellerMainScreenState extends State<SellerMainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;
  late final String _ownerId;

  @override
  void initState() {
    super.initState();
    _ownerId = _resolveOwnerId();
    _pages = [
      SellerDashboardScreen(ownerId: _ownerId),
      SellerProductsScreen(ownerId: _ownerId),
      SellerOrdersScreen(ownerId: _ownerId),
      SellerMessengerScreen(sellerId: _ownerId),
      SellerProfileOverviewScreen(ownerId: _ownerId),
    ];
  }

  String _resolveOwnerId() {
    if (widget.ownerId.isNotEmpty) return widget.ownerId;
    final session = GetIt.I<SessionLocal>();
    final fromSession = session.getLastUserId();
    if (fromSession != null && fromSession.isNotEmpty) return fromSession;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.uid.isNotEmpty) return user.uid;
    return '';
  }

  void _showExitConfirmDialog() {
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thoát ứng dụng'),
        content: const Text('Bạn có chắc muốn thoát không?'),
        actions: [
          TextButton(
            onPressed: () => navigator.pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: SystemNavigator.pop,
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return;
        }

        _showExitConfirmDialog();
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: sellerAccent,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (value) => setState(() => _currentIndex = value),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Sản phẩm',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Đơn hàng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Tin nhắn',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Hồ sơ',
            ),
          ],
        ),
      ),
    );
  }
}
