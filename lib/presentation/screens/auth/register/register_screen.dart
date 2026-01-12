// lib/presentation/features/auth/screens/register_screen.dart
import 'package:datn_foodecommerce_flutter_app/presentation/screens/auth/register/register_ui_state.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/auth/register/register_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final phoneC = TextEditingController();
  final passC = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  late final RegisterViewModel vm;
  RegisterUiState? _pendingEffect;

  @override
  void initState() {
    super.initState();
    vm = GetIt.I<RegisterViewModel>();
  }

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    phoneC.dispose();
    passC.dispose();
    super.dispose();
  }

  void _handleStateEffects(RegisterUiState state) {
    if (state is RegisterError) {
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

    if (state is RegisterSuccess) {
      if (identical(_pendingEffect, state)) return;
      _pendingEffect = state;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thành công')),
        );
        context.go('/login');
        vm.resetState();
        _pendingEffect = null;
      });
      return;
    }

    if (state is RegisterInitial) {
      _pendingEffect = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RegisterViewModel>.value(
      value: vm,
      child: Consumer<RegisterViewModel>(
        builder: (_, viewModel, __) {
          final uiState = viewModel.uiState;
          final isLoading = uiState is RegisterLoading;

          _handleStateEffects(uiState);

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
                      form: _buildFormCard(isLoading),
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
      ),
    );
  }

  Widget _buildFormCard(bool isLoading) {
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
            'Đăng ký tài khoản',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tạo tài khoản để bắt trải nghiệm cùng chúng tôi nhé!',
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
                  controller: nameC,
                  decoration: _inputDecoration(
                    label: 'Họ và tên',
                    hint: 'Nguyễn Văn A',
                    prefix: const Icon(Icons.person_outline, color: Color(0xFFFF6B00)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập họ tên';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: emailC,
                  decoration: _inputDecoration(
                    label: 'Địa chỉ Email',
                    hint: 'abcd@qtifood.com',
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
                  controller: phoneC,
                  decoration: _inputDecoration(
                    label: 'Số điện thoại',
                    hint: '09xx xxx xxx',
                    prefix: const Icon(Icons.phone_outlined, color: Color(0xFFFF6B00)),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: passC,
                  decoration: _inputDecoration(
                    label: 'Mật khẩu',
                    hint: 'Tối thiểu 6 ký tự',
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
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            FocusScope.of(context).unfocus();
                            vm.register(
                              email: emailC.text.trim(),
                              password: passC.text,
                              fullName: nameC.text.trim(),
                              phone: phoneC.text.trim().isEmpty ? null : phoneC.text.trim(),
                              roles: const [],
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
                      child: isLoading
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
                              'Đăng ký ngay',
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
                    const Text('Đã có tài khoản?'),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text(
                        'Đăng nhập',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
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
