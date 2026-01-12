import 'package:flutter/foundation.dart';

import '../../../../data/datasources/local/session_local.dart';
import '../../../../domain/usecases/auth/login/send_password_reset.dart';
import '../../../../domain/usecases/auth/login/sign_in_email.dart';
import '../../../../domain/usecases/auth/login/sign_in_google.dart';
import '../../../../utils/result.dart';
import '../../../../domain/entities/user.dart';
import 'login_ui_state.dart';
import '../../../../services/notifications/push_notification_service.dart';
import 'package:get_it/get_it.dart';

class LoginViewModel extends ChangeNotifier {
  final SignInEmail signInEmail;
  final SignInGoogle signInGoogle;
  final SendPasswordReset sendPasswordReset;
  final SessionLocal sessionLocal;

  LoginViewModel(
    this.signInEmail,
    this.signInGoogle,
    this.sendPasswordReset,
    this.sessionLocal,
  ) {
    rememberMe = sessionLocal.getRememberMe();
    savedEmail = sessionLocal.getLastEmail();
  }

  LoginUiState _uiState = const LoginInitial();
  LoginUiState get uiState => _uiState;
  bool get isLoading => _uiState is LoginLoading;
  bool get isGoogleLoading =>
      _uiState is LoginLoading && (_uiState as LoginLoading).channel == LoginChannel.google;

  bool rememberMe = true;
  String? savedEmail;

  void _emit(LoginUiState state) {
    if (identical(_uiState, state)) return;
    _uiState = state;
    notifyListeners();
  }

  void resetState() {
    if (_uiState is LoginInitial) return;
    _emit(const LoginInitial());
  }

  void updateRememberMe(bool value) {
    rememberMe = value;
    sessionLocal.setRememberMe(value);
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (kDebugMode) {
      debugPrint('[LoginViewModel] login email=$email remember=$rememberMe');
    }
    if (isLoading) return;
    _emit(const LoginLoading(channel: LoginChannel.email));

    final result = await signInEmail(email: email, password: password);
    result.when(
      ok: (user) async {
        await _persistAfterLogin(email: email, user: user);
        // Đăng ký device token ngay sau khi đăng nhập
        await GetIt.I<PushNotificationService>()
            .syncTokenForUser(userId: user.id, role: user.roles.isNotEmpty ? user.roles.first : 'CUSTOMER');
        _emit(LoginSuccess(user));
      },
      err: (message) => _emit(LoginError(message)),
    );
  }

  Future<void> loginWithGoogle() async {
    if (kDebugMode) {
      debugPrint('[LoginViewModel] loginWithGoogle start');
    }
    if (isLoading) return;
    _emit(const LoginLoading(channel: LoginChannel.google));

    final result = await signInGoogle();
    result.when(
      ok: (user) async {
        await _persistAfterLogin(email: user.email, user: user);
        await GetIt.I<PushNotificationService>()
            .syncTokenForUser(userId: user.id, role: user.roles.isNotEmpty ? user.roles.first : 'CUSTOMER');
        _emit(LoginSuccess(user));
      },
      err: (message) => _emit(LoginError(message)),
    );
  }

  Future<Result<void>> sendReset(String email) async {
    if (kDebugMode) {
      debugPrint('[LoginViewModel] sendReset email=$email');
    }
    if (email.trim().isEmpty) {
      return const Err('Vui lòng nhập email');
    }
    return await sendPasswordReset(email.trim());
  }

  Future<void> _persistAfterLogin({required String email, AppUser? user}) async {
    await sessionLocal.setRememberMe(rememberMe);
    if (email.isNotEmpty) {
      await sessionLocal.setLastEmail(email);
      savedEmail = email;
    }
    if (user != null) {
      final role = user.roles.isNotEmpty ? user.roles.first : 'CUSTOMER';
      await sessionLocal.saveLastUser(userId: user.id, role: role);
    }
  }
}
