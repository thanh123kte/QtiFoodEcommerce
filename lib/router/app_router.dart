// lib/app/router/app_router.dart
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/addresses/add_address_screen.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/profile/profile_detail_screen.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/seller/root/seller_main_screen.dart';
import 'package:datn_foodecommerce_flutter_app/router/auth_notifier.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/root/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/auth/login/login_screen.dart';
import '../presentation/screens/auth/register/register_screen.dart';
import '../presentation/screens/customer/home/home_screen.dart';
import '../presentation/screens/customer/profile/profile_ui_state.dart';
import '../presentation/screens/customer/profile/profile_view_model.dart';
import '../presentation/screens/customer/addresses/addresses_screen.dart';
import '../presentation/screens/customer/seller/seller_registration_screen.dart';
import '../presentation/screens/customer/wishlist/favorite_stores_screen.dart';
import '../presentation/screens/customer/wallet/customer_wallet_screen.dart';
import '../presentation/screens/customer/wallet/wallet_transaction_detail_screen.dart';
import '../presentation/screens/seller/wallet/seller_wallet_screen.dart';
import '../presentation/screens/customer/orders/order_list_view_model.dart';
import '../presentation/screens/customer/orders/screens/order_detail_screen.dart';
import '../presentation/screens/customer/orders/order_tracking_screen.dart';
import '../presentation/screens/seller/orders/seller_order_detail_screen.dart';
import '../presentation/screens/seller/orders/seller_orders_view_model.dart';
import '../presentation/screens/messenger/messenger_screen.dart';
import '../presentation/screens/messenger/chat_screen.dart';
import '../presentation/screens/messenger/ai_chat_screen.dart';
import '../presentation/screens/messenger/seller_messenger_screen.dart';
import '../presentation/screens/messenger/seller_chat_screen.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../domain/entities/wallet_transaction.dart';

enum AppRoute {
  login,
  register,
  home,
  mainscreen,
  orderDetail,
  profileDetail,
  addresses,
  addAddress,
  sellerRegister,
  sellerHome,
  wallet,
  sellerWallet,
  walletTransaction,
  sellerOrderDetail,
  wishlist,
  messenger,
  chat,
  aiChat,
  sellerMessenger,
  sellerChat,
}

final _auth = GetIt.I<AuthNotifier>();

