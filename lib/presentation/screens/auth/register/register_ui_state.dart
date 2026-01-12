/// LCE state for the register flow.
sealed class RegisterUiState {
  const RegisterUiState();
}

class RegisterInitial extends RegisterUiState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterUiState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterUiState {
  const RegisterSuccess();
}

class RegisterError extends RegisterUiState {
  final String message;

  const RegisterError(this.message);
}
