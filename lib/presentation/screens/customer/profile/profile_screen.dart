import 'package:datn_foodecommerce_flutter_app/presentation/common/profile_action_card.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/common/profile_header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../seller/products/widgets/product_theme.dart';
import 'profile_ui_state.dart';
import 'profile_view_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final FirebaseAuth _firebaseAuth = GetIt.I<FirebaseAuth>();
  late final ProfileViewModel _viewModel = GetIt.I<ProfileViewModel>();

  @override
  void initState() {
    super.initState();
    final uid = _firebaseAuth.currentUser?.uid ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadProfile(userId: uid);
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileViewModel>.value(
      value: _viewModel,
      child: Consumer<ProfileViewModel>(
        builder: (_, vm, __) {
          final state = vm.uiState;

          return Scaffold(
            backgroundColor: sellerBackground,
            body: SafeArea(
              child: RefreshIndicator(
                color: sellerAccent,
                onRefresh: vm.refresh,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          ProfileHeader(state: state),
                          if (state is ProfileRefreshing)
                            const SizedBox(
                              width: double.infinity,
                              child: LinearProgressIndicator(minHeight: 2, color: sellerAccent),
                            ),
                          const SizedBox(height: 16),
                          _buildBody(state, vm),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(ProfileUiState state, ProfileViewModel vm) {
    if (state is ProfileLoading || state is ProfileInitial) {
      return const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is ProfileError) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          children: [
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: vm.retry,
              child: const Text('Thu lai'),
            ),
          ],
        ),
      );
    }

    final data = switch (state) {
      ProfileLoaded(:final data) => data,
      ProfileRefreshing(:final data) => data,
      _ => null,
    };

    if (data == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _ActionWrapper(
            child: ProfileActionCard(
              icon: Icons.favorite_border,
              iconColor: sellerAccent,
              title: 'Quán ăn yêu thích',
              onTap: () => context.push('/wishlist'),
            ),
          ),
          const SizedBox(height: 12),
          _ActionWrapper(
            child: ProfileActionCard(
              icon: Icons.location_on_outlined,
              iconColor: sellerAccent,
              title: 'Địa chỉ của tôi',
              onTap: () => context.push('/addresses'),
            ),
          ),
          const SizedBox(height: 12),
          _ActionWrapper(
            child: ProfileActionCard(
              icon: Icons.badge_outlined,
              iconColor: sellerAccent,
              title: 'Hồ sơ của tôi',
              onTap: () => _openProfileDetail(data),
            ),
          ),
          if ((data.role ?? '').toUpperCase() == 'CUSTOMER') ...[
            const SizedBox(height: 12),
            _ActionWrapper(
              child: ProfileActionCard(
                icon: Icons.store_outlined,
                iconColor: sellerAccent,
                title: 'Trở thành đối tác',
                onTap: () => _openSellerRegistration(data),
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            _ActionWrapper(
              child: ProfileActionCard(
                icon: Icons.dashboard_outlined,
                iconColor: sellerAccent,
                title: 'Quản lý cửa hàng',
                onTap: () => _openStoreManagement(data),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _ActionWrapper(
            child: ProfileActionCard(
              icon: Icons.support_agent_outlined,
              iconColor: sellerAccent,
              title: 'Hỗ trợ',
              onTap: () => context.push('/messenger'),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: sellerAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _openProfileDetail(ProfileViewData data) {
    context.push('/profile/detail', extra: {'data': data, 'vm': _viewModel});
  }

  void _openSellerRegistration(ProfileViewData data) {
    final ownerId = _firebaseAuth.currentUser?.uid ?? '';
    if (ownerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Khong xac dinh duoc tai khoan. Vui long dang nhap lai.'),
        ),
      );
      return;
    }
    context.push(
      '/seller/register',
      extra: {
        'ownerId': ownerId,
        'profile': data,
      },
    );
  }

  void _openStoreManagement(ProfileViewData data) {
    final ownerId = _firebaseAuth.currentUser?.uid ?? '';
    if (ownerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không xác định được tài khoản. Vui lòng đăng nhập lại.'),
        ),
      );
      return;
    }
    context.push(
      '/seller/home',
      extra: {
        'ownerId': ownerId,
      },
    );
  }

  Future<void> _handleLogout() async {
    try {
      await _firebaseAuth.signOut();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi đăng xuất: $e')),
      );
    }
  }
}

class _ActionWrapper extends StatelessWidget {
  final Widget child;

  const _ActionWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
        border: Border.all(color: sellerBorder),
      ),
      child: child,
    );
  }
}