final appRouter = GoRouter(
  initialLocation: '/login',
  refreshListenable: _auth,
  redirect: (context, state) {
    final loggedIn = _auth.isLoggedIn;
    final loggingIn = state.matchedLocation == '/login';
    final registering = state.matchedLocation == '/register';

    if (!loggedIn && !loggingIn && !registering) {
      return '/login';
    }
    if (loggedIn && loggingIn) {
      return '/mainscreen';
    }
    // Cho phép ở lại màn register dù auth state tạm thời là logged-in (đăng ký vừa tạo Firebase user)
    if (loggedIn && registering) {
      return null;
    }
    return null;
  },
  routes: [
    GoRoute(path: '/login', name: AppRoute.login.name, builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', name: AppRoute.register.name, builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/home', name: AppRoute.home.name, builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/mainscreen', name: AppRoute.mainscreen.name, builder: (_, __) => const MainScreen()),
    GoRoute(
      path: '/orders/:orderId',
      name: AppRoute.orderDetail.name,
      builder: (_, state) {
        final extra = state.extra;
        OrderListViewData? order;
        if (extra is OrderListViewData) {
          order = extra;
        }
        final orderId = state.pathParameters['orderId'] ?? '';
        return OrderDetailScreen(orderId: orderId, order: order);
      },
    ),
    GoRoute(
      path: '/orders/:orderId/tracking',
      name: 'orderTracking',
      builder: (_, state) {
        final orderId = state.pathParameters['orderId'] ?? '';
        final orderIdInt = int.tryParse(orderId) ?? 0;
        return OrderTrackingScreen(orderId: orderIdInt);
      },
    ),
    GoRoute(
      path: '/wallet',
      name: AppRoute.wallet.name,
      builder: (_, state) {
        return CustomerWalletScreen();
      },
    ),
    GoRoute(
      path: '/seller/wallet',
      name: AppRoute.sellerWallet.name,
      builder: (_, state) {
        return const SellerWalletScreen();
      },
    ),
    GoRoute(
      path: '/wallet/transaction',
      name: AppRoute.walletTransaction.name,
      builder: (_, state) {
        final extra = state.extra;
        if (extra is WalletTransaction) {
          return WalletTransactionDetailScreen(transaction: extra);
        }
        return const Scaffold(
          body: Center(child: Text('Không tìm thấy giao dịch.')),
        );
      },
    ),
    
    GoRoute(path: '/addresses', name: AppRoute.addresses.name, builder: (_, __) => const AddressesScreen()),
    GoRoute(path: '/wishlist', name: AppRoute.wishlist.name, builder: (_, __) => const FavoriteStoresScreen()),
    GoRoute(path: '/messenger', name: AppRoute.messenger.name, builder: (_, __) => const MessengerScreen()),
    GoRoute(path: '/messenger/ai', name: AppRoute.aiChat.name, builder: (_, __) => const AiChatScreen()),
    GoRoute(
      path: '/messenger/chat',
      name: AppRoute.chat.name,
      builder: (_, state) {
        String? sellerId;
        String? storeName;
        String? avatar;
        int? conversationId;
        final extra = state.extra;
        if (extra is Map) {
          if (extra['sellerId'] is String) sellerId = extra['sellerId'] as String;
          if (extra['storeName'] is String) storeName = extra['storeName'] as String;
          if (extra['avatar'] is String) avatar = extra['avatar'] as String;
          if (extra['conversationId'] is int) conversationId = extra['conversationId'] as int;
        }
        if (sellerId == null || sellerId.isEmpty) {
          return const Scaffold(body: Center(child: Text('Khong tim thay nguoi ban')));
        }
        return ChatScreen(
          sellerId: sellerId,
          storeName: storeName,
          counterpartAvatar: avatar,
          conversationId: conversationId,
        );
      },
    ),
    GoRoute(
      path: '/seller/messenger/:sellerId',
      name: AppRoute.sellerMessenger.name,
      builder: (_, state) {
        final sellerId = state.pathParameters['sellerId'] ?? '';
        return SellerMessengerScreen(sellerId: sellerId);
      },
    ),
    GoRoute(
      path: '/seller/chat',
      name: AppRoute.sellerChat.name,
      builder: (_, state) {
        int? conversationId;
        String? counterpartName;
        String? counterpartAvatar;
        final extra = state.extra;
        if (extra is Map) {
          if (extra['conversationId'] is int) conversationId = extra['conversationId'] as int;
          if (extra['counterpartName'] is String) counterpartName = extra['counterpartName'] as String;
          if (extra['counterpartAvatar'] is String) counterpartAvatar = extra['counterpartAvatar'] as String;
        }
        if (conversationId == null) {
          return const Scaffold(body: Center(child: Text('Khong tim thay cuoc chat')));
        }
        return SellerChatScreen(
          conversationId: conversationId,
          counterpartName: counterpartName,
          counterpartAvatar: counterpartAvatar,
        );
      },
    ),
    
    GoRoute(
      path: '/addresses/add',
      name: AppRoute.addAddress.name,
      builder: (context, state) {
        final userId = state.extra as String;
        return AddAddressScreen(userId: userId);
      },
    ),

    GoRoute(
      path: '/profile/detail',
      name: AppRoute.profileDetail.name,
      builder: (_, state) {
        ProfileViewData? data;
        ProfileViewModel? vm;
        final extra = state.extra;
        if (extra is Map) {
          if (extra['data'] is ProfileViewData) {
            data = extra['data'] as ProfileViewData;
          }
          if (extra['vm'] is ProfileViewModel) {
            vm = extra['vm'] as ProfileViewModel;
          }
        } else if (extra is ProfileViewData) {
          data = extra;
        }

        final viewModel = vm ?? GetIt.I<ProfileViewModel>();

        return ChangeNotifierProvider<ProfileViewModel>.value(
          value: viewModel,
          child: ProfileDetailScreen(data: data),
        );
      },
    ),
    GoRoute(
      path: '/seller/register',
      name: AppRoute.sellerHome.name,
      builder: (context, state) {
        String? ownerId;
        final extra = state.extra;
        if (extra is Map) {
          if (extra['ownerId'] is String) {
            ownerId = extra['ownerId'] as String;
          }
        }
        return SellerRegistrationScreen(
          ownerId: ownerId ?? '',
        );
      },
    ),
    GoRoute(
      path: '/seller/home',
      name: AppRoute.sellerRegister.name,
      builder: (context, state) {
        String? ownerId;
        final extra = state.extra;
        if (extra is Map) {
          if (extra['ownerId'] is String) {
            ownerId = extra['ownerId'] as String;
          }
        }
        return SellerMainScreen(
          ownerId: ownerId ?? '',
        );
      },
    ),
    GoRoute(
      path: '/seller/orders/:orderId',
      name: AppRoute.sellerOrderDetail.name,
      builder: (_, state) {
        final extra = state.extra;
        SellerOrderListItem? order;
        if (extra is SellerOrderListItem) {
          order = extra;
        }
        final orderId = state.pathParameters['orderId'] ?? '';
        return SellerOrderDetailScreen(orderId: orderId, order: order);
      },
    ),
  ],
);
