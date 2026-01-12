import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/cart/cart_screen.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/profile/profile_screen.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/common/cart_animation_registry.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/seller/products/widgets/product_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/home/home_screen.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/orders/screens/order_list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final _pages = const [
    HomeScreen(),
    CartScreen(),
    OrderListScreen(),
    ProfileScreen(),
  ];

  void _showExitConfirmDialog() {
    final navigator = Navigator.of(context); // lấy trước, tránh dùng context sau async
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
            onPressed: () {
              SystemNavigator.pop();
            },
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Tự kiểm soát hành vi back, để luôn chặn pop mặc định
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return; // đã pop rồi thì thôi

        if (_currentIndex != 0) {
          // Nếu không ở tab Home -> đưa về Home
          setState(() => _currentIndex = 0);
          return;
        }

        // Ở tab Home -> hỏi xác nhận thoát
        _showExitConfirmDialog();
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: BottomNavigationBar(
          key: CartAnimationRegistry.navBarKey,
          currentIndex: _currentIndex,
          selectedItemColor: sellerAccent,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Giỏ hàng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Đơn hàng',
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
