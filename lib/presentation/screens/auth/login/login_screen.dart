// lib/presentation/features/auth/screens/login_screen.dart
import 'package:datn_foodecommerce_flutter_app/presentation/screens/auth/login/login_ui_state.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/auth/login/login_viewmodel.dart';
import 'package:datn_foodecommerce_flutter_app/services/notifications/push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _emailPrefilled = false;

  LoginUiState? _pendingEffect;

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  void _prefillEmail(LoginViewModel vm) {
    if (_emailPrefilled) return;
    final cached = vm.savedEmail;
    if (cached != null && cached.isNotEmpty) {
      emailC.text = cached;
      _emailPrefilled = true;
    }
  }

  void _handleStateEffects(LoginUiState state, LoginViewModel vm) {
    if (state is LoginError) {
      if (identical(_pendingEffect, state)) return;
      _pendingEffect = state;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
        vm.resetState();
        _pendingEffect = null;
      });
      return;
    }

    if (state is LoginSuccess) {
      if (identical(_pendingEffect, state)) return;
      _pendingEffect = state;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final push = GetIt.I<PushNotificationService>();
        push.syncTokenForUser(
          userId: state.user.id,
          role: state.user.roles.isNotEmpty ? state.user.roles.first : 'CUSTOMER',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập thành công')),
        );
        context.go('/mainscreen');
        vm.resetState();
        _pendingEffect = null;
      });
      return;
    }

    if (state is LoginInitial) {
      _pendingEffect = null;
    }
  }

  Future<void> _showForgotPassword(LoginViewModel vm) async {
    final controller = TextEditingController(
      text: emailC.text.trim().isNotEmpty ? emailC.text.trim() : vm.savedEmail ?? '',
    );
    bool sending = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Quên mật khẩu'),
              content: TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email khôi phục',
                  hintText: 'nhập email đã đăng ký',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: sending ? null : () => Navigator.of(context).pop(),
                  child: const Text('Đóng'),
                ),
                ElevatedButton(
                  onPressed: sending
                      ? null
                      : () async {
                          setState(() => sending = true);
                          final result = await vm.sendReset(controller.text);
                          result.when(
                            ok: (_) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã gửi email đặt lại mật khẩu'),
                                ),
                              );
                            },
                            err: (message) {
                              setState(() => sending = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(message)),
                              );
                            },
                          );
                        },
                  child: sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Gửi liên kết'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginViewModel>(
      create: (_) => GetIt.I<LoginViewModel>(),
      builder: (context, _) {
        final vm = context.watch<LoginViewModel>();
        final uiState = vm.uiState;
        final isEmailLoading =
            uiState is LoginLoading && uiState.channel == LoginChannel.email;
        final isGoogleLoading = vm.isGoogleLoading;

        _prefillEmail(vm);
        _handleStateEffects(uiState, vm);

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;
                  final content = _AuthLayout(
                    isWide: isWide,
                    form: _buildFormCard(vm, isEmailLoading, isGoogleLoading),
                  );
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: content,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormCard(LoginViewModel vm, bool isEmailLoading, bool isGoogleLoading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      margin: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _BrandBadge(EditableText.defaultStylusHandwritingEnabled),
              SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Đăng nhập QTIFood',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Đăng nhập để trải nghiệm dịch vụ của chúng tôi',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF475467),
            ),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: emailC,
                  decoration: _inputDecoration(
                    label: 'Địa chỉ Email',
                    hint: 'abcd@email.com',
                    prefix: const Icon(Icons.email_outlined, color: Color(0xFFFF6B00)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!value.contains('@')) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: passC,
                  decoration: _inputDecoration(
                    label: 'Mật khẩu',
                    hint: 'Nhập mật khẩu',
                    prefix: const Icon(Icons.lock_outline, color: Color(0xFFFF6B00)),
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: const Color(0xFF98A2B3),
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Mật khẩu tối thiểu 6 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: vm.rememberMe,
                      onChanged: (value) => vm.updateRememberMe(value ?? false),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      activeColor: const Color(0xFFFF6B00),
                    ),
                    const Text('Ghi nhớ đăng nhập'),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _showForgotPassword(vm),
                      child: const Text('Quên mật khẩu?', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFFF6B00))),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isEmailLoading
                        ? null
                        : () {
                            if (!_formKey.currentState!.validate()) return;
                            FocusScope.of(context).unfocus();
                            vm.login(
                              email: emailC.text.trim(),
                              password: passC.text,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: isEmailLoading
                          ? const SizedBox(
                              key: ValueKey('loading'),
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Đăng nhập',
                              key: ValueKey('text'),
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Chưa có tài khoản?'),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text(
                        'Đăng ký ngay',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFFF6B00)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 28),
                Center(
                  child: Text(
                    'Hoặc đăng nhập bằng',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: (isEmailLoading || isGoogleLoading)
                        ? null
                        : () {
                            FocusScope.of(context).unfocus();
                            vm.loginWithGoogle();
                          },
                    icon: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/google.png',
                        width: 20,
                        height: 20,
                      )
                    ),
                    label: isGoogleLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Đăng nhập với Google',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      foregroundColor: const Color(0xFF111827),
                      backgroundColor: Colors.grey.shade50,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthLayout extends StatelessWidget {
  const _AuthLayout({
    required this.form,
    required this.isWide,
  });
  final Widget form;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Row(
        children: [
          const SizedBox(width: 20),
          Expanded(child: form),
        ],
      );
    }
    return Column(
      children: [
        const SizedBox(height: 16),
        form,
      ],
    );
  }
}

class _BrandBadge extends StatelessWidget {
  const _BrandBadge(this.onGradient);

  final bool onGradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: onGradient ? Colors.white.withOpacity(0.18) : const Color(0xFFFFEDE0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: onGradient ? Colors.white.withOpacity(0.25) : const Color(0xFFFFD1A8),
        ),
      ),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B00), // màu cam giống logo
          borderRadius: BorderRadius.circular(10), // bo góc giống ảnh
        ),
        child: const Text(
          "QTI",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration({
  required String label,
  required Icon prefix,
  String? hint,
  Widget? suffix, 
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: prefix,
    filled: true,
    fillColor: const Color(0xFFF9FAFB),
    suffixIcon: suffix,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
  );
}
