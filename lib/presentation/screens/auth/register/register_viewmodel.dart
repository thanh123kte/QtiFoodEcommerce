import 'package:flutter/foundation.dart';

import '../../../../domain/usecases/auth/register/sign_up_email.dart';
import 'register_ui_state.dart';

class RegisterViewModel extends ChangeNotifier {
  final SignUpEmail signUpEmail;

  RegisterViewModel(this.signUpEmail);

  RegisterUiState _uiState = const RegisterInitial();
  RegisterUiState get uiState => _uiState;
  bool get isLoading => _uiState is RegisterLoading;

  void _emit(RegisterUiState state) {
    if (identical(_uiState, state)) return;
    _uiState = state;
    notifyListeners();
  }

  void resetState() {
    if (_uiState is RegisterInitial) return;
    _emit(const RegisterInitial());
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? avatarUrl,
    DateTime? dob,
    String? gender,
    bool? isActive,
    List<String>? roles,
  }) async {
    if (kDebugMode) {
      debugPrint('[RegisterViewModel] register email=$email fullName=$fullName');
    }
    if (isLoading) return;
    _emit(const RegisterLoading());
    final result = await signUpEmail(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      avatarUrl: avatarUrl,
      dob: dob,
      gender: gender,
      isActive: isActive ?? true,
      roles: roles,
    );
    result.when(
      ok: (_) => _emit(const RegisterSuccess()),
      err: (message) => _emit(RegisterError(message)),
    );
  }
}
