import '../../../../domain/entities/user.dart';

/// LCE state for the login flow.
sealed class LoginUiState {
  const LoginUiState();
}

enum LoginChannel { email, google }

class LoginInitial extends LoginUiState {
  const LoginInitial();
}

class LoginLoading extends LoginUiState {
  final LoginChannel channel;

  const LoginLoading({this.channel = LoginChannel.email});
}

class LoginSuccess extends LoginUiState {
  final AppUser user;

  const LoginSuccess(this.user);
}

class LoginError extends LoginUiState {
  final String message;

  const LoginError(this.message);
}
